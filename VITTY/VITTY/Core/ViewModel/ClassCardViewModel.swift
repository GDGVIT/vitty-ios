//
//  ClassCardViewModel.swift
//  VITTY
//
//  Created by Ananya George on 2/17/22.
//

import Foundation
import UIKit

class ClassCardViewModel: ObservableObject {
    static var classCardVM = ClassCardViewModel()
    let VIT = "Vellore+Institute+of+Technology,+Vellore+India"
    let blocks = [
        "CDMM":"Centre+For+Disaster+Mitigation+And+Management",
        "SJT" : "SJT+Building+%2F+Silver+Jubilee+Towers",
        "MB" : "MB+-+Main+Building",
        "MGB" : "Mahatma+Gandhi+Block",
        "TT" : "Technology+Tower+-+TT",
        "SMV" : "SMV",
        "PLB" : "Pearl+Research+Block",
        "CBMR" : "CBMR+block",
        "GDN" : "GDN",
        "PRP" : "Pearl+Research+Block"
    ]
    let appleMapsURL = "maps://?q="
    let googleMapsURL = "comgooglemaps://?q="
    let browserURL = "https://www.google.com/maps/dir/?api=1&destination="
    
    func navigateToClass(at location: String) {
        let block = self.extractBlock(from: location)
        let dirs = "\(self.blocks[block] ?? ""),+\(self.VIT)"
        var url = URL(string: "\(self.googleMapsURL)\(dirs)&directionsmode=walking")
        if UIApplication.shared.canOpenURL(url!) {
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        } else {
            print("Couldn't open Google Maps, trying the default browser now...")
            url = URL(string: "\(browserURL)\(dirs)&travelmode=walking")
            UIApplication.shared.open(url!)
        }
        
        
    }
    
    func extractBlock(from location: String) -> String {
        var block = ""
        for char in location {
            if char.isLetter { block.append(char) }
        }
        return block
    }
}
