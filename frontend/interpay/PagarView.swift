//
//  PagarView.swift
//  interpay
//
//  Created by Diego Obed on 08/11/25.
//

import SwiftUI
import LocalAuthentication

public struct PayInformation {
    var localType: String
    var businessType: String
    var localAmount: Double
    var businessAmount: Double
}

struct SaldoRequest: Codable {
    let monto: Double
}

struct InterledgerRequest: Codable {
    let value: Double
}

struct PagarView: View {
    // --- ESTADOS ---
    @State private var payInfo = PayInformation(
        localType: "MXN",  // Tu moneda local
        businessType: "-", // La moneda que llegará
        localAmount: 0.0,
        businessAmount: 0.0
    )
    @EnvironmentObject var sendAmount: SendAmount
    private let currencyConverter = CurrencyConverter()
    @State private var isLoading = false
    @State private var rotationAngle: Double = 0
    @State private var showCancelAlert = false
    @EnvironmentObject var authManager: AuthManager
    @State private var paymentError: String? = nil
    
    var body: some View {
        VStack(spacing: 20) {
            
            if sendAmount.solicitudRecibida == nil {
                // --- 1. WAITING STATE ---
                VStack(spacing: 20) {
                    Spacer()
                    
                    // Animated icon
                    ZStack {
                        Circle()
                            .stroke(Color(red: 0/255, green: 157/255, blue: 136/255).opacity(0.2), lineWidth: 3)
                            .frame(width: 80, height: 80)
                        
                        Circle()
                            .trim(from: 0, to: 0.7)
                            .stroke(Color(red: 0/255, green: 157/255, blue: 136/255), lineWidth: 3)
                            .frame(width: 80, height: 80)
                            .rotationEffect(Angle(degrees: rotationAngle))
                        
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.system(size: 36))
                            .foregroundColor(Color(red: 0/255, green: 157/255, blue: 136/255))
                    }
                    .padding(.bottom, 8)
                    .onAppear {
                        withAnimation(
                            Animation.linear(duration: 1.5)
                                .repeatForever(autoreverses: false)
                        ) {
                            rotationAngle = 360
                        }
                    }
                    
                    // Main text
                    Text("Waiting for payment")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    // Subtitle
                    Text("Stand by while we receive the request")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    Spacer()
                }
                
            } else {
                // --- 2. SOLICITUD RECIBIDA ---
                // Comprueba si está cargando (convirtiendo) o si ya terminó
                
                if isLoading {
                    // --- 2A. LOADING / CONVERSION STATE ---
                    VStack(spacing: 20) {
                        Spacer()
                        
                        ZStack {
                            Circle()
                                .stroke(Color(red: 0/255, green: 157/255, blue: 136/255).opacity(0.2), lineWidth: 3)
                                .frame(width: 60, height: 60)
                            
                            Circle()
                                .trim(from: 0, to: 0.7)
                                .stroke(Color(red: 0/255, green: 157/255, blue: 136/255), lineWidth: 3)
                                .frame(width: 60, height: 60)
                                .rotationEffect(Angle(degrees: rotationAngle))
                            
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.system(size: 24))
                                .foregroundColor(Color(red: 0/255, green: 157/255, blue: 136/255))
                        }
                        .onAppear {
                            withAnimation(
                                Animation.linear(duration: 1.5)
                                    .repeatForever(autoreverses: false)
                            ) {
                                rotationAngle = 360
                            }
                        }
                        
                        Text("Calculating conversion")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text("Please wait a moment")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                    
                } else {
                    // --- 2B. PAYMENT READY STATE ---
                    VStack(spacing: 0) {
                        
                        ScrollView {
                            VStack(spacing: 20) {
                                // Header with cancel button
                                HStack {
                                    Spacer()
                                    
                                    Button(action: {
                                        showCancelAlert = true
                                    }) {
                                        HStack(spacing: 6) {
                                            Image(systemName: "xmark.circle.fill")
                                                .font(.system(size: 16))
                                            Text("Cancel")
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                        }
                                        .foregroundColor(.red)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(
                                            Capsule()
                                                .fill(Color.red.opacity(0.1))
                                        )
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.top, 10)
                                
                                // Header
                                VStack(spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 50))
                                        .foregroundColor(Color(red: 0/255, green: 157/255, blue: 136/255))
                                    
                                    Text("Payment Request Received")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                }
                                .padding(.bottom, 10)
                                
                                // Local Currency Card
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Image(systemName: "banknote")
                                            .foregroundColor(Color(red: 0/255, green: 157/255, blue: 136/255))
                                        Text("Pay in \(payInfo.localType)")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Text("$\(payInfo.localAmount, specifier: "%.2f")")
                                        .font(.system(size: 40, weight: .bold))
                                        .foregroundColor(.primary)
                                    
                                    Text(payInfo.localType)
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color(red: 0/255, green: 157/255, blue: 136/255))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 4)
                                        .background(Color(red: 0/255, green: 157/255, blue: 136/255).opacity(0.1))
                                        .cornerRadius(8)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(20)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color(.systemBackground))
                                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color(red: 0/255, green: 157/255, blue: 136/255).opacity(0.2), lineWidth: 1)
                                )
                                .padding(.horizontal, 20)
                                
