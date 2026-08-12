import SwiftUI

public struct ProgressRingView: View {
    public var progress: Double
    public var color: Color
    public var lineWidth: CGFloat = 8
    
    public init(progress: Double, color: Color, lineWidth: CGFloat = 8) {
        self.progress = min(max(progress, 0.0), 1.0)
        self.color = color
        self.lineWidth = lineWidth
    }
    
    public var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.2), lineWidth: lineWidth)
            
            Circle()
                .trim(from: 0, to: CGFloat(progress))
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 0.5), value: progress)
        }
    }
}

public struct DualProgressRingView: View {
    public var outerProgress: Double
    public var innerProgress: Double
    public var outerColor: Color
    public var innerColor: Color
    public var size: CGFloat
    
    public init(outerProgress: Double, innerProgress: Double, outerColor: Color = .green, innerColor: Color = .blue, size: CGFloat = 40) {
        self.outerProgress = outerProgress
        self.innerProgress = innerProgress
        self.outerColor = outerColor
        self.innerColor = innerColor
        self.size = size
    }
    
    public var body: some View {
        ZStack {
            ProgressRingView(progress: outerProgress, color: outerColor, lineWidth: size * 0.15)
                .frame(width: size, height: size)
            
            ProgressRingView(progress: innerProgress, color: innerColor, lineWidth: size * 0.15)
                .frame(width: size * 0.65, height: size * 0.65)
        }
    }
}
