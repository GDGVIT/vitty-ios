//
//  EmptyClassRoomViewModel.swift
//  VITTY
//
//  Created by Rujin Devkota on 2/27/25.
//

import Foundation

@MainActor
class EmptyClassroomViewModel: ObservableObject {
    @Published var emptyClassrooms: [String] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    private var currentSlot: String = "A1"

    func fetchEmptyClassrooms(slot: String, authToken: String) async {
        guard !slot.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        currentSlot = slot
        
        do {
            let classrooms = try await EmptyClassRoomAPIService.shared.getEmptyClassrooms(slot: slot, authToken: authToken)
            emptyClassrooms = classrooms
        } catch {
            errorMessage = "Failed to load empty classrooms: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}

