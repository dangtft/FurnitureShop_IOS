import SwiftUI
import Charts

struct AnalyticsView: View {
    @State private var revenueData: [Double] = []
    @State private var profitData: [Double] = []
    @State private var viewsData: [Double] = []
    @State private var labels: [String] = []
    @State private var userAccessCount: Int = 0
    @State private var totalRevenue: Double = 0.0
    @State private var totalProfit: Double = 0.0

    private let firestoreService = FirestoreService()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if revenueData.isEmpty || profitData.isEmpty || viewsData.isEmpty {
                    ProgressView("Loading Analytics Data...")
                        .padding()
                } else {
                    ChartSection(title: "Total Revenue", data: revenueData, labels: labels, totalAmount: totalRevenue)
                    ChartSection(title: "Total Profit", data: profitData, labels: labels, totalAmount: totalProfit)
                    ChartSection(title: "Total Views", data: viewsData, labels: labels, totalAmount: Double(userAccessCount))
                }
            }
            .padding()
        }
        .onAppear {
            fetchAnalyticsData()
            fetchStatistics()
        }
    }

    private func fetchAnalyticsData() {
        firestoreService.fetchChartData { revenue, labels in
            self.revenueData = revenue
            self.labels = labels
        }

        firestoreService.fetchProfitData { profit in
            self.profitData = profit
        }

        firestoreService.fetchViewsData { views in
            self.viewsData = views
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
}

struct ChartSection: View {
    var title: String
    var data: [Double]
    var labels: [String]
    var totalAmount : Double

    var body: some View {
        VStack {
            Text(title)
                .font(.headline)
                .padding()
            Text("\(totalAmount, specifier: "%.2f")")
                .font(.headline)
                .padding(.top, 5)
                .foregroundColor(.blue)

            Chart {
                ForEach(0..<min(data.count, labels.count), id: \.self) { index in
                    LineMark(
                        x: .value("Label", labels[index]),
                        y: .value("Value", data[index])
                    )
                    .interpolationMethod(.catmullRom)
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 3]))

                    PointMark(
                        x: .value("Label", labels[index]),
                        y: .value("Value", data[index])
                    )
                    .symbol(.circle)
                    .foregroundStyle(.blue)
                }
            }
            .frame(height: 300)
            .padding()
        }
    }
}



