import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authService: AuthService
    @State private var showingProfile = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Header con bienvenida
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("¡Hola, \(authService.currentUser?.name ?? "Usuario")!")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Text("Bienvenido a TrainIA")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        // Avatar en la esquina superior derecha
                        Button(action: { showingProfile = true }) {
                            if let url = URL(string: authService.currentUser?.avatarUrl ?? ""), !((authService.currentUser?.avatarUrl ?? "").isEmpty) {
                                AsyncImage(url: url) { image in
                                    image.resizable()
                                        .aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    Image(systemName: "person.crop.circle.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .foregroundColor(.accentColor)
                                }
                                .frame(width: 44, height: 44)
                                .clipShape(Circle())
                                .shadow(radius: 3)
                            } else {
                                Image(systemName: "person.crop.circle")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 44, height: 44)
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .accessibilityLabel("Perfil")
                    }
                    .padding(.horizontal, 20)
                    
                    // Información del usuario
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Email:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(authService.currentUser?.email ?? "")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        
                        HStack {
                            Text("Suscripción:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(authService.currentUser?.subscriptionStatus.capitalized ?? "")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(authService.currentUser?.subscriptionStatus == "premium" ? .green : .orange)
                        }
                    }
                    .padding(.horizontal, 20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.top, 20)
                
                // Contenido principal
                VStack(spacing: 20) {
                    // Tarjetas de funcionalidades
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        // Entrenamientos
                        NavigationCard(
                            title: "Entrenamientos",
                            icon: "dumbbell.fill",
                            color: .blue
                        ) {
                            // Funcionalidad pendiente
                        }
                        
                        // Rutinas
                        NavigationCard(
                            title: "Rutinas",
                            icon: "list.bullet.clipboard",
                            color: .green
                        ) {
                            // Funcionalidad pendiente
                        }
                        
                        // Progreso
                        NavigationCard(
                            title: "Progreso",
                            icon: "chart.line.uptrend.xyaxis",
                            color: .orange
                        ) {
                            // Funcionalidad pendiente
                        }
                        
                        // Configuración
                        NavigationCard(
                            title: "Perfil",
                            icon: "person.crop.circle",
                            color: .purple
                        ) {
                            showingProfile = true
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                Spacer()
                
                // Botón de logout
                Button(action: {
                    authService.logout()
                }) {
                    HStack {
                        Image(systemName: "arrow.right.square")
                        Text("Cerrar Sesión")
                    }
                    .foregroundColor(.red)
                    .font(.headline)
                }
                .padding(.bottom, 30)
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingProfile) {
                ProfileView()
                    .environmentObject(authService)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthService())
} 