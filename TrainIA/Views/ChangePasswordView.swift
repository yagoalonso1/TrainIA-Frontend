import SwiftUI

struct ChangePasswordView: View {
    @StateObject private var viewModel = ChangePasswordViewModel()
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authService: AuthService
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "lock.shield")
                            .font(.system(size: 48))
                            .foregroundColor(.blue)
                        
                        Text("Cambiar Contraseña")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Ingresa tu contraseña actual y la nueva contraseña que deseas usar")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    // Formulario-
                    VStack(spacing: 20) {
                        // Contraseña actual
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Contraseña actual")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            HStack {
                                if viewModel.showCurrentPassword {
                                    TextField("Ingresa tu contraseña actual", text: $viewModel.currentPassword)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .onChange(of: viewModel.currentPassword) { oldValue, newValue in
                                            // Solo limpiar errores si el campo es válido
                                            if viewModel.validateCurrentPassword() {
                                                viewModel.clearCurrentPasswordError()
                                            }
                                        }
                                } else {
                                    SecureField("Ingresa tu contraseña actual", text: $viewModel.currentPassword)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .onChange(of: viewModel.currentPassword) { oldValue, newValue in
                                            // Solo limpiar errores si el campo es válido
                                            if viewModel.validateCurrentPassword() {
                                                viewModel.clearCurrentPasswordError()
                                            }
                                        }
                                }
                                
                                Button(action: {
                                    viewModel.showCurrentPassword.toggle()
                                }) {
                                    Image(systemName: viewModel.showCurrentPassword ? "eye.slash" : "eye")
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            if !viewModel.errorCurrent.isEmpty {
                                Text(viewModel.errorCurrent)
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                        
                        // Nueva contraseña
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Nueva contraseña")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            HStack {
                                if viewModel.showNewPassword {
                                    TextField("Ingresa tu nueva contraseña", text: $viewModel.newPassword)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .onChange(of: viewModel.newPassword) { oldValue, newValue in
                                            viewModel.calculatePasswordStrength()
                                            // Solo limpiar errores si el campo es válido
                                            if viewModel.validateNewPassword() {
                                                viewModel.clearNewPasswordError()
                                            }
                                        }
                                } else {
                                    SecureField("Ingresa tu nueva contraseña", text: $viewModel.newPassword)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .onChange(of: viewModel.newPassword) { oldValue, newValue in
                                            viewModel.calculatePasswordStrength()
                                            // Solo limpiar errores si el campo es válido
                                            if viewModel.validateNewPassword() {
                                                viewModel.clearNewPasswordError()
                                            }
                                        }
                                }
                                
                                Button(action: {
                                    viewModel.showNewPassword.toggle()
                                }) {
                                    Image(systemName: viewModel.showNewPassword ? "eye.slash" : "eye")
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            // Indicador de fortaleza
                            if !viewModel.newPassword.isEmpty {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text("Fortaleza:")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        
                                        Text(viewModel.passwordStrengthLabel)
                                            .font(.caption)
                                            .fontWeight(.medium)
                                            .foregroundColor(viewModel.passwordStrengthColor)
                                        
                                        Spacer()
                                    }
                                    
                                    ProgressView(value: Double(viewModel.passwordStrength), total: 100)
                                        .progressViewStyle(LinearProgressViewStyle(tint: viewModel.passwordStrengthColor))
                                        .scaleEffect(y: 2)
                                }
                                .padding(.top, 4)
                            }
                            
                            if !viewModel.errorNew.isEmpty {
                                Text(viewModel.errorNew)
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                        
                        // Confirmar nueva contraseña
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Confirmar nueva contraseña")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            HStack {
                                if viewModel.showConfirmPassword {
                                    TextField("Confirma tu nueva contraseña", text: $viewModel.confirmPassword)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .onChange(of: viewModel.confirmPassword) { oldValue, newValue in
                                            // Solo limpiar errores si el campo es válido
                                            if viewModel.validateConfirmPassword() {
                                                viewModel.clearConfirmPasswordError()
                                            }
                                        }
                                } else {
                                    SecureField("Confirma tu nueva contraseña", text: $viewModel.confirmPassword)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .onChange(of: viewModel.confirmPassword) { oldValue, newValue in
                                            // Solo limpiar errores si el campo es válido
                                            if viewModel.validateConfirmPassword() {
                                                viewModel.clearConfirmPasswordError()
                                            }
                                        }
                                }
                                
                                Button(action: {
                                    viewModel.showConfirmPassword.toggle()
                                }) {
                                    Image(systemName: viewModel.showConfirmPassword ? "eye.slash" : "eye")
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            if !viewModel.errorConfirm.isEmpty {
                                Text(viewModel.errorConfirm)
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                        
                        // Error general
                        if !viewModel.generalError.isEmpty {
                            HStack {
                                Image(systemName: "exclamationmark.triangle")
                                    .foregroundColor(.red)
                                Text(viewModel.generalError)
                                    .font(.caption)
                                    .foregroundColor(.red)
                                Spacer()
                            }
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                        }
                        
                        // Mensaje de éxito
                        if viewModel.showSuccess {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("¡Contraseña cambiada exitosamente!")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(.green)
                                    Text("Serás redirigido al login por seguridad")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                            }
                            .padding()
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Botón de cambio de contraseña
                    Button(action: {
                        Task {
                            await viewModel.changePassword()
                        }
                    }) {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "lock.rotation")
                                Text("Cambiar Contraseña")
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.isFormValid ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .fontWeight(.semibold)
                    }
                    .disabled(!viewModel.isFormValid || viewModel.isLoading)
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
            .alert("Contraseña Cambiada", isPresented: $viewModel.showSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Tu contraseña ha sido cambiada exitosamente.")
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    ChangePasswordView()
} 