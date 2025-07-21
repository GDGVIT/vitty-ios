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
    @State private var scrollPosition: Int? = 0
    
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
                    contentView
                }
            }
        }
        .sheet(item: $selectedLecture) { lecture in
            LectureDetailView(lecture: lecture)
        }
        .alert("Refresh Timetable", isPresented: $showingRefreshAlert) {
            alertButtons
        } message: {
            Text("This will clear your local timetable and fetch fresh data from the server. Continue?")
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            logger.debug("onAppear triggered")
            loadTimetable()
        }
        .onChange(of: timetableItem) { oldValue, newValue in
            handleTimetableChange(oldValue: oldValue, newValue: newValue)
        }
        .onChange(of: scenePhase) { _, newPhase in
            handleScenePhaseChange(newPhase)
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        switch viewModel.stage {
        case .loading:
            loadingView
        case .error:
            errorView
        case .empty:
            emptyView
        case .data:
            dataView
        }
    }
    
    @ViewBuilder
    private var loadingView: some View {
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
    }
    
    @ViewBuilder
    private var errorView: some View {
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
            
            refreshButton
            
            Spacer()
        }
    }
    
    @ViewBuilder
    private var refreshButton: some View {
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
    }
    
    @ViewBuilder
    private var emptyView: some View {
        EmptyTimetableView(
            onReload: {
                Task {
                    await refreshTimetable()
                }
            },
            isRefreshing: isRefreshing
        )
    }
    
    @ViewBuilder
    private var dataView: some View {
        if viewModel.isEmpty {
            emptyView
        } else {
            timetableContentView
        }
    }
    
    @ViewBuilder
    private var timetableContentView: some View {
        VStack(spacing: 0) {
            daysSelectorView
            lecturesContentView
        }
    }
    
    @ViewBuilder
    private var daysSelectorView: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(Array(daysOfWeek.enumerated()), id: \.offset) { index, day in
                        dayTabView(day: day, index: index)
                    }
                }
            }
            .scrollTargetBehavior(.paging)
            .scrollIndicators(.hidden)
            .scrollPosition(id: $scrollPosition)
            .onChange(of: scrollPosition) { oldValue, newValue in
                handleScrollPositionChange(newValue: newValue)
            }
            .onAppear {
                if let currentPosition = scrollPosition {
                    proxy.scrollTo(currentPosition, anchor: .center)
                }
            }
        }
        .frame(height: 54)
        .background(Color("Secondary"))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private func dayTabView(day: String, index: Int) -> some View {
        let isSelected = viewModel.dayNo == index
        
        GeometryReader { geometry in
            Text(day)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(isSelected ? Color("Background") : Color("Accent"))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(isSelected ? Color("Accent") : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .onTapGesture {
                    handleDayTap(index: index)
                }
        }
        
        .frame(width: UIScreen.main.bounds.width / 6, height: 54)
        .id(index)
    }
    
    @ViewBuilder
    private var lecturesContentView: some View {
        if viewModel.lectures.isEmpty {
            noClassesView
        } else {
            lecturesListView
        }
    }
    
    @ViewBuilder
    private var noClassesView: some View {
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
    }
    
    @ViewBuilder
    private var lecturesListView: some View {
        ScrollView(.vertical, showsIndicators: false) {
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
        
        .gesture(
            DragGesture()
                .onEnded { value in
                    handleSwipeGesture(value)
                }
        )
    }
    
    @ViewBuilder
    private var alertButtons: some View {
        Button("Cancel", role: .cancel) { }
        Button("Refresh", role: .destructive) {
            Task {
                await refreshTimetable()
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func handleSwipeGesture(_ value: DragGesture.Value) {
        let horizontalMovement = value.translation.width
        let minimumSwipeDistance: CGFloat = 50
        
      
        if abs(horizontalMovement) > minimumSwipeDistance {
            if horizontalMovement > 0 {
              
                switchToPreviousDay()
            } else {
               
                switchToNextDay()
            }
        }
    }
    
    private func switchToNextDay() {
        let nextDay = min(viewModel.dayNo + 1, daysOfWeek.count - 1)
        if nextDay != viewModel.dayNo {
            withAnimation(.easeInOut(duration: 0.3)) {
                scrollPosition = nextDay
                viewModel.dayNo = nextDay
                viewModel.changeDay()
            }
        }
    }
    
    private func switchToPreviousDay() {
        let previousDay = max(viewModel.dayNo - 1, 0)
        if previousDay != viewModel.dayNo {
            withAnimation(.easeInOut(duration: 0.3)) {
                scrollPosition = previousDay
                viewModel.dayNo = previousDay
                viewModel.changeDay()
            }
        }
    }
    
    private func handleDayTap(index: Int) {
        withAnimation(.easeInOut(duration: 0.3)) {
            scrollPosition = index
            viewModel.dayNo = index
            viewModel.changeDay()
        }
    }
    
    private func handleScrollPositionChange(newValue: Int?) {
        guard let newValue = newValue, newValue != viewModel.dayNo else { return }
        
        withAnimation(.easeInOut(duration: 0.2)) {
            viewModel.dayNo = newValue
            viewModel.changeDay()
        }
    }
    
    private func handleTimetableChange(oldValue: [TimeTable], newValue: [TimeTable]) {
        logger.debug("Timetable data changed, reloading view.")
        
        if oldValue.count != newValue.count {
            loadTimetable()
        } else if let newTable = newValue.first {
            viewModel.refreshFromDatabase(newTable)
        }
    }
    
    private func handleScenePhaseChange(_ newPhase: ScenePhase) {
        if newPhase == .active {
            viewModel.resetSyncStatus()
            
            if viewModel.stage == .error || viewModel.stage == .empty {
                loadTimetable()
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
            scrollPosition = dayIndex
        } else {
            viewModel.dayNo = 0
            scrollPosition = 0
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
