import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var timeTables: [TimeTable]

    @StateObject private var viewModel = SettingsViewModel()

    @State private var showDaySelection = false
    @State private var selectedDay: String? = nil
    @State private var showResetAlert = false
    @State private var showDeleteUserAlert = false
    @State private var isDeletingUser = false
    
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
                                
                                Button {
                                    if let url = URL(string: "https://vitty.dscvit.com") {
                                        UIApplication.shared.open(url)
                                    }
                                } label: {
                                    SettingsRowView(
                                        icon: "pencil.and.ellipsis.rectangle",
                                        title: "Update Timetable",
                                        subtitle: "Keep your timetable up-to-date. Don't miss a class."
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
                            AboutLinkView(image: "github-icon", title: "GitHub Repository", url: URL(string: "https://github.com/GDGVIT/vitty-ios"))
                            AboutLinkView(image: "gdsc-logo", title: "GDSC VIT", url: URL(string: "https://dscvit.com/"))
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
            }
            .navigationBarBackButtonHidden(true)
            .interactiveDismissDisabled(true)
            .onAppear {
                viewModel.timetable = timeTables.first
                viewModel.checkNotificationAuthorization()
                loadSelectedDay()
                print("Saturday before save:", timeTables.first?.saturday.map { $0.name } ?? [])
            }
            .alert("Notifications Disabled", isPresented: $viewModel.showNotificationDisabledAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("You will no longer receive class reminders.")
            }
        }
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
        
     
        
      
        let lecturesToCopy = currentTimeTable.lectures(forDay: day)
        print("Found \(lecturesToCopy.count) lectures to copy")
        
        
        let newSaturdayLectures = lecturesToCopy.map { originalLecture in
            let newLecture = Lecture(
                name: originalLecture.name,
                code: originalLecture.code,
                venue: originalLecture.venue,
                slot: originalLecture.slot,
                type: originalLecture.type,
                startTime: originalLecture.startTime,
                endTime: originalLecture.endTime
            )
            return newLecture
        }
        
       
        let newTimeTable = TimeTable(
            monday: currentTimeTable.monday.map { $0.deepCopy() },
            tuesday: currentTimeTable.tuesday.map { $0.deepCopy() },
            wednesday: currentTimeTable.wednesday.map { $0.deepCopy() },
            thursday: currentTimeTable.thursday.map { $0.deepCopy() },
            friday: currentTimeTable.friday.map { $0.deepCopy() },
            saturday: newSaturdayLectures,
            sunday: currentTimeTable.sunday.map { $0.deepCopy() },
            saturdaySourceDay: day
        )
        
       
        do {
            print("Deleting old timetable")
            modelContext.delete(currentTimeTable)
            
           
            print("Inserting new timetable with Saturday lectures")
            modelContext.insert(newTimeTable)
            
          
            try modelContext.save()
            
           
            self.selectedDay = day
            
            print("Successfully copied \(day) to Saturday using orthodox method")
            print("New Saturday has \(newTimeTable.saturday.count) lectures")
            
            
            Task { @MainActor in
                NotificationCenter.default.post(
                    name: NSNotification.Name("TimetableDidChange"),
                    object: nil
                )
            }
            
        } catch {
            print("Error during orthodox copy: \(error)")
            
            modelContext.rollback()
        }
    }
    
   
    private func resetSaturdayClasses() {
        guard let currentTimeTable = timeTables.first else {
            print("No timetable found")
            return
        }
        
        print("Starting orthodox reset of Saturday classes")
        
        
        let newTimeTable = TimeTable(
            monday: currentTimeTable.monday.map { $0.deepCopy() },
            tuesday: currentTimeTable.tuesday.map { $0.deepCopy() },
            wednesday: currentTimeTable.wednesday.map { $0.deepCopy() },
            thursday: currentTimeTable.thursday.map { $0.deepCopy() },
            friday: currentTimeTable.friday.map { $0.deepCopy() },
            saturday: [],
            sunday: currentTimeTable.sunday.map { $0.deepCopy() },
            saturdaySourceDay: nil
        )
        
     
        do {
            print("Deleting old timetable")
            modelContext.delete(currentTimeTable)
            
         
            print("Inserting new timetable with empty Saturday")
            modelContext.insert(newTimeTable)
            
           
            try modelContext.save()
            
           
            self.selectedDay = nil
            
            print("Successfully reset Saturday classes using orthodox method")
            
            
            Task { @MainActor in
                NotificationCenter.default.post(
                    name: NSNotification.Name("TimetableDidChange"),
                    object: nil
                )
            }
            
        } catch {
            print("Error during orthodox reset: \(error)")
            
            modelContext.rollback()
        }
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

        var body: some View {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(.white)
                    .frame(width: 30, height: 30)

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

// Custom Reset Alert Component
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
            // Empty tap gesture to prevent dismissal
        }
    }
}

// Custom Delete User Alert Component
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
            // Empty tap gesture to prevent dismissal
        }
    }
}
