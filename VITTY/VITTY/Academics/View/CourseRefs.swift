import SwiftUI
import SwiftData

struct CourseRefs: View {
    var courseName: String
    var courseInstitution: String
    var slot: String
    var courseCode: String

    @State private var showBottomSheet = false
    @State private var showReminderSheet = false
    @State private var navigateToNotesEditor = false

    @Environment(\.dismiss) private var dismiss

    private let maxVisible = 4

    // Fetch remainders with dynamic predicate
    @Query private var filteredRemainders: [Remainder]

    init(courseName: String, courseInstitution: String, slot: String, courseCode: String) {
        self.courseName = courseName
        self.courseInstitution = courseInstitution
        self.slot = slot
        self.courseCode = courseCode

        // Dynamic predicate and descriptor
        let predicate = #Predicate<Remainder> {
            $0.subject == courseName && $0.isCompleted == false
        }

        let descriptor = FetchDescriptor<Remainder>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.date, order: .forward)]
        )

        _filteredRemainders = Query(descriptor)
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

                        Button(action: {}) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.white)
                                .font(.title2)
                        }
                    }
                    .padding()

                    HStack {
                        Spacer()
                        TextField("Search", text: .constant(""))
                            .padding(10)
                            .frame(width: UIScreen.main.bounds.width * 0.85)
                            .background(Color.white.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding(.horizontal)
                        Spacer()
                    }
                    Spacer().frame(height: 20)

                    Text("\(courseName) - \(courseInstitution)")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                        .padding(.horizontal)

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
                            CourseCardNotes(title: "Sample Title", description: "Data science and software engineering experience is recommended.")
                            CourseCardNotes(title: "More Information", description: "This certification is intended for you if you have both technical and non-technical backgrounds.")
                        }
                        .padding()
                    }
                }

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showBottomSheet.toggle()
                        }) {
                            Image(systemName: "plus")
                                .font(.title)
                                .padding(18)
                                .background(Color("Secondary"))
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationBarHidden(true)
            .edgesIgnoringSafeArea(.bottom)
            .sheet(isPresented: $showBottomSheet) {
                ZStack {
                    Color("Secondary").edgesIgnoringSafeArea(.all)

                    HStack {
                        BottomSheetButton(icon: "upload", title: "Write Note") {
                            showBottomSheet = false
                            navigateToNotesEditor = true
                        }

                        BottomSheetButton(icon: "edit_document", title: "Upload File")
                        BottomSheetButton(icon: "alarm", title: "Set Reminder") {
                            showBottomSheet = false
                            showReminderSheet = true
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 20)
                }
                .presentationDetents([.height(200)])
                .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showReminderSheet) {
                ReminderView(courseName: courseName, slot: slot, courseCode: courseCode)
                    .presentationDetents([.fraction(0.8)])
            }
            .navigationDestination(isPresented: $navigateToNotesEditor) {
                NoteEditorView()
            }
        }
    }
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
  
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.bottom, 5)
            
            Text(description)
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(2)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.black.opacity(0.2))
        .cornerRadius(15)
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


