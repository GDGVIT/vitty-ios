//
//  NotesHelper.swift
//  VITTY
//
//  Created by Rujin Devkota on 3/5/25.

//

import Down

import Foundation
import UIKit

extension NSAttributedString {
    func toMarkdown() -> String {
        let mutableString = NSMutableString()
        self.enumerateAttributes(in: NSRange(location: 0, length: self.length), options: []) { (attributes, range, _) in
            let substring = self.attributedSubstring(from: range).string
            var markdownString = substring

            
            if let font = attributes[.font] as? UIFont, font.fontDescriptor.symbolicTraits.contains(.traitBold) {
                markdownString = "**\(markdownString)**"
            }

            if let font = attributes[.font] as? UIFont, font.fontDescriptor.symbolicTraits.contains(.traitItalic) {
                markdownString = "*\(markdownString)*"
            }

        
            if let underline = attributes[.underlineStyle] as? Int, underline == NSUnderlineStyle.single.rawValue {
                markdownString = "__\(markdownString)__"
            }

          
            if let font = attributes[.font] as? UIFont {
                switch font.pointSize {
                case 24:
                    markdownString = "# \(markdownString)"
                case 20:
                    markdownString = "## \(markdownString)"
                case 18:
                    markdownString = "### \(markdownString)"
                default:
                    break
                }
            }

            mutableString.append(markdownString)
        }
        return mutableString as String
    }
}


extension String {
    func toAttributedString() -> NSAttributedString? {
        let down = Down(markdownString: self)
        return try? down.toAttributedString()
    }
}
