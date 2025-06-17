import SwiftUI
import AVFoundation

struct JoinGroup: View {
    let screenHeight = UIScreen.main.bounds.height
    let screenWidth = UIScreen.main.bounds.width
    
    @Binding var groupCode: String
    @State private var isScanning = false
    @State private var scannedCode: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Capsule()
                .fill(Color.gray.opacity(0.5))
                .frame(width: 50, height: 5)
                .padding(.top, 10)
            
            Text("Join Group")
                .font(.system(size: 21, weight: .bold))
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Enter group code")
                    .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color("Accent"))
                
                TextField("", text: $groupCode)
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
                Rectangle()
                    .fill(Color.gray.opacity(0.5))
                    .frame(height: 1)
                Text("OR")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                Rectangle()
                    .fill(Color.gray.opacity(0.5))
                    .frame(height: 1)
            }
            .padding(.horizontal, 20)
            
            HStack{
                Text("Scan Qr Code").font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color("Accent")).padding(.leading,20)
                Spacer()
            }
            
            VStack {
                Image(systemName: "qrcode.viewfinder")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .foregroundColor(Color.gray)
            }
            .frame(width: screenWidth*0.8, height: screenHeight*0.25)
            .background(Color.black.opacity(0.3))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
            )
            
            Spacer()
            
            HStack {
                Spacer()
                Text("JOIN")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color("Accent")).padding(.trailing,20)
            }
            .padding(.leading, 20)
            .padding(.bottom, 20)
        }
        
        .presentationDetents([.height(screenHeight * 0.65)])
        .background(Color("Secondary"))
    }
}

#Preview {
    JoinGroup(groupCode: .constant(""))
}
