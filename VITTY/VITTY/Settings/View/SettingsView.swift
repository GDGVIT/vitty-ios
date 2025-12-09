import SwiftUI
import SwiftData


struct SettingsView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var timeTables: [TimeTable]

    @StateObject private var viewModel = SettingsViewModel()
    @StateObject private var settingsTipManager = SettingsTipManager()

    @State private var showDaySelection = false
    @State private var selectedDay: String? = nil
    @State private var showResetAlert = false
    @State private var showDeleteUserAlert = false
    @State private var isDeletingUser = false
    @State private var isSyncing = false
    @State private var showSyncAlert = false
    @State private var syncMessage = ""
    @State private var syncSuccess = false
    
    private let selectedDayKey = "SelectedSaturdayDay"

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView()

                VStack {
                    headerView

                    List {
                        SettingsSectionView(title: "Account Details") {
                            HStack(spacing: 12) {
                                UserImage(
                                    url: authViewModel.loggedInBackendUser?.picture ?? "",
                                    height: 60,
                                    width: 60
                                )
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(authViewModel.loggedInFirebaseUser?.displayName ?? "")
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundColor(.white)

                                    Text(authViewModel.loggedInFirebaseUser?.email ?? "")
                                        .font(.system(size: 13))
                                        .foregroundColor(.gray.opacity(0.8))
                                }
                            }
                        }

                        SettingsSectionView(title: "Timetable Management") {
                            VStack(alignment: .leading, spacing: 12) {
                                Button {
                                    syncTimetable()
                                } label: {
                                    SettingsRowView(
                                        icon: "arrow.clockwise.circle.fill",
                                        title: "Sync Timetable",
                                        subtitle: isSyncing ? "Syncing..." : "Update timetable from server",
                                        isLoading: isSyncing
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                                .disabled(isSyncing)
                                
                                Button {
                                    if let url = URL(string: "https://vitty.dscvit.com") {
                                        UIApplication.shared.open(url)
                                    }
                                } label: {
                                    SettingsRowView(
                                        icon: "pencil.and.ellipsis.rectangle",
                                        title: "Update Timetable Online",
                                        subtitle: "Modify your timetable on the web portal"
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }

                        SettingsSectionView(title: "Class Settings") {
                            VStack(alignment: .leading, spacing: 12) {
                                Button {
                                    withAnimation {
                                        showDaySelection.toggle()
                                    }
                                } label: {
                                    SettingsRowView(
                                        icon: "calendar.badge.plus",
                                        title: "Saturday Class",
                                        subtitle: selectedDay == nil ? "Select a day to copy to Saturday" : "Saturday classes are a copy of \(selectedDay!)"
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())

                                if showDaySelection {
                                    VStack(alignment: .leading, spacing: 8) {
                                        ForEach(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"], id: \.self) { day in
                                            HStack(spacing: 12) {
                                                Image(systemName: selectedDay == day ? "largecircle.fill.circle" : "circle")
                                                    .foregroundColor(.blue)
                                                Text(day)
                                                    .foregroundColor(.white)
                                                Spacer()
                                            }
                                            .padding([.leading, .vertical], 4)
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                copyLecturesToSaturday(from: day)
                                                withAnimation {
                                                    showDaySelection = false
                                                }
                                            }
                                        }
                                    }
                                    .padding(.top, 8)
                                    .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .top)))
                                }
                                
                                Button {
                                    showResetAlert = true
                                } label: {
                                    SettingsRowView(
                                        icon: "trash.circle.fill",
                                        title: "Reset Saturday Classes",
                                        subtitle: "Remove all classes from Saturday"
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }

                        SettingsSectionView(title: "Notifications") {
                            Toggle(isOn: $viewModel.notificationsEnabled) {
                                HStack {
                                    Image(systemName: "bell.badge.fill")
                                        .foregroundColor(.white)
                                    Text("Enable Notifications")
                                        .foregroundColor(.white)
                                        .font(.system(size: 15, weight: .semibold))
                                }
                            }
                            .toggleStyle(SwitchToggleStyle(tint: .green))
                        }

                        SettingsSectionView(title: "Account Management") {
                            Button {
                                showDeleteUserAlert = true
                            } label: {
                                SettingsRowView(
                                    icon: "person.badge.minus",
                                    title: "Delete Account",
                                    subtitle: "Permanently delete your account and all data"
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            .disabled(isDeletingUser)
                        }

                        SettingsSectionView(title: "About") {
                            VStack(alignment: .leading, spacing: 12) {
                                AboutLinkView(image: "github-icon", title: "GitHub Repository", url: URL(string: "https://github.com/GDGVIT/vitty-ios"))
                                AboutLinkView(image: "gdsc-logo", title: "GDSC VIT", url: URL(string: "https://dscvit.com/"))
                                
                                // Support Email
                                HStack(spacing: 12) {
                                    Image(systemName: "envelope.fill")
                                        .foregroundColor(.white)
                                        .frame(width: 30, height: 30)

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Support")
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(.white)
                                        
                                        Text("dscvit.vitty@gmail.com")
                                            .font(.system(size: 12))
                                            .foregroundColor(.gray.opacity(0.8))
                                    }
                                    
                                    Spacer()
                                }
                                .padding(.vertical, 6)
                               .onTapGesture {
                                    sendSupportEmail()
                                }
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
                
               
                if showResetAlert {
                    ResetSaturdayAlert(
                        onCancel: { showResetAlert = false },
                        onReset: {
                            resetSaturdayClasses()
                            showResetAlert = false
                        }
                    )
                    .zIndex(1)
                }
                
                if showDeleteUserAlert {
                    DeleteUserAlert(
                        isDeleting: isDeletingUser,
                        onCancel: {
                            showDeleteUserAlert = false
                        },
                        onDelete: {
                            deleteUser()
                        }
                    )
                    .zIndex(1)
                }
                
                if showSyncAlert {
                    SyncAlert(
                        message: syncMessage,
                        isSuccess: syncSuccess,
                        onDismiss: {
                            showSyncAlert = false
                        }
                    )
                    .zIndex(1)
                }
                
              
                SettingsTipOverlay(tipManager: settingsTipManager)
                    .zIndex(2)
            }
            .navigationBarBackButtonHidden(true)
            .interactiveDismissDisabled(true)
            .onAppear {
                viewModel.timetable = timeTables.first
                viewModel.checkNotificationAuthorization()
                loadSelectedDay()
                setupSettingsOnboarding()
            }
            .alert("Notifications Disabled", isPresented: $viewModel.showNotificationDisabledAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("You will no longer receive class reminders.")
            }
        }
    }
    
    // MARK: - Settings Tooltip Setup
    private func setupSettingsOnboarding() {
       
        if !settingsTipManager.hasCompletedSettingsOnboarding {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                settingsTipManager.startOnboarding()
            }
        }
    }
    
    // MARK: - Sync Timetable Functions
    private func syncTimetable() {
        guard let username = authViewModel.loggedInBackendUser?.username,
              let authToken = authViewModel.loggedInBackendUser?.token else {
            showSyncMessage("Unable to sync: No authentication credentials", success: false)
            return
        }
        
        isSyncing = true
        
        Task {
            do {
                // Fetch updated timetable from API
                let remoteTimeTable = try await TimeTableAPIService.shared.getTimeTable(
                    with: username,
                    authToken: authToken
                )
                
                await MainActor.run {
                    updateLocalTimetable(with: remoteTimeTable)
                }
                
            } catch {
                await MainActor.run {
                    isSyncing = false
                    showSyncMessage("Sync failed: \(error.localizedDescription)", success: false)
                }
            }
        }
    }

    private func syncTimetableAlternative() {
        guard let username = authViewModel.loggedInBackendUser?.username,
              let authToken = authViewModel.loggedInBackendUser?.token else {
            showSyncMessage("Unable to sync: No authentication credentials", success: false)
            return
        }
        
        isSyncing = true
        
        Task {
            do {
               
                let remoteTimeTable = try await TimeTableAPIService.shared.getTimeTable(
                    with: username,
                    authToken: authToken
                )
                
                await MainActor.run {
                    updateLocalTimetable(with: remoteTimeTable)
                }
                
            } catch {
                await MainActor.run {
                    isSyncing = false
                    showSyncMessage("Sync failed: \(error.localizedDescription)", success: false)
                }
            }
        }
    }
    
    private func updateLocalTimetable(with remoteTimeTable: TimeTable) {
        guard let currentTimeTable = timeTables.first else {
            insertNewTimetable(remoteTimeTable)
            return
        }
        
        let finalTimeTable = preserveSaturdayCustomization(
            remote: remoteTimeTable,
            local: currentTimeTable
        )
        
        do {
            modelContext.delete(currentTimeTable)
            modelContext.insert(finalTimeTable)
            try modelContext.save()
            
            isSyncing = false
            showSyncMessage("Timetable synced successfully!", success: true)
            
            // Update viewModel timetable to trigger notification rescheduling
            viewModel.timetable = finalTimeTable
            
            // Post notification to update TimeTableView
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                NotificationCenter.default.post(
                    name: NSNotification.Name("TimetableDidChange"),
                    object: nil
                )
                
                // Also post a refresh notification
                NotificationCenter.default.post(
                    name: NSNotification.Name("RefreshTimetableFromSettings"),
                    object: nil
                )
            }
            
        } catch {
            isSyncing = false
            showSyncMessage("Failed to save synced timetable: \(error.localizedDescription)", success: false)
            modelContext.rollback()
        }
    }
    
    private func insertNewTimetable(_ timeTable: TimeTable) {
        do {
            modelContext.insert(timeTable)
            try modelContext.save()
            
            isSyncing = false
            showSyncMessage("Timetable synced successfully!", success: true)
            
            // Update viewModel timetable to trigger notification rescheduling
            viewModel.timetable = timeTable
            
            NotificationCenter.default.post(
                name: NSNotification.Name("TimetableDidChange"),
                object: nil
            )
            
        } catch {
            isSyncing = false
            showSyncMessage("Failed to save new timetable: \(error.localizedDescription)", success: false)
        }
    }
    
    private func preserveSaturdayCustomization(remote: TimeTable, local: TimeTable) -> TimeTable {
      
        let newTimeTable = TimeTable(
            monday: remote.monday.map { $0.deepCopy() },
            tuesday: remote.tuesday.map { $0.deepCopy() },
            wednesday: remote.wednesday.map { $0.deepCopy() },
            thursday: remote.thursday.map { $0.deepCopy() },
            friday: remote.friday.map { $0.deepCopy() },
            saturday: remote.saturday.map { $0.deepCopy() },
            sunday: remote.sunday.map { $0.deepCopy() }
        )
        
       
        if let saturdaySourceDay = local.saturdaySourceDay {
            print("Preserving Saturday customization from: \(saturdaySourceDay)")
            
            let lecturesToCopy = newTimeTable.lectures(forDay: saturdaySourceDay)
            newTimeTable.saturday = lecturesToCopy.map { $0.deepCopy() }
            newTimeTable.saturdaySourceDay = saturdaySourceDay
        }
        
        return newTimeTable
    }
    
    private func showSyncMessage(_ message: String, success: Bool) {
        syncMessage = message
        syncSuccess = success
        showSyncAlert = true
    }
    
    
    private func loadSelectedDay() {
        selectedDay = timeTables.first?.saturdaySourceDay
    }
    
    private func deleteUser() {
        guard let username = authViewModel.loggedInBackendUser?.username else {
            print("No username found")
            return
        }
        
        isDeletingUser = true
        
        Task {
            do {
                try await deleteUserFromServer(username: username)
                
                await MainActor.run {
                    Task {
                        await cleanupLocalData()
                        authViewModel.signOut()
                        showDeleteUserAlert = false
                        isDeletingUser = false
                    }
                }
            } catch {
                await MainActor.run {
                    isDeletingUser = false
                    print("Failed to delete user: \(error)")
                }
            }
        }
    }
    
    private func deleteUserFromServer(username: String) async throws {
        guard let url = URL(string: "\(APIConstants.base_url)/users/\(username)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        let token = authViewModel.loggedInBackendUser?.token ?? ""
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }
    }
    
    private func cleanupLocalData() async {
        do {
            await Task.detached { [modelContext] in
                do {
                    try modelContext.delete(model: TimeTable.self)
                    try modelContext.delete(model: Remainder.self)
                    try modelContext.delete(model: CreateNoteModel.self)
                    try modelContext.delete(model: UploadedFile.self)
                    try modelContext.save()
                    print("Successfully cleaned up local data")
                } catch {
                    print("Failed to clean up local data: \(error)")
                }
            }.value
        } catch {
            print("Failed to clear local data: \(error)")
        }
    }

    private func copyLecturesToSaturday(from day: String) {
        guard let currentTimeTable = timeTables.first else {
            print("No timetable found")
            return
        }
        
        print("Starting SAFE copy from \(day) to Saturday - DELETE & RECREATE approach")
        
        let lecturesToCopy = currentTimeTable.lectures(forDay: day)
        print("Found \(lecturesToCopy.count) lectures to copy from \(day)")
        
        // Create backup data
        let backupData = (
            monday: currentTimeTable.monday.map { $0.deepCopy() },
            tuesday: currentTimeTable.tuesday.map { $0.deepCopy() },
            wednesday: currentTimeTable.wednesday.map { $0.deepCopy() },
            thursday: currentTimeTable.thursday.map { $0.deepCopy() },
            friday: currentTimeTable.friday.map { $0.deepCopy() },
            saturday: currentTimeTable.saturday.map { $0.deepCopy() },
            sunday: currentTimeTable.sunday.map { $0.deepCopy() },
            saturdaySourceDay: currentTimeTable.saturdaySourceDay
        )
        
        do {
            // Delete existing timetable
            modelContext.delete(currentTimeTable)
            print("Deleted existing timetable")
            
            // Create new Saturday lectures
            let newSaturdayLectures = lecturesToCopy.map { originalLecture in
                Lecture(
                    name: originalLecture.name,
                    code: originalLecture.code,
                    venue: originalLecture.venue,
                    slot: originalLecture.slot,
                    type: originalLecture.type,
                    startTime: originalLecture.startTime,
                    endTime: originalLecture.endTime
                )
            }
            
            print("Created \(newSaturdayLectures.count) new lectures for Saturday")
            
            // Create new timetable
            let newTimeTable = TimeTable(
                monday: backupData.monday,
                tuesday: backupData.tuesday,
                wednesday: backupData.wednesday,
                thursday: backupData.thursday,
                friday: backupData.friday,
                saturday: newSaturdayLectures,
                sunday: backupData.sunday,
                saturdaySourceDay: day
            )
            
            // Insert new timetable
            modelContext.insert(newTimeTable)
            print("Inserted new timetable with Saturday lectures")
            
            // Save changes
            try modelContext.save()
            
            // Update local state IMMEDIATELY after successful save
            self.selectedDay = day
            
            print("Successfully recreated timetable with \(day) copied to Saturday")
            print("New Saturday has \(newTimeTable.saturday.count) lectures")
            
            // Force immediate UI update
            DispatchQueue.main.async {
                // Send notification immediately
                NotificationCenter.default.post(
                    name: NSNotification.Name("TimetableDidChange"),
                    object: nil
                )
                
                // Also send a refresh notification for the timetable view
                NotificationCenter.default.post(
                    name: NSNotification.Name("RefreshTimetableFromSettings"),
                    object: nil
                )
            }
            
        } catch {
            print("Error during timetable recreation: \(error)")
            modelContext.rollback()
            
            // Restore backup data on error
            print("Attempting to restore backup data...")
            do {
                let restoredTimeTable = TimeTable(
                    monday: backupData.monday,
                    tuesday: backupData.tuesday,
                    wednesday: backupData.wednesday,
                    thursday: backupData.thursday,
                    friday: backupData.friday,
                    saturday: backupData.saturday,
                    sunday: backupData.sunday,
                    saturdaySourceDay: backupData.saturdaySourceDay
                )
                
                modelContext.insert(restoredTimeTable)
                try modelContext.save()
                print("Successfully restored backup data")
            } catch {
                print("Failed to restore backup data: \(error)")
            }
        }
    }

    // MARK: - Fixed resetSaturdayClasses method in SettingsView
    private func resetSaturdayClasses() {
        guard let currentTimeTable = timeTables.first else {
            print("No timetable found")
            return
        }
        
        print("Starting SAFE reset of Saturday classes - DELETE & RECREATE approach")
        
        // Create backup data
        let backupData = (
            monday: currentTimeTable.monday.map { $0.deepCopy() },
            tuesday: currentTimeTable.tuesday.map { $0.deepCopy() },
            wednesday: currentTimeTable.wednesday.map { $0.deepCopy() },
            thursday: currentTimeTable.thursday.map { $0.deepCopy() },
            friday: currentTimeTable.friday.map { $0.deepCopy() },
            saturday: currentTimeTable.saturday.map { $0.deepCopy() },
            sunday: currentTimeTable.sunday.map { $0.deepCopy() },
            saturdaySourceDay: currentTimeTable.saturdaySourceDay
        )
        
        do {
            // Delete existing timetable
            modelContext.delete(currentTimeTable)
            print("Deleted existing timetable")
            
            // Create new timetable with empty Saturday
            let newTimeTable = TimeTable(
                monday: backupData.monday,
                tuesday: backupData.tuesday,
                wednesday: backupData.wednesday,
                thursday: backupData.thursday,
                friday: backupData.friday,
                saturday: [], // Empty Saturday
                sunday: backupData.sunday,
                saturdaySourceDay: nil // Clear source day
            )
            
            // Insert new timetable
            modelContext.insert(newTimeTable)
            print("Inserted new timetable with empty Saturday")
            
            // Save changes
            try modelContext.save()
            
            // Update local state IMMEDIATELY after successful save
            self.selectedDay = nil
            
            print("Successfully recreated timetable with empty Saturday")
            
            // Force immediate UI update
            DispatchQueue.main.async {
                // Send notification immediately
                NotificationCenter.default.post(
                    name: NSNotification.Name("TimetableDidChange"),
                    object: nil
                )
                
                // Also send a refresh notification for the timetable view
                NotificationCenter.default.post(
                    name: NSNotification.Name("RefreshTimetableFromSettings"),
                    object: nil
                )
            }
            
        } catch {
            print("Error during timetable reset: \(error)")
            modelContext.rollback()
            
            // Restore backup data on error
            print("Attempting to restore backup data...")
            do {
                let restoredTimeTable = TimeTable(
                    monday: backupData.monday,
                    tuesday: backupData.tuesday,
                    wednesday: backupData.wednesday,
                    thursday: backupData.thursday,
                    friday: backupData.friday,
                    saturday: backupData.saturday,
                    sunday: backupData.sunday,
                    saturdaySourceDay: backupData.saturdaySourceDay
                )
                
                modelContext.insert(restoredTimeTable)
                try modelContext.save()
                print("Successfully restored backup data")
            } catch {
                print("Failed to restore backup data: \(error)")
            }
        }
    }

    private func sendSupportEmail() {
        let emailSubject = "VITTY iOS App - Bug Report"
        let emailBody = createBugReportTemplate()
        
        let encodedSubject = emailSubject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedBody = emailBody.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        let mailtoURL = "mailto:dscvit.vitty@gmail.com?subject=\(encodedSubject)&body=\(encodedBody)"
        
        if let url = URL(string: mailtoURL) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
                print("SUPPORT EMAIL: Opening mail app with bug report template")
            } else {
                print("SUPPORT EMAIL: Mail app not available")
            }
        } else {
            print(" SUPPORT EMAIL: Failed to create mailto URL")
        }
    }

    private func createBugReportTemplate() -> String {
        let userInfo = getUserInfo()
        let deviceInfo = getDeviceInfo()
        let appInfo = getAppInfo()
        
        return """
    Hello VITTY Support Team,

    I'm reporting a bug in the VITTY iOS app. Please find the details below:

    **User Information:**
    - Username: \(userInfo.username)
    - Full Name: \(userInfo.fullName)
    - Email: \(userInfo.email)
    - Campus: \(userInfo.campus)

    **Device Information:**
    - Device Model: \(deviceInfo.deviceModel)
    - iOS Version: \(deviceInfo.iosVersion)
    - App Version: \(appInfo.version)
    - Build Number: \(appInfo.buildNumber)
    - Device Language: \(deviceInfo.language)
    - Time Zone: \(deviceInfo.timeZone)

    **Bug Report:**

    **Describe the bug**
    A clear and concise description of what the bug is.

    **To Reproduce**
    Steps to reproduce the behavior:
    1. Go to '...'
    2. Click on '....'
    3. Scroll down to '....'
    4. See error

    **Expected behavior**
    A clear and concise description of what you expected to happen.

    **Screenshots**
    If applicable, add screenshots to help explain your problem.

    **Additional context**
    Add any other context about the problem here.

    ---
    This email was generated automatically from the VITTY iOS app.
    Report submitted on: \(getCurrentDateTime())
    """
    }

    private func getUserInfo() -> (username: String, fullName: String, email: String, campus: String) {
        let username = authViewModel.loggedInBackendUser?.username ?? "N/A"
        let fullName = authViewModel.loggedInBackendUser?.name ?? "N/A"
        let email = authViewModel.loggedInFirebaseUser?.email ?? "N/A"
        let campus = authViewModel.loggedInBackendUser?.campus?.capitalized ?? "N/A"
        
        return (username, fullName, email, campus)
    }

    private func getDeviceInfo() -> (deviceModel: String, iosVersion: String, language: String, timeZone: String) {
        let device = UIDevice.current
        let deviceModel = getDeviceModel()
        let iosVersion = "\(device.systemName) \(device.systemVersion)"
        let language = Locale.current.language.languageCode?.identifier ?? "Unknown"
        let timeZone = TimeZone.current.identifier
        
        return (deviceModel, iosVersion, language, timeZone)
    }

    private func getDeviceModel() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        return getReadableDeviceName(from: identifier)
    }

    private func getReadableDeviceName(from identifier: String) -> String {
        switch identifier {
        case "iPhone8,1": return "iPhone 6s"
        case "iPhone8,2": return "iPhone 6s Plus"
        case "iPhone9,1", "iPhone9,3": return "iPhone 7"
        case "iPhone9,2", "iPhone9,4": return "iPhone 7 Plus"
        case "iPhone10,1", "iPhone10,4": return "iPhone 8"
        case "iPhone10,2", "iPhone10,5": return "iPhone 8 Plus"
        case "iPhone10,3", "iPhone10,6": return "iPhone X"
        case "iPhone11,2": return "iPhone XS"
        case "iPhone11,4", "iPhone11,6": return "iPhone XS Max"
        case "iPhone11,8": return "iPhone XR"
        case "iPhone12,1": return "iPhone 11"
        case "iPhone12,3": return "iPhone 11 Pro"
        case "iPhone12,5": return "iPhone 11 Pro Max"
        case "iPhone13,1": return "iPhone 12 mini"
        case "iPhone13,2": return "iPhone 12"
        case "iPhone13,3": return "iPhone 12 Pro"
        case "iPhone13,4": return "iPhone 12 Pro Max"
        case "iPhone14,4": return "iPhone 13 mini"
        case "iPhone14,5": return "iPhone 13"
        case "iPhone14,2": return "iPhone 13 Pro"
        case "iPhone14,3": return "iPhone 13 Pro Max"
        case "iPhone14,7": return "iPhone 14"
        case "iPhone14,8": return "iPhone 14 Plus"
        case "iPhone15,2": return "iPhone 14 Pro"
        case "iPhone15,3": return "iPhone 14 Pro Max"
        case "iPhone15,4": return "iPhone 15"
        case "iPhone15,5": return "iPhone 15 Plus"
        case "iPhone16,1": return "iPhone 15 Pro"
        case "iPhone16,2": return "iPhone 15 Pro Max"
        case "i386", "x86_64", "arm64": return "Simulator"
        default: return identifier
        }
    }

    private func getAppInfo() -> (version: String, buildNumber: String) {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
        
        return (version, buildNumber)
    }

    private func getCurrentDateTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone.current
        return formatter.string(from: Date())
    }



    private var headerView: some View {
        HStack {
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.white)
                    .font(.title2)
            }
            Spacer()
            Text("Settings")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top)
    }

    // MARK: - Supporting Views
    struct SettingsSectionView<Content: View>: View {
        let title: String
        @ViewBuilder let content: () -> Content

        var body: some View {
            Section(header: Text(title).foregroundColor(.white)) {
                content()
                    .padding(.vertical, 6)
            }
            .listRowBackground(Color("Secondary"))
        }
    }

    struct SettingsRowView: View {
        let icon: String
        let title: String
        let subtitle: String
        let isLoading: Bool
        
        init(icon: String, title: String, subtitle: String, isLoading: Bool = false) {
            self.icon = icon
            self.title = title
            self.subtitle = subtitle
            self.isLoading = isLoading
        }

        var body: some View {
            HStack(alignment: .top, spacing: 12) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                        .frame(width: 30, height: 30)
                } else {
                    Image(systemName: icon)
                        .foregroundColor(.white)
                        .frame(width: 30, height: 30)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)

                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(.gray.opacity(0.8))
                }
                
                Spacer()
            }
            .padding(.vertical, 6)
            .contentShape(Rectangle())
        }
    }

    struct AboutLinkView: View {
        let image: String
        let title: String
        let url: URL?

        var body: some View {
            HStack(spacing: 12) {
                Image(image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)

                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
            }
            .padding(.vertical, 6)
            .onTapGesture {
                if let url = url {
                    UIApplication.shared.open(url)
                }
            }
        }
    }
}

