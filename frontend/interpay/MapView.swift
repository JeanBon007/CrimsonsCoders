//
//  MapView.swift
//  interpay
//
//  Created by macbook on 08/11/25.
//

import SwiftUI
import MapKit
import Combine

struct Place: Identifiable {
    let id = UUID()
    let name: String
    let subtitle: String?
    let coordinate: CLLocationCoordinate2D
    let isPremium: Bool
}

@MainActor
final class MapViewModel: ObservableObject {
    @Published var region: MKCoordinateRegion
    @Published var places: [Place] = []
    @Published var selectedCategory: Category = .all
    
    enum Category: String, CaseIterable, Identifiable {
        case all = "Todo"
        case restaurants = "Restaurantes"
        case cafes = "Cafés"
        case stores = "Tiendas"
        case banks = "Bancos"
        
        var id: String { rawValue }
        
        var displayPrefix: String {
            switch self {
            case .all: return "Lugar"
            case .restaurants: return "Restaurante"
            case .cafes: return "Café"
            case .stores: return "Tienda"
            case .banks: return "Banco"
            }
        }
    }
    
    // Ubicación fija: Centro Histórico, Ciudad de México
    private let baseCoordinate = CLLocationCoordinate2D(latitude: 19.432608, longitude: -99.133209)
    
    init() {
        self.region = MKCoordinateRegion(
            center: baseCoordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.06, longitudeDelta: 0.06)
        )
        generateMockPlaces()
    }
    
    func generateMockPlaces() {
        // Configuración
        let count = 15
        let latDeltaRange: ClosedRange<Double> = -0.02...0.02
        let lonDeltaRange: ClosedRange<Double> = -0.02...0.02
        let premiumProbability = 0.3 // 30% premium
        
        var newPlaces: [Place] = []
        for i in 1...count {
            let latOffset = Double.random(in: latDeltaRange)
            let lonOffset = Double.random(in: lonDeltaRange)
            let coord = CLLocationCoordinate2D(
                latitude: baseCoordinate.latitude + latOffset,
                longitude: baseCoordinate.longitude + lonOffset
            )
            
            let prefix: String
            if selectedCategory == .all {
                let allPrefixes: [Category] = [.restaurants, .cafes, .stores, .banks]
                prefix = allPrefixes.randomElement()?.displayPrefix ?? "Lugar"
            } else {
                prefix = selectedCategory.displayPrefix
            }
            
            let premium = Double.random(in: 0...1) < premiumProbability
            
            let place = Place(
                name: "\(prefix) \(i)",
                subtitle: premium ? "Destacado" : "Zona Centro, CDMX",
                coordinate: coord,
                isPremium: premium
            )
            newPlaces.append(place)
        }
        self.places = newPlaces
    }
}

struct MapView: View {
    @StateObject private var vm = MapViewModel()
    @State private var position: MapCameraPosition = .automatic
    
    var body: some View {
        VStack(spacing: 0) {
            controlBar
            
            Map(position: $position) {
                ForEach(vm.places) { place in
                    Annotation(place.name, coordinate: place.coordinate) {
                        markerView(for: place)
                            .accessibilityLabel(place.name)
                            .accessibilityHint(place.subtitle ?? "")
                    }
                }
            }
            .mapControls {
                MapCompass()
                MapPitchToggle()
                MapScaleView()
            }
            .task {
                position = .region(vm.region)
            }
            .onChange(of: vm.selectedCategory) { _, _ in
                vm.generateMockPlaces()
            }
        }
        .navigationTitle("Mapa")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // Marcador personalizado: premium (amarillo un poco más grande) vs normal (azul)
    @ViewBuilder
    private func markerView(for place: Place) -> some View {
        if place.isPremium {
            // Premium: sutilmente más grande que el normal
            ZStack {
                // Halo suave (ligeramente mayor que el normal)
                Circle()
                    .fill(Color.yellow.opacity(0.20))
                    .frame(width: 24, height: 24)
                    .blur(radius: 1.0)
                
                // Círculo principal un poco más grande (16 vs 12)
                Circle()
                    .fill(Color.yellow)
                    .frame(width: 16, height: 16)
                    .shadow(color: Color.yellow.opacity(0.35), radius: 3, x: 0, y: 1)
                
                // Borde blanco sutil (ligeramente mayor)
                Circle()
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: 20, height: 20)
            }
        } else {
            // Normal: azul
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.18))
                    .frame(width: 20, height: 20)
                Circle()
                    .fill(Color.blue)
                    .frame(width: 12, height: 12)
                Circle()
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: 16, height: 16)
            }
        }
    }
    
    private var controlBar: some View {
        HStack(spacing: 8) {
            Picker("Categoría", selection: $vm.selectedCategory) {
                ForEach(MapViewModel.Category.allCases) { category in
                    Text(category.rawValue).tag(category)
                }
            }
            .pickerStyle(.segmented)
            
            Button {
                vm.generateMockPlaces()
            } label: {
                Image(systemName: "arrow.clockwise")
                    .padding(8)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .accessibilityLabel("Actualizar lugares")
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
    }
}

#Preview {
    NavigationStack {
        MapView()
    }
}
