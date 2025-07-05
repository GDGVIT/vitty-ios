import OSLog
import SwiftData
import SwiftUI

struct TimeTableView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(\.modelContext) private var context
    @Environment(\.scenePhase) private var scenePhase

    private let daysOfWeek = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

    @State private var viewModel = TimeTableViewModel()
    @State private var selectedLecture: Lecture? = nil
    @State private var isRefreshing = false
    @State private var showingRefreshAlert = false
    
    @Query private var timetableItem: [TimeTable]
    @Environment(\.dismiss) private var dismiss
    let friend: Friend?

    var isFriendsTimeTable: Bool

    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(
            describing: TimeTableView.self
        )
    )

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView()
                VStack {
                    if isFriendsTimeTable {
                        HStack {
                            Button(action: { dismiss() }) {
                                Image(systemName: "chevron.left")
                                    .foregroundColor(Color("Accent")).font(.title2)
                            }
                            Spacer()
                        }.padding(8)
                    }

                    switch viewModel.stage {
                    case .loading:
                        VStack {
                            Spacer()
                            ProgressView()
                                .scaleEffect(1.2)
                            Text("Loading timetable...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, 8)
                            Spacer()
                        }
                    case .error:
                        VStack {
                            Spacer()
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 50))
                                .foregroundColor(.orange)
                                .padding(.bottom, 16)
                            
                            Text("Something went wrong!")
                                .font(Font.custom("Poppins-Bold", size: 24))
                                .padding(.bottom, 8)
                            
                            Text("Sorry if you are late for your class!")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.bottom, 20)
                            
                            Button(action: {
                                showingRefreshAlert = true
                            }) {
                                HStack {
                                    Image(systemName: "arrow.clockwise")
                                    Text("Refresh Timetable")
                                }
                                .foregroundColor(.white)
                                .padding()
                                .background(Color("Accent"))
                                .cornerRadius(10)
                            }
                            .disabled(isRefreshing)
                            
                            Spacer()
                        }
                    case .data:
                        VStack(spacing: 0) {
                            // Day selector
                            ScrollView(.horizontal) {
                                HStack {
                                    ForEach(daysOfWeek, id: \.self) { day in
                                        Text(day)
                                            .foregroundStyle(daysOfWeek[viewModel.dayNo] == day
                                                ? Color("Background") : Color("Accent"))
                                            .frame(width: 60, height: 54)
                                            .background(
                                                daysOfWeek[viewModel.dayNo] == day
                                                ? Color("Accent") : Color.clear
                                            )
                                            .onTapGesture {
                                                withAnimation(.easeInOut(duration: 0.2)) {
                                                    viewModel.dayNo = daysOfWeek.firstIndex(
                                                        of: day
                                                    )!
                                                    viewModel.changeDay()
                                                }
                                            }
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                    }
                                }
                            }
                            .scrollIndicators(.hidden)
                            .background(Color("Secondary"))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding(.horizontal)

                            if viewModel.lectures.isEmpty {
                                Spacer()
                                VStack(spacing: 16) {
                                    Image(systemName: "calendar.badge.exclamationmark")
                                        .font(.system(size: 50))
                                        .foregroundColor(.secondary)
                                    
                                    Text("No classes today!")
                                        .font(Font.custom("Poppins-Bold", size: 24))
                                    
                                    Text(StringConstants.noClassQuotesOffline.randomElement() ?? "Enjoy your free time!")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal)
                                }
                                Spacer()
                            } else {
                                ScrollView {
                                    VStack(spacing: 12) {
                                        ForEach(viewModel.lectures.sorted()) { lecture in
                                            LectureItemView(
                                                lecture: lecture,
                                                selectedDayIndex: viewModel.dayNo,
                                                allLectures: viewModel.lectures
                                            ) {
                                                selectedLecture = lecture
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                    .padding(.top, 12)
                                    .padding(.bottom, 100)
                                }
                            }
                        }
                    }
                }
            }
        }
        .sheet(item: $selectedLecture) { lecture in
            LectureDetailView(lecture: lecture)
        }
        .alert("Refresh Timetable", isPresented: $showingRefreshAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Refresh", role: .destructive) {
                Task {
                    await refreshTimetable()
                }
            }
        } message: {
            Text("This will clear your local timetable and fetch fresh data from the server. Continue?")
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            logger.debug("onAppear triggered")
            loadTimetable()
        }
        .onChange(of: timetableItem) { oldValue, newValue in
            logger.debug("Timetable data changed, reloading view.")
            
            // NEW: Check if this is a meaningful change
            let oldCount = oldValue.count
            let newCount = newValue.count
            
            // Handle different change scenarios
            if oldCount != newCount {
                // Data was added or removed
                loadTimetable()
            } else if let oldTable = oldValue.first, let newTable = newValue.first {
                // Check if the actual content changed (especially Saturday)
                if oldTable.isDifferentFrom(newTable) {
                    logger.debug("Timetable content changed, refreshing ViewModel")
                    // Directly refresh the ViewModel with the new data
                    viewModel.refreshFromDatabase(newTable)
                }
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                viewModel.resetSyncStatus()
                
                // Check if we need to reload due to potential data corruption
                if viewModel.stage == .error || viewModel.timeTable == nil {
                    loadTimetable()
                }
            }
        }
    }

    private func loadTimetable() {
        guard !isRefreshing else { return }
        
       
        Task { @MainActor in
            await viewModel.loadTimeTable(
                existingTimeTable: timetableItem.first,
                username: friend?.username ?? (authViewModel.loggedInBackendUser?.username ?? ""),
                authToken: authViewModel.loggedInBackendUser?.token ?? "",
                context: context
            )
        }
        
        logger.debug("User token: \(authViewModel.loggedInBackendUser?.token ?? "empty")")
    }
    
    private func refreshTimetable() async {
        await MainActor.run {
            isRefreshing = true
        }
        
        await viewModel.forceRefresh(
            username: friend?.username ?? (authViewModel.loggedInBackendUser?.username ?? ""),
            authToken: authViewModel.loggedInBackendUser?.token ?? "",
            context: context
        )
        
        await MainActor.run {
            isRefreshing = false
        }
    }
}
