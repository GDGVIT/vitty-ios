//
//  EmptyClassAPIService.swift
//  VITTY
//
//  Created by Rujin Devkota on 2/27/25.
//

import SwiftUI

struct EmptyClassRoom: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @StateObject private var viewModel = EmptyClassroomViewModel()
    @State private var selectedSlot: String = "A1"
    @State private var searchText: String = ""
    @Environment(\.dismiss) private var dismiss

    let slots = ["A1", "B1", "C1", "D1", "E1", "F1", "G1", "A2", "B2", "C2", "D2", "E2", "F2", "G2"]
    
    // Computed property for filtered classrooms
    private var filteredClassrooms: [String] {
        if searchText.isEmpty {
            return viewModel.emptyClassrooms
        } else {
            return viewModel.emptyClassrooms.filter { room in
                room.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView()
                
                VStack(spacing: 0) {
                    headerView
                    searchBarView
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
        .padding(.top, 10)
    }
    
    private var searchBarView: some View {
        EmptyClassSearchBar(searchText: $searchText)
            .padding(.top, 16)
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
        .padding(.top, 12)
    }
    
    private var contentView: some View {
        Group {
            if viewModel.isLoading {
                loadingView
            } else if viewModel.isGenerating {
                generatingView
            } else if let errorMessage = viewModel.errorMessage {
                errorView(errorMessage)
            } else if viewModel.emptyClassrooms.isEmpty {
                emptyStateView
            } else if filteredClassrooms.isEmpty && !searchText.isEmpty {
                noResultsView
            } else {
                classroomsGrid
            }
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(.white)
            Text("Loading classrooms...")
                .foregroundColor(.white.opacity(0.8))
                .font(.subheadline)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    private var generatingView: some View {
        VStack(spacing: 24) {
            // Animated hourglass icon
            Image(systemName: "hourglass")
                .font(.system(size: 50))
                .foregroundColor(.blue.opacity(0.7))
                .rotationEffect(.degrees(viewModel.isGenerating ? 180 : 0))
                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: viewModel.isGenerating)
            
            VStack(spacing: 16) {
                Text("Preparing Your Data")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text("Our system is currently generating the latest classroom information for slot \(selectedSlot).")
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .font(.body)
                    .padding(.horizontal, 20)
                
                VStack(spacing: 8) {
                    Text("This process may take a few moments")
                        .foregroundColor(.blue.opacity(0.8))
                        .font(.subheadline)
                    
                    Text("Please check again after a while")
                        .foregroundColor(.white.opacity(0.6))
                        .font(.caption)
                }
                .padding(.top, 8)
            }
            
            Button(action: {
                viewModel.reload(slot: selectedSlot, authToken: authViewModel.loggedInBackendUser?.token ?? "")
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 14, weight: .medium))
                    Text("Reload")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.blue.opacity(0.7))
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                )
            }
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    private func errorView(_ errorMessage: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundColor(.orange.opacity(0.8))
            
            Text("Oops!")
                .font(.headline)
                .foregroundColor(.white)
            
            Text(errorMessage)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .font(.subheadline)
                .padding(.horizontal)
            
            Button(action: {
                viewModel.reload(slot: selectedSlot, authToken: authViewModel.loggedInBackendUser?.token ?? "")
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 14, weight: .medium))
                    Text("Reload")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.orange.opacity(0.7))
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "building.2")
                .font(.system(size: 40))
                .foregroundColor(.white.opacity(0.6))
            Text("No Classrooms Available")
                .font(.headline)
                .foregroundColor(.white)
            Text("There are no empty classrooms for slot \(selectedSlot) at this time.")
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .font(.subheadline)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    private var noResultsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40))
                .foregroundColor(.white.opacity(0.6))
            Text("No Results Found")
                .font(.headline)
                .foregroundColor(.white)
            Text("No classrooms match '\(searchText)'")
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .font(.subheadline)
            Button("Clear Search") {
                searchText = ""
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .background(Color.blue.opacity(0.7))
            .cornerRadius(8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    private var classroomsGrid: some View {
        ScrollView {
            LazyVGrid(columns: gridColumns, spacing: 16) {
                ForEach(filteredClassrooms, id: \.self) { room in
                    ClassRoomCard(room: room)
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .scale.combined(with: .opacity)
                        ))
                }
            }
            .padding()
            .animation(.easeInOut(duration: 0.3), value: filteredClassrooms)
        }
    }
    
    // MARK: - Helper Properties and Methods
    
    private var gridColumns: [GridItem] {
        [GridItem(.flexible()), GridItem(.flexible())]
    }
    
    private func handleSlotSelection(_ slot: String) {
        guard selectedSlot != slot else { return }
        selectedSlot = slot
        searchText = "" // Clear search when changing slots
        Task {
            await viewModel.fetchEmptyClassrooms(slot: slot, authToken: authViewModel.loggedInBackendUser?.token ?? "")
        }
    }
}

struct ClassRoomCard: View {
    let room: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "building.2")
                .font(.system(size: 24))
                .foregroundColor(.white.opacity(0.8))
            
            Text(room)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 120)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color("Secondary"))
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
}

struct EmptyClassSearchBar: View {
    @Binding var searchText: String
    @FocusState private var isSearchFocused: Bool
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.white.opacity(0.6))
                .font(.system(size: 16))
            
            TextField("Search classrooms...", text: $searchText)
                .focused($isSearchFocused)
                .foregroundColor(.white)
                .tint(.white)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                    isSearchFocused = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white.opacity(0.6))
                        .font(.system(size: 16))
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.15))
                .stroke(isSearchFocused ? Color.blue.opacity(0.5) : Color.clear, lineWidth: 1)
        )
        .padding(.horizontal)
        .animation(.easeInOut(duration: 0.2), value: searchText.isEmpty)
        .animation(.easeInOut(duration: 0.2), value: isSearchFocused)
    }
}

struct SlotFilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .medium)
                .foregroundColor(.white)
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? Color.blue.opacity(0.7) : Color("Secondary"))
                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                )
                .scaleEffect(isSelected ? 1.05 : 1.0)
        }
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}
