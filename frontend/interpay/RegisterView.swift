import SwiftUI

struct RegisterView: View {
    @Environment(\.dismiss) private var dismiss
    
    // Datos de registro
    @State private var fullName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var acceptTerms: Bool = false
    
    // UI State
    @State private var isSecurePassword: Bool = true
    @State private var isSecureConfirm: Bool = true
    @State private var isLoading: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var animateBG: Bool = false
    
    // Si quieres autenticar automáticamente tras crear cuenta
    var onRegistered: (() -> Void)? = nil
    
    var body: some View {
        ZStack {
            animatedBackground
            
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(Color.green.opacity(0.15))
                            .frame(width: 110, height: 110)
                            .blur(radius: 2)
                        Image(systemName: "person.crop.circle.badge.plus")
                            .font(.system(size: 64, weight: .semibold))
                            .foregroundStyle(.green)
                            .shadow(color: .green.opacity(0.5), radius: 12, x: 0, y: 0)
                    }
                    Text("Crear cuenta")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(.white)
                    Text("Únete a InterPay y comienza a cobrar y pagar fácil.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 24)
                
                // Formulario
                VStack(spacing: 16) {
                    field(title: "Nombre completo", text: $fullName, icon: "person.fill", keyboard: .namePhonePad)
                    
                    field(title: "Correo electrónico", text: $email, icon: "envelope.fill", keyboard: .emailAddress)
                    
                    secureField(title: "Contraseña", text: $password, isSecure: $isSecurePassword, icon: "lock.fill")
                    
                    secureField(title: "Confirmar contraseña", text: $confirmPassword, isSecure: $isSecureConfirm, icon: "lock.rotation")
                    
                    Toggle(isOn: $acceptTerms) {
                        Text("Acepto los Términos y Condiciones")
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .green))
                    
                    if showError {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .transition(.opacity)
                    }
                    
                    Button(action: registerAction) {
                        HStack {
                            if isLoading {
                                ProgressView().tint(.black)
                            } else {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.title3)
                            }
                            Text(isLoading ? "Creando cuenta..." : "Crear cuenta")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(colors: [.green, Color.green.opacity(0.7)],
                                           startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .foregroundColor(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .shadow(color: .green.opacity(0.4), radius: 10, x: 0, y: 6)
                    }
                    .disabled(!isValidForm || isLoading)
                    .opacity(isValidForm ? 1 : 0.6)
                    
                    Button {
                        dismiss()
                    } label: {
                        Text("Ya tengo cuenta, Iniciar sesión")
                            .font(.footnote.weight(.semibold))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding(.top, 4)
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color.white.opacity(0.06))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .stroke(Color.white.opacity(0.12), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.25), radius: 20, x: 0, y: 10)
                )
                .padding(.horizontal)
                
                Spacer()
                
                Text("© \(Calendar.current.component(.year, from: Date())) InterPay")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.bottom, 16)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
                animateBG = true
            }
        }
    }
    
    // Validación básica
    private var isValidForm: Bool {
        !fullName.trimmingCharacters(in: .whitespaces).isEmpty &&
        email.contains("@") && email.contains(".") &&
        password.count >= 6 &&
        password == confirmPassword &&
        acceptTerms
    }
    
    private func registerAction() {
        guard isValidForm else {
            withAnimation {
                showError = true
                errorMessage = "Revisa tus datos y acepta los términos."
            }
            return
        }
        showError = false
        isLoading = true
        // Simula creación de cuenta
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            isLoading = false
            onRegistered?()
            dismiss()
        }
    }
    
    // MARK: - Componentes
    private func field(title: String, text: Binding<String>, icon: String, keyboard: UIKeyboardType) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .foregroundColor(.green)
                TextField(title, text: text)
                    .keyboardType(keyboard)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .foregroundColor(.white)
            }
            .padding(14)
            .background(Color.white.opacity(0.06))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }
    
    private func secureField(title: String, text: Binding<String>, isSecure: Binding<Bool>, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .foregroundColor(.green)
                if isSecure.wrappedValue {
                    SecureField("••••••••", text: text)
                        .textContentType(.newPassword)
                        .foregroundColor(.white)
                } else {
                    TextField(title, text: text)
                        .textContentType(.newPassword)
                        .foregroundColor(.white)
                }
                Button {
                    isSecure.wrappedValue.toggle()
                } label: {
                    Image(systemName: isSecure.wrappedValue ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding(14)
            .background(Color.white.opacity(0.06))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }
    
    private var animatedBackground: some View {
        ZStack {
            LinearGradient(
                colors: [Color.black, Color.black.opacity(0.9)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            // ondas verdes suaves
            Circle()
                .fill(Color.green.opacity(animateBG ? 0.18 : 0.10))
                .frame(width: animateBG ? 360 : 300, height: animateBG ? 360 : 300)
                .blur(radius: 60)
                .offset(x: -120, y: -180)
                .animation(.easeInOut(duration: 6).repeatForever(autoreverses: true), value: animateBG)
            Circle()
                .fill(Color.green.opacity(animateBG ? 0.14 : 0.08))
                .frame(width: animateBG ? 400 : 340, height: animateBG ? 400 : 340)
                .blur(radius: 80)
                .offset(x: 140, y: 160)
                .animation(.easeInOut(duration: 6).repeatForever(autoreverses: true), value: animateBG)
        }
        .ignoresSafeArea()
    }
}
