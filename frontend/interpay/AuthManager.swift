//
//  AuthManager.swift
//  interpay
//
//  Created by Diego Obed on 09/11/25.
//

import Foundation


import Combine // Necesario para ObservableObject

// El manager se encarga de conectar la lógica de UI con el Keychain
class AuthManager: ObservableObject {
    
    /**
     Esta variable 'user' es la ÚNICA fuente de verdad.
     - Si es 'nil', el usuario NO está autenticado.
     - Si tiene un 'User', el usuario SÍ está autenticado.
     El '@Published' avisa a toda tu app (como tu 'Group' en ContentView)
     cada vez que este valor cambia.
     */
    @Published var user: User? = nil
    
    // Una variable 'computada' para que sea fácil comprobar
    // si estamos logueados o no (ej. 'if authManager.isAuthenticated')
    var isAuthenticated: Bool {
        user != nil
    }
    
    // Constantes para los servicios del Keychain.
    // Es bueno guardarlos para no escribirlos mal.
    private let userKeychainService = "com.tu-app.interpay.user"
    private let lastUserEmailKey = "lastUserEmail" // Para UserDefaults

    init() {
        // Al iniciar la app, intenta "recordar" al último usuario
        loadUserFromKeychain()
    }
    
    // --- LÓGICA DE LOGIN ---
    // LoginView llama a esta función DESPUÉS de que la API responde con éxito
    func login(user: User) {
        do {
            // 1. Codifica el objeto User a Data (JSON)
            let userData = try JSONEncoder().encode(user)
            
            // 2. Guarda ese Data en el Keychain
            //    usando el email como 'account' (la llave única)
            try KeychainHelper.save(
                data: userData,
                service: userKeychainService,
                account: user.email
            )
            
            // 3. Guarda el email en UserDefaults (que no es seguro)
            //    Solo para saber a quién buscar la próxima vez que se abra la app.
            UserDefaults.standard.setValue(user.email, forKey: lastUserEmailKey)
            
            // 4. Publica el usuario en el hilo principal.
            //    Esto es lo que hace que la UI cambie a la pantalla de 'TabView'.
            DispatchQueue.main.async {
                self.user = user
            }
            
        } catch {
            print("AuthManager Error (Login): \(error.localizedDescription)")
        }
    }
    
    // --- LÓGICA DE LOGOUT ---
    // ProfileView llamará a esta función
    func logout() {
        // 1. Asegúrate de que haya un email para saber qué borrar
        guard let email = user?.email else { return }
        
        // 2. Borra al usuario del Keychain
        KeychainHelper.delete(service: userKeychainService, account: email)
        
        // 3. Borra la llave de UserDefaults
        UserDefaults.standard.removeObject(forKey: lastUserEmailKey)
        
        // 4. Publica el cambio (user = nil) en el hilo principal.
        //    Esto es lo que hace que la UI regrese a 'LoginView'.
        DispatchQueue.main.async {
            self.user = nil
        }
    }
    
    // --- LÓGICA DE "RECORDAR SESIÓN" ---
    // Se llama solo 1 vez, cuando se crea el AuthManager
    func loadUserFromKeychain() {
        // 1. Revisa si guardamos un email la última vez
        guard let email = UserDefaults.standard.string(forKey: lastUserEmailKey) else {
            print("AuthManager: No hay un último usuario guardado. Se requiere login.")
            return
        }
        
        // 2. Intenta cargar los datos del usuario desde el Keychain usando ese email
        guard let userData = KeychainHelper.load(service: userKeychainService, account: email) else {
            print("AuthManager: Se encontró email pero no datos en Keychain.")
            return
        }
        
        // 3. Intenta decodificar los datos de vuelta a un objeto User
        do {
            let loadedUser = try JSONDecoder().decode(User.self, from: userData)
            
            // 4. ¡Éxito! Inicia la sesión
            DispatchQueue.main.async {
                self.user = loadedUser
                print("AuthManager: Sesión restaurada para \(loadedUser.name)")
            }
        } catch {
            print("AuthManager: Error al decodificar usuario del Keychain. \(error)")
        }
    }
}
