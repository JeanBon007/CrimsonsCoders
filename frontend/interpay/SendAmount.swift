import Foundation
import Combine
import MultipeerConnectivity
import SwiftUI

// --- 1. DEFINICIÓN DE MENSAJEROS ---

// Tu struct original, la necesitamos para el .request
struct SolicitudPago: Codable, Equatable {
    var id: UUID
    var amount: Double
    var currency: String // Usaremos el 'rawValue' de tu enum, ej: "MXN"
    var senderUserID: Int
}

// NUEVO: El "mensajero" que envuelve todos nuestros tipos de mensajes
enum PaymentMessage: Codable {
    case request(SolicitudPago)
    case cancel(UUID) // Enviamos el ID de la solicitud a cancelar
}


// --- 2. TU CLASE 'SendAmount' ACTUALIZADA ---

// Este manager manejará toda la lógica de MPC
class SendAmount: NSObject, ObservableObject, MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate {
    
    // (Propiedades de sesión - Sin cambios)
    private let serviceType = "interpay-mpc"
    private let myPeerID: MCPeerID
    let session: MCSession
    private let serviceAdvertiser: MCNearbyServiceAdvertiser
    private let serviceBrowser: MCNearbyServiceBrowser

    private var invitedPeers: [MCPeerID] = []
    // (Propiedades @Published - Sin cambios)
    @Published var connectedPeers: [MCPeerID] = []
    @Published var solicitudRecibida: SolicitudPago? = nil
    @Published var solicitudEnviada: SolicitudPago? = nil
    
    // --- NUEVA PROPIEDAD ---
    // Guarda el ID de la última solicitud que ENVIAMOS
    private var lastSentRequestID: UUID?

