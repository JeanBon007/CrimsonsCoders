//
//  CobrarView.swift
//  interpay
//
//  Created by Diego Obed on 08/11/25.
//

import SwiftUI
import MultipeerConnectivity

struct CobrarView: View {
    @State private var amount: String = ""
    @State private var selectedCurrency: Currency = .MXN
    @State private var showCurrencyPicker: Bool = false
    // @State private var showRequestSent: Bool = false
    @FocusState private var isAmountFocused: Bool
    @EnvironmentObject var sendAmount: SendAmount
    @EnvironmentObject var authManager: AuthManager
    
    enum Currency: String, CaseIterable {
        case PKR = "PKR"
        case PEB = "PEB"
        case EGG = "EGG"
        case CAD = "CAD"
        case SGD = "SGD"
        case MXN = "MXN"
        case GBP = "GBP"
        case ZAR = "ZAR"
        case EUR = "EUR"
        case USD = "USD"
        
        var symbol: String {
            switch self {
            case .PKR: return "₨"
            case .PEB: return "₽"
            case .EGG: return "E£"
            case .CAD: return "$"
            case .SGD: return "$"
            case .MXN: return "$"
            case .GBP: return "£"
            case .ZAR: return "R"
            case .EUR: return "€"
            case .USD: return "$"
            }
        }
        
        var flag: String {
            switch self {
            case .PKR: return "🇵🇰"
            case .PEB: return "🇷🇺"
            case .EGG: return "🇪🇬"
            case .CAD: return "🇨🇦"
            case .SGD: return "🇸🇬"
            case .MXN: return "🇲🇽"
            case .GBP: return "🇬🇧"
            case .ZAR: return "🇿🇦"
            case .EUR: return "🇪🇺"
            case .USD: return "🇺🇸"
            }
        }
        
        var name: String {
            switch self {
            case .PKR: return "Pakistani Rupee"
            case .PEB: return "Russian Ruble"
            case .EGG: return "Egyptian Pound"
            case .CAD: return "Canadian Dollar"
            case .SGD: return "Singapore Dollar"
            case .MXN: return "Mexican Peso"
            case .GBP: return "British Pound"
            case .ZAR: return "South African Rand"
            case .EUR: return "Euro"
            case .USD: return "US Dollar"
            }
        }
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(.systemBackground),
                    Color(red: 0/255, green: 157/255, blue: 136/255).opacity(0.03)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "arrow.down.circle.fill")
                        .font(.system(size: 44))
                        .foregroundColor(Color(red: 0/255, green: 157/255, blue: 136/255))
                    
                    Text("Request Payment")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                .padding(.top, 50)
                .padding(.bottom, 30)
                
