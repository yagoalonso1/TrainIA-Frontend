import SwiftUI

struct MenuView: View {
    @EnvironmentObject var authService: AuthService
    
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                VStack(spacing: geometry.size.height * 0.04) {
                    // Logo o título
                    VStack(spacing: geometry.size.height * 0.02) {
                        Image(systemName: "dumbbell.fill")
                            .font(.system(size: geometry.size.width * 0.18))
                            .foregroundColor(.accentColor)
                        
                        Text("TrainIA")
                            .font(.system(size: geometry.size.width * 0.09, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("Tu entrenador personal inteligente")
                            .font(.system(size: geometry.size.width * 0.045))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, geometry.size.height * 0.08)
                    
                    Spacer()
                    
                    // Botones
                    VStack(spacing: geometry.size.height * 0.02) {
                        // Botón de Registro (no funcional aún)
                        Button(action: {}) {
                            HStack {
                                Image(systemName: "person.badge.plus")
                                    .font(.title2)
                                Text("Crear Cuenta")
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(true)
                        .opacity(0.6)
                        
                        // Botón de Login
                        NavigationLink(destination: LoginView().navigationBarBackButtonHidden(true)) {
                            HStack {
                                Image(systemName: "person.circle")
                                    .font(.title2)
                                Text("Iniciar Sesión")
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, geometry.size.width * 0.08)
                    
                    Spacer()
                    
                    // Texto inferior
                    VStack(spacing: 8) {
                        Button(action: {}) {
                            Text("¿No tienes cuenta? Regístrate")
                                .font(.footnote)
                                .foregroundColor(.blue)
                                .underline()
                        }
                        .disabled(true)
                        .opacity(0.7)
                    }
                    .padding(.bottom, geometry.size.height * 0.04)
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .navigationBarHidden(true)
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
        .ignoresSafeArea(.keyboard)
    }
}

#Preview {
    MenuView()
        .environmentObject(AuthService())
} 