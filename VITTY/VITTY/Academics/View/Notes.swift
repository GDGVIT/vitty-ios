//
//  Academics.swift
//  VITTY
//
//  Created by Rujin Devkota on 2/27/25.

import SwiftUI
import UIKit

struct RichTextView: UIViewRepresentable {
    @Binding var attributedText: NSMutableAttributedString
    @Binding var selectedRange: NSRange
    @Binding var typingAttributes: [NSAttributedString.Key: Any]
    @Binding var isEmpty: Bool
    
   
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = true
        textView.isScrollEnabled = true
        textView.delegate = context.coordinator
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.typingAttributes = typingAttributes
        textView.backgroundColor = .clear
        textView.textColor = .white
        
       
        textView.attributedText = attributedText
        textView.selectedRange = selectedRange
        
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
       
        if context.coordinator.isUpdating {
            return
        }
        
       
        if !uiView.attributedText.isEqual(to: attributedText) {
            let previousSelectedRange = uiView.selectedRange
            context.coordinator.isUpdating = true
            uiView.attributedText = attributedText
            
    
            if previousSelectedRange.location <= uiView.attributedText.length {
                let maxRange = min(previousSelectedRange.location + previousSelectedRange.length, uiView.attributedText.length)
                let validRange = NSRange(location: previousSelectedRange.location, length: maxRange - previousSelectedRange.location)
                uiView.selectedRange = validRange
            }
            context.coordinator.isUpdating = false
        }
        

        if !NSEqualRanges(uiView.selectedRange, selectedRange) &&
           selectedRange.location <= uiView.attributedText.length &&
           NSMaxRange(selectedRange) <= uiView.attributedText.length {
            context.coordinator.isUpdating = true
            uiView.selectedRange = selectedRange
            context.coordinator.isUpdating = false
        }
        
 
        if !NSDictionary(dictionary: uiView.typingAttributes).isEqual(to: typingAttributes) {
            uiView.typingAttributes = typingAttributes
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: RichTextView
        var isUpdating = false

        init(_ parent: RichTextView) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
           
            guard !isUpdating else { return }
            
            isUpdating = true
            defer { isUpdating = false }
            
         
            parent.attributedText = NSMutableAttributedString(attributedString: textView.attributedText)
            parent.isEmpty = textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            
            
            parent.typingAttributes = textView.typingAttributes
        }

        func textViewDidChangeSelection(_ textView: UITextView) {
     
            guard !isUpdating else { return }
            
            isUpdating = true
            defer { isUpdating = false }
            
            parent.selectedRange = textView.selectedRange
            
           
            if textView.selectedRange.length == 0 && textView.selectedRange.location > 0 {
               
                let location = min(textView.selectedRange.location - 1, textView.attributedText.length - 1)
                if location >= 0 {
                    let attributes = textView.attributedText.attributes(at: location, effectiveRange: nil)
                    parent.typingAttributes = attributes
                }
            }
        }
    }
}



