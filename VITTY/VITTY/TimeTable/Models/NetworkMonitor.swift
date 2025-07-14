//
//  NetworkMonitor.swift
//  VITTY
//
//  Created by Rujin Devkota on 7/11/25.
//



import Foundation
import Network



class NetworkMonitor: ObservableObject {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
  
    @Published var isConnected = true

    init() {
        monitor.pathUpdateHandler = { path in
            
            DispatchQueue.main.async {
                self.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }
}
