# InterPay

InterPay es una app para iOS construida con SwiftUI que facilita pagos cercanos entre personas y comercios, con persistencia segura de sesión (Keychain), conversión de divisas, registro de usuarios, un perfil con preferencias, suscripciones y un panel de ventas con analítica visual (Charts). Además integra Multipeer Connectivity para descubrir y comunicarse con dispositivos cercanos al momento de enviar/cancelar solicitudes de pago.

## Requisitos

- Xcode 15 o superior
- Swift 5.9 o superior
- iOS 16.0 o superior
- Conectividad a internet si usas la conversión de divisas (ExchangeRate API)
- Permisos de red local y Bluetooth/Wi‑Fi para Multipeer Connectivity en dispositivos reales

## Tecnologías y Arquitectura

- UI: SwiftUI
- Arquitectura: MVVM ligera
  - AuthManager como fuente de verdad de autenticación (@Published user)
  - Vistas reactivas con @EnvironmentObject
- Persistencia de sesión:
  - Keychain (JSON del usuario)
  - UserDefaults (solo guarda el último email para lookup)
- Concurrencia:
  - URLSession con async/await (CurrencyConverter)
  - Publicaciones en main thread para cambios de UI
- Conectividad cercana:
  - MultipeerConnectivity (descubrimiento, invitación, sesión, envío/recepción de datos)
- Analítica:
  - Charts (framework nativo de Apple)
- Modelado:
  - User, LoginRequest, LoginResponse, AuthError
  - PaymentMessage y SolicitudPago para mensajería P2P
- Dependencias externas:
  - No hay paquetes de terceros; todo es del SDK de Apple

## Estructura del Proyecto

- AuthManager.swift
  - @Published var user: User?
  - login(user:), logout(), loadUserFromKeychain()
  - Integra KeychainHelper y UserDefaults
- KeychainHelper.swift
  - save(data:service:account:)
  - load(service:account:)
  - delete(service:account:)
  - Envoltorio de Security.framework para credenciales/usuario
- UserModels.swift
  - LoginRequest, LoginResponse, User (Codable, Equatable)
  - AuthError
- ProfileView.swift
  - Lee AuthManager vía @EnvironmentObject
  - Muestra datos del usuario (name/email), preferencias (divisa, biometría, tema), ayuda y logout
  - Sincroniza preferredCurrency con user.type_money en onAppear
- RegisterView.swift
  - Registro con validaciones básicas y UI animada
  - Campos: nombre, email, contraseña y términos
  - Callback opcional onRegistered
- SalesView.swift
  - Analítica de ventas con datos mock
  - Selector Semana/Mes, totales, promedios, gráfica (Line + Area), lista por categoría
- SubscriptionView.swift
  - Flujo de suscripción simulado (mensual/anual), activación, cancelación y features premium
- SendAmount.swift
  - Lógica MultipeerConnectivity
  - Descubrimiento y publicidad de peers
  - Envío y cancelación de PaymentMessage (request/cancel)
  - Manejo de sesión y peers conectados
- CurrencyConverter.swift
  - Conversión de divisas con URLSession async/await
  - Manejo de códigos de moneda y parseo de ExchangeRate API

Nota: El punto de entrada @main (App.swift/ContentView.swift) y LoginView no fueron incluidos en los fragmentos mostrados, pero se asume que inyectan AuthManager como .environmentObject y controlan el flujo autenticado/no autenticado.

## Instalación

1. Clonar el repositorio:
   git clone https://github.com/tu-org/interpay.git
   cd interpay

2. Abrir en Xcode:
   - Abre el .xcodeproj (o .xcworkspace si lo hubiere)

3. Dependencias:
   - Charts y MultipeerConnectivity son parte del SDK de iOS 16+
   - No se requiere CocoaPods ni SPM externos

4. Configuración de API (opcional para divisas):
   - En CurrencyConverter.swift se utiliza una API key de ejemplo
   - Para producción, muévela a .xcconfig o mecanismo seguro (no hardcode)

## Ejecución

- Selecciona el esquema de la app
- Elige un simulador o dispositivo (iOS 16+)
- Presiona Run (⌘R)

Para probar MultipeerConnectivity:
- Usa dos dispositivos reales o dos simuladores (con ciertas limitaciones)
- Asegúrate de que ambos ejecuten la app simultáneamente y estén en la misma red/local
- Observa en consola el descubrimiento, invitaciones y estado de sesión

## Pruebas

- Si añades suites con Swift Testing o XCTest:
  - Product > Test (⌘U)
- Recomendado:
  - Unit tests para AuthManager (login/logout/load)
  - Tests de validación de formularios
  - Tests de formateo y helpers de divisas