// MARK: - Alert Components
struct ResetSaturdayAlert: View {
    let onCancel: () -> Void
    let onReset: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 12) {
                Text("Reset Saturday Classes?")
                    .font(.custom("Poppins-SemiBold", size: 18))
                    .foregroundColor(.white)
                
                Text("Are you sure you want to remove all classes from Saturday? This action cannot be undone.")
                    .font(.custom("Poppins-Regular", size: 14))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                HStack(spacing: 10) {
                    Button(action: onCancel) {
                        Text("Cancel")
                            .font(.custom("Poppins-Regular", size: 14))
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.3))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    Button(action: onReset) {
                        Text("Reset")
                            .font(.custom("Poppins-Regular", size: 14))
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
            }
            .frame(height: 150)
            .padding(20)
            .background(Color("Background"))
            .cornerRadius(16)
            .padding(.horizontal, 30)
            .transition(.scale.combined(with: .opacity))
            Spacer()
        }
        .background(Color.black.opacity(0.5).edgesIgnoringSafeArea(.all))
        .onTapGesture {
          
        }
    }
}

struct DeleteUserAlert: View {
    let isDeleting: Bool
    let onCancel: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.red)
                
                Text("Delete Account?")
                    .font(.custom("Poppins-SemiBold", size: 18))
                    .foregroundColor(.white)
                
                Text("This action will permanently delete your account and all associated data. This cannot be undone.")
                    .font(.custom("Poppins-Regular", size: 14))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                if isDeleting {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .frame(height: 40)
                } else {
                    HStack(spacing: 10) {
                        Button(action: onCancel) {
                            Text("Cancel")
                                .font(.custom("Poppins-Regular", size: 14))
                                .padding(.vertical, 10)
                                .frame(maxWidth: .infinity)
                                .background(Color.gray.opacity(0.3))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        
                        Button(action: onDelete) {
                            Text("Delete Account")
                                .font(.custom("Poppins-Regular", size: 14))
                                .padding(.vertical, 10)
                                .frame(maxWidth: .infinity)
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                }
            }
            .frame(minHeight: 200)
            .padding(20)
            .background(Color("Background"))
            .cornerRadius(16)
            .padding(.horizontal, 30)
            .transition(.scale.combined(with: .opacity))
            Spacer()
        }
        .background(Color.black.opacity(0.5).edgesIgnoringSafeArea(.all))
        .onTapGesture {
           
        }
    }
}


struct SyncAlert: View {
    let message: String
    let isSuccess: Bool
    let onDismiss: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 16) {
                Image(systemName: isSuccess ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(isSuccess ? .green : .red)
                
                Text(isSuccess ? "Sync Successful" : "Sync Failed")
                    .font(.custom("Poppins-SemiBold", size: 18))
                    .foregroundColor(.white)
                
                Text(message)
                    .font(.custom("Poppins-Regular", size: 14))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Button(action: onDismiss) {
                    Text("OK")
                        .font(.custom("Poppins-Regular", size: 14))
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(isSuccess ? Color.green : Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .frame(minHeight: 180)
            .padding(20)
            .background(Color("Background"))
            .cornerRadius(16)
            .padding(.horizontal, 30)
            .transition(.scale.combined(with: .opacity))
            Spacer()
        }
        .background(Color.black.opacity(0.5).edgesIgnoringSafeArea(.all))
        .onTapGesture {
           
        }
    }
}
