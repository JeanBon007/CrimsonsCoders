import SwiftUI

// MARK: - Modelos
struct Subscription {
    let isActive: Bool
    let planName: String
    let startDate: Date?
    let endDate: Date?
    let price: Double
    let billingPeriod: BillingPeriod
    
    enum BillingPeriod: String {
        case monthly = "Mensual"
        case yearly = "Anual"
    }
}

struct SubscriptionFeature: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
    let isActive: Bool
}

// MARK: - Vista Principal
struct SubscriptionView: View {
    @State private var subscription: Subscription = Subscription(
        isActive: false,
        planName: "Gratis",
        startDate: nil,
        endDate: nil,
        price: 0,
        billingPeriod: .monthly
    )
    
    @State private var selectedPlan: PlanType = .monthly
    @State private var showCancellationAlert = false
    
    enum PlanType {
        case monthly
        case yearly
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Estado actual
                    currentStatusCard
                    
                    if !subscription.isActive {
                        // Planes disponibles
                        plansSection
                        
                        // Características Premium
                        featuresSection
                        
                        // Botón de suscripción
                        subscribeButton
                    } else {
                        // Información de suscripción activa
                        activeSubscriptionDetails
                        
                        // Características activas
                        activeFeaturesSection
                        
                        // Botón de cancelación
                        cancelButton
                    }
                    