struct NoteEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AcademicsViewModel.self) private var academicsViewModel
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var attributedText = NSMutableAttributedString()
    @State private var selectedRange = NSRange(location: 0, length: 0)
    @State private var typingAttributes: [NSAttributedString.Key: Any] = [
        .font: UIFont.systemFont(ofSize: 18),
        .foregroundColor: UIColor.white
    ]
    
    let existingNote: CreateNoteModel?
    let preloadedAttributedString: NSAttributedString? // Pre-processed content
    @State private var selectedFont: UIFont = UIFont.systemFont(ofSize: 18)
    @State private var selectedColor: Color = .white
    @State private var showFontPicker = false
    @State private var showFontSizePicker = false
    @State private var isEmpty = true
    @State private var hasUnsavedChanges = false
    @State private var isInitialized = false
    @State private var goback = false
    
    // New state variables for title alert
    @State private var showTitleAlert = false
    @State private var noteTitle = ""
    
    @Environment(\.modelContext) private var modelContext
    let courseCode: String
    let courseName: String
    let courseIns : String
    let courseSlot : String
    
    init(existingNote: CreateNoteModel? = nil, preloadedAttributedString: NSAttributedString? = nil, courseCode: String, courseName: String,courseIns: String , courseSlot: String) {
        self.existingNote = existingNote
        self.preloadedAttributedString = preloadedAttributedString
        self.courseCode = existingNote?.courseId ?? courseCode
        self.courseName = existingNote?.courseName ?? courseName
        self.courseIns = courseIns
        self.courseSlot = courseSlot
    }
    
    private func handleBackNavigation() {
        
        if hasUnsavedChanges || (existingNote == nil && !isEmpty) {
            
            if existingNote != nil && !noteTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                saveNoteWithTitle()
            } else {
                showTitleAlert = true
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if presentationMode.wrappedValue.isPresented {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
    
    private func initializeContent() {
        guard !isInitialized else { return }
        
        if let note = existingNote {
            // Pre-populate the title field with existing note name
            noteTitle = note.noteName
            
            if let preloaded = preloadedAttributedString {
                attributedText = NSMutableAttributedString(attributedString: preloaded)
                isEmpty = preloaded.string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                isInitialized = true
            } else {
                Task { @MainActor in
                    await loadNoteContent(note)
                    isInitialized = true
                }
            }
        } else {
            attributedText = NSMutableAttributedString()
            isEmpty = true
            isInitialized = true
        }
    }
    
    @MainActor
    private func loadNoteContent(_ note: CreateNoteModel) async {
        if let cachedAttributedString = note.cachedAttributedString {
            attributedText = NSMutableAttributedString(attributedString: cachedAttributedString)
            isEmpty = cachedAttributedString.string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            return
        }
        
        do {
            guard let data = Data(base64Encoded: note.noteContent) else {
                print("Failed to decode base64 data")
                attributedText = NSMutableAttributedString(string: note.noteContent)
                isEmpty = note.noteContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                return
            }
            
            if let loadedAttributedString = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSAttributedString.self, from: data) {
                attributedText = NSMutableAttributedString(attributedString: loadedAttributedString)
                isEmpty = loadedAttributedString.string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            } else {
                print("Failed to unarchive attributed string")
                attributedText = NSMutableAttributedString(string: note.noteContent)
                isEmpty = note.noteContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            }
        } catch {
            print("Error loading note content: \(error)")
            attributedText = NSMutableAttributedString(string: note.noteContent)
            isEmpty = note.noteContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }

    func saveContent() {
        
        if existingNote != nil && !noteTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            saveNoteWithTitle()
        } else {
            
            showTitleAlert = true
        }
    }

   
    
    private func saveNoteWithTitle() {
        guard !noteTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: attributedText, requiringSecureCoding: false)
            let dataString = data.base64EncodedString()

            if let note = existingNote {
                note.noteName = noteTitle
                note.noteContent = dataString
                note.createdAt = Date.now
                CreateNoteModel.clearCache()
            } else {
                let newNote = CreateNoteModel(
                    noteName: noteTitle,
                    userName: authViewModel.loggedInBackendUser?.name ?? "",
                    courseId: courseCode,
                    courseName: courseName,
                    noteContent: dataString,
                    createdAt: Date.now
                )
                print("saved with a course id of \(courseCode)")
                modelContext.insert(newNote)
            }

            try modelContext.save()
            print("Note saved/updated in SwiftData.")
            hasUnsavedChanges = false
            dismiss()
        } catch {
            print("Error saving note: \(error)")
        }
    }
    
    func generateSmartTitle(from plainText: String) -> String {
        let lines = plainText.components(separatedBy: .newlines)
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        if let firstLine = lines.first {
            return String(firstLine.prefix(40)).trimmingCharacters(in: .whitespaces)
        }
        return "Untitled Note"
    }

    private let fonts: [UIFont] = [
        UIFont.systemFont(ofSize: 18),
        UIFont(name: "Times New Roman", size: 18) ?? UIFont.systemFont(ofSize: 18),
        UIFont(name: "Helvetica", size: 18) ?? UIFont.systemFont(ofSize: 18),
        UIFont(name: "Courier", size: 18) ?? UIFont.systemFont(ofSize: 18)
    ]

    private let fontSizes: [CGFloat] = [12, 14, 16, 18, 20, 22, 24, 28, 32, 36, 42, 48]

    var body: some View {
        ZStack {
            Color("Background")
                .edgesIgnoringSafeArea(.all)
            
            if isInitialized {
                VStack {
                    headerView
                    textEditorView
                    toolbarView
                }
            } else {
                ProgressView("Loading...")
                    .foregroundColor(.white)
            }

            if showFontPicker {
                fontPickerOverlay
            }
            
            if showFontSizePicker {
                fontSizePickerOverlay
            }
        }
        .onAppear {
            initializeContent()
        }
        .onChange(of: attributedText) { _, _ in
            if isInitialized {
                hasUnsavedChanges = true
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .animation(.easeInOut(duration: 0.3), value: showFontPicker)
        .animation(.easeInOut(duration: 0.3), value: showFontSizePicker)
        .alert("Save Note", isPresented: $showTitleAlert) {
            TextField("Enter note title", text: $noteTitle)
                .textInputAutocapitalization(.words)
            
            Button("Save") {
                saveNoteWithTitle()
            }
            .disabled(noteTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            
            Button("Cancel", role: .cancel) {
                noteTitle = existingNote?.noteName ?? ""
            }
            
            Button("Don't Save", role: .destructive) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if presentationMode.wrappedValue.isPresented {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        } message: {
            Text("Please enter a title for your note.")
        }
    }
    
    // MARK: - View Components
    
    private var headerView: some View {
        HStack {
            Button(action: { handleBackNavigation() }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(Color("Accent")).font(.title2)
            }
            Spacer()
            Text("Note")
                .foregroundColor(.white)
                .font(.system(size: 25, weight: .bold))
            Spacer()
            Button(action: { saveContent() }) {
                Image("save")
                    .resizable()
                    .frame(width: 30, height: 30)
            }
        }
        .padding()
    }
    
    private var textEditorView: some View {
        ZStack(alignment: .topLeading) {
            RichTextView(
                attributedText: $attributedText,
                selectedRange: $selectedRange,
                typingAttributes: $typingAttributes,
                isEmpty: $isEmpty
            )
            .padding()
            .frame(maxHeight: .infinity)
            
            if isEmpty {
                Text("Start typing here...")
                    .foregroundColor(.gray.opacity(0.6))
                    .font(.system(size: 18))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 24)
                    .allowsHitTesting(false)
            }
        }
    }
    
    private var toolbarView: some View {
        HStack(spacing: 20) {
            Button(action: {
                showFontPicker.toggle()
                showFontSizePicker = false
            }) {
                Image(systemName: "textformat")
                    .foregroundColor(Color("Accent"))
            }
            
            Button(action: {
                showFontSizePicker.toggle()
                showFontPicker = false
            }) {
                HStack(spacing: 2) {
                    Text("a")
                        .font(.system(size: 12))
                        .foregroundColor(Color("Accent"))
                    Text("A")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color("Accent"))
                }
            }
            
            formatButton(action: toggleBold, icon: "bold", isActive: isBoldActive())
            formatButton(action: toggleItalic, icon: "italic", isActive: isItalicActive())
            formatButton(action: toggleUnderline, icon: "underline", isActive: isUnderlineActive())

            ColorPicker("", selection: $selectedColor, supportsOpacity: false)
                .labelsHidden()
                .frame(width: 30, height: 30)
                .onChange(of: selectedColor) { _, newColor in
                    applyAttribute(.foregroundColor, value: UIColor(newColor))
                }

            Button(action: addBulletPoints) {
                Image(systemName: "list.bullet")
                    .foregroundColor(Color("Accent"))
            }
        }
        .padding()
        .background(Color("Background").opacity(0.8))
    }
    
    private func formatButton(action: @escaping () -> Void, icon: String, isActive: Bool) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .foregroundColor(Color("Accent"))
                .padding(8)
                .background(isActive ? Color("Accent").opacity(0.2) : Color.clear)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isActive ? Color("Accent") : Color.clear, lineWidth: 1)
                )
        }
    }
    
    // MARK: - Overlay Views
    
    private var fontPickerOverlay: some View {
        VStack {
            Spacer()
            VStack(spacing: 0) {
                ForEach(fonts, id: \.fontName) { font in
                    Button(action: {
                        selectedFont = font
                        applyFontFamily(font)
                        showFontPicker = false
                    }) {
                        Text(font.fontName.replacingOccurrences(of: "-", with: " "))
                            .foregroundColor(.white)
                            .font(Font(font as CTFont))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                    if font != fonts.last {
                        Divider().background(Color.gray.opacity(0.3))
                    }
                }
            }
            .background(Color("Background"))
            .cornerRadius(10)
            .shadow(color: .black.opacity(0.3), radius: 10)
            .padding(.horizontal, 40)
            .padding(.bottom, 100)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
        .background(Color.black.opacity(0.3))
        .onTapGesture {
            showFontPicker = false
        }
    }
    
    private var fontSizePickerOverlay: some View {
        VStack {
            Spacer()
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 10) {
                    ForEach(fontSizes, id: \.self) { size in
                        Button(action: {
                            applyFontSize(size)
                            showFontSizePicker = false
                        }) {
                            Text("\(Int(size))")
                                .foregroundColor(.white)
                                .font(.system(size: min(size, 24)))
                                .frame(width: 50, height: 40)
                                .background(Color("Accent").opacity(0.2))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color("Accent"), lineWidth: 1)
                                )
                        }
                    }
                }
                .padding()
            }
            .frame(maxHeight: 300)
            .background(Color("Background"))
            .cornerRadius(10)
            .shadow(color: .black.opacity(0.3), radius: 10)
            .padding(.horizontal, 40)
            .padding(.bottom, 100)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
        .background(Color.black.opacity(0.3))
        .onTapGesture {
            showFontSizePicker = false
        }
    }

    func addBulletPoints() {
        guard selectedRange.length > 0 else { return }

        let selectedText = attributedText.attributedSubstring(from: selectedRange).string
        let lines = selectedText.components(separatedBy: "\n")
        let bulletedText = lines.map { "• \($0)" }.joined(separator: "\n")

        let mutableAttributedString = NSMutableAttributedString(attributedString: attributedText)
        mutableAttributedString.replaceCharacters(in: selectedRange, with: bulletedText)

        attributedText = mutableAttributedString
        selectedRange.length = bulletedText.count
    }

    func isBoldActive() -> Bool {
        return checkTraitActive(.traitBold)
    }

    func isItalicActive() -> Bool {
        return checkTraitActive(.traitItalic)
    }

    func isUnderlineActive() -> Bool {
        let underline = getCurrentUnderlineStyle()
        return underline == NSUnderlineStyle.single.rawValue
    }
    
    private func checkTraitActive(_ trait: UIFontDescriptor.SymbolicTraits) -> Bool {
        if selectedRange.length > 0 {
            var hasTraitThroughout = true
            let endLocation = min(selectedRange.location + selectedRange.length, attributedText.length)
            
            attributedText.enumerateAttribute(.font, in: NSRange(location: selectedRange.location, length: endLocation - selectedRange.location), options: []) { value, range, stop in
                if let font = value as? UIFont {
                    if !font.fontDescriptor.symbolicTraits.contains(trait) {
                        hasTraitThroughout = false
                        stop.pointee = true
                    }
                }
            }
            return hasTraitThroughout
        } else {
            if let font = typingAttributes[.font] as? UIFont {
                return font.fontDescriptor.symbolicTraits.contains(trait)
            }
            return false
        }
    }
    
    private func getCurrentFont() -> UIFont {
        if selectedRange.length > 0 && selectedRange.location < attributedText.length {
            return attributedText.attribute(.font, at: selectedRange.location, effectiveRange: nil) as? UIFont ?? UIFont.systemFont(ofSize: 18)
        } else {
            return typingAttributes[.font] as? UIFont ?? UIFont.systemFont(ofSize: 18)
        }
    }
    
    private func getCurrentUnderlineStyle() -> Int {
        if selectedRange.length > 0 && selectedRange.location < attributedText.length {
            return attributedText.attribute(.underlineStyle, at: selectedRange.location, effectiveRange: nil) as? Int ?? 0
        } else {
            return typingAttributes[.underlineStyle] as? Int ?? 0
        }
    }
    
    func applyFontFamily(_ font: UIFont) {
        let size = getCurrentFont().pointSize
        let newFont = UIFont(name: font.fontName, size: size) ?? font
        applyAttribute(.font, value: newFont)
    }
    
    func applyFontSize(_ size: CGFloat) {
        let currentFont = getCurrentFont()
        let newFont = UIFont(descriptor: currentFont.fontDescriptor, size: size)
        applyAttribute(.font, value: newFont)
    }

    func toggleBold() {
        if selectedRange.length > 0 {
            let mutableAttributedString = NSMutableAttributedString(attributedString: attributedText)
            let endLocation = min(selectedRange.location + selectedRange.length, attributedText.length)
            let range = NSRange(location: selectedRange.location, length: endLocation - selectedRange.location)
            
            mutableAttributedString.enumerateAttribute(.font, in: range, options: []) { value, subRange, _ in
                if let font = value as? UIFont {
                    var traits = font.fontDescriptor.symbolicTraits
                    if traits.contains(.traitBold) {
                        traits.remove(.traitBold)
                    } else {
                        traits.insert(.traitBold)
                    }
                    if let newFontDescriptor = font.fontDescriptor.withSymbolicTraits(traits) {
                        let newFont = UIFont(descriptor: newFontDescriptor, size: font.pointSize)
                        mutableAttributedString.addAttribute(.font, value: newFont, range: subRange)
                    }
                }
            }
            attributedText = mutableAttributedString
        } else {
            let currentFont = typingAttributes[.font] as? UIFont ?? UIFont.systemFont(ofSize: 18)
            var traits = currentFont.fontDescriptor.symbolicTraits
            if traits.contains(.traitBold) {
                traits.remove(.traitBold)
            } else {
                traits.insert(.traitBold)
            }
            if let newFontDescriptor = currentFont.fontDescriptor.withSymbolicTraits(traits) {
                let newFont = UIFont(descriptor: newFontDescriptor, size: currentFont.pointSize)
                typingAttributes[.font] = newFont
            }
        }
        hasUnsavedChanges = true
    }

    func toggleItalic() {
        if selectedRange.length > 0 {
            let mutableAttributedString = NSMutableAttributedString(attributedString: attributedText)
            let endLocation = min(selectedRange.location + selectedRange.length, attributedText.length)
            let range = NSRange(location: selectedRange.location, length: endLocation - selectedRange.location)
            
            mutableAttributedString.enumerateAttribute(.font, in: range, options: []) { value, subRange, _ in
                if let font = value as? UIFont {
                    var traits = font.fontDescriptor.symbolicTraits
                    if traits.contains(.traitItalic) {
                        traits.remove(.traitItalic)
                    } else {
                        traits.insert(.traitItalic)
                    }
                    if let newFontDescriptor = font.fontDescriptor.withSymbolicTraits(traits) {
                        let newFont = UIFont(descriptor: newFontDescriptor, size: font.pointSize)
                        mutableAttributedString.addAttribute(.font, value: newFont, range: subRange)
                    }
                }
            }
            attributedText = mutableAttributedString
        } else {
            let currentFont = typingAttributes[.font] as? UIFont ?? UIFont.systemFont(ofSize: 18)
            var traits = currentFont.fontDescriptor.symbolicTraits
            if traits.contains(.traitItalic) {
                traits.remove(.traitItalic)
            } else {
                traits.insert(.traitItalic)
            }
            if let newFontDescriptor = currentFont.fontDescriptor.withSymbolicTraits(traits) {
                let newFont = UIFont(descriptor: newFontDescriptor, size: currentFont.pointSize)
                typingAttributes[.font] = newFont
            }
        }
        hasUnsavedChanges = true
    }
   
    func toggleUnderline() {
        if selectedRange.length > 0 {
            let mutableAttributedString = NSMutableAttributedString(attributedString: attributedText)
            let endLocation = min(selectedRange.location + selectedRange.length, attributedText.length)
            let range = NSRange(location: selectedRange.location, length: endLocation - selectedRange.location)
            
            mutableAttributedString.enumerateAttribute(.underlineStyle, in: range, options: []) { value, subRange, _ in
                let currentUnderline = value as? Int ?? 0
                let newUnderline = currentUnderline == NSUnderlineStyle.single.rawValue ? 0 : NSUnderlineStyle.single.rawValue
                mutableAttributedString.addAttribute(.underlineStyle, value: newUnderline, range: subRange)
            }
            attributedText = mutableAttributedString
        } else {
            let currentUnderline = typingAttributes[.underlineStyle] as? Int ?? 0
            let newUnderline = currentUnderline == NSUnderlineStyle.single.rawValue ? 0 : NSUnderlineStyle.single.rawValue
            typingAttributes[.underlineStyle] = newUnderline
        }
        hasUnsavedChanges = true
    }

    func applyAttribute(_ key: NSAttributedString.Key, value: Any) {
        if selectedRange.length > 0 {
            let mutableAttributedString = NSMutableAttributedString(attributedString: attributedText)
            let endLocation = min(selectedRange.location + selectedRange.length, attributedText.length)
            let range = NSRange(location: selectedRange.location, length: endLocation - selectedRange.location)
            mutableAttributedString.addAttribute(key, value: value, range: range)
            attributedText = mutableAttributedString
        } else {
            typingAttributes[key] = value
        }
        hasUnsavedChanges = true
    }
}
