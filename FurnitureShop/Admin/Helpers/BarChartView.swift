import SwiftUI
import Charts

struct BarChartView: View {
    @State private var selectedValue: String? = nil
    @State private var userAccessCount: Int = 0
    @State private var totalRevenue: Double = 0.0
    @State private var totalProfit: Double = 0.0
    @State private var chartData: [Double] = []
    @State private var chartLabels: [String] = []
    
    private let firestoreService = FirestoreService()

    var body: some View {
        VStack {
            if !chartData.isEmpty {
                ChartView(numbers: chartData, labels: chartLabels)
            } else {
                ProgressView("Loading Chart Data...")
                    .frame(height: 300)
            }
            
            Divider()
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: -25) {
                    TotalViewCustom(totalName: "TOTAL REVENUE", totalAmount: totalRevenue)
                    TotalViewCustom(totalName: "TOTAL PROFIT", totalAmount: totalProfit)
                    TotalUserViewCustom(totalName: "TOTAL VIEWS", totalAmount: userAccessCount)
                }
            }
            .padding(.top, 10)
        }
        .onAppear {
            fetchStatistics()
            fetchChartData()
        }
    }
    
    private func fetchStatistics() {
        firestoreService.fetchUserAccessCount { count in
            userAccessCount = count
        }
        firestoreService.fetchTotalRevenue { revenue in
            totalRevenue = revenue
        }
        firestoreService.fetchTotalProfit { profit in
            totalProfit = profit
        }
    }
    
    private func fetchChartData() {
        firestoreService.fetchChartData { data, labels in
            chartData = data
            chartLabels = labels
        }
    }
}

struct TotalViewCustom: View {
    var totalName: String
    var totalAmount: Double
    
    var body: some View {
        VStack {
            Text(totalName)
                .font(.headline)
                .foregroundColor(.gray)
            
            Text("$ \(totalAmount, specifier: "%.2f")")
                .font(.headline)
                .padding(.top, 5)
                .foregroundColor(.blue)
                
        }
        .padding()
        .border(Color.black, width: 0.1)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.black, lineWidth: 0.1)
                )
        .frame(width: 200, height: 100)
    }
        
}

struct TotalUserViewCustom: View {
    var totalName: String
    var totalAmount: Int
    
    var body: some View {
        VStack {
            Text(totalName)
                .font(.headline)
                .foregroundColor(.gray)
            
            Text("\(totalAmount)")
                .font(.headline)
                .padding(.top, 5)
                .foregroundColor(.blue)
                
        }
        .padding()
        .border(Color.black, width: 0.1)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.black, lineWidth: 0.1)
                )
        .frame(width: 200, height: 100)
    }
        
}

struct ChartView: View {
    let numbers: [Double]
    let labels: [String]
    
    var body: some View {
        Chart {
            RuleMark(y: .value("Limit", 2000))
            
            ForEach(Array(numbers.enumerated()), id: \.offset) { index, value in
                LineMark(
                    x: .value("Label", labels[index]),
                    y: .value("Value", value)
                )
                .interpolationMethod(.catmullRom)
                .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 3]))

                PointMark(
                    x: .value("Label", labels[index]),
                    y: .value("Value", value)
                )
                .symbol(.circle)
                .foregroundStyle(.blue)
            }
        }
        .frame(height: 300)
        .padding()
    }
}
