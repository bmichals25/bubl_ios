import SwiftUI

struct VideoCallPlaceholderView: View {
    @State private var isCalling = false
    
    var body: some View {
        VStack(spacing: 30) {
            if isCalling {
                // Video call in progress UI
                ZStack {
                    // Background color
                    Color.black.edgesIgnoringSafeArea(.all)
                    
                    VStack {
                        // Bubl video feed (placeholder)
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray6))
                                .aspectRatio(16/9, contentMode: .fit)
                            
                            VStack {
                                BublAnimationView(emotion: .happy)
                                    .frame(width: 150, height: 150)
                                
                                Text("Bubl is on video")
                                    .foregroundColor(.black)
                            }
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                        
                        // User camera preview (smaller)
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemGray3))
                                .frame(width: 120, height: 160)
                            
                            Image(systemName: "person.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                        }
                        .shadow(radius: 5)
                        .offset(x: 100, y: -60)
                        
                        // Call controls
                        HStack(spacing: 30) {
                            Button(action: {}) {
                                Image(systemName: "mic.slash.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                                    .padding(15)
                                    .background(Color.gray)
                                    .clipShape(Circle())
                            }
                            
                            Button(action: {
                                withAnimation {
                                    isCalling = false
                                }
                            }) {
                                Image(systemName: "phone.down.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                                    .padding(15)
                                    .background(Color.red)
                                    .clipShape(Circle())
                            }
                            
                            Button(action: {}) {
                                Image(systemName: "video.slash.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                                    .padding(15)
                                    .background(Color.gray)
                                    .clipShape(Circle())
                            }
                        }
                        .padding(.bottom, 30)
                    }
                }
            } else {
                // Call initiation UI
                Spacer()
                
                BublAnimationView(emotion: .happy)
                    .frame(width: 200, height: 200)
                
                Text("Video Chat with Bubl")
                    .font(.title)
                    .fontWeight(.medium)
                
                Text("Tap the button below to start a video call with Bubl")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Spacer()
                
                // Call button
                Button(action: {
                    withAnimation {
                        isCalling = true
                    }
                }) {
                    Image(systemName: "video.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                        .padding(30)
                        .background(Color.purple)
                        .clipShape(Circle())
                        .shadow(color: Color.purple.opacity(0.4), radius: 10, x: 0, y: 5)
                }
                .padding(.bottom, 50)
            }
        }
        .navigationTitle(isCalling ? "" : "Video Bubl")
        .navigationBarHidden(isCalling)
    }
} 