                // Main content area
                ScrollView {
                    VStack(spacing: 24) {
                        // Currency selector
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                showCurrencyPicker = true
                                isAmountFocused = false
                            }
                        }) {
                            HStack(spacing: 16) {
                                // Flag circle
                                ZStack {
                                    Circle()
                                        .fill(Color(red: 0/255, green: 157/255, blue: 136/255).opacity(0.1))
                                        .frame(width: 56, height: 56)
                                    
                                    Text(selectedCurrency.flag)
                                        .font(.system(size: 28))
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(selectedCurrency.rawValue)
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                    
                                    Text(selectedCurrency.name)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.down.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(Color(red: 0/255, green: 157/255, blue: 136/255))
                                    .rotationEffect(.degrees(showCurrencyPicker ? 180 : 0))
                            }
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color(red: 0/255, green: 157/255, blue: 136/255).opacity(0.15), lineWidth: 1)
                            )
                        }
                        .padding(.horizontal, 24)
                        
                        // Amount input card
                        VStack(spacing: 16) {
                            Text("Enter Amount")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            HStack(alignment: .center, spacing: 8) {
                                Text(selectedCurrency.symbol)
                                    .font(.system(size: 56, weight: .semibold))
                                    .foregroundColor(Color(red: 0/255, green: 157/255, blue: 136/255).opacity(0.6))
                                
                                TextField("0", text: $amount)
                                    .font(.system(size: 64, weight: .bold))
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.leading)
                                    .focused($isAmountFocused)
                                    .foregroundColor(.primary)
                                    .frame(maxWidth: .infinity)
                            }
                            
                            // Currency badge
                            HStack {
                                Spacer()
                                Text(selectedCurrency.rawValue)
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(red: 0/255, green: 157/255, blue: 136/255))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        Capsule()
                                            .fill(Color(red: 0/255, green: 157/255, blue: 136/255).opacity(0.1))
                                    )
                            }
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color(.systemBackground))
                                .shadow(color: Color.black.opacity(0.06), radius: 15, x: 0, y: 4)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(
                                    isAmountFocused ?
                                    Color(red: 0/255, green: 157/255, blue: 136/255).opacity(0.3) :
                                    Color.clear,
                                    lineWidth: 2
                                )
                        )
                        .padding(.horizontal, 24)
                        
                        // Quick amount suggestions
                        if amount.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Quick amounts")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.secondary)
                                    .padding(.leading, 4)
                                
                                HStack(spacing: 12) {
                                    QuickAmountButton(amount: "10", currency: selectedCurrency) {
                                        amount = "10"
                                    }
                                    QuickAmountButton(amount: "50", currency: selectedCurrency) {
                                        amount = "50"
                                    }
                                    QuickAmountButton(amount: "100", currency: selectedCurrency) {
                                        amount = "100"
                                    }
                                    QuickAmountButton(amount: "500", currency: selectedCurrency) {
                                        amount = "500"
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                    .padding(.bottom, 120)
                }
                
                Spacer()
            }
            
            // Fixed bottom button
            VStack {
                Spacer()
                
                VStack(spacing: 0) {
                    Divider()
                    
                    Button(action: {
                        cobrarAction()
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.title3)
                            Text("Generate Request")
                                .fontWeight(.semibold)
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(
                                    amount.isEmpty ?
                                    Color.gray.opacity(0.5) :
                                    Color(red: 0/255, green: 157/255, blue: 136/255)
                                )
                        )
                        .shadow(
                            color: amount.isEmpty ?
                            Color.clear :
                            Color(red: 0/255, green: 157/255, blue: 136/255).opacity(0.3),
                            radius: 10,
                            x: 0,
                            y: 4
                        )
                    }
                    .disabled(amount.isEmpty)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .background(Color(.systemBackground))
                }
            }
            
            // Currency Picker Overlay
            if showCurrencyPicker {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            showCurrencyPicker = false
                        }
                    }
                
                VStack {
                    Spacer()
                    
                    VStack(spacing: 0) {
                        // Drag indicator
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.secondary.opacity(0.3))
                            .frame(width: 40, height: 5)
                            .padding(.top, 12)
                        
                        // Header
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Select Currency")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                
                                Text("\(Currency.allCases.count) currencies available")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    showCurrencyPicker = false
                                }
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                                    .font(.title2)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        
                        Divider()
                        
                        // Currency list
                        ScrollView {
                            LazyVStack(spacing: 0) {
                                ForEach(Currency.allCases, id: \.self) { currency in
                                    CurrencyRow(
                                        currency: currency,
                                        isSelected: selectedCurrency == currency
                                    ) {
                                        withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                                            selectedCurrency = currency
                                            showCurrencyPicker = false
                                        }
                                    }
                                }
                            }
                            .padding(.bottom, 100)
                        }
                        .frame(maxHeight: 450)
                    }
                    .background(Color(.systemBackground))
                    .cornerRadius(24, corners: [.topLeft, .topRight])
                    .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: -5)
                    .transition(.move(edge: .bottom))
                }
                .ignoresSafeArea(edges: .bottom)
            }
            
            // Request Sent Overlay
            if let sentRequest = sendAmount.solicitudEnviada {
                RequestSentView(
                    amount: String(sentRequest.amount),
                    currency: sentRequest.currency,
                    
                    onCancel: {
                        sendAmount.sendCancelRequest()
                    }
                )
                .environmentObject(sendAmount)
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
            }        }
        .onTapGesture {
            isAmountFocused = false
        }
    }
    
    private func cobrarAction() {
        guard let amountValue = Double(amount) else { return }
        guard let myUserID = authManager.user?.id_user else {
                    print("Error: No se pudo encontrar el ID del usuario para cobrar.")
                    return
                }
        isAmountFocused = false
        // Enviar la solicitud
        print("Cobrando \(selectedCurrency.symbol)\(amountValue) \(selectedCurrency.rawValue)")
        sendAmount.sendPaymentRequest(amount: amountValue, currency: selectedCurrency.rawValue, senderID: myUserID)
    }
}

// Request Sent View Component
struct RequestSentView: View {
    @State private var pulseAnimation: Bool = false
    @State private var rotationAngle: Double = 0
    @State private var showCheckmark: Bool = false
    @State private var dotsCount: Int = 0
    @State private var timer: Timer?
    @EnvironmentObject var sendAmount: SendAmount
    
    let amount: String
    let currency: String
    let onCancel: () -> Void
    
