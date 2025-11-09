import SwiftUI

struct ContentView: View {
    
    // --- 1. CAMBIO: Recibe los "cerebros" de la app ---
    // (Ya no los crea aquí)
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var sendAmount: SendAmount // <-- También lo recibes

    // (BORRA ESTO: @State private var isAuthenticated = false)
    // (BORRA ESTO: @StateObject private var sendAmount = SendAmount())
    
    // --- (El resto de tus @State y enum no cambia) ---
    @State private var selectedTab: Tab = .home
    
    enum Tab {
        case home
        case cobrar
        case pagar
        case mapa
        case perfil
        case sales
        case subscription
    }
    
    var body: some View {
        Group {
            // --- 2. CAMBIO: Comprueba usando el manager ---
            if authManager.isAuthenticated {
                
                TabView(selection: $selectedTab) {
                    HomeView()
                        .tag(Tab.home)
                        .tabItem { Label("Inicio", systemImage: "house.fill") }
                    
                    // --- 3. CAMBIO: Lógica de Roles ---
                    
                    // Muestra estas pestañas SÓLO si es "empresa"
                    // (Asegúrate de que "empresa" sea el string exacto de tu API)
                    if authManager.user?.rol == "negocio" {
                        CobrarView()
                            .tag(Tab.cobrar)
                            .tabItem { Label("Cobrar", systemImage: "arrow.down.circle") }
                        
                        SubscriptionView()
                            .tag(Tab.subscription)
                            .tabItem{ Label("Suscription", systemImage: "card") }
                        
                        SalesView()
                            .tag(Tab.sales)
                            .tabItem { Label("Analytics", systemImage: "chart.bar.xaxis") }
                    }
                    
                    // Muestra esta pestaña SÓLO si es "cliente"
                    if authManager.user?.rol == "cliente" {
                        PagarView()
                            .tag(Tab.pagar)
                            .tabItem { Label("Pagar", systemImage: "arrow.up.circle") }
                    }
                    
                    // (Estas pestañas son para todos)
                    NavigationStack {
                        MapView()
                    }
                    .tag(Tab.mapa)
                    .tabItem { Label("Mapa", systemImage: "map") }
                    
                    // --- 4. CAMBIO: Limpia la llamada a ProfileView ---
                    // (Ya no necesita el binding $isAuthenticated)
                    // (Tu ProfileView debe usar @EnvironmentObject var authManager)
                    ProfileView()
                        .tag(Tab.perfil)
                        .tabItem { Label("Perfil", systemImage: "person.crop.circle") }
                }
                // (El .environmentObject(sendAmount) se BORRA de aquí,
                //  ya que se inyecta desde el archivo principal)

            } else {
                // --- 5. CAMBIO: Limpia la llamada a LoginView ---
                LoginView()
            }
        }
    }
}
