import SwiftUI

struct CircularProgressRing: View {
    let progress: Double   // 0..1
    let gradient: LinearGradient
    var lineWidth: CGFloat = 10
    var size: CGFloat = 72
    var label: String? = nil
    var sublabel: String? = nil

    var body: some View {
        ZStack {
            Circle()
                .stroke(AppTheme.surface3, lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: min(progress, 1))
                .stroke(gradient, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.spring(duration: 0.7, bounce: 0.3), value: progress)
            VStack(spacing: 0) {
                if let label {
                    Text(label)
                        .font(.system(size: size * 0.20, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                }
                if let sublabel {
                    Text(sublabel)
                        .font(.system(size: size * 0.14, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(width: size, height: size)
    }
}
