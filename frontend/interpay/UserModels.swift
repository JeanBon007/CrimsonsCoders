//
//  UserModels.swift
//  interpay
//
//  Created by Diego Obed on 09/11/25.
//

import Foundation

// 1. Estructura para ENVIAR el JSON de login
struct LoginRequest: Codable {
    let email: String
    let password: String
}

// 2. Esta es la respuesta COMPLETA de la API
struct LoginResponse: Codable {
    let message: String
    let user: User
}

// 3. Este es el objeto 'user' anidado
struct User: Codable, Equatable {
    let id_user: Int
    let name: String
    let email: String
    let password: String
    let created_at: String
    let updated_at: String
    let lenguaje: String
    let type_money: String
    let rol: String // La propiedad clave
    let key_url: String
}

// 4. Un enum de error personalizado (también debe ser global)
enum AuthError: Error {
    case invalidCredentials
    case serverError
    case networkError(Error)
    case encodingError // Añadí este por si falla la codificación
    case unknown
}
