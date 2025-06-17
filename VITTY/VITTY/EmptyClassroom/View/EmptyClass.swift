import SwiftUI

struct EmptyClassRoom: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @StateObject private var viewModel = EmptyClassroomViewModel()
    @State private var selectedSlot: String = "A1"
    @Environment(\.dismiss) private var dismiss

    let slots = ["A1", "B1", "C1", "D1", "E1", "F1", "G1", "A2", "B2", "C2", "D2", "E2", "F2", "G2"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView()
                
                VStack {
                    headerView
                    EmptyClassSearchBar()
                    slotsScrollView
                    contentView
                    Spacer()
                }
                .onAppear {
                    Task {
                        await viewModel.fetchEmptyClassrooms(slot: selectedSlot, authToken: authViewModel.loggedInBackendUser?.token ?? "")
                    }
                }
            }.navigationBarBackButtonHidden(true)
        }
    }
    
    // MARK: - Extracted Components
    
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
            Text("Classrooms")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            Spacer()
        }
        .padding(.horizontal)
    }
    
    private var slotsScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(slots, id: \.self) { slot in
                    SlotFilterButton(
                        title: slot,
                        isSelected: selectedSlot == slot,
                        action: { handleSlotSelection(slot) }
                    )
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 5)
        }
    }
    
    private var contentView: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading...")
                    .foregroundColor(.white)
                    .padding()
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            } else if viewModel.emptyClassrooms.isEmpty {
                Text("No classrooms available for this slot.")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                classroomsGrid
            }
        }
    }
    
    private var classroomsGrid: some View {
        ScrollView {
            LazyVGrid(columns: gridColumns, spacing: 16) {
                ForEach(viewModel.emptyClassrooms, id: \.self) { room in
                    ClassRoomCard(room: room)
                }
            }
            .padding()
        }
    }
    
    // MARK: - Helper Properties and Methods
    
    private var gridColumns: [GridItem] {
        [GridItem(.flexible()), GridItem(.flexible())]
    }
    
    private func handleSlotSelection(_ slot: String) {
        guard selectedSlot != slot else { return }
        selectedSlot = slot
        Task {
            await viewModel.fetchEmptyClassrooms(slot: slot, authToken: authViewModel.loggedInBackendUser?.token ?? "")
        }
    }
}


struct ClassRoomCard: View {
    let room: String
    
    var body: some View {
        VStack {
            Text(room)
                .font(.headline)
                .foregroundColor(.white)
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 100)
        .background(Color("Secondary"))
        .cornerRadius(10)
    }
}

struct EmptyClassSearchBar: View {
    @State private var searchText = ""
    
    var body: some View {
        TextField("Search", text: $searchText)
            .padding(10)
            .background(Color.secondary.opacity(0.3))
            .cornerRadius(10)
            .padding(.horizontal)
    }
}

struct SlotFilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .foregroundColor(.white)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(isSelected ? Color.blue.opacity(0.7) : Color("Secondary"))
                .cornerRadius(8)
        }
    }
}
