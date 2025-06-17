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
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.attributedText = attributedText
        uiView.selectedRange = selectedRange
        uiView.typingAttributes = typingAttributes
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: RichTextView

        init(_ parent: RichTextView) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.attributedText = NSMutableAttributedString(attributedString: textView.attributedText)
            // Update isEmpty state based on text content
            parent.isEmpty = textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }

        func textViewDidChangeSelection(_ textView: UITextView) {
            parent.selectedRange = textView.selectedRange
        }
    }
}

struct NoteEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AcademicsViewModel.self) private var academicsViewModel
    @Environment(AuthViewModel.self) private var authViewModel
    
    @State private var attributedText = NSMutableAttributedString() // Start with empty text
    @State private var selectedRange = NSRange(location: 0, length: 0)
    @State private var typingAttributes: [NSAttributedString.Key: Any] = [
        .font: UIFont.systemFont(ofSize: 18),
        .foregroundColor: UIColor.white
    ]
    @State private var selectedFont: UIFont = UIFont.systemFont(ofSize: 18)
    @State private var selectedColor: Color = .white
    @State private var showFontPicker = false
    @State private var showFontSizePicker = false
    @State private var isEmpty = true // Track if the text view is empty

    func saveContent() {
        let markdown = attributedText.toMarkdown()
        let note = CreateNoteModel(
            noteName:"",
            userName: "",
            courseId:"",
            courseName: "",
            noteContent: markdown,
            createdAt: Date.now
           )

        let uRL = URL(string: "\(APIConstants.base_url)notes/save")!
        
        academicsViewModel.createNote(at: uRL ,
                                      authToken:authViewModel.loggedInBackendUser?.token ?? "", note: note)
    }
    
    private let fonts: [UIFont] = [
        UIFont.systemFont(ofSize: 18),
        UIFont(name: "Times New Roman", size: 18)!,
        UIFont(name: "Helvetica", size: 18)!,
        UIFont(name: "Courier", size: 18)!
    ]

    // Font sizes for the aA picker
    private let fontSizes: [CGFloat] = [12, 14, 16, 18, 20, 22, 24, 28, 32, 36, 42, 48]

    var body: some View {
        ZStack {
            Color("Background")
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(Color("Accent"))
                    }
                    Spacer()
                    Text("Note")
                        .foregroundColor(.white)
                        .font(.system(size: 25,weight: Font.Weight.bold))
                    Spacer()
                    Button(action:{
                        saveContent()
                    }){
                        Image("save").resizable().frame(width: 30,height: 30)
                    }
                }
                .padding()

                ZStack(alignment: .topLeading) {
                    RichTextView(
                        attributedText: $attributedText,
                        selectedRange: $selectedRange,
                        typingAttributes: $typingAttributes,
                        isEmpty: $isEmpty
                    )
                    .padding()
                    .frame(maxHeight: .infinity)
                    
                    // Placeholder overlay
                    if isEmpty {
                        Text("Start typing here...")
                            .foregroundColor(.gray.opacity(0.6))
                            .font(.system(size: 18))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 24)
                            .allowsHitTesting(false) // Allow taps to pass through to the text view
                    }
                }

                HStack(spacing: 20) {
                    // Font family picker
                    Button(action: {
                        showFontPicker.toggle()
                        showFontSizePicker = false
                    }) {
                        Image(systemName: "textformat")
                            .foregroundColor(Color("Accent"))
                    }
                    
                    // Font size picker (aA icon)
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
                    
                    Button(action: { toggleBold() }) {
                        Image(systemName: "bold")
                            .foregroundColor(Color("Accent"))
                            .padding(8)
                            .background(isBoldActive() ? Color("Accent").opacity(0.2) : Color.clear)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(isBoldActive() ? Color("Accent") : Color.clear, lineWidth: 1)
                            )
                    }
                    
                    Button(action: { toggleItalic() }) {
                        Image(systemName: "italic")
                            .foregroundColor(Color("Accent"))
                            .padding(8)
                            .background(isItalicActive() ? Color("Accent").opacity(0.2) : Color.clear)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(isItalicActive() ? Color("Accent") : Color.clear, lineWidth: 1)
                            )
                    }
                    
                    Button(action: { toggleUnderline() }) {
                        Image(systemName: "underline")
                            .foregroundColor(Color("Accent"))
                            .padding(8)
                            .background(isUnderlineActive() ? Color("Accent").opacity(0.2) : Color.clear)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(isUnderlineActive() ? Color("Accent") : Color.clear, lineWidth: 1)
                            )
                    }

                    ColorPicker("", selection: $selectedColor, supportsOpacity: false)
                        .labelsHidden()
                        .frame(width: 30, height: 30)
                        .onChange(of: selectedColor) { newColor in
                            applyAttribute(.foregroundColor, value: UIColor(newColor))
                        }

                    Button(action: { addBulletPoints() }) {
                        Image(systemName: "list.bullet")
                            .foregroundColor(Color("Accent"))
                    }
                }
                .padding()
                .background(Color("Background").opacity(0.8))
            }

            // Font family picker overlay
            if showFontPicker {
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
            
            // Font size picker overlay
            if showFontSizePicker {
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
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .animation(.easeInOut(duration: 0.3), value: showFontPicker)
        .animation(.easeInOut(duration: 0.3), value: showFontSizePicker)
    }

    func addBulletPoints() {
        guard selectedRange.length > 0 else { return }

        let selectedText = attributedText.attributedSubstring(from: selectedRange).string
        let lines = selectedText.components(separatedBy: "\n")
        var bulletedText = lines.map { "• \($0)" }.joined(separator: "\n")

        let mutableAttributedString = NSMutableAttributedString(attributedString: attributedText)
        mutableAttributedString.replaceCharacters(in: selectedRange, with: bulletedText)

        attributedText = mutableAttributedString
        selectedRange.length = bulletedText.count
    }

    func isBoldActive() -> Bool {
        if selectedRange.length > 0 {
            if let font = attributedText.attribute(.font, at: selectedRange.location, effectiveRange: nil) as? UIFont {
                return font.fontDescriptor.symbolicTraits.contains(.traitBold)
            }
        } else {
            if let font = typingAttributes[.font] as? UIFont {
                return font.fontDescriptor.symbolicTraits.contains(.traitBold)
            }
        }
        return false
    }

    func isItalicActive() -> Bool {
        if selectedRange.length > 0 {
            if let font = attributedText.attribute(.font, at: selectedRange.location, effectiveRange: nil) as? UIFont {
                return font.fontDescriptor.symbolicTraits.contains(.traitItalic)
            }
        } else {
            if let font = typingAttributes[.font] as? UIFont {
                return font.fontDescriptor.symbolicTraits.contains(.traitItalic)
            }
        }
        return false
    }

    func isUnderlineActive() -> Bool {
        if selectedRange.length > 0 {
            if let underline = attributedText.attribute(.underlineStyle, at: selectedRange.location, effectiveRange: nil) as? Int {
                return underline == NSUnderlineStyle.single.rawValue
            }
        } else {
            if let underline = typingAttributes[.underlineStyle] as? Int {
                return underline == NSUnderlineStyle.single.rawValue
            }
        }
        return false
    }
    
    func applyFontFamily(_ font: UIFont) {
        let currentFont = (selectedRange.length > 0 ? attributedText.attribute(.font, at: selectedRange.location, effectiveRange: nil) : typingAttributes[.font]) as? UIFont ?? UIFont.systemFont(ofSize: 18)
        let newFont = UIFont(name: font.fontName, size: currentFont.pointSize) ?? font
        applyAttribute(.font, value: newFont)
    }
    
    func applyFontSize(_ size: CGFloat) {
        let currentFont = (selectedRange.length > 0 ? attributedText.attribute(.font, at: selectedRange.location, effectiveRange: nil) : typingAttributes[.font]) as? UIFont ?? UIFont.systemFont(ofSize: 18)
        let newFont = UIFont(descriptor: currentFont.fontDescriptor, size: size)
        applyAttribute(.font, value: newFont)
    }

    func toggleBold() {
        let currentFont = (selectedRange.length > 0 ? attributedText.attribute(.font, at: selectedRange.location, effectiveRange: nil) : typingAttributes[.font]) as? UIFont ?? UIFont.systemFont(ofSize: 18)
        var traits = currentFont.fontDescriptor.symbolicTraits
        if traits.contains(.traitBold) {
            traits.remove(.traitBold)
        } else {
            traits.insert(.traitBold)
        }
        if let newFontDescriptor = currentFont.fontDescriptor.withSymbolicTraits(traits) {
            let newFont = UIFont(descriptor: newFontDescriptor, size: currentFont.pointSize)
            applyAttribute(.font, value: newFont)
        }
    }

    func toggleItalic() {
        let currentFont = (selectedRange.length > 0 ? attributedText.attribute(.font, at: selectedRange.location, effectiveRange: nil) : typingAttributes[.font]) as? UIFont ?? UIFont.systemFont(ofSize: 18)
        var traits = currentFont.fontDescriptor.symbolicTraits
        if traits.contains(.traitItalic) {
            traits.remove(.traitItalic)
        } else {
            traits.insert(.traitItalic)
        }
        if let newFontDescriptor = currentFont.fontDescriptor.withSymbolicTraits(traits) {
            let newFont = UIFont(descriptor: newFontDescriptor, size: currentFont.pointSize)
            applyAttribute(.font, value: newFont)
        }
    }

    func toggleUnderline() {
        let currentUnderline = (selectedRange.length > 0 ? attributedText.attribute(.underlineStyle, at: selectedRange.location, effectiveRange: nil) : typingAttributes[.underlineStyle]) as? Int ?? 0
        let newUnderline = currentUnderline == NSUnderlineStyle.single.rawValue ? 0 : NSUnderlineStyle.single.rawValue
        applyAttribute(.underlineStyle, value: newUnderline)
    }

    func applyAttribute(_ key: NSAttributedString.Key, value: Any) {
        if selectedRange.length > 0 {
            let mutableAttributedString = NSMutableAttributedString(attributedString: attributedText)
            mutableAttributedString.addAttribute(key, value: value, range: selectedRange)
            attributedText = mutableAttributedString
        } else {
            typingAttributes[key] = value
        }
    }
}
