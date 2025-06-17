//
//  Academics.swift
//  VITTY
//
//  Created by Rujin Devkota on 2/27/25.
//

import SwiftUI
import SwiftData

struct RemindersView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allReminders: [Remainder]
    
    @State private var searchText = ""
    @State private var selectedTab = 0
    
    // Filtered reminders based on search text
    private var filteredReminders: [Remainder] {
        if searchText.isEmpty {
            return allReminders
        } else {
            return allReminders.filter { reminder in
                reminder.title.localizedCaseInsensitiveContains(searchText) ||
                reminder.subject.localizedCaseInsensitiveContains(searchText) ||
                reminder.courseCode.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    // Group reminders by date
    private var groupedReminders: [ReminderGroup] {
        let grouped = Dictionary(grouping: filteredReminders) { reminder in
            Calendar.current.startOfDay(for: reminder.date)
        }
        
        return grouped.map { (date, reminders) in
            let daysToGo = Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "d MMMM"
            
            return ReminderGroup(
                date: dateFormatter.string(from: date),
                daysToGo: max(0, daysToGo),
                items: reminders.map { remainder in
                    ReminderItem(
                        id: remainder.persistentModelID,
                        title: remainder.title,
                        course: "\(remainder.subject) - \(remainder.courseCode)",
                        isQuiz: remainder.title.lowercased().contains("quiz"),
                        time: remainder.slot.isEmpty ? nil : remainder.slot,
                        isCompleted: remainder.isCompleted,
                        subjectDescription: remainder.subjectDescription
                    )
                }
            )
        }.sorted { $0.daysToGo < $1.daysToGo }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search", text: $searchText)
                        .foregroundColor(.white)
                    
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(10)
                .background(Color("Secondary"))
                .cornerRadius(8)
                .padding(.horizontal)
                .padding(.top, 16)
                
                // Status Tabs
                HStack(spacing: 16) {
                    StatusTabView(isSelected: selectedTab == 0, title: "Pending")
                        .onTapGesture { selectedTab = 0 }
                    StatusTabView(isSelected: selectedTab == 1, title: "Completed")
                        .onTapGesture { selectedTab = 1 }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 16)
                
                // Reminder Groups
                VStack(spacing: 24) {
                    ForEach(groupedReminders, id: \.id) { group in
                        if selectedTab == 0 && !group.items.filter({ !$0.isCompleted }).isEmpty {
                            ReminderGroupView(
                                group: ReminderGroup(
                                    date: group.date,
                                    daysToGo: group.daysToGo,
                                    items: group.items.filter { !$0.isCompleted }
                                ),
                                completeItem: { itemId in
                                    completeReminderItem(itemId: itemId)
                                }
                            )
                            .transition(.move(edge: .trailing))
                        } else if selectedTab == 1 && !group.items.filter({ $0.isCompleted }).isEmpty {
                            ReminderGroupView(
                                group: ReminderGroup(
                                    date: group.date,
                                    daysToGo: group.daysToGo,
                                    items: group.items.filter { $0.isCompleted }
                                ),
                                completeItem: { _ in }
                            )
                            .transition(.move(edge: .trailing))
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 16)
                
                // Empty state
                if groupedReminders.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "calendar.badge.exclamationmark")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        
                        Text(searchText.isEmpty ? "No reminders yet" : "No reminders found")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.gray)
                        
                        if !searchText.isEmpty {
                            Text("Try adjusting your search terms")
                                .font(.system(size: 14))
                                .foregroundColor(.gray.opacity(0.7))
                        }
                    }
                    .padding(.top, 60)
                }
            }
        }
        .scrollIndicators(.hidden)
        .background(Color("Background").edgesIgnoringSafeArea(.all))
    }
    
    private func completeReminderItem(itemId: PersistentIdentifier) {
        if let remainder = allReminders.first(where: { $0.persistentModelID == itemId }) {
            withAnimation(.easeInOut(duration: 0.3)) {
                remainder.isCompleted = true
                try? modelContext.save()
            }
        }
    }
}

struct StatusTabView: View {
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

struct ReminderGroupView: View {
    let group: ReminderGroup
    let completeItem: (PersistentIdentifier) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(group.date)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(group.daysToGo <= 2 ? Color.red : Color.yellow)
                        .frame(width: 8, height: 8)
                    
                    Text(group.daysToGo == 0 ? "Today" : "\(group.daysToGo) days to go")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            VStack(spacing: 12) {
                ForEach(group.items, id: \.id) { item in
                    if item.isCompleted {
                        ReminderItemView(item: item)
                    } else {
                        SwipeableReminderItemView(
                            item: item,
                            onComplete: { completeItem(item.id) }
                        )
                    }
                }
            }
        }
    }
}

struct SwipeableReminderItemView: View {
    let item: ReminderItem
    let onComplete: () -> Void
    
    @State private var offset: CGFloat = 0
    @State private var isRemoved = false
    
    var body: some View {
        ZStack {
            if !isRemoved {
                HStack {
                    Spacer()
                    VStack {
                        Image(systemName: "checkmark")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                        Text("Completed")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                    }
                    .frame(width: 100)
                    .frame(maxHeight: .infinity)
                    .background(Color.green)
                    .cornerRadius(16)
                    .opacity(offset < -75 ? 1 : 0)
                }
            }

            ReminderItemView(item: item)
                .background(RoundedRectangle(cornerRadius: 16).fill(Color("Secondary")))
                .offset(x: offset)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            if !isRemoved {
                                offset = min(0, gesture.translation.width)
                            }
                        }
                        .onEnded { _ in
                            if offset < -75 {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    offset = -UIScreen.main.bounds.width
                                    isRemoved = true
                                }
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    onComplete()
                                }
                            } else {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    offset = 0
                                }
                            }
                        }
                )
        }
        .frame(height: isRemoved ? 0 : nil)
        .opacity(isRemoved ? 0 : 1)
        .animation(.easeInOut(duration: 0.3), value: isRemoved)
    }
}

struct ReminderItemView: View {
    let item: ReminderItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(item.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                if let time = item.time {
                    Spacer()
                    Text(time)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color("Accent").opacity(0.3))
                        .cornerRadius(8)
                }
            }
            .padding(.top, 16)
            .padding(.horizontal, 16)
            
            HStack {
                Text(item.course)
                    .font(.system(size: 14))
                    .foregroundColor(Color("Accent"))
                
                if item.isQuiz {
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.orange)
                        Text("Quiz")
                            .font(.system(size: 12))
                            .foregroundColor(.orange)
                    }
                }
            }
            .padding(.horizontal, 16)
            
            if let description = item.subjectDescription, !description.isEmpty {
                Text(description)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.horizontal, 16)
            }
        }
        .padding(.bottom, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color("Secondary")))
    }
}

// Updated models to work with SwiftData
struct ReminderGroup: Identifiable {
    let id = UUID()
    let date: String
    let daysToGo: Int
    var items: [ReminderItem]
}

struct ReminderItem: Identifiable {
    let id: PersistentIdentifier
    let title: String
    let course: String
    let isQuiz: Bool
    let time: String?
    var isCompleted: Bool
    let subjectDescription: String?
}
