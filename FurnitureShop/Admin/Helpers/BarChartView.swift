import SwiftUI
import Charts

struct BarChartView: View {
    @State private var selectedValue: String? = nil
    let totalRevenue: [Double] = [2000, 2500, 1500, 4500, 500]

    var body: some View {
        VStack {
            ChartView(numbers: totalRevenue)
            
            Divider()
            
            ScrollView(.horizontal, showsIndicators: false){
                HStack(spacing: -25){
                    TotalViewCustom(totalName: "TOTAL REVENUE", totalAmount: 300.32)
                    
                    TotalViewCustom(totalName: "TOTAL PROFIT", totalAmount: 223.5)
                    
                    TotalViewCustom(totalName: "TOTAL VIEWS", totalAmount: 323.5)
                }
            }
            .padding(.top, 10)
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

struct ChartView: View {
    let numbers: [Double]
    
    var body: some View {
        Chart {
            RuleMark(y: .value("Limit", 2000))
            ForEach(Array(numbers.enumerated()), id: \.offset) { index, value in
                LineMark(
                    x: .value("Index", index),
                    y: .value("Value", value)
                )
                .interpolationMethod(.catmullRom)
                .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 3]))

                PointMark(
                    x: .value("Index", index),
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

struct BarChartView_Previews: PreviewProvider {
    static var previews: some View {
        BarChartView()
    }
}
