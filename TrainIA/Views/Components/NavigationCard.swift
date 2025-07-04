import SwiftUI

struct NavigationCard: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 30))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

#Preview {
    NavigationCard(
        title: "Entrenamientos",
        icon: "dumbbell.fill",
        color: .blue
    ) {
        // Acción de ejemplo
    }
} 