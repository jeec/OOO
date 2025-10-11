import SwiftUI

// MARK: - 协议定义
protocol Drawable {
    var name: String { get }
    var color: Color { get }
    
    func draw() -> String
    func area() -> Double
}

protocol Movable {
    var position: CGPoint { get set }
    
    mutating func move(to newPosition: CGPoint)
}

protocol Resizable {
    var size: CGSize { get set }
    
    mutating func resize(to newSize: CGSize)
}

// MARK: - 具体实现
struct DrawableCircle: Drawable, Movable, Resizable {
    var name: String
    var color: Color
    var position: CGPoint
    var size: CGSize
    
    init(name: String, color: Color, position: CGPoint, size: CGSize) {
        self.name = name
        self.color = color
        self.position = position
        self.size = size
    }
    
    func draw() -> String {
        return "绘制圆形: \(name)"
    }
    
    func area() -> Double {
        let radius = min(size.width, size.height) / 2
        return Double.pi * radius * radius
    }
    
    mutating func move(to newPosition: CGPoint) {
        position = newPosition
    }
    
    mutating func resize(to newSize: CGSize) {
        size = newSize
    }
}

struct DrawableRectangle: Drawable, Movable, Resizable {
    var name: String
    var color: Color
    var position: CGPoint
    var size: CGSize
    
    init(name: String, color: Color, position: CGPoint, size: CGSize) {
        self.name = name
        self.color = color
        self.position = position
        self.size = size
    }
    
    func draw() -> String {
        return "绘制矩形: \(name)"
    }
    
    func area() -> Double {
        return Double(size.width * size.height)
    }
    
    mutating func move(to newPosition: CGPoint) {
        position = newPosition
    }
    
    mutating func resize(to newSize: CGSize) {
        size = newSize
    }
}

// MARK: - 协议组合
typealias DrawableMovable = Drawable & Movable

// MARK: - 协议扩展
extension Drawable {
    func description() -> String {
        return "\(name) - 面积: \(String(format: "%.2f", area()))"
    }
}

// MARK: - 主视图
struct ProtocolDemoView: View {
    @State private var shapes: [any Drawable] = []
    @State private var selectedShape: String = "圆形"
    @State private var shapeColor: Color = .blue
    @State private var showDetails: Bool = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("📋 Protocol演示")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("面向协议编程")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    // 形状选择器
                    VStack(spacing: 15) {
                        Text("选择形状类型")
                            .font(.headline)
                            .foregroundColor(.blue)
                        
                        Picker("形状类型", selection: $selectedShape) {
                            Text("圆形").tag("圆形")
                            Text("矩形").tag("矩形")
                        }
                        .pickerStyle(.segmented)
                        
                        ColorPicker("选择颜色", selection: $shapeColor)
                            .padding(.horizontal)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                    
                    // 添加形状按钮
                    Button("添加\(selectedShape)") {
                        addShape()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(shapeColor)
                    
                    // 形状列表
                    if !shapes.isEmpty {
                        VStack(spacing: 10) {
                            Text("形状列表")
                                .font(.headline)
                                .foregroundColor(.green)
                            
                            ForEach(Array(shapes.enumerated()), id: \.offset) { index, shape in
                                ShapeRowView(shape: shape, index: index) {
                                    removeShape(at: index)
                                }
                            }
                        }
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    // 协议特点说明
                    VStack(alignment: .leading, spacing: 10) {
                        Text("💡 Protocol特点:")
                            .font(.headline)
                            .foregroundColor(.purple)
                        
                        Text("• 定义接口规范")
                        Text("• 支持多协议继承")
                        Text("• 协议组合使用")
                        Text("• 协议扩展功能")
                        Text("• 面向协议编程")
                    }
                    .padding()
                    .background(Color.purple.opacity(0.1))
                    .cornerRadius(8)
                    
                    // 详细信息
                    if showDetails {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("🔍 协议详情:")
                                .font(.headline)
                                .foregroundColor(.orange)
                            
                            Text("• Drawable: 可绘制协议")
                            Text("• Movable: 可移动协议")
                            Text("• Resizable: 可调整大小协议")
                            Text("• 协议组合: Drawable & Movable")
                            Text("• 协议扩展: 添加默认实现")
                        }
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    Button(showDetails ? "隐藏详情" : "显示详情") {
                        showDetails.toggle()
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
            }
            .navigationTitle("Protocol演示")
        }
    }
    
    private func addShape() {
        let position = CGPoint(x: 100, y: 100)
        let size = CGSize(width: 80, height: 80)
        
        if selectedShape == "圆形" {
            let circle = DrawableCircle(
                name: "圆形\(shapes.count + 1)",
                color: shapeColor,
                position: position,
                size: size
            )
            shapes.append(circle)
        } else {
            let rectangle = DrawableRectangle(
                name: "矩形\(shapes.count + 1)",
                color: shapeColor,
                position: position,
                size: size
            )
            shapes.append(rectangle)
        }
    }
    
    private func removeShape(at index: Int) {
        shapes.remove(at: index)
    }
}

// MARK: - 形状行视图
struct ShapeRowView: View {
    let shape: any Drawable
    let index: Int
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            // 形状图标
            if shape is DrawableCircle {
                SwiftUI.Circle()
                    .fill(shape.color)
                    .frame(width: 30, height: 30)
            } else {
                SwiftUI.Rectangle()
                    .fill(shape.color)
                    .frame(width: 30, height: 30)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(shape.name)
                    .font(.headline)
                Text(shape.description())
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button("删除") {
                onDelete()
            }
            .buttonStyle(.bordered)
            .foregroundColor(.red)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .shadow(radius: 2)
    }
}

#Preview {
    ProtocolDemoView()
}
