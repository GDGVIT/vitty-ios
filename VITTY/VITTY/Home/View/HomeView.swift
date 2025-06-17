import SwiftUI

import SwiftUI

struct HomeView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @State private var selectedPage = 1
    @State private var showProfileSidebar: Bool = false

    @State private var isCreatingGroup = false
 
    
    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView()
                
                VStack(spacing: 0) {
                    HStack {
                        Text(
                            selectedPage == 3 ? "Academics" :
                            selectedPage == 2 ? "Connects" :
                            "Schedule"
                        )
                        .font(Font.custom("Poppins-Bold", size: 26))
                        
                        Spacer()
                        
                        if selectedPage != 2 {
                            Button {
                                withAnimation {
                                    showProfileSidebar = true
                                }
                            } label: {
                                UserImage(
                                    url: authViewModel.loggedInBackendUser?.picture ?? "",
                                    height: 30,
                                    width: 40
                                )
                            }
                        }else{
                            
                          
                            
                            
                           
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    .padding(.bottom, 8)
                    
                    ZStack {
                        switch selectedPage {
                        case 1:
                            TimeTableView(friend: nil)
                        case 2:
                            ConnectPage(isCreatingGroup: $isCreatingGroup)
                        case 3:
                            Academics()
                        default:
                            Text("Error Lol")
                        }
                    }
                    .padding(.top, 4)
                    
                    Spacer()
                    
                    BottomBarView(presentTab: $selectedPage)
                        .padding(.bottom, 24)
                }
                
                
                // In your HomeView
                if showProfileSidebar {
                    ZStack {
                        // Full screen overlay to darken the background
                        Color.black.opacity(0.3)
                            .edgesIgnoringSafeArea(.all)
                            .onTapGesture {
                                withAnimation {
                                    showProfileSidebar = false
                                }
                            }
                        
                      
                        GeometryReader { geometry in
                            HStack(spacing: 0) {
                                Spacer()
                                
                                UserProfileSidebar(isPresented: $showProfileSidebar)
                                    .frame(width: geometry.size.width * 0.75)
                                    .transition(.move(edge: .trailing))
                                    .background(Color.clear)
                                    .edgesIgnoringSafeArea(.all)
                            }
                        }
                    }
                    .edgesIgnoringSafeArea(.all)
                }
                
            }
            .ignoresSafeArea(edges: .bottom)
          
        }
    }
}
