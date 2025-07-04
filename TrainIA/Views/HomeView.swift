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
                        
                        // Avatar del usuario
                        AsyncImage(url: URL(string: authService.currentUser?.avatarUrl ?? "")) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.accentColor)
                        }
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .onTapGesture {
                            showingProfile = true
                        }
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
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $showingProfile) {
            // Vista de perfil (placeholder)
            NavigationView {
                VStack(spacing: 20) {
                    Text("Perfil de Usuario")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    if let user = authService.currentUser {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Nombre: \(user.name)")
                            Text("Email: \(user.email)")
                            Text("Rol: \(user.role)")
                            Text("Suscripción: \(user.subscriptionStatus)")
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    Spacer()
                }
                .padding()
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Cerrar") {
                            showingProfile = false
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthService())
} 