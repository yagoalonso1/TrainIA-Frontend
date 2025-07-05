import SwiftUI

struct MainView: View {
    @StateObject private var authService = AuthService()
    @State private var showLogin = true
    @State private var prefilledEmail: String? = nil
    
    var body: some View {
        Group {
            if authService.isLoggedIn {
                HomeView()
                    .environmentObject(authService)
            } else {
                ZStack {
                    if showLogin {
                        LoginView(
                            prefilledEmail: prefilledEmail,
                            onRegisterTap: {
                                withAnimation(.easeInOut) {
                                    showLogin = false
                                }
                            }
                        ) { email in
                            prefilledEmail = email
                            withAnimation(.easeInOut) {
                                showLogin = true
                            }
                        }
                        .environmentObject(authService)
                        .transition(.move(edge: .leading))
                    } else {
                        RegisterView(onRegisterSuccess: { email in
                            prefilledEmail = email
                            withAnimation(.easeInOut) {
                                showLogin = true
                            }
                        }, onLoginTap: {
                            withAnimation(.easeInOut) {
                                showLogin = true
                            }
                        })
                        .environmentObject(authService)
                        .transition(.move(edge: .trailing))
                    }
                }
            }
        }
        .onAppear {
            authService.checkAuthStatus()
        }
        .animation(.easeInOut(duration: AppConstants.UI.animationDuration), value: authService.isLoggedIn)
    }
}

#Preview {
    MainView()
} 