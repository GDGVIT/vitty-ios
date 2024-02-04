//
//  InstructionsView.swift
//  VITTY
//
//  Created by Ananya George on 12/23/21.
//

import SwiftUI

struct InstructionsView: View {
	@Environment(AuthViewModel.self) private var authState
	@EnvironmentObject var ttVM: TimetableViewModel

	@State var goToHomeScreen = UserDefaults.standard.bool(forKey: "instructionsComplete")
	@State var displayLogout: Bool = false
	@State var displayFollowInstructions = false

	@State var hideInstructionsView: Bool = false

	// notifsSetup is true when notifications don't need to be setup and false when they do
	@AppStorage(AuthViewModel.notifsSetupKey) var notifsSetup = false
	
	var isNewUser: Binding<Bool> {
		return Binding (
			get: {authState.isNewUser},
			set: {authState.isNewUser = $0}
		)
	}

	var body: some View {
		ZStack {
			if !hideInstructionsView {
				instructionsView()
					.fullScreenCover(
						isPresented: isNewUser,
						content: {
							UserName()
						}
					)
			}
			else {
				HomeView()
					.navigationTitle("").navigationBarHidden(true).environmentObject(ttVM)
					.environment(authState)
//					.environmentObject(notifVM)
			}

		}
		.onAppear(perform: {
			hideInstructionsView = UserDefaults.standard.bool(forKey: "hideInstructionsView")
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
			.environment(AuthViewModel())
			.environmentObject(TimetableViewModel())
//			.environmentObject(NotificationsViewModel())
	}
}

extension InstructionsView {
	private func instructionsView() -> some View {
		ZStack {
			VStack {
				header()
					.font(Font.custom("Poppins-Bold", size: 24))
					.foregroundColor(Color.white)
				instructions()
				Spacer()

				NavigationLink {
					HomeView()
						.navigationTitle("").navigationBarHidden(true).environmentObject(ttVM)
						.environment(authState)
				} label: {
					doneButton()
				}

				NavigationLink(
					destination: HomeView().navigationTitle("").navigationBarHidden(true)
						.environmentObject(ttVM).environment(authState),
//						.environmentObject(notifVM),
					isActive: $goToHomeScreen
				) {
					EmptyView()
				}
			}
			.blur(radius: displayLogout ? 10 : 0)
			.padding()
			.background(
				Image("InstructionsBG").resizable().scaledToFill().edgesIgnoringSafeArea(.all)
			)

			if displayLogout {
				LogoutPopup(showLogout: $displayLogout)
			}
		}
	}

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
			if authState.myUser.username == "" {
				authState.isNewUser = true
			}
			else {
				self.displayFollowInstructions = true
				UserDefaults.standard.setValue(true, forKey: "hideInstructionsView")

				goToHomeScreen = true
			}
		}
	}
}

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