import SwiftUI

struct MainView: View {
    @StateObject private var authService = AuthService()
    
    var body: some View {
        Group {
            if authService.isLoggedIn {
                HomeView()
                    .environmentObject(authService)
            } else {
                MenuView()
                    .environmentObject(authService)
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