//
//  Circles.swift
//  VITTY
//
//  Created by Rujin Devkota on 2/27/25.
//

import SwiftUI

struct CirclesView: View {
    @Binding var isCreatingGroup: Bool
    @State private var searchText = ""
    @Environment(CommunityPageViewModel.self) private var communityPageViewModel
    @Environment(AuthViewModel.self) private var authViewModel
    
    @EnvironmentObject private var navigationCoordinator: NavigationCoordinator
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Spacer().frame(height: 8)
                SearchBar(searchText: $searchText)
                Spacer().frame(height: 8)

                if communityPageViewModel.errorCircle {
                    Spacer()
                    VStack(spacing: 5) {
                        Text("No Circles?")
                            .multilineTextAlignment(.center)
                            .font(Font.custom("Poppins-SemiBold", size: 18))
                            .foregroundColor(Color.white)
                        Text("Create or join a circle to see group activities")
                            .multilineTextAlignment(.center)
                            .font(Font.custom("Poppins-Regular", size: 12))
                            .foregroundColor(Color.white)
                    }
                    Spacer()
                } else if communityPageViewModel.loadingCircle {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else {
                    let filteredCircles = communityPageViewModel.circles.filter { circle in
                        searchText.isEmpty || circle.circleName.localizedCaseInsensitiveContains(searchText)
                    }

                    if filteredCircles.isEmpty {
                        Spacer()
                        Text("No circles match your search")
                            .font(Font.custom("Poppins-Regular", size: 16))
                            .foregroundColor(.white)
                        Spacer()
                    } else {
                        ScrollView {
                            VStack(spacing: 10) {
                                ForEach(filteredCircles, id: \.circleID) { circle in
                                    NavigationLink(destination: InsideCircle(circleName: circle.circleName, circle_id: circle.circleID, circle_join_code: circle.circleJoinCode, circle_role: circle.circleRole)) {
                                        CirclesRow(circle: circle)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal)
                        }
                        .safeAreaPadding(.bottom, 100)
                    }
                }
            }
            .refreshable {
                fetchCircleData()
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("CircleJoinedSuccessfully"))) { _ in
                fetchCircleData()
            }
            .onAppear {
               
                fetchCircleData()
                
               
                if let pendingInvite = navigationCoordinator.pendingCircleInvite {
                    print("CirclesView appeared with pending invite: \(pendingInvite.code)")
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    private func fetchCircleData() {
        guard let token = authViewModel.loggedInBackendUser?.token else {
            print("No authentication token available")
            return
        }
        
        communityPageViewModel.fetchCircleData(
            from: "\(APIConstants.base_urlv3)circles",
            token: token,
            loading: true
        )
    }
}
