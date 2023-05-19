//
//  SmallWidgetView.swift
//  VITTY
//
//  Created by Ananya George on 2/26/22.
//

import SwiftUI
import WidgetKit

struct SmallWidgetView: View {
    var widgetData: VITTYWidgetDataModel
    var body: some View {
        VStack(alignment: .leading) {
            ZStack {
                if widgetData.classesCompleted < widgetData.classInfo.count && widgetData.error == nil {
                    VStack(alignment: .leading, spacing: 0) {
                        WidgetHeader()
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(LinearGradient.secGrad)
                            WidgetSmallClassCard(classInfo: widgetData.classInfo[widgetData.classesCompleted], onlineMode: RemoteConfigManager.sharedInstance.onlineMode)
                        }
                        .padding(.horizontal, 5)
                        .padding(.bottom, 5)
                    }
                    .padding(5)
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.darkbg)
                        VStack(alignment: .leading) {
                            Text("No more class today!")
                                .font(Font.custom("Poppins-Bold", size: 15))
                            Text(RemoteConfigManager.sharedInstance.onlineMode
                                ? StringConstants.noClassQuotesOnline.randomElement() ?? "Have fun today!" : StringConstants.noClassQuotesOffline.randomElement() ?? "Have fun today!")
                                .font(Font.custom("Poppins-Regular", size: 12))
                        }
                        .foregroundColor(Color.white)
                    }
                    .padding(5)
                }
            }
        }
        .background(Color.widgbg).edgesIgnoringSafeArea(.all)
    }
}

struct SmallWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        SmallWidgetView(widgetData: VITTYWidgetDataModel(classInfo: StringConstants.dummyClassArray, classesCompleted: 0, error: nil))
    }
}
