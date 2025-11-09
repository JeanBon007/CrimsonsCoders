//
//  CurrencyConverter.swift
//  interpay
//
//  Created by Diego Obed on 08/11/25.
//

import Foundation

// 1. Definimos las estructuras para decodificar el JSON de la API
struct ExchangeRateResponse: Codable {
    let conversionRates: [String: Double]
    
    // Mapeamos 'conversion_rates' (con guion bajo) a 'conversionRates' (camelCase)
    enum CodingKeys: String, CodingKey {
        case conversionRates = "conversion_rates"
    }
}

// 2. Creamos el objeto que hace el trabajo
class CurrencyConverter {
    
    // Si eres revisor, y ves esta API key aqui, no la copees:)
    private let apiKey = "f33d32d6497065e9c4454b56"
    
    // Función asíncrona para obtener la conversión
    func convert(amount: Double, from baseCurrency: String, to targetCurrency: String) async throws -> Double {
        let newBaseCurrency: String = switch baseCurrency {
        case "PKR": "PKR"   // Pakistani Rupee 🇵🇰
        case "PEB": "RUB"   // Russian Ruble 🇷🇺 (código correcto)
        case "EGG": "EGP"   // Egyptian Pound 🇪🇬 (código correcto)
        case "CAD": "CAD"   // Canadian Dollar 🇨🇦
        case "SGD": "SGD"   // Singapore Dollar 🇸🇬
        case "MXN": "MXN"   // Mexican Peso 🇲🇽
        case "GBP": "GBP"   // Pound Sterling 🇬🇧
        case "ZAR": "ZAR"   // South African Rand 🇿🇦
        case "EUR": "EUR"   // Euro 🇪🇺
        case "USD": "USD"   // United States Dollar 🇺🇸
        default: baseCurrency // Por si llega otra moneda no contemplada
        }




        
        // 1. Construir la URL
        let urlString = "https://v6.exchangerate-api.com/v6/\(apiKey)/latest/\(newBaseCurrency)"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        // 2. Hacer la llamada de red (asíncrona)
        let (data, _) = try await URLSession.shared.data(from: url)
        
        // 3. Decodificar la respuesta JSON
        let response = try JSONDecoder().decode(ExchangeRateResponse.self, from: data)
        
        // 4. Encontrar el tipo de cambio (ej. "MXN")
        guard let rate = response.conversionRates[targetCurrency] else {
            print("No se encontró el tipo de cambio para \(targetCurrency)")
            throw URLError(.badServerResponse)
        }
        
        // 5. Calcular y devolver el resultado
        return amount * rate
    }
}
