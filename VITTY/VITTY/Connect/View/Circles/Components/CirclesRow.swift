//
//  CirclesRow.swift
//  VITTY
//
//  Created by Rujin Devkota on 2/28/25.
//

import SwiftUI

struct CirclesRow: View {
    let circle: CircleModel
    @Environment(CommunityPageViewModel.self) private var communityPageViewModel
    @Environment(AuthViewModel.self) private var authViewModel
    
   
    private var circleMembers: [CircleUserTemp] {
        communityPageViewModel.circleMembers(for: circle.circleID)
    }
    
   
    private var busyCount: Int {
        circleMembers.filter {
            $0.status != nil && $0.status != "available" && $0.status != "free"
        }.count
    }
    
    private var availableCount: Int {
        circleMembers.filter {
            $0.status == nil || $0.status == "available" || $0.status == "free"
        }.count
    }
    
    private var isLoadingMembers: Bool {
        communityPageViewModel.isLoadingCircleMembers(for: circle.circleID)
    }

    var body: some View {
        HStack {
            
            //TODO: left to add a circle image right now its a picsum image
            
            CircleImageView(imageURL: "https://picsum.photos/200/300", size: 48)
            
            Spacer().frame(width: 20)
            VStack(alignment: .leading) {
                
                Text(cleanName(circle.circleName))
                    .font(Font.custom("Poppins-SemiBold", size: 18))
                    .foregroundColor(Color.white)
                
                if isLoadingMembers {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.7)
                        Text("Loading...")
                            .font(Font.custom("Poppins-Regular", size: 12))
                            .foregroundStyle(Color("Accent"))
                    }
                } else {
                    HStack {
                        
                        if busyCount > 0 {
                            Image("inclass").resizable().frame(width: 20, height: 20)
                            Text("\(busyCount) busy").foregroundStyle(Color("Accent"))
                            
                            if availableCount > 0 {
                                Spacer().frame(width: 20)
                            }
                        }
                        
                      
                        if availableCount > 0 {
                            Image("available").resizable().frame(width: 20, height: 20)
                            Text("\(availableCount) available").foregroundStyle(Color("Accent"))
                        }
                        
                       
                        if circleMembers.isEmpty && !isLoadingMembers {
                            Text("No members")
                                .font(Font.custom("Poppins-Regular", size: 12))
                                .foregroundStyle(Color("Accent").opacity(0.7))
                        }
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
        .onAppear {
            
            communityPageViewModel.fetchCircleMemberData(
                from: "\(APIConstants.base_url)circles/\(circle.circleID)",
                token: authViewModel.loggedInBackendUser?.token ?? "",
                loading: true,
                circleID: circle.circleID
            )
        }
        
        
    }
    
    
    func cleanName(_ fullName: String) -> String {
        let pattern = "\\b\\d{2}[A-Z]+\\d+\\b"
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        
        let range = NSRange(location: 0, length: fullName.utf16.count)
        let cleanedName = regex?.stringByReplacingMatches(in: fullName, options: [], range: range, withTemplate: "").trimmingCharacters(in: .whitespaces) ?? fullName
        
        return cleanedName
    }
}
struct CircleImageView: View {
    let imageURL: String
    let size: CGFloat
    
    var body: some View {
        AsyncImage(url: URL(string: imageURL)) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: size, height: size)
                .clipShape(Circle())
        } placeholder: {
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: size, height: size)
                .overlay(
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: size * 0.5))
                        .foregroundColor(.gray)
                )
        }
    }
}
