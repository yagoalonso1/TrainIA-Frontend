import SwiftUI

struct MainView: View {
    @StateObject private var authService = AuthService()
    @State private var showLogin = true
    @State private var prefilledEmail: String? = nil
    
    var body: some View {
        Group {
            if authService.isCheckingAuth {
                // Pantalla de carga (Splash)
                VStack {
                    Spacer()
                    Image(systemName: "dumbbell.fill")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.accentColor)
                        .padding(.bottom, 16)
                    ProgressView("Cargando...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .accentColor))
                        .padding()
                    Spacer()
                }
                .background(Color(.systemBackground).ignoresSafeArea())
            } else if authService.isLoggedIn {
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