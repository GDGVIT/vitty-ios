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
                    case .empty:
                        // Show empty timetable view with reload functionality
                        EmptyTimetableView(
                            onReload: {
                                Task {
                                    await refreshTimetable()
                                }
                            },
                            isRefreshing: isRefreshing
                        )
                    case .data:
                        if viewModel.isEmpty{
                            EmptyTimetableView(
                                onReload: {
                                    Task {
                                        await refreshTimetable()
                                    }
                                },
                                isRefreshing: isRefreshing
                            )
                        } else{
                            VStack(spacing: 0) {
                               
                                ScrollViewReader { proxy in
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
                                                            
                                                            proxy.scrollTo(day, anchor: .center)
                                                        }
                                                    }
                                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                                    .id(day)
                                            }
                                        }
                                        .padding(.horizontal, 8)
                                    }
                                    .scrollIndicators(.hidden)
                                    .onAppear {
                                        let currentDay = daysOfWeek[viewModel.dayNo]
                                        proxy.scrollTo(currentDay, anchor: .center)
                                    }
                                    .onChange(of: viewModel.dayNo) { oldValue, newValue in
                                        let selectedDay = daysOfWeek[newValue]
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            proxy.scrollTo(selectedDay, anchor: .center)
                                        }
                                    }
                                }
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
            
            // Simplified change detection
            if oldValue.count != newValue.count {
                // Data was added or removed
                loadTimetable()
            } else if let newTable = newValue.first {
                // Data content changed
                viewModel.refreshFromDatabase(newTable)
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                viewModel.resetSyncStatus()
                
                // Reload if in error state or empty state
                if viewModel.stage == .error || viewModel.stage == .empty {
                    loadTimetable()
                }
            }
        }
    }

    private func loadTimetable() {
        logger.debug("Loading timetable with local-first approach")
        
        let calendar = Calendar.current
        let today = calendar.component(.weekday, from: Date())
        
        let dayIndex = (today == 1) ? 6 : today - 2
        
        if dayIndex >= 0 && dayIndex < daysOfWeek.count {
            viewModel.dayNo = dayIndex
        } else {
            viewModel.dayNo = 0
        }
        
        Task {
            await viewModel.loadTimeTable(
                existingTimeTable: timetableItem.first,
                username: authViewModel.loggedInBackendUser?.username ?? "",
                authToken: authViewModel.loggedInBackendUser?.token ?? "",
                context: context
            )
        }
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