                                // Exchange Icon
                                Image(systemName: "arrow.up.arrow.down.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.secondary)
                                    .padding(.vertical, 8)
                                
                                // Foreign Currency Card
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Image(systemName: "globe")
                                            .foregroundColor(.secondary)
                                        Text("Equivalent in \(payInfo.businessType)")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Text("$\(payInfo.businessAmount, specifier: "%.2f")")
                                        .font(.system(size: 32, weight: .semibold))
                                        .foregroundColor(.primary)
                                    
                                    Text(payInfo.businessType)
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 4)
                                        .background(Color(.systemGray5))
                                        .cornerRadius(8)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(20)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color(.systemGray6))
                                )
                                .padding(.horizontal, 20)
                                
                                Spacer(minLength: 100)
                            }
                        }
                        
                        // Payment Button (Fixed at bottom)
                        VStack(spacing: 0) {
                            Divider()
                            
                            Button(action: {
                                print("Payment processed.")
                                Task {
                                    await onPaymentButtonTapped()
                                }
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "lock.shield.fill")
                                    Text("Proceed to Payment")
                                        .fontWeight(.semibold)
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color(red: 0/255, green: 157/255, blue: 136/255))
                                .cornerRadius(14)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(Color(.systemBackground))
                        }
                    }
                }
            }
        }
        .alert("Cancel Payment Request", isPresented: $showCancelAlert) {
            Button("No, Keep It", role: .cancel) {}
            Button("Yes, Cancel", role: .destructive) {
                cancelPaymentRequest()
            }
        } message: {
            Text("Are you sure you want to cancel this payment request?")
        }
        .task(id: sendAmount.solicitudRecibida) {
            // Esto se dispara en cuanto 'solicitudRecibida' cambia
            guard let solicitud = sendAmount.solicitudRecibida else {
                // Opcional: Si la solicitud se borra, resetea la vista
                payInfo.businessAmount = 0.0
                payInfo.businessType = "-"
                payInfo.localAmount = 0.0
                return
            }
            // Inicia la conversión
            await actualizarMontos(from: solicitud)
        }
    }
    
    // Tu función de conversión (sin cambios)
    func actualizarMontos(from solicitud: SolicitudPago) async {
        isLoading = true
        
        payInfo.businessType = solicitud.currency
        payInfo.businessAmount = solicitud.amount
        
        do {
            if payInfo.businessType == payInfo.localType {
                // Caso 1: La moneda recibida es la misma que mi local (MXN -> MXN)
                payInfo.localAmount = payInfo.businessAmount
            } else {
                // Caso 2: Convertir moneda externa a mi local (USD -> MXN)
                let montoConvertido = try await currencyConverter.convert(
                    amount: payInfo.businessAmount,
                    from: payInfo.businessType,
                    to: payInfo.localType
                )
                payInfo.localAmount = montoConvertido
            }
        } catch {
            print("Error al convertir moneda: \(error.localizedDescription)")
            payInfo.localType = "Error"
            payInfo.businessType = "Error"
        }
        
        isLoading = false
    }
    
    // Función para cancelar la solicitud
    func cancelPaymentRequest() {
        guard let idToCancel = sendAmount.solicitudRecibida?.id else {
                // No hay solicitud que cancelar, solo resetea localmente
                sendAmount.solicitudRecibida = nil
                return
            }
        sendAmount.broadcastCancelMessage(for: idToCancel)
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            sendAmount.solicitudRecibida = nil
            payInfo = PayInformation(
                localType: "MXN",
                businessType: "-",
                localAmount: 0.0,
                businessAmount: 0.0
            )
        }
    }
    
    func authenticate() async {
            let context = LAContext()
            let reason = "Para autorizar tus pagos."

            do {
                // Intenta la autenticación
                let success = try await context.evaluatePolicy(
                    .deviceOwnerAuthenticationWithBiometrics,
                    localizedReason: reason
                )
                
                // Si tiene éxito...
                if success {
                    // ✅ Autenticación Exitosa
                    print("Payment processed.")
                    // Aquí va tu lógica de pago real
                } else {
                    // El usuario pudo haber fallado
                    print("Authentication failed.")
                }
            } catch {
                // ❌ Ocurrió un error
                print("Error: \(error.localizedDescription)")
            }
    }
    
    private func onPaymentButtonTapped() async {
            isLoading = true
            paymentError = nil
            
            // 1. Autenticar con Face ID
            let isAuthenticated = await authenticateWithBiometrics()
            guard isAuthenticated else {
                print("Autenticación biométrica fallida.")
                isLoading = false
                return
            }
            
            print("Autenticación exitosa. Procesando pago...")
            
            // 2. Procesar el pago
            do {
                try await processPayment()
                
                // 3. ¡Éxito! Limpia la vista
                print("¡Pago completado con éxito!")
                await MainActor.run {
                    isLoading = false
                    // Resetea la vista (vuelve a "Waiting...")
                    sendAmount.solicitudRecibida = nil
                }
                
            } catch {
                // 4. Manejar error
                print("Error al procesar el pago: \(error.localizedDescription)")
                await MainActor.run {
                    isLoading = false
                    paymentError = "No se pudo completar la transacción. \(error.localizedDescription)"
                }
            }
        }
        
        /// 1. Autentica al usuario con Face ID / Touch ID
        private func authenticateWithBiometrics() async -> Bool {
            let context = LAContext()
            let reason = "Confirma tu identidad para autorizar el pago."
            
            do {
                let success = try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)
                return success
            } catch {
                print("Error de Biometría: \(error.localizedDescription)")
                return false
            }
        }
        
        /// 2. Llama a las APIs para transferir el saldo
        private func processPayment() async throws {
            // 2a. Obtener los datos necesarios
            guard let payerID = authManager.user?.id_user else {
                throw AuthError.unknown // Error: No se encontró el ID del pagador
            }
            guard let solicitud = sendAmount.solicitudRecibida else {
                    throw AuthError.unknown // Error: No hay solicitud
            }
            
            let receiverID = solicitud.senderUserID
            
            // NOTA: Aquí decidimos qué montos transferir.
            // Asumimos que el PAGADOR paga el monto en SU moneda local (MXN).
            // Y el RECEPTOR recibe el monto en SU moneda original (USD, CAD, etc.).
            let amountToSubtract = payInfo.localAmount
            let amountToReceive = payInfo.businessAmount
            
            // 2b. Descontar saldo al pagador (tú)
            try await updateSaldo(
                userID: payerID,
                monto: amountToSubtract,
                type: "descontar"
            )
            
            // 2c. Agregar saldo al receptor (el cobrador)
            try await updateSaldo(
                userID: receiverID,
                monto: amountToReceive,
                type: "agregar"
            )
        }

        /// 3. Función de red reutilizable
        private func updateSaldo(userID: Int, monto: Double, type: String) async throws {
            let urlString = "http://192.168.1.109:3001/api/auth/saldo/\(type)/\(userID)"
            guard let url = URL(string: urlString) else {
                throw AuthError.unknown // URL inválida
            }
            
            // Prepara el body
            let body = SaldoRequest(monto: monto)
            let bodyData = try JSONEncoder().encode(body)
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = bodyData
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            print("Enviando \(type) de \(monto) para usuario \(userID)")
            
            // Ejecuta la llamada
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw AuthError.serverError // Error de servidor
            }
            
            // (Opcional: puedes decodificar una respuesta si la hay)
            print("Respuesta de \(type) exitosa.")
        }
    private func transaccion(monto: Double) async throws {
        let urlString = "http://192.168.1.109:3001/api/interledger/run-service"
        guard let url = URL(string: urlString) else {
            throw AuthError.unknown // URL inválida
        }
        
        // Prepara el body
        let body = InterledgerRequest(value: monto)
        let bodyData = try JSONEncoder().encode(body)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = bodyData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        
        // Ejecuta la llamada
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw AuthError.serverError // Error de servidor
        }
        
        // (Opcional: puedes decodificar una respuesta si la hay)
    }
}

#Preview {
    PagarView()
        .environmentObject(SendAmount())
}
