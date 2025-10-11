import SwiftUI

// MARK: - 主视图
struct GestureStateDemoView: View {
    @State private var dragOffset: CGSize = .zero
    @State private var scale: CGFloat = 1.0
    @State private var rotation: Double = 0.0
    @State private var selectedDemo: GestureDemo = .drag
    
    enum GestureDemo: String, CaseIterable {
        case drag = "拖拽手势"
        case scale = "缩放手势"
        case rotation = "旋转手势"
        case combined = "组合手势"
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("👆 @GestureState演示")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("处理用户手势交互")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    // 手势选择器
                    VStack(spacing: 15) {
                        Text("选择手势类型")
                            .font(.headline)
                            .foregroundColor(.blue)
                        
                        Picker("手势类型", selection: $selectedDemo) {
                            ForEach(GestureDemo.allCases, id: \.self) { demo in
                                Text(demo.rawValue).tag(demo)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                    
                    // 手势演示区域
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.gray.opacity(0.1))
                            .frame(height: 300)
                        
                        // 根据选择的手势显示不同的演示
                        switch selectedDemo {
                        case .drag:
                            DragGestureDemo()
                        case .scale:
                            ScaleGestureDemo()
                        case .rotation:
                            RotationGestureDemo()
                        case .combined:
                            CombinedGestureDemo()
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(12)
                    
                    // 说明文字
                    VStack(alignment: .leading, spacing: 10) {
                        Text("💡 @GestureState特点:")
                            .font(.headline)
                            .foregroundColor(.purple)
                        
                        Text("• 专门处理手势状态")
                        Text("• 手势结束时自动重置")
                        Text("• 性能优化，避免重复计算")
                        Text("• 支持拖拽、缩放、旋转等手势")
                    }
                    .padding()
                    .background(Color.purple.opacity(0.1))
                    .cornerRadius(8)
                }
                .padding()
            }
            .navigationTitle("@GestureState")
        }
    }
}

// MARK: - 拖拽手势演示
struct DragGestureDemo: View {
    @State private var position: CGPoint = CGPoint(x: 150, y: 150)
    
    var body: some View {
        SwiftUI.Circle()
            .fill(Color.blue)
            .frame(width: 60, height: 60)
            .position(position)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        position = value.location
                    }
            )
    }
}

// MARK: - 缩放手势演示
struct ScaleGestureDemo: View {
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        SwiftUI.Rectangle()
            .fill(Color.green)
            .frame(width: 80, height: 80)
            .scaleEffect(scale)
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        scale = value
                    }
            )
    }
}

// MARK: - 旋转手势演示
struct RotationGestureDemo: View {
    @State private var rotation: Double = 0.0
    
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.orange)
            .frame(width: 80, height: 80)
            .rotationEffect(.degrees(rotation))
            .gesture(
                RotationGesture()
                    .onChanged { value in
                        rotation = value.degrees
                    }
            )
    }
}

// MARK: - 组合手势演示
struct CombinedGestureDemo: View {
    @State private var position: CGPoint = CGPoint(x: 150, y: 150)
    @State private var scale: CGFloat = 1.0
    @State private var rotation: Double = 0.0
    
    var body: some View {
        SwiftUI.Circle()
            .fill(Color.purple)
            .frame(width: 60, height: 60)
            .position(position)
            .scaleEffect(scale)
            .rotationEffect(Angle.degrees(rotation))
            .gesture(
                SimultaneousGesture(
                    DragGesture()
                        .onChanged { value in
                            position = value.location
                        },
                    MagnificationGesture()
                        .onChanged { value in
                            scale = value
                        }
                )
            )
    }
}

#Preview {
    GestureStateDemoView()
}
