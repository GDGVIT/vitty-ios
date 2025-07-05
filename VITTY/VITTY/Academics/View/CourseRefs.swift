//
//  Academics.swift
//  VITTY
//
//  Created by Rujin Devkota on 2/27/25.


import SwiftUI
import SwiftData

struct OCourseRefs: View {
    var courseName: String
    var courseInstitution: String
    var slot: String
    var courseCode: String

    @State private var showBottomSheet = false
    @State private var showReminderSheet = false
    @State private var showNotes = false
    @State private var navigateToNotesEditor = false
    @State var showCourseNotes: Bool = false
    @State private var selectedNote: CreateNoteModel?
    @State private var preloadedAttributedString: NSAttributedString?
    @State private var searchText = ""
    @State private var showDeleteAlert = false
    @State private var noteToDelete: CreateNoteModel?
    @State private var fileToDelete: UploadedFile?
    @State private var isLoadingNote = false
    @State private var loadingNoteId: Date?
    @State private var showimgDeleteAlert = false
    // File upload related states
    @State private var showFileUpload = false
    @State private var showFileGallery = false
    @State private var selectedContentType: ContentType = .notes
    @State private var showExpandedFAB = false

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
  
    private let maxVisible = 4

    @Query private var filteredRemainders: [Remainder]
    @Query private var courseNotes: [CreateNoteModel]
    @Query private var courseFiles: [UploadedFile]

    enum ContentType: String, CaseIterable {
        case notes = "Notes"
        case files = "Files"
        
        var icon: String {
            switch self {
            case .notes: return "doc.text"
            case .files: return "folder"
            }
        }
    }

    init(courseName: String, courseInstitution: String, slot: String, courseCode: String) {
        self.courseName = courseName
        self.courseInstitution = courseInstitution
        self.slot = slot
        self.courseCode = courseCode

        let reminderPredicate = #Predicate<Remainder> {
            $0.subject == courseName && $0.isCompleted == false
        }
        _filteredRemainders = Query(
            FetchDescriptor(predicate: reminderPredicate, sortBy: [SortDescriptor(\.date, order: .forward)])
        )

