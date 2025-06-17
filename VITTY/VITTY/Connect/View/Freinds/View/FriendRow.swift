import SwiftUI

struct FriendRow: View {
    let friend: Friend

    var body: some View {
        HStack {
            UserImage(url: friend.picture, height: 48, width: 48)
            Spacer().frame(width: 20)
            VStack(alignment: .leading) {
                
                Text(cleanName(friend.name))
                    .font(Font.custom("Poppins-SemiBold", size: 18))
                    .foregroundColor(Color.white)
                
                if friend.currentStatus.status == "free" {
                    HStack {
                        Image("available").resizable().frame(width: 20, height: 20)
                        Text("Available").foregroundStyle(Color("Accent"))
                    }
                } else {
                    HStack {
                        Image("inclass")
                        Text(friend.currentStatus.venue ?? "")
                            .font(Font.custom("Poppins-Regular", size: 14))
                            .foregroundColor(Color("Accent"))
                    }
                }
            }
            Spacer()
        }
        .padding().frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color("Secondary"))
        )
    }

    
    func cleanName(_ fullName: String) -> String {
        let pattern = "\\b\\d{2}[A-Z]+\\d+\\b" //
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        
        let range = NSRange(location: 0, length: fullName.utf16.count)
        let cleanedName = regex?.stringByReplacingMatches(in: fullName, options: [], range: range, withTemplate: "").trimmingCharacters(in: .whitespaces) ?? fullName
        
        return cleanedName
    }
}

