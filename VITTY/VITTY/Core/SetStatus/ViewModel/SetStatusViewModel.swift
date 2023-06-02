//
//  SetStatusViewModel.swift
//  VITTY
//
//  Created by Prashanna Rajbhandari on 03/06/2023.
//

import Foundation

struct statusModel: Identifiable {
    let id: Int
    let imageName: String
    let statusName: String
    let time: String
}

class SetStatusViewModel: ObservableObject {
    @Published var stausArray: [statusModel] = [
        statusModel(id: 1, imageName: "calendar", statusName: "In a meeting", time: "1 hour"),
        statusModel(id: 2, imageName: "sick", statusName: "Not feeling well", time: "Today"),
        statusModel(id: 3, imageName: "vacation", statusName: "Vacationing", time: "Don't clear"),
        statusModel(id: 4, imageName: "class", statusName: "In a class", time: "1 hour"),
        statusModel(id: 5, imageName: "class", statusName: "In a lab", time: "1.4 hour")
    ]
}
