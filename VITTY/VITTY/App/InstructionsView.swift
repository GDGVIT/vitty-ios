//
//  InstructionsView.swift
//  VITTY
//
//  Created by Ananya George on 12/23/21.
//

import SwiftUI

struct InstructionsView: View {
    @EnvironmentObject var authState: AuthService
    @EnvironmentObject var ttVM: TimetableViewModel
    @State var goToHomeScreen = UserDefaults.standard.bool(forKey: "instructionsComplete")
    @State var displayLogout: Bool = false
    @State var displayFollowInstructions = false
    @EnvironmentObject var notifVM: NotificationsViewModel
    // notifsSetup is true when notifications don't need to be setup and false when they do
    @AppStorage(AuthService.notifsSetupKey) var notifsSetup = false
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Text("Sync Timetable")
                    Spacer()
                    Image(systemName: "arrow.right.square")
                        .onTapGesture {
                            displayLogout = true
                        }
                }
                .font(Font.custom("Poppins-Bold", size: 24))
                .foregroundColor(Color.white)
                ScrollView {
                    if displayFollowInstructions {
                        Text(StringConstants.followInstructionsText.uppercased())
                            .foregroundColor(Color.white)
                            .padding(.vertical)
                            .font(.custom("Poppins-Regular", size: 16))
                        
                    }
                    InstructionsCards()
                        .padding(.vertical)
                }
                Spacer()
                CustomButton(buttonText: "Done") {
                    self.displayFollowInstructions = true
                    if ttVM.timetable.isEmpty {
                        ttVM.getData {
                            if !notifsSetup {
                                notifVM.setupNotificationPreferences(timetable: ttVM.timetable)
                            }
                        }
                    } else {
                        print("time table is populated")
                        UserDefaults.standard.set(true, forKey:"instructionsComplete")
                        goToHomeScreen = true
                    }
                }
                NavigationLink(destination: HomePage().navigationTitle("").navigationBarHidden(true).environmentObject(ttVM).environmentObject(authState).environmentObject(notifVM), isActive: $goToHomeScreen) {
                    EmptyView()
                }
            }
            .blur(radius: displayLogout ? 10 : 0)
            .padding()
            .background(Image("InstructionsBG").resizable().scaledToFill().edgesIgnoringSafeArea(.all))
            
            if displayLogout {
                LogoutPopup(showLogout: $displayLogout)
            }
        }
        .onAppear {
            ttVM.getData {
                if !notifsSetup {
                    notifVM.setupNotificationPreferences(timetable: ttVM.timetable)
                }
            }
            notifVM.getNotifPrefs()
        }
    }
}

struct InstructionsView_Previews: PreviewProvider {
    static var previews: some View {
        InstructionsView()
            .environmentObject(AuthService())
            .environmentObject(TimetableViewModel())
            .environmentObject(NotificationsViewModel())
    }
}
