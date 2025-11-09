//
//  AnalyticsView.swift
//  interpay
//
//  Created by Diego Obed on 09/11/25.
//
import SwiftUI
import Charts

// MARK: - Modelos
struct SaleData: Identifiable {
    let id = UUID()
    let date: Date
    let amount: Double
    let category: String
}

struct CategorySales: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let weekTotal: Double
    let monthTotal: Double
    let color: Color
}

// MARK: - Vista Principal
struct SalesView: View {
    @State private var selectedPeriod: Period = .week
    
    enum Period: String, CaseIterable {
        case week = "Semana"
        case month = "Mes"
    }
    
    // Datos mock - Categorías de artesanías
    let categories = [
        CategorySales(name: "Textiles", icon: "🧶", weekTotal: 3200, monthTotal: 12800, color: .blue),
        CategorySales(name: "Cerámica", icon: "🏺", weekTotal: 2800, monthTotal: 11200, color: .orange),
        CategorySales(name: "Joyería", icon: "💍", weekTotal: 4100, monthTotal: 16400, color: .purple),
        CategorySales(name: "Madera", icon: "🪵", weekTotal: 2500, monthTotal: 10000, color: .brown),
        CategorySales(name: "Decoración", icon: "🎨", weekTotal: 1900, monthTotal: 7600, color: .pink)
    ]
    
    var weeklySales: [SaleData] {
        var sales: [SaleData] = []
        let calendar = Calendar.current
        let today = Date()
        
        for day in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -day, to: today) {
                for category in categories {
                    let randomAmount = Double.random(in: 300...700)
                    sales.append(SaleData(date: date, amount: randomAmount, category: category.name))
                }
            }
        }
        return sales.sorted { $0.date < $1.date }
    }
    
    var monthlySales: [SaleData] {
        var sales: [SaleData] = []
        let calendar = Calendar.current
        let today = Date()
        
        for week in 0..<4 {
            if let date = calendar.date(byAdding: .weekOfYear, value: -week, to: today) {
                for category in categories {
                    let randomAmount = Double.random(in: 2000...4000)
                    sales.append(SaleData(date: date, amount: randomAmount, category: category.name))
                }
            }
        }
        return sales.sorted { $0.date < $1.date }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header con info del negocio
                    headerView
                    
                    // Selector de período
                    Picker("Período", selection: $selectedPeriod) {
                        ForEach(Period.allCases, id: \.self) { period in
                            Text(period.rawValue).tag(period)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    // Resumen de totales
                    totalsSummaryView
                    
                    // Gráfica
                    chartView
                    
                    // Lista de categorías
                    categoriesListView
                }
                .padding(.vertical)
            }
            .navigationTitle("Ventas")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(.systemGroupedBackground))
        }
    }
    
    // MARK: - Subvistas
    
    var headerView: some View {
        VStack(spacing: 8) {
            Text("🎨")
                .font(.system(size: 48))
            Text("Artesanías Locales")
                .font(.title2)
                .fontWeight(.bold)
            Text("Ventas y estadísticas")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [Color.orange.opacity(0.1), Color.pink.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .padding(.horizontal)
    }
    
    var totalsSummaryView: some View {
        VStack(spacing: 16) {
            HStack(spacing: 20) {
                // Total de ventas
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "cart.fill")
                            .foregroundColor(.green)
                        Text("Total Ventas")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(formatCurrency(totalSales))
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                
                // Promedio diario
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.blue)
                        Text(selectedPeriod == .week ? "Por Día" : "Por Semana")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(formatCurrency(averageSales))
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
            }
            
            // Indicador de crecimiento
            HStack(spacing: 6) {
                Image(systemName: "arrow.up.right.circle.fill")
                    .foregroundColor(.green)
                Text("+8.3% respecto al período anterior")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
        }
        .padding(.horizontal)
    }
    
    var chartView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(selectedPeriod == .week ? "Ventas Diarias" : "Ventas Semanales")
                .font(.headline)
                .padding(.horizontal)
            
            Chart {
                ForEach(currentSales) { sale in
                    LineMark(
                        x: .value("Fecha", sale.date, unit: selectedPeriod == .week ? .day : .weekOfYear),
                        y: .value("Ventas", sale.amount)
                    )
                    .foregroundStyle(by: .value("Categoría", sale.category))
                    .symbol(by: .value("Categoría", sale.category))
                    .interpolationMethod(.catmullRom)
                    
                    AreaMark(
                        x: .value("Fecha", sale.date, unit: selectedPeriod == .week ? .day : .weekOfYear),
                        y: .value("Ventas", sale.amount)
                    )
                    .foregroundStyle(by: .value("Categoría", sale.category))
                    .opacity(0.15)
                }
            }
            .frame(height: 280)
            .chartXAxis {
                AxisMarks(values: .automatic) { _ in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.day().month(.abbreviated))
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let amount = value.as(Double.self) {
                            Text(formatCurrencyShort(amount))
                        }
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
        .padding(.horizontal)
    }
    
    var categoriesListView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ventas por Categoría")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                ForEach(categories.sorted { getCurrentTotal($0) > getCurrentTotal($1) }) { category in
                    CategoryRow(
                        category: category,
                        selectedPeriod: selectedPeriod,
                        total: totalSales
                    )
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Propiedades Computadas
    
    var currentSales: [SaleData] {
        selectedPeriod == .week ? weeklySales : monthlySales
    }
    
    var totalSales: Double {
        categories.reduce(0) { total, category in
            total + (selectedPeriod == .week ? category.weekTotal : category.monthTotal)
        }
    }
    
    var averageSales: Double {
        let divisor = selectedPeriod == .week ? 7.0 : 4.0
        return totalSales / divisor
    }
    
    func getCurrentTotal(_ category: CategorySales) -> Double {
        selectedPeriod == .week ? category.weekTotal : category.monthTotal
    }
    
    // MARK: - Helpers
    
    func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "es_MX")
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "$0"
    }
    
    func formatCurrencyShort(_ value: Double) -> String {
        if value >= 1000 {
            return String(format: "$%.1fk", value / 1000)
        }
        return String(format: "$%.0f", value)
    }
}

// MARK: - Fila de Categoría
struct CategoryRow: View {
    let category: CategorySales
    let selectedPeriod: SalesView.Period
    let total: Double
    
    var currentTotal: Double {
        selectedPeriod == .week ? category.weekTotal : category.monthTotal
    }
    
    var percentage: Double {
        (currentTotal / total) * 100
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(category.icon)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(category.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text("\(Int(percentage))% del total")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(formatCurrency(currentTotal))
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(category.color)
                    
                    Text(selectedPeriod == .week ? "7 días" : "4 semanas")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            // Barra de progreso
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 6)
                        .cornerRadius(3)
                    
                    Rectangle()
                        .fill(category.color)
                        .frame(width: geometry.size.width * (percentage / 100), height: 6)
                        .cornerRadius(3)
                }
            }
            .frame(height: 6)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 2)
    }
    
    func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "es_MX")
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "$0"
    }
}

// MARK: - Preview
struct SalesView_Previews: PreviewProvider {
    static var previews: some View {
        SalesView()
    }
}