    var body: some View {
        ZStack {
            // Background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                // Animated icon
                ZStack {
                    // Outer pulse circles
                    ForEach(0..<3) { index in
                        Circle()
                            .stroke(Color(red: 0/255, green: 157/255, blue: 136/255).opacity(0.3), lineWidth: 2)
                            .frame(width: 120 + CGFloat(index * 40), height: 120 + CGFloat(index * 40))
                            .scaleEffect(pulseAnimation ? 1.3 : 0.8)
                            .opacity(pulseAnimation ? 0 : 0.8)
                            .animation(
                                Animation.easeOut(duration: 2.0)
                                    .repeatForever(autoreverses: false)
                                    .delay(Double(index) * 0.3),
                                value: pulseAnimation
                            )
                    }
                    
                    // Main circle with rotation
                    Circle()
                        .fill(Color(red: 0/255, green: 157/255, blue: 136/255))
                        .frame(width: 120, height: 120)
                        .shadow(color: Color(red: 0/255, green: 157/255, blue: 136/255).opacity(0.4), radius: 20, x: 0, y: 10)
                    
                    // Rotating border
                    Circle()
                        .trim(from: 0, to: 0.7)
                        .stroke(Color.white.opacity(0.5), lineWidth: 3)
                        .frame(width: 110, height: 110)
                        .rotationEffect(.degrees(rotationAngle))
                    
                    // Icon
                    if showCheckmark {
                        Image(systemName: "checkmark")
                            .font(.system(size: 50, weight: .bold))
                            .foregroundColor(.white)
                            .transition(.scale.combined(with: .opacity))
                    } else {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                    }
                }
                .padding(.bottom, 20)
                .onAppear {
                    pulseAnimation = true
                    
                    withAnimation(
                        Animation.linear(duration: 2.0)
                            .repeatForever(autoreverses: false)
                    ) {
                        rotationAngle = 360
                    }
                    
                    // Simulate checkmark after 1.5 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                            showCheckmark = true
                        }
                    }
                    
                    // Start dots animation
                    timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                        dotsCount = (dotsCount + 1) % 3
                    }
                }
                .onDisappear {
                    timer?.invalidate()
                    timer = nil
                }
                
                // Content card
                VStack(spacing: 24) {
                    VStack(spacing: 12) {
                        Text(showCheckmark ? "Request Sent!" : "Sending Request")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text(showCheckmark ? "Waiting for payment" : "Please wait")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        // Animated dots
                        if !showCheckmark {
                            HStack(spacing: 4) {
                                ForEach(0..<3) { index in
                                    Circle()
                                        .fill(Color(red: 0/255, green: 157/255, blue: 136/255))
                                        .frame(width: 8, height: 8)
                                        .opacity(dotsCount == index ? 1.0 : 0.3)
                                }
                            }
                        }
                    }
                    
                    Divider()
                        .padding(.horizontal)
                    
                    // Amount info
                    VStack(spacing: 12) {
                        HStack {
                            Text("Requested Amount")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        
                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            Text(currency)
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(Color(red: 0/255, green: 157/255, blue: 136/255))
                            
                            Text(amount)
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    if showCheckmark {
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "clock.fill")
                                    .foregroundColor(Color(red: 0/255, green: 157/255, blue: 136/255))
                                Text("The other user will receive your request shortly")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(red: 0/255, green: 157/255, blue: 136/255).opacity(0.1))
                        )
                        .padding(.horizontal, 20)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                    
                    // Cancel button
                    Button(action:{
                        // 1. Esto llama a la NUEVA función que acabamos de crear en SendAmount
                        sendAmount.sendCancelRequest()
                            
                        // 2. Esto ejecuta el cierre de la vista (como ya lo hacía)
                        onCancel()
                    }
                    ) {
                        Text("Cancel Request")
                            .font(.headline)
                            .foregroundColor(Color(red: 0/255, green: 157/255, blue: 136/255))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(red: 0/255, green: 157/255, blue: 136/255), lineWidth: 2)
                            )
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 8)
                }
                .padding(.vertical, 28)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(.systemBackground))
                )
                .padding(.horizontal, 24)
                
                Spacer()
            }
        }
    }
}

// Quick amount button component
struct QuickAmountButton: View {
    let amount: String
    let currency: CobrarView.Currency
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(currency.symbol)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text(amount)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Currency row component
struct CurrencyRow: View {
    let currency: CobrarView.Currency
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Flag circle
                ZStack {
                    Circle()
                        .fill(
                            isSelected ?
                            Color(red: 0/255, green: 157/255, blue: 136/255).opacity(0.15) :
                            Color(.systemGray6)
                        )
                        .frame(width: 48, height: 48)
                    
                    Text(currency.flag)
                        .font(.system(size: 24))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(currency.rawValue)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(currency.name)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color(red: 0/255, green: 157/255, blue: 136/255))
                        .font(.title3)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(
                isSelected ?
                Color(red: 0/255, green: 157/255, blue: 136/255).opacity(0.05) :
                Color.clear
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Extension for corner radius
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    CobrarView()
        .environmentObject(SendAmount())
}
