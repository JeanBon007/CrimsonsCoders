import SwiftUI

struct Movement: Identifiable {
    let id = UUID()
    let title: String
    let date: Date
    let amount: Double
    let isIncome: Bool
    let icon: String
}

struct HomeView: View {
    @State private var balance: Double = 12500.75
    @State private var currency: String = "MXN"
    
    // Animaciones
    @State private var cardAppear = false
    @State private var cardBreath = false
    @State private var cardOffsetY: CGFloat = 0
    
    // Mock de últimos movimientos
    @State private var movements: [Movement] = [
        Movement(title: "Pago recibido", date: Date().addingTimeInterval(-3600), amount: 850.0, isIncome: true, icon: "arrow.down.left.circle.fill"),
        Movement(title: "Café El Centro", date: Date().addingTimeInterval(-7200), amount: -65.0, isIncome: false, icon: "cup.and.saucer.fill"),
        Movement(title: "Suscripción Música", date: Date().addingTimeInterval(-86400), amount: -129.0, isIncome: false, icon: "music.note.list"),
        Movement(title: "Transferencia", date: Date().addingTimeInterval(-172800), amount: 1500.0, isIncome: true, icon: "arrow.down.left.circle.fill"),
        Movement(title: "Restaurante", date: Date().addingTimeInterval(-259200), amount: -420.0, isIncome: false, icon: "fork.knife")
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                // GeometryReader para parallax vertical sutil en la tarjeta
                GeometryReader { geo in
                    let minY = geo.frame(in: .global).minY
                    Color.clear
                        .onChange(of: minY) { _, newValue in
                            // Parallax sutil: limitamos el movimiento
                            cardOffsetY = min(12, max(-12, newValue / 20))
                        }
                }
                .frame(height: 0) // lector invisible
                
                VStack(spacing: 20) {
                    balanceCard
                        .offset(y: cardOffsetY)
                        .scaleEffect(cardBreath ? 1.0 : 0.995) // “breathing” muy sutil
                        .opacity(cardAppear ? 1 : 0)
                        .offset(y: cardAppear ? 0 : 20)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: cardAppear)
                        .animation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true), value: cardBreath)
                        .onAppear {
                            cardAppear = true
                            // Iniciar “breathing” luego de la entrada
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                cardBreath = true
                            }
                        }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Últimos movimientos")
                            .font(.headline)
                            .padding(.horizontal, 4)
                        
                        VStack(spacing: 10) {
                            ForEach(movements) { move in
                                movementRow(move)
                                    .padding(.horizontal)
                            }
                        }
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color(.systemBackground))
                                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
                        )
                    }
                    .padding(.horizontal)
                }
                .padding(.top)
                .padding(.bottom, 24)
            }
            .navigationTitle("Inicio")
        }
    }
    
    private var balanceCard: some View {
        ZStack {
            // Capa base: negro grafito con gradiente verde profundo
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0.95),
                            Color.black.opacity(0.85)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay {
                    // Gradiente verde sutil “debajo” para dar profundidad
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(
                            RadialGradient(
                                colors: [Color.green.opacity(0.22), .clear],
                                center: .center,
                                startRadius: 10,
                                endRadius: 400
                            )
                        )
                        .blendMode(.plusLighter)
                }
                .shadow(color: Color.green.opacity(0.25), radius: 18, x: 0, y: 10)
                .overlay(
                    // Borde con brillo verde
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [Color.green.opacity(0.65), Color.green.opacity(0.15)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.2
                        )
                        .shadow(color: Color.green.opacity(0.35), radius: 8, x: 0, y: 0)
                )
                .modifier(Shimmer(active: cardAppear)) // shimmer muy sutil en el borde
            
            // Capa metálica: “brushed metal” + franja diagonal brillante
            metallicLayer
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .allowsHitTesting(false)
            
            // Contenido
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Saldo disponible")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.85))
                        Text("$\(balance, specifier: "%.2f") \(currency)")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(.white)
                            .contentTransition(.numericText())
                            .shadow(color: Color.green.opacity(0.35), radius: 6, x: 0, y: 0)
                    }
                    Spacer()
                    // Icono con “glow” verde
                    Image(systemName: "creditcard.fill")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(Color.green.opacity(0.95))
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.white.opacity(0.06))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(Color.green.opacity(0.35), lineWidth: 1)
                                )
                        )
                        .shadow(color: Color.green.opacity(0.45), radius: 10, x: 0, y: 0)
                        .rotationEffect(.degrees(cardBreath ? 0 : -1.5))
                        .animation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true), value: cardBreath)
                }
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Titular")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.75))
                        Text("Diego Obed")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .fontWeight(.semibold)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Terminación")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.75))
                        Text("•••• 1234")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .fontWeight(.semibold)
                    }
                }
                .padding(.top, 4)
            }
            .padding(20)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 180)
        .padding(.horizontal)
    }
    
    // Capa metálica: combinación de rayas diagonales suaves + “brushed” horizontal
    private var metallicLayer: some View {
        ZStack {
            // Brushed metal horizontal (líneas finas con baja opacidad)
            GeometryReader { proxy in
                let size = proxy.size
                Canvas { context, _ in
                    let lineSpacing: CGFloat = 3
                    for y in stride(from: 0.0, through: size.height, by: lineSpacing) {
                        var path = Path()
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: size.width, y: y))
                        context.stroke(path, with: .color(.white.opacity(0.03)), lineWidth: 1)
                    }
                }
            }
            .opacity(0.7)
            
            // Franja diagonal brillante (efecto “metal glossy”)
            LinearGradient(
                colors: [
                    .clear,
                    Color.white.opacity(0.12),
                    Color.white.opacity(0.24),
                    Color.white.opacity(0.12),
                    .clear
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .blendMode(.screen)
            .rotationEffect(.degrees(0))
            .mask(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .padding(0)
            )
            .opacity(0.7)
            
            // Sutil patrón diagonal para profundidad
            diagonalStripes
                .opacity(0.10)
        }
    }
    
    // Rayas diagonales muy sutiles para textura del fondo
    private var diagonalStripes: some View {
        GeometryReader { proxy in
            let size = proxy.size
            Canvas { context, _ in
                let stripeWidth: CGFloat = 8
                let spacing: CGFloat = 22
                let total = Int((size.width + size.height) / spacing)
                
                for i in 0...total {
                    var path = Path()
                    let x = CGFloat(i) * spacing - size.height
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x + size.height, y: size.height))
                    context.stroke(path, with: .color(.white.opacity(0.06)), lineWidth: stripeWidth)
                }
            }
            .rotationEffect(.degrees(-18))
        }
        .allowsHitTesting(false)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
    
    private func movementRow(_ move: Movement) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(move.isIncome ? Color.green.opacity(0.15) : Color.red.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: move.icon)
                    .foregroundColor(move.isIncome ? .green : .red)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(move.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(formattedDate(move.date))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text("\(move.isIncome ? "+" : "")\(currencySymbol(for: currency))\(abs(move.amount), specifier: "%.2f")")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(move.isIncome ? .green : .primary)
        }
        .padding(.vertical, 8)
    }
    
    private func currencySymbol(for code: String) -> String {
        switch code.uppercased() {
        case "MXN": return "$"
        case "USD": return "$"
        case "EUR": return "€"
        case "GBP": return "£"
        default: return ""
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_MX")
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// Modifier para shimmer muy sutil
struct Shimmer: ViewModifier {
    var active: Bool
    
    func body(content: Content) -> some View {
        content
            .overlay {
                if active {
                    LinearGradient(colors: [
                        Color.white.opacity(0.0),
                        Color.white.opacity(0.22),
                        Color.white.opacity(0.0)
                    ], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .blendMode(.screen)
                    .mask(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(.linearGradient(colors: [.white, .white, .clear], startPoint: .leading, endPoint: .trailing))
                    )
                    .allowsHitTesting(false)
                }
            }
    }
}