        let notesPredicate = #Predicate<CreateNoteModel> {
            $0.courseId == courseCode
        }
        _courseNotes = Query(
            FetchDescriptor(predicate: notesPredicate, sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        )
        
        
        let filesPredicate = #Predicate<UploadedFile> {
            $0.courseCode == courseCode
        }
        _courseFiles = Query(
            FetchDescriptor(predicate: filesPredicate, sortBy: [SortDescriptor(\.uploadDate, order: .reverse)])
        )
    }

    private var filteredNotes: [CreateNoteModel] {
        if searchText.isEmpty {
            return courseNotes
        } else {
            return courseNotes.filter { note in
                note.noteName.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    private var filteredFiles: [UploadedFile] {
        if searchText.isEmpty {
            return courseFiles
        } else {
            return courseFiles.filter { file in
                file.fileName.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color("Background").edgesIgnoringSafeArea(.all)

                VStack(alignment: .leading) {
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.white)
                                .font(.title2)
                        }

                        Spacer()

                        Text("Course Page")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)

                        Spacer()
                        
                      
                        if selectedContentType == .files && !courseFiles.isEmpty {
                            Button("View All") {
                                showFileGallery = true
                            }
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color("Secondary"))
                        }
                    }
                    .padding()

                    HStack {
                        Spacer()
                        TextField(selectedContentType == .notes ? "Search notes..." : "Search files...", text: $searchText)
                            .padding(10)
                            .frame(width: UIScreen.main.bounds.width * 0.85)
                            .background(Color.white.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding(.horizontal)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    
                   
                   

                    Spacer().frame(height: 15)

                    Text("\(courseName) - \(courseInstitution)")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    
                    HStack(spacing: 12) {
                        ForEach(ContentType.allCases, id: \.self) { contentType in
                            ContentTypeTab(
                                contentType: contentType,
                                isSelected: selectedContentType == contentType,
                                count: contentType == .notes ? filteredNotes.count : filteredFiles.count
                            ) {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedContentType = contentType
                                    searchText = ""
                                }
                            }
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            let visible = Array(filteredRemainders.prefix(maxVisible))
                            ForEach(visible, id: \.self) { reminder in
                                TagView(reminder: reminder)
                            }

                            let remainingCount = filteredRemainders.count - maxVisible
                            if remainingCount > 0 {
                                MoreTagView(count: remainingCount)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 10)

                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 15) {
                            if selectedContentType == .notes {
                             
                                if filteredNotes.isEmpty {
                                    EmptyStateView(
                                        icon: searchText.isEmpty ? "doc.text" : "magnifyingglass",
                                        title: searchText.isEmpty ? "No notes found for this course" : "No notes match your search",
                                        subtitle: searchText.isEmpty ? nil : "Try searching with different keywords"
                                    )
                                } else {
                                    ForEach(filteredNotes, id: \.createdAt) { note in
                                        CourseCardNotes(
                                            title: note.noteName,
                                            description: note.cachedPlainText,
                                            isLoading: loadingNoteId == note.createdAt,
                                            onDelete: {
                                                noteToDelete = note
                                                showDeleteAlert = true
                                            }
                                        )
                                        .onTapGesture {
                                            openNote(note)
                                        }
                                    }
                                }
                            } else {
                               
                                if filteredFiles.isEmpty {
                                    EmptyStateView(
                                        icon: searchText.isEmpty ? "folder" : "magnifyingglass",
                                        title: searchText.isEmpty ? "No files found for this course" : "No files match your search",
                                        subtitle: searchText.isEmpty ? "Upload some files to get started" : "Try searching with different keywords"
                                    )
                                } else {
                                    LazyVGrid(columns: [
                                        GridItem(.flexible()),
                                        GridItem(.flexible())
                                    ], spacing: 12) {
                                        ForEach(Array(filteredFiles.prefix(6)), id: \.id) { file in
                                            CompactFileCard(file: file) {
                                                           
                                                          
                                                           showimgDeleteAlert = true
                                                            fileToDelete = file
                                                       }
                                        }
                                    }
                                    
                                    if filteredFiles.count > 6 {
                                        Button("View All \(filteredFiles.count) Files") {
                                            showFileGallery = true
                                        }
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(Color("Secondary"))
                                        .padding(.top, 8)
                                        .frame(maxWidth: .infinity)
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }

               
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        
                        // Expandable FAB
                        VStack(spacing: 16) {
                            // Action buttons (shown when expanded)
                            if showExpandedFAB {
                                VStack(spacing: 12) {
                                    // Set Reminder Button
                                    ExpandableFABButton(
                                        icon: "bell.fill",
                                        title: "Set Reminder",
                                        color: Color.orange
                                    ) {
                                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                            showExpandedFAB = false
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                            showReminderSheet = true
                                        }
                                    }
                                    
                                    // Upload File Button
                                    ExpandableFABButton(
                                        icon: "doc.fill",
                                        title: "Upload File",
                                        color: Color.blue
                                    ) {
                                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                            showExpandedFAB = false
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                            showFileUpload = true
                                        }
                                    }
                                    
                                    // Write Note Button
                                    ExpandableFABButton(
                                        icon: "pencil",
                                        title: "Write Note",
                                        color: Color.green
                                    ) {
                                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                            showExpandedFAB = false
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                            navigateToNotesEditor = true
                                        }
                                    }
                                }
                                .transition(.asymmetric(
                                    insertion: .scale(scale: 0.8).combined(with: .opacity).combined(with: .move(edge: .bottom)),
                                    removal: .scale(scale: 0.8).combined(with: .opacity).combined(with: .move(edge: .bottom))
                                ))
                            }
                            
                            // Main FAB Button
                            Button(action: {
                                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                impactFeedback.impactOccurred()
                                
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                    showExpandedFAB.toggle()
                                }
                            }) {
                                Image(systemName: showExpandedFAB ? "xmark" : "plus")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(width: 56, height: 56)
                                    .background(Color("Secondary"))
                                    .clipShape(Circle())
                                    .rotationEffect(.degrees(showExpandedFAB ? 45 : 0))
                                    .scaleEffect(showExpandedFAB ? 1.1 : 1.0)
                                    .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 5)
                            }
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 30)
                    }
                }
                
                if showDeleteAlert {
                    DeleteNoteAlert(
                        noteName: noteToDelete?.noteName ?? "",
                        onCancel: {
                            showDeleteAlert = false
                            noteToDelete = nil
                        },
                        onDelete: {
                            deleteNote()
                        }
                    )
                    .zIndex(1)
                }
                if showimgDeleteAlert {
                    DeleteFileAlert(
                        noteName: noteToDelete?.noteName ?? "",
                        onCancel: {
                            showimgDeleteAlert = false
                            fileToDelete = nil
                        },
                        onDelete: {
                            deleteFile()
                        }
                    )
                    .zIndex(1)
                }
                
                
            }
            .onAppear {
                print("this is course code")
                print(courseCode)
            }.onTapGesture {
                if showExpandedFAB {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        showExpandedFAB = false
                    }
                }
            }
            .navigationBarHidden(true)
            .edgesIgnoringSafeArea(.bottom)
            .sheet(isPresented: $showReminderSheet) {
                ReminderView(courseName: courseName, slot: slot, courseCode: courseCode)
                    .presentationDetents([.fraction(0.8)])
            }
            .sheet(isPresented: $showFileUpload) {
                FileUploadView(courseName: courseName, courseCode: courseCode)
            }
            .sheet(isPresented: $showFileGallery) {
                FileGalleryView(courseCode: courseCode)
            }
            .navigationDestination(isPresented: $navigateToNotesEditor) {
                NoteEditorView(courseCode: courseCode, courseName: courseName, courseIns: courseInstitution, courseSlot: slot)
            }
            .sheet(isPresented: $showNotes, content: {
                NoteEditorView(
                    existingNote: selectedNote,
                    preloadedAttributedString: preloadedAttributedString,
                    courseCode: courseCode,
                    courseName: courseName,
                    courseIns: courseInstitution,
                    courseSlot: slot
                )
            })
        }
    }

    // MARK: - Note Loading Function
    private func openNote(_ note: CreateNoteModel) {
        guard !isLoadingNote else { return }
        
        isLoadingNote = true
        loadingNoteId = note.createdAt
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        Task { @MainActor in
            do {
                let attributedString = try await loadNoteContent(note)
                
                selectedNote = note
                preloadedAttributedString = attributedString
                
                try await Task.sleep(nanoseconds: 300_000_000)
                
                isLoadingNote = false
                loadingNoteId = nil
                showNotes = true
                
            } catch {
                print("Error loading note: \(error)")
                isLoadingNote = false
                loadingNoteId = nil
                
                let errorFeedback = UINotificationFeedbackGenerator()
                errorFeedback.notificationOccurred(.error)
            }
        }
    }
    struct ExpandableFABButton: View {
        let icon: String
        let title: String
        let color: Color
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(width: 44, height: 44)
                        .background(.white)
                        .clipShape(Circle())
                        .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
                    
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.black.opacity(0.8))
                        .clipShape(Capsule())
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    @MainActor
    private func loadNoteContent(_ note: CreateNoteModel) async throws -> NSAttributedString {
        if let cachedAttributedString = note.cachedAttributedString {
            return cachedAttributedString
        }
        
        guard let data = Data(base64Encoded: note.noteContent) else {
            throw NoteLoadingError.invalidData
        }
        
        if let attributedString = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSAttributedString.self, from: data) {
            return attributedString
        } else {
            throw NoteLoadingError.unarchiveFailed
        }
    }

    private func deleteNote() {
        guard let note = noteToDelete else { return }
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        modelContext.delete(note)
        
        do {
            try modelContext.save()
        } catch {
            print("Failed to delete note: \(error)")
        }
        
        showDeleteAlert = false
        noteToDelete = nil
    }
    
    private func deleteFile(){
        guard let file = fileToDelete else{return}
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        modelContext.delete(file)
        do {
            try modelContext.save()
        } catch {
            print("Failed to delete file: \(error)")
        }
        showimgDeleteAlert = false
        
    }
    
}



