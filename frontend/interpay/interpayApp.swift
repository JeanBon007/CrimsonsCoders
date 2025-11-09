import SwiftUI

@main
struct interpayApp: App {
    
    // 1. Crea tus "cerebros" (managers) aquí UNA SOLA VEZ
    // Usamos @StateObject para que vivan mientras la app esté viva.
    @StateObject private var authManager = AuthManager()
    @StateObject private var sendAmount = SendAmount()

    var body: some Scene {
        WindowGroup {
            
            // 2. Esta es tu vista principal (ContentView)
            ContentView()
            
                // 3. Inyéctales los managers para que ContentView
                //    y TODAS las demás vistas (Login, Pagar, Cobrar, Profile)
                //    puedan usarlos.
                .environmentObject(authManager)
                .environmentObject(sendAmount)
        }
    }
}
