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
    @EnvironmentObject var notifVM: NotificationsViewModel

    @State var goToHomeScreen = UserDefaults.standard.bool(forKey: "instructionsComplete")
    @State var displayLogout: Bool = false
    @State var displayFollowInstructions = false

    // notifsSetup is true when notifications don't need to be setup and false when they do
    @AppStorage(AuthService.notifsSetupKey) var notifsSetup = false

    var body: some View {
        ZStack {
            VStack {
                header()
                    .font(Font.custom("Poppins-Bold", size: 24))
                    .foregroundColor(Color.white)
                instructions()
                Spacer()

                
                NavigationLink {
                    HomePage()
                        .navigationTitle("").navigationBarHidden(true).environmentObject(ttVM).environmentObject(authState).environmentObject(notifVM)
                } label: {
                    doneButton()
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
        .fullScreenCover(isPresented: $authState.isNewUser, content: {
            UserName()
        })
//        .onAppear {
//            ttVM.getData {
//                if !notifsSetup {
//                    notifVM.setupNotificationPreferences(timetable: ttVM.timetable)
//                }
//            }
//            notifVM.getNotifPrefs()
//         }
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

extension InstructionsView {
    private func header() -> some View {
        HStack {
            Text("Sync Timetable")
            Spacer()
            Image(systemName: "arrow.right.square")
                .onTapGesture {
                    displayLogout = true
                }
        }
    }

    private func instructions() -> some View {
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
    }

    private func doneButton() -> some View {
        CustomButton(buttonText: "Done") {
            self.displayFollowInstructions = true
            ttVM.getTimeTable(token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6InByYXNoYW5uYS5yYWpiaGFuZGFyaTNAZ21haWwuY29tIiwicm9sZSI6Im5vcm1hbCIsInVzZXJuYW1lIjoicHJhc2hhbm5hdGVzdCJ9.JULv80sjDUdC2SAgpepRcBBZHTsDjisN1xtNZp7-jVs", username: "prashannatest")
            goToHomeScreen = true
            
//            if ttVM.timetable.isEmpty {
//                ttVM.getData {
//                    if !notifsSetup {
//                        notifVM.setupNotificationPreferences(timetable: ttVM.timetable)
//                    }
//                }
//            } else {
//                print("time table is populated")
//                UserDefaults.standard.set(true, forKey: "instructionsComplete")
//                goToHomeScreen = true
//            }
        }
    }
}