struct ContentTypeTab: View {
    let contentType: OCourseRefs.ContentType
    let isSelected: Bool
    let count: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: contentType.icon)
                    .font(.system(size: 14))
                
                Text(contentType.rawValue)
                    .font(.system(size: 14, weight: .medium))
                
                if count > 0 {
                    Text("(\(count))")
                        .font(.system(size: 12))
                        .opacity(0.8)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? Color("Accent") : Color("Secondary"))
            .foregroundColor(isSelected ? .black : .white)
            .cornerRadius(20)
        }
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String?
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(.gray.opacity(0.6))
            
            Text(title)
                .foregroundColor(.gray)
                .font(.system(size: 16, weight: .medium))
                .multilineTextAlignment(.center)
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .foregroundColor(.gray.opacity(0.8))
                    .font(.system(size: 14))
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }
}
struct CompactFileCard: View {
    let file: UploadedFile
    let onDelete: (() -> Void)?
    
    @State private var showFileViewer = false
    @State private var showActionSheet = false
    @State private var fileImage: UIImage?
    @State private var imageLoadError = false
    @State private var isLoading = true
    
    init(file: UploadedFile, onDelete: (() -> Void)? = nil) {
        self.file = file
        self.onDelete = onDelete
    }
    
    var body: some View {
        VStack(spacing: 8) {
           
            if file.isImage && !imageLoadError {
                Group {
                    if let image = fileImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else if isLoading {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .overlay(
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            )
                    } else {
                        Rectangle()
                            .fill(Color.red.opacity(0.3))
                            .overlay(
                                VStack(spacing: 4) {
                                    Image(systemName: "exclamationmark.triangle")
                                        .foregroundColor(.red)
                                        .font(.system(size: 16))
                                    Text("Not found")
                                        .font(.caption2)
                                        .foregroundColor(.red)
                                }
                            )
                    }
                }
                .frame(height: 80)
                .clipped()
                .cornerRadius(8)
            } else {
                Rectangle()
                    .fill(getFileTypeColor(file.fileType).opacity(0.2))
                    .frame(height: 80)
                    .overlay(
                        VStack(spacing: 4) {
                            Image(systemName: getFileTypeIcon(file.fileType))
                                .font(.system(size: 24))
                                .foregroundColor(getFileTypeColor(file.fileType))
                            
                            Text(file.fileType.uppercased())
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(getFileTypeColor(file.fileType))
                        }
                    )
                    .cornerRadius(8)
            }
            
            
            VStack(alignment: .leading, spacing: 2) {
                Text(file.fileName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Text(FileManagerHelper.shared.formatFileSize(file.fileSize))
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .onTapGesture {
            showFileViewer = true
        }
        .onLongPressGesture(minimumDuration: 0.5) {
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            showActionSheet = true
        }
        .onAppear {
            if file.isImage {
                loadImageFile()
            }
        }
        .sheet(isPresented: $showFileViewer) {
            EnhancedFileViewerSheet(file: file)
        }
        .confirmationDialog("File Options", isPresented: $showActionSheet, titleVisibility: .visible) {
            Button("Share") {
                shareFile()
            }
            
            if let onDelete = onDelete {
                Button("Delete", role: .destructive) {
                    onDelete()
                }
            }
            
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Choose an action for \(file.fileName)")
        }
    }
    
    // MARK: - File Loading Methods
    
    private func loadImageFile() {
        isLoading = true
        imageLoadError = false
        
        Task {
            let imagePaths = [file.thumbnailPath, file.localPath].compactMap { $0 }
            var loadedImage: UIImage?
            
            for path in imagePaths {
                if let data = FileManagerHelper.shared.loadFileWithFallback(from: path, courseCode: file.courseCode),
                   let image = UIImage(data: data) {
                    loadedImage = image
                    break
                }
            }
            
            await MainActor.run {
                if let image = loadedImage {
                    self.fileImage = image
                    self.imageLoadError = false
                } else {
                    self.imageLoadError = true
                }
                self.isLoading = false
            }
        }
    }
    
    private func shareFile() {
        guard let data = FileManagerHelper.shared.loadFileWithFallback(from: file.localPath, courseCode: file.courseCode) else {
            print("Cannot share file: File not found")
            return
        }
        
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(file.fileName)
        
        do {
            if FileManager.default.fileExists(atPath: tempURL.path) {
                try FileManager.default.removeItem(at: tempURL)
            }
            try data.write(to: tempURL)
            
            let activityVC = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let rootViewController = window.rootViewController {
                
                if let popover = activityVC.popoverPresentationController {
                    popover.sourceView = window
                    popover.sourceRect = CGRect(x: window.bounds.midX, y: window.bounds.midY, width: 0, height: 0)
                    popover.permittedArrowDirections = []
                }
                
                rootViewController.present(activityVC, animated: true)
            }
        } catch {
            print("Error sharing file: \(error)")
        }
    }
    
    private func getFileTypeIcon(_ fileType: String) -> String {
        switch fileType.lowercased() {
        case "pdf":
            return "doc.richtext.fill"
        case "txt":
            return "doc.text.fill"
        case "rtf", "rtfd":
            return "doc.richtext.fill"
        case "doc", "docx":
            return "doc.fill"
        case "jpg", "jpeg", "png", "gif", "heic":
            return "photo.fill"
        default:
            return "doc.fill"
        }
    }
    
    private func getFileTypeColor(_ fileType: String) -> Color {
        switch fileType.lowercased() {
        case "pdf":
            return .red
        case "txt":
            return .blue
        case "rtf", "rtfd":
            return .purple
        case "doc", "docx":
            return .blue
        case "jpg", "jpeg", "png", "gif", "heic":
            return .green
        default:
            return .gray
        }
    }
}

// MARK: - Error Handling
enum NoteLoadingError: Error {
    case invalidData
    case unarchiveFailed
}


struct BottomSheetButton: View {
    var icon: String
    var title: String
    var action: (() -> Void)? = nil
    
    var body: some View {
        Button(action: {
            action?()
        }) {
            VStack {
                Image(icon)
                    .font(.title)
                    .padding()
                    .background(Color.white)
                    .clipShape(Circle())
                Text(title)
                    .font(.footnote)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 10)
        }
    }
}

struct TagView: View {
    var reminder: Remainder

    var body: some View {
        HStack {
            Circle()
                .frame(width: 8, height: 8)
                .foregroundColor(tagColor)

            Text(reminder.title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.white.opacity(0.1))
        .clipShape(Capsule())
    }

    private var tagColor: Color {
        let now = Date()
        let calendar = Calendar.current
        if let daysBetween = calendar.dateComponents([.day], from: now, to: reminder.date).day,
           daysBetween >= 0 && daysBetween <= 7 {
            return .red
        } else {
            return .green
        }
    }
}

struct MoreTagView: View {
    var count: Int

    var body: some View {
        Text("+\(count) more")
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.white.opacity(0.1))
            .clipShape(Capsule())
    }
}

struct CourseCardNotes: View {
    var title: String
    var description: String
    var isLoading: Bool = false
    var onDelete: () -> Void

    @State private var showComingSoonAlert = false

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)

                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }

            Spacer()

            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(0.8)
                    .padding(.trailing, 8)
            } else {
                Menu {
                    Button(role: .destructive) {
                        let feedback = UISelectionFeedbackGenerator()
                        feedback.selectionChanged()
                        onDelete()
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }

                    Button {
                        let feedback = UISelectionFeedbackGenerator()
                        feedback.selectionChanged()
                        showComingSoonAlert = true
                    } label: {
                        Label("Export Markdown", systemImage: "square.and.arrow.down")
                    }

                } label: {
                    Image(systemName: "ellipsis")
                        .rotationEffect(.degrees(90))
                        .foregroundColor(.white)
                        .font(.system(size: 20, weight: .medium))
                        .padding(8)
                        .clipShape(Circle())
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.black.opacity(0.2))
        .cornerRadius(15)
        .opacity(isLoading ? 0.7 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isLoading)
        .alert("Feature coming soon", isPresented: $showComingSoonAlert) {
            Button("OK", role: .cancel) { }
        }
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
