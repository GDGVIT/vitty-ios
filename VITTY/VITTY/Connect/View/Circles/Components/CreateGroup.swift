import SwiftUI

struct CreateGroup: View {
    let screenHeight = UIScreen.main.bounds.height
    let screenWidth = UIScreen.main.bounds.width
    
    @Binding var groupCode: String
    @State private var groupName: String = ""
    @State private var selectedImage: UIImage? = nil
    @State private var showImagePicker = false
    @State private var selectedFriends: [String] = ["A", "B", "C", "D", "E"]
    
    var body: some View {
        VStack(spacing: 20) {
            
            Capsule()
                .fill(Color("Accent"))
                .frame(width: 80, height: 5)
                .padding(.top, 10)
            
            Text("Create Group")
                .font(.system(size: 23, weight: .bold))
                .foregroundColor(.white)
            
            Spacer().frame(height: 20)
            
            // Group Icon Picker
            Button(action: {
                showImagePicker = true
            }) {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 80, height: 80)
                    
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 75, height: 75)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "camera.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.white)
                    }
                }
            }
            .sheet(isPresented: $showImagePicker) {
                
            }
            
           
            VStack(alignment: .leading, spacing: 10) {
                Text("Enter group name")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color("Accent"))
                
                TextField("Group Name", text: $groupName)
                    .padding()
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(8)
                    .foregroundColor(.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    )
            }
            .padding(.horizontal, 20)
            
         
            HStack {
                Text("Add Friends")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color("Accent"))
                    .padding(.leading, 20)
                
                Spacer()
                
                Button(action: {
                    
                }) {
                    Image(systemName: "person.badge.plus")
                        .foregroundColor(.white)
                        .font(.system(size: 20, weight: .bold))
                }
                .padding(.trailing, 20)
            }
            
           
            HStack {
                Spacer().frame(width : 90)
                ZStack {
                    ForEach(Array(selectedFriends.prefix(3).enumerated()), id: \.element) { index, friend in
                        Circle()
                            .fill(Color.green.opacity(0.8))
                            .frame(width: 40, height: 40)
                            .overlay(Text(friend).foregroundColor(.white))
                            .offset(x: CGFloat(index * -25))
                    }
                }
                Spacer()
                if selectedFriends.count > 3 {
                    Text("+ \(selectedFriends.count - 3) more")
                        .foregroundColor(.gray)
                        .padding(.trailing, 20)
                }
                
                
            }
            .frame(width: screenWidth * 0.9, height: 80).overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color("Accent"), lineWidth: 2)
            )
            .background(Color.black.opacity(0.3))
            .cornerRadius(12)
            .padding(.horizontal, 20)
            
            Spacer()
            
          
            HStack {
                Spacer()
                Button(action: {
                    
                }) {
                    Text("Cretae ")
                        .font(.system(size: 18, weight: .bold)).foregroundStyle(Color.black)
                       
                        .frame(width: 90, height: 40)
                        .background(Color("Accent"))
                        .cornerRadius(10)
                }
                .padding(.trailing, 20)
            }
            .padding(.bottom, 20)
            
        }
        .presentationDetents([.height(screenHeight * 0.65)])
        .background(Color("Secondary"))
    }
}

#Preview {
    CreateGroup(groupCode: .constant(""))
}