                    // Términos y condiciones
                    termsSection
                }
                .padding(.vertical)
            }
            .navigationTitle("Suscripción")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(.systemGroupedBackground))
        }
        .alert("Cancelar Suscripción", isPresented: $showCancellationAlert) {
            Button("No, mantener", role: .cancel) { }
            Button("Sí, cancelar", role: .destructive) {
                cancelSubscription()
            }
        } message: {
            Text("¿Estás seguro de que deseas cancelar tu suscripción Premium? Perderás acceso a todas las funciones premium.")
        }
    }
    
    // MARK: - Subvistas
    
    var currentStatusCard: some View {
        VStack(spacing: 16) {
            // Icono y estado
            ZStack {
                Circle()
                    .fill(subscription.isActive ?
                          LinearGradient(colors: [.yellow, .orange], startPoint: .topLeading, endPoint: .bottomTrailing) :
                          LinearGradient(colors: [.gray.opacity(0.3), .gray.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 80, height: 80)
                
                Image(systemName: subscription.isActive ? "crown.fill" : "lock.fill")
                    .font(.system(size: 36))
                    .foregroundColor(subscription.isActive ? .white : .gray)
            }
            
            VStack(spacing: 6) {
                Text(subscription.isActive ? "Premium Plan Active" : "Free Plan")
                    .font(.title2)
                    .fontWeight(.bold)
                
                if subscription.isActive, let endDate = subscription.endDate {
                    Text("Valid until \(formatDate(endDate))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } else {
                    Text("Upgrade your business with Premium")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        .padding(.horizontal)
    }
    
    var plansSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Elige tu plan")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            HStack(spacing: 16) {
                // Plan Mensual
                PlanCard(
                    isSelected: selectedPlan == .monthly,
                    title: "Mensual",
                    price: 149,
                    period: "mes",
                    savings: nil
                ) {
                    selectedPlan = .monthly
                }
                
                // Plan Anual
                PlanCard(
                    isSelected: selectedPlan == .yearly,
                    title: "Anual",
                    price: 1490,
                    period: "año",
                    savings: "Ahorra 17%"
                ) {
                    selectedPlan = .yearly
                }
            }
            .padding(.horizontal)
        }
    }
    
    var featuresSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Qué incluye Premium")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                FeatureRow(
                    icon: "map.fill",
                    iconColor: .yellow,
                    title: "Destaca en el Mapa",
                    description: "Tu negocio aparece con un ícono amarillo más grande y llamativo"
                )
                
                FeatureRow(
                    icon: "chart.bar.fill",
                    iconColor: .blue,
                    title: "Métricas Avanzadas",
                    description: "Accede a estadísticas detalladas de ventas y rendimiento"
                )
                
                FeatureRow(
                    icon: "star.fill",
                    iconColor: .orange,
                    title: "Prioridad en Búsquedas",
                    description: "Aparece primero cuando los clientes buscan artesanías"
                )
                
                FeatureRow(
                    icon: "megaphone.fill",
                    iconColor: .purple,
                    title: "Promociones Destacadas",
                    description: "Publica ofertas y eventos especiales"
                )
            }
            .padding(.horizontal)
        }
    }
    
    var subscribeButton: some View {
        Button(action: activateSubscription) {
            HStack {
                Image(systemName: "crown.fill")
                Text("Activar Premium - \(selectedPlan == .monthly ? "$149/mes" : "$1,490/año")")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .foregroundColor(.white)
            .background(
                LinearGradient(
                    colors: [.yellow, .orange],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
        }
        .padding(.horizontal)
    }
    
    var activeSubscriptionDetails: some View {
        VStack(spacing: 16) {
            // Detalles de pago
            VStack(alignment: .leading, spacing: 12) {
                Text("Detalles de tu suscripción")
                    .font(.headline)
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Precio")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("$\(Int(subscription.price))")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Facturación")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(subscription.billingPeriod.rawValue)
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                }
                
                Divider()
                
                if let startDate = subscription.startDate {
                    HStack {
                        Text("Inicio:")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(formatDate(startDate))
                            .fontWeight(.medium)
                    }
                    .font(.subheadline)
                }
                
                if let endDate = subscription.endDate {
                    HStack {
                        Text("Próxima renovación:")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(formatDate(endDate))
                            .fontWeight(.medium)
                    }
                    .font(.subheadline)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
        .padding(.horizontal)
    }
    
    var activeFeaturesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Funciones activas")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                ActiveFeatureRow(
                    icon: "map.fill",
                    iconColor: .yellow,
                    title: "Ícono Destacado",
                    status: "Activo"
                )
                
                ActiveFeatureRow(
                    icon: "chart.bar.fill",
                    iconColor: .blue,
                    title: "Métricas Avanzadas",
                    status: "Activo"
                )
                
                ActiveFeatureRow(
                    icon: "star.fill",
                    iconColor: .orange,
                    title: "Prioridad en Búsquedas",
                    status: "Activo"
                )
            }
            .padding(.horizontal)
        }
    }
    
    var cancelButton: some View {
        Button(action: { showCancellationAlert = true }) {
            Text("Cancelar Suscripción")
                .fontWeight(.medium)
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundColor(.red)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.red.opacity(0.5), lineWidth: 1)
                )
        }
        .padding(.horizontal)
    }
    
    var termsSection: some View {
        VStack(spacing: 8) {
            Text("• La suscripción se renueva automáticamente")
            Text("• Puedes cancelar en cualquier momento")
            Text("• Conservas el acceso hasta el final del período pagado")
        }
        .font(.caption)
        .foregroundColor(.secondary)
        .multilineTextAlignment(.center)
        .padding()
    }
    
    // MARK: - Funciones
    
    func activateSubscription() {
        let calendar = Calendar.current
        let startDate = Date()
        let endDate: Date
        let price: Double
        let billingPeriod: Subscription.BillingPeriod
        
        if selectedPlan == .monthly {
            endDate = calendar.date(byAdding: .month, value: 1, to: startDate) ?? startDate
            price = 149
            billingPeriod = .monthly
        } else {
            endDate = calendar.date(byAdding: .year, value: 1, to: startDate) ?? startDate
            price = 1490
            billingPeriod = .yearly
        }
        
        subscription = Subscription(
            isActive: true,
            planName: "Premium",
            startDate: startDate,
            endDate: endDate,
            price: price,
            billingPeriod: billingPeriod
        )
    }
    
    func cancelSubscription() {
        subscription = Subscription(
            isActive: false,
            planName: "Gratis",
            startDate: nil,
            endDate: nil,
            price: 0,
            billingPeriod: .monthly
        )
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "es_MX")
        return formatter.string(from: date)
    }
}

// MARK: - Componentes

struct PlanCard: View {
    let isSelected: Bool
    let title: String
    let price: Int
    let period: String
    let savings: String?
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                if let savings = savings {
                    Text(savings)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)
                }
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(isSelected ? .primary : .secondary)
                
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("$")
                        .font(.title3)
                    Text("\(price)")
                        .font(.system(size: 32, weight: .bold))
                }
                .foregroundColor(isSelected ? .orange : .primary)
                
                Text("por \(period)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? Color.orange : Color.gray.opacity(0.2), lineWidth: isSelected ? 2 : 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

struct FeatureRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .font(.system(size: 20))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct ActiveFeatureRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let status: String
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .font(.system(size: 18))
            }
            
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
            
            Spacer()
            
            HStack(spacing: 4) {
                Circle()
                    .fill(.green)
                    .frame(width: 8, height: 8)
                
                Text(status)
                    .font(.caption)
                    .foregroundColor(.green)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Color.green.opacity(0.1))
            .cornerRadius(8)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Preview
struct SubscriptionView_Previews: PreviewProvider {
    static var previews: some View {
        SubscriptionView()
    }
}
