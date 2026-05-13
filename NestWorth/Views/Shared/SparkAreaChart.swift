import SwiftUI
import Charts

struct SparkAreaChart: View {
    let data: [Double]
    var color: Color = AppTheme.mint
    var height: CGFloat = 48

    private var min: Double { data.min() ?? 0 }
    private var max: Double { data.max().map { $0 * 1.05 } ?? 1 }

    var body: some View {
        Chart {
            ForEach(Array(data.enumerated()), id: \.offset) { i, v in
                AreaMark(
                    x: .value("i", i),
                    yStart: .value("base", min),
                    yEnd: .value("v", v)
                )
                .foregroundStyle(AppTheme.chartFillGradient(color))
                .interpolationMethod(.catmullRom)

                LineMark(
                    x: .value("i", i),
                    y: .value("v", v)
                )
                .foregroundStyle(color)
                .lineStyle(StrokeStyle(lineWidth: 1.5))
                .interpolationMethod(.catmullRom)
            }
        }
        .chartYScale(domain: min...max)
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .frame(height: height)
    }
}