    // (init - Sin cambios)
    override init() {
        self.myPeerID = MCPeerID(displayName: UIDevice.current.name)
        self.session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: serviceType)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: serviceType)
        super.init()
        self.session.delegate = self
        self.serviceAdvertiser.delegate = self
        self.serviceBrowser.delegate = self
        self.serviceAdvertiser.startAdvertisingPeer()
        self.serviceBrowser.startBrowsingForPeers()
    }
    
    // (deinit - Sin cambios)
    deinit {
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
    }

    // --- FUNCIÓN DE ENVÍO (ACTUALIZADA) ---
    func sendPaymentRequest(amount: Double, currency: String, senderID: Int) {
        guard !session.connectedPeers.isEmpty else {
            print("No hay peers conectados a los que enviar la solicitud.")
            return
        }

        // 1. Crea la solicitud
        let solicitud = SolicitudPago(id: UUID(), amount: amount, currency: currency, senderUserID: senderID)

        // 2. NUEVO: Guarda este ID localmente
        self.lastSentRequestID = solicitud.id
        
        DispatchQueue.main.async {
                    self.solicitudEnviada = solicitud
        }
        
        // 3. NUEVO: Envuelve la solicitud en nuestro "Mensajero"
        let message = PaymentMessage.request(solicitud)
        
        do {
            // 4. Codifica el 'message', no la 'solicitud'
            let data = try JSONEncoder().encode(message)
            
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
            print("Mensaje de 'solicitud' enviado con ID: \(solicitud.id)")
            
        } catch let error {
            print("Error al codificar o enviar PaymentMessage.request: \(error.localizedDescription)")
        }
    }
    
    // --- FUNCIÓN DE CANCELAR  ---
    func sendCancelRequest() {
        guard !session.connectedPeers.isEmpty else {
            print("No hay peers a los que cancelar.")
            return
        }
        
        // 1. Busca el ID que acabamos de enviar
        guard let idToCancel = lastSentRequestID else {
            print("No hay un 'lastSentRequestID' para cancelar.")
            return
        }
        
        // 2. Crea el mensaje de cancelación
        let message = PaymentMessage.cancel(idToCancel)
        
        do {
            // 3. Codifica y envía
            let data = try JSONEncoder().encode(message)
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
            print("Mensaje de 'cancelación' enviado para ID: \(idToCancel)")
            
        } catch let error {
            print("Error al enviar PaymentMessage.cancel: \(error.localizedDescription)")
        }
        DispatchQueue.main.async {
            self.solicitudEnviada = nil
        }
        // 4. Limpia el ID para no volver a cancelarlo
        self.lastSentRequestID = nil
        
    }
    
    
    func broadcastCancelMessage(for id: UUID) {
        guard !session.connectedPeers.isEmpty else {
            print("No hay peers a los que notificar cancelación.")
            return
        }
        
        // 1. Crea el mismo mensaje de cancelación
        let message = PaymentMessage.cancel(id)
        
        do {
            // 2. Codifica y envía a todos
            let data = try JSONEncoder().encode(message)
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
            print("Mensaje de 'cancelación' (broadcast) enviado para ID: \(id)")
        } catch {
            print("Error al enviar broadcast de PaymentMessage.cancel: \(error)")
        }
    }

    // --- Métodos Requeridos del Delegado MCSession ---

    // (session:peer:didChange - Sin cambios)
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            switch state {
            case .connected:
                print("Conectado a: \(peerID.displayName)")
                if !self.connectedPeers.contains(peerID) {
                    self.connectedPeers.append(peerID)
                }
            case .notConnected:
                print("Desconectado de: \(peerID.displayName)")
                self.connectedPeers.removeAll(where: { $0 == peerID })
            case .connecting:
                print("Conectando a: \(peerID.displayName)")
            
            @unknown default:
                fatalError("Estado desconocido de MCSession")
            }
        }
    }

    // --- FUNCIÓN DE RECEPCIÓN (ACTUALIZADA) ---
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        
        do {
            // 1. Decodifica el 'PaymentMessage' (en lugar de SolicitudPago)
            let message = try JSONDecoder().decode(PaymentMessage.self, from: data)

            // 2. Comprueba qué tipo de mensaje es
            switch message {
                
            case .request(let solicitud):
                // Es una solicitud de pago (como antes)
                print("Mensaje 'request' RECIBIDO de \(peerID.displayName) con ID: \(solicitud.id)")
                DispatchQueue.main.async {
                    self.solicitudRecibida = solicitud
                }
                
            case .cancel(let idToCancel):
                // Es una cancelación
                print("Mensaje 'cancel' RECIBIDO de \(peerID.displayName) para ID: \(idToCancel)")
                
                // Comprueba si es para la solicitud que estamos mostrando
                if self.solicitudRecibida?.id == idToCancel {
                    DispatchQueue.main.async {
                        self.solicitudRecibida = nil // Esto resetea PagarView
                    }
                }
                // Si nos cancelan una solicitud que ENVIAMOS
                if self.solicitudEnviada?.id == idToCancel {
                    DispatchQueue.main.async {
                        self.solicitudEnviada = nil
                        self.lastSentRequestID = nil
                    }
                }
            }
            
        } catch let error {
            // Esto puede pasar si el otro dispositivo tiene una versión vieja de la app
            print("Error al decodificar PaymentMessage de \(peerID.displayName): \(error.localizedDescription)")
        }
    }
    
    // (Otros métodos de delegado - Sin cambios)
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) { }
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) { }
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) { }

    // (Métodos de Advertiser y Browser - Sin cambios)
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print("Invitación recibida de \(peerID.displayName)")
        invitationHandler(true, self.session)
    }

    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
            
            // Comprueba si ya estamos conectados O si ya lo invitamos
            let isAlreadyConnected = session.connectedPeers.contains(peerID)
            let hasAlreadyBeenInvited = invitedPeers.contains(peerID)
            
            if !isAlreadyConnected && !hasAlreadyBeenInvited {
                // Solo invita si es nuevo
                print("Peer encontrado: \(peerID.displayName). Invitando...")
                browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
                
                // Añádelo a nuestra lista de invitados
                invitedPeers.append(peerID)
                
            } else {
                // Ya lo conocemos, no hacemos nada
                print("Peer encontrado: \(peerID.displayName), pero ya está conectado o invitado.")
            }
        }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("Peer perdido: \(peerID.displayName)")
    }
    
}
