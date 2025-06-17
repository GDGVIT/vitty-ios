import SwiftUI
import SwiftData

struct CoursesView: View {
    @Query private var timeTables: [TimeTable]
    @State private var searchText = ""
    @State private var isCurrentSemester = true
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        let courses = timeTables.first.map { extractCourses(from: $0) } ?? []
        let filtered = filteredCourses(from: courses)

        ScrollView {
            VStack(spacing: 0) {
                SearchBar(searchText: $searchText)

                HStack(spacing: 16) {
                    SemesterFilterButton(isSelected: isCurrentSemester, title: "Current Semester")
                        .onTapGesture { isCurrentSemester = true }

                    SemesterFilterButton(isSelected: !isCurrentSemester, title: "All Semesters")
                        .onTapGesture { isCurrentSemester = false }

                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 16)

                VStack(spacing: 16) {
                    ForEach(filtered) { course in
                        NavigationLink(destination: CourseRefs(courseName: course.title, courseInstitution: course.code,slot:course.slot,courseCode: course.code)) {
                            CourseCardView(course: course)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
        }
        .scrollIndicators(.hidden)
        .background(Color("Background").edgesIgnoringSafeArea(.all))
    }
    private func filteredCourses(from allCourses: [Course]) -> [Course] {
        allCourses.filter { course in
            let matchesSearch = searchText.isEmpty || course.title.lowercased().contains(searchText.lowercased())
            if isCurrentSemester {
                return matchesSearch && course.semester == determineSemester(for: Date())
            } else {
                return matchesSearch
            }
        }
    }

    private func extractCourses(from timetable: TimeTable) -> [Course] {
        let allLectures = timetable.monday + timetable.tuesday + timetable.wednesday +
                          timetable.thursday + timetable.friday + timetable.saturday +
                          timetable.sunday

        let currentSemester = determineSemester(for: Date())

       
        let groupedLectures = Dictionary(grouping: allLectures, by: { $0.name })

        var result: [Course] = []

        for (title, lectures) in groupedLectures {
            _ = lectures.map { $0.slot }.joined(separator: " + ")
            let uniqueSlot = Set(lectures.map { $0.slot }).joined(separator: " + ")
            _ = Set(lectures.map { $0.code }).joined(separator: " / ")
            

            result.append(
                Course(
                    title: title,
                    slot: uniqueSlot,
                    code: uniqueSlot,
                    semester: currentSemester,
                    isFavorite: false
                )
            )
        }

        return result
    }


    private func determineSemester(for date: Date) -> String {
        let month = Calendar.current.component(.month, from: date)
        
        switch month {
        case 12, 1, 2:
            return "Winter \(academicYear(for: date))"
        case 3...6:
            return "Summer \(academicYear(for: date))"
        case 7...11:
            return "Fall \(academicYear(for: date))"
        default:
            return "Unknown"
        }
    }

    private func academicYear(for date: Date) -> String {
        let year = Calendar.current.component(.year, from: date)
        let month = Calendar.current.component(.month, from: date)
        if month < 3 {
            return "\(year - 1)-\(String(format: "%02d", year % 100))"
        } else {
            return "\(year)-\(String(format: "%02d", (year + 1) % 100))"
        }
    }

}

struct SemesterFilterButton: View {
    let isSelected: Bool
    let title: String
    
    var body: some View {
        HStack(spacing: 8) {
            if isSelected {
                Image(systemName: "checkmark")
                    .font(.system(size: 12))
                    .foregroundColor(.white)
            }
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.white)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
        .background(isSelected ? Color("Accent") : Color.clear)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? Color.clear : Color.gray.opacity(0.5), lineWidth: 1)
        )
    }
}

struct CourseCardView: View {
    let course: Course
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(course.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                if course.isFavorite {
                    Image(systemName: "star.fill")
                        .foregroundColor(Color.yellow)
                }
            }
            .padding(.top, 16)
            .padding(.horizontal, 16)
            
            Text(course.code + " | " + course.semester)
                .font(.system(size: 14))
                .foregroundColor(Color("Accent"))
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color("Secondary")))
    }
}

struct Course: Identifiable {
    let id = UUID()
    let title: String
    let slot: String
    let code : String
    let semester: String
    let isFavorite: Bool
}
