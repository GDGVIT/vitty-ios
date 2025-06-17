import OSLog
import SwiftData
import SwiftUI


struct TimeTableView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(\.modelContext) private var context
    
    private let daysOfWeek = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

    @State private var viewModel = TimeTableViewModel()
    @State private var selectedLecture: Lecture? = nil
    @Query private var timetableItem : [TimeTable]
    let friend: Friend?

    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(
            describing: TimeTableView.self
        )
    )

    var body: some View {
        NavigationStack{
            ZStack {
                BackgroundView()
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
                                            LectureItemView(lecture: lecture) {
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
            .sheet(item: $selectedLecture) { lecture in
                LectureDetailView(lecture: lecture)
            }
            .onAppear {
                print(authViewModel.loggedInBackendUser?.token ?? "auth auth token")
                logger.debug("onAppear triggered")
                if let existing = timetableItem.first {
                    logger.debug("exixting")
                    
                    if existing.isEmpty {
                     
                        logger.debug("is empty")
                        Task {
                            await viewModel.fetchTimeTable(
                                username: friend?.username ?? (authViewModel.loggedInBackendUser?.username ?? ""),
                                authToken: authViewModel.loggedInBackendUser?.token ?? ""
                            )
                            if let fetched = viewModel.timeTable {
                                context.insert(fetched)
                            }
                        }
                    } else {
                       
                       
                        viewModel.timeTable = existing
                        viewModel.changeDay()
                        viewModel.stage = .data
                    }
                } else {
                    logger.debug("fetching")
                    Task {
                        await viewModel.fetchTimeTable(
                            username: friend?.username ?? (authViewModel.loggedInBackendUser?.username ?? ""),
                            authToken: authViewModel.loggedInBackendUser?.token ?? ""
                        )
                        if let fetched = viewModel.timeTable {
                            context.insert(fetched)
                           
                        }
                    }
                }
            }

        }
    }
}