## Estándares de Código

- Swift 5.9+, SwiftUI, preferencia por async/await
- Actualizaciones de UI en MainActor/DispatchQueue.main
- Nomenclatura clara, documentación en tipos públicos
- Convencional Commits (feat:, fix:, chore:, refactor:, test:, docs:)

## Seguridad

- El objeto User se guarda en Keychain (Data JSON)
- UserDefaults solo guarda el último email (no sensible)
- No exponer API keys en código fuente para builds de producción
- Considerar Secure Enclave / Keychain Access Groups si aplica

## Funcionalidades

- Autenticación
  - Persistencia de sesión con Keychain
  - Restauración automática al iniciar la app
  - Cierre de sesión desde Perfil
- Perfil
  - Datos del usuario (name/email)
  - Preferencias: divisa preferida, biometría, tema
  - Cambio de contraseña (simulado)
  - Sección de ayuda
- Registro
  - Formulario con validaciones y animaciones
- Pagos cercanos (P2P)
  - Descubrimiento e invitación de peers (MultipeerConnectivity)
  - Envío de solicitud de pago (PaymentMessage.request)
  - Cancelación de solicitud (PaymentMessage.cancel)
  - Seguimiento de peers conectados y solicitudes activas
- Divisas
  - Conversión de montos vía ExchangeRate API (async/await)
  - Mapeo de códigos y formateo local
- Analítica de Ventas
  - Totales, promedios y distribución por categoría
  - Gráficas interactivas con Charts
- Suscripciones
  - Activación/cancelación simulada (mensual/anual)
  - Visualización de beneficios premium

## Roadmap

- Integración real de backend (login/registro/cambio de contraseña/preferencias)
- Persistir preferencias (divisa, biometría) en API
- Confirmación/aceptación de pagos y recibos con Multipeer
- Manejo robusto de errores y estados vacíos
- Tests unitarios y de integración
- CI/CD (Xcode Cloud / GitHub Actions)
- Accesibilidad y localización adicional (en/es)

## Problemas Conocidos

- SalesView y SubscriptionView usan datos simulados
- Cambio de contraseña es simulado
- CurrencyConverter expone una API key en el código (mover a .xcconfig)
- El flujo de aceptación de pagos (receiver) puede requerir UI adicional

## Licencia

Indica aquí la licencia (MIT/Apache-2.0/Propietaria).

## Contribuir

1. Crea una rama desde main: feat/nombre-feature
2. Abre un Pull Request con descripción clara
3. Asegúrate de que los tests (si existen) y el lint pasen

## Cómo funciona la app

- Flujo de usuario:
  1. Al abrir la app, si existe una sesión previa en Keychain, se restaura automáticamente y entras a la app; de lo contrario, se muestra login/registro.
  2. En Perfil, ves tu nombre y correo, ajustas preferencias (divisa, biometría, tema), consultas ayuda o cierras sesión.
  3. En Ventas, consultas métricas por semana/mes, con totales, promedios y distribución por categorías, visualizadas con gráficas.
  4. En Suscripción, puedes activar un plan Premium (simulado) o cancelarlo.
  5. Para pagos cercanos, al estar junto a otro dispositivo con InterPay, se establece una conexión P2P y puedes enviar/cancelar solicitudes de pago.

- Flujo técnico:
  1. AuthManager (@ObservableObject) expone @Published var user: User?.
     - Si user == nil, la UI muestra el flujo no autenticado; si tiene valor, muestra el flujo autenticado.
  2. Al iniciar, loadUserFromKeychain() lee de UserDefaults el último email y busca en Keychain el JSON del usuario para restaurar la sesión.
  3. En login(user:), se codifica User a JSON y se guarda en Keychain, se persiste el email en UserDefaults y se publica el estado en main thread.
  4. En logout(), se elimina el registro del Keychain y el email de UserDefaults, y se pone user = nil para volver al login.
  5. ProfileView usa @EnvironmentObject AuthManager para mostrar datos del usuario y sincroniza la divisa local con user.type_money al aparecer.
  6. SendAmount configura MultipeerConnectivity:
     - Crea un MCPeerID, inicia MCSession, anuncia y navega (advertiser + browser).
     - Envía PaymentMessage.request(SolicitudPago) y PaymentMessage.cancel(UUID) a peers conectados.
     - Decodifica mensajes recibidos y actualiza @Published solicitudRecibida/solicitudEnviada en el hilo principal.
  7. CurrencyConverter realiza llamadas async/await a ExchangeRate API, decodifica conversion_rates y calcula montos convertidos.
  8. SalesView utiliza Charts para renderizar series por categoría, con LineMark/AreaMark, y formatea montos al locale es_MX.

