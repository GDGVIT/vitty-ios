
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
                            Spacer()
                        }
                    case .error:
                        VStack {
                            Spacer()
                            Text("It's an error!\(String(describing: authViewModel.loggedInBackendUser?.username))")
                                .font(Font.custom("Poppins-Bold", size: 24))
                            Text("Sorry if you are late for your class!")
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
                                                withAnimation {
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
                                Text("No classes today!")
                                    .font(Font.custom("Poppins-Bold", size: 24))
                                Text(StringConstants.noClassQuotesOffline.randomElement()!)
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
        .navigationBarBackButtonHidden(true)
        .onAppear {
            logger.debug("onAppear triggered")
            loadTimetable()
        }
        .onChange(of: scenePhase) { _, newPhase in
           
            if newPhase == .active {
                viewModel.resetSyncStatus()
            }
        }
    }
    
    private func loadTimetable() {
        Task {
            await viewModel.loadTimeTable(
                existingTimeTable: timetableItem.first,
                username: friend?.username ?? (authViewModel.loggedInBackendUser?.username ?? ""),
                authToken: authViewModel.loggedInBackendUser?.token ?? "",
                context: context
            )
        }
        print("this is users token is \(authViewModel.loggedInBackendUser?.token ?? "")")
    }
}
