//
//  TimeTableScrollView.swift
//  VITTY
//
//  Created by Ananya George on 1/21/22.
//

import SwiftUI

struct TimeTableScrollView: View {
    var selectedTT: [Classes]
    @Binding var tabSelected: Int
    @EnvironmentObject var timetableViewModel: TimetableViewModel
    @ObservedObject var notifSingleton = NotificationsViewModel.shared
    @StateObject var RemoteConf = RemoteConfigManager.sharedInstance
    var body: some View {
        VStack {
            if !selectedTT .isEmpty {
                ScrollView {
                    ScrollViewReader { scrollView in
                        ForEach(0..<selectedTT.count, id:\.self) { ind in
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.darkbg)
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(LinearGradient.secGrad)
                                    .opacity((tabSelected == Date.convertToMondayWeek()) && timetableViewModel.classesCompleted == ind ? 1 : 0)
                                ClassCards(classInfo: selectedTT[ind], onlineMode: RemoteConf.onlineMode)
                                    .id(ind)
                            }
                            .padding(.bottom,2)
                        }
                        .onAppear {
                            print((Calendar.current.dateComponents([.weekday], from: Date()).weekday ?? 1) - 1)
                            print(tabSelected)
                            scrollView.scrollTo(timetableViewModel.classesCompleted)
                        }
                        .onChange(of: notifSingleton.notificationTapped) { _ in
                            tabSelected = (Calendar.current.dateComponents([.weekday], from: Date()).weekday ?? 1) - 1
                            scrollView.scrollTo(timetableViewModel.classesCompleted)
                        }
                    }
                    .padding(.top, 5)
                    .padding(.horizontal, 10)
                    .onAppear {
                        timetableViewModel.updateClassCompleted()
                    }
                }
            }
            else {
                Spacer()
                VStack(alignment: .center) {
                    Text("No class today!")
                        .font(Font.custom("Poppins-Bold", size: 24))
                    //                        TODO: remote config
                    Text(RemoteConf.onlineMode
                         ? StringConstants.noClassQuotesOnline.randomElement() ?? "Have fun today!" : StringConstants.noClassQuotesOffline.randomElement() ?? "Have fun today!")
                        .font(Font.custom("Poppins-Regular",size:20))
                }
                .foregroundColor(Color.white)
                Spacer()
            }
        }
    }
}

