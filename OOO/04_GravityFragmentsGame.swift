//
//  04_GravityFragmentsGame.swift
//  OOO
//
//  Created by Ji Yongchun on 2025/10/2.
//

import SwiftUI
import CoreMotion
import Combine

// MARK: - 碎片数据模型
struct Fragment: Identifiable {
    let id = UUID()
    var position: CGPoint
    var velocity: CGVector
    var color: Color
    var size: CGFloat
    var shape: FragmentShape
    var rotation: Double
    var rotationSpeed: Double
    
    // 物理属性
    var mass: CGFloat = 1.0  // 质量
    var pressure: CGFloat = 0.0  // 承受的压力
    var isStable: Bool = false  // 是否稳定（停止运动）
    var contactCount: Int = 0  // 接触的碎片数量
    
    init(position: CGPoint, color: Color, size: CGFloat) {
        self.position = position
        self.velocity = CGVector(dx: Double.random(in: -50...50), dy: 0)
        self.color = color
        self.size = size
        self.shape = FragmentShape.allCases.randomElement() ?? .circle
        self.rotation = Double.random(in: 0...360)
        self.rotationSpeed = Double.random(in: -180...180)
        
        // 根据大小计算质量（体积越大质量越大，但限制最大质量）
        let rawMass = size * size * size * 0.0001
        self.mass = min(rawMass, 10.0) // 限制最大质量为10
    }
}

// MARK: - 碎片形状枚举
enum FragmentShape: CaseIterable {
    case circle
    case square
    case triangle
    case diamond
    case star
    case hexagon
    case pentagon
    case octagon
    case heart
    case cross
    case arrow
    case lightning
    
    var systemName: String {
        switch self {
        case .circle: return "circle.fill"
        case .square: return "square.fill"
        case .triangle: return "triangle.fill"
        case .diamond: return "diamond.fill"
        case .star: return "star.fill"
        case .hexagon: return "hexagon.fill"
        case .pentagon: return "pentagon.fill"
        case .octagon: return "octagon.fill"
        case .heart: return "heart.fill"
        case .cross: return "cross.fill"
        case .arrow: return "arrow.up.fill"
        case .lightning: return "bolt.fill"
        }
    }
}

// MARK: - 游戏状态管理
class GravityGameViewModel: ObservableObject {
    @Published var fragments: [Fragment] = []
    @Published var isGameRunning: Bool = false
    @Published var gravityDirection: CGVector = CGVector(dx: 0, dy: 1)
    @Published var deviceOrientation: UIDeviceOrientation = .portrait
    
    private let motionManager = CMMotionManager()
    private var gameTimer: Timer?
    // 移除碎片数量限制，允许更多碎片
    
    // 颜色池
    private let colors: [Color] = [
        .red, .blue, .green, .yellow, .orange, .purple, .pink, .cyan, .mint, .indigo,
        .teal, .brown, .gray, .black, .white, .primary, .secondary,
        Color(red: 0.8, green: 0.2, blue: 0.8), // 紫红色
        Color(red: 0.2, green: 0.8, blue: 0.2), // 翠绿色
        Color(red: 0.8, green: 0.8, blue: 0.2), // 金黄色
        Color(red: 0.2, green: 0.2, blue: 0.8), // 深蓝色
        Color(red: 0.8, green: 0.4, blue: 0.2), // 橙红色
        Color(red: 0.4, green: 0.2, blue: 0.8)  // 深紫色
    ]
    
    init() {
        setupMotionManager()
        setupOrientationObserver()
    }
    
    // MARK: - 游戏控制
    func startGame() {
        isGameRunning = true
        startGameLoop()
    }
    
    func stopGame() {
        isGameRunning = false
        gameTimer?.invalidate()
        gameTimer = nil
    }
    
    func clearFragments() {
        fragments.removeAll()
    }
    
    // MARK: - 碎片管理
    func addFragment(at location: CGPoint) {
        // 移除碎片数量限制，允许更多碎片
        let newFragment = Fragment(
            position: location,
            color: colors.randomElement() ?? .blue,
            size: CGFloat.random(in: 10...80)  // 进一步扩大碎片大小范围：10-80
        )
        
        fragments.append(newFragment)
    }
    
    // MARK: - 物理更新
    private func startGameLoop() {
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { _ in
            self.updatePhysics()
        }
    }
    
    private func updatePhysics() {
        guard isGameRunning else { return }
        
        let deltaTime: Double = 1.0/60.0
        let gravity = 2000.0 // 重力强度 - 更接近真实重力
        
        // 重置压力和接触计数
        for i in fragments.indices {
            fragments[i].pressure = 0.0
            fragments[i].contactCount = 0
        }
        
        // 计算压力传导
        calculatePressureDistribution()
        
        for i in fragments.indices {
            let fragment = fragments[i]
            
            // 应用重力（考虑质量，但质量因子要合理）
            let massFactor = 1.0 + (fragment.mass * 0.1) // 质量因子：1.0-2.0之间
            fragments[i].velocity.dx += gravityDirection.dx * gravity * deltaTime * massFactor
            fragments[i].velocity.dy += gravityDirection.dy * gravity * deltaTime * massFactor
            
            // 应用摩擦力（质量越大，摩擦力越大）
            let friction = 0.98 - (massFactor * 0.01)
            fragments[i].velocity.dx *= friction
            fragments[i].velocity.dy *= friction
            
            // 当速度很小时，直接停止运动
            let minVelocity: CGFloat = 5.0
            if abs(fragments[i].velocity.dx) < minVelocity {
                fragments[i].velocity.dx = 0
            }
            if abs(fragments[i].velocity.dy) < minVelocity {
                fragments[i].velocity.dy = 0
            }
            
            // 更新位置
            fragments[i].position.x += fragments[i].velocity.dx * deltaTime
            fragments[i].position.y += fragments[i].velocity.dy * deltaTime
            
            // 更新旋转
            fragments[i].rotation += fragments[i].rotationSpeed * deltaTime
        }
        
        // 碎片间碰撞检测
        checkCollisions()
        
        // 边界检测和反弹 - 适配屏幕安全区域
        for i in fragments.indices {
            let screenBounds = UIScreen.main.bounds
            let fragmentSize = fragments[i].size
            let safeAreaTop: CGFloat = 50  // 顶部安全区域
            let safeAreaBottom: CGFloat = 100  // 底部安全区域（为控制面板留空间）
            
            // 左右边界
            if fragments[i].position.x < fragmentSize/2 {
                fragments[i].position.x = fragmentSize/2
                fragments[i].velocity.dx = -fragments[i].velocity.dx * 0.8
            } else if fragments[i].position.x > screenBounds.width - fragmentSize/2 {
                fragments[i].position.x = screenBounds.width - fragmentSize/2
                fragments[i].velocity.dx = -fragments[i].velocity.dx * 0.8
            }
            
            // 上下边界 - 考虑安全区域
            if fragments[i].position.y < safeAreaTop + fragmentSize/2 {
                fragments[i].position.y = safeAreaTop + fragmentSize/2
                fragments[i].velocity.dy = -fragments[i].velocity.dy * 0.8
            } else if fragments[i].position.y > screenBounds.height - safeAreaBottom - fragmentSize/2 {
                fragments[i].position.y = screenBounds.height - safeAreaBottom - fragmentSize/2
                fragments[i].velocity.dy = -fragments[i].velocity.dy * 0.8
            }
        }
    }
    
    // MARK: - 压力传导系统
    private func calculatePressureDistribution() {
        // 简化压力传导，只计算接触计数
        for i in fragments.indices {
            var contactCount: Int = 0
            
            for j in fragments.indices {
                if i == j { continue }
                
                let fragment1 = fragments[i]
                let fragment2 = fragments[j]
                let dx = fragment1.position.x - fragment2.position.x
                let dy = fragment1.position.y - fragment2.position.y
                let distance = sqrt(dx * dx + dy * dy)
                let contactDistance = (fragment1.size + fragment2.size) / 2
                
                // 如果碎片接触
                if distance < contactDistance {
                    contactCount += 1
                }
            }
            
            // 更新接触计数
            fragments[i].contactCount = contactCount
        }
    }
    
    // MARK: - 碰撞检测
    private func checkCollisions() {
        for i in 0..<fragments.count {
            for j in (i+1)..<fragments.count {
                let fragment1 = fragments[i]
                let fragment2 = fragments[j]
                
                // 计算两个碎片之间的距离
                let dx = fragment1.position.x - fragment2.position.x
                let dy = fragment1.position.y - fragment2.position.y
                let distance = sqrt(dx * dx + dy * dy)
                
                // 碰撞半径（两个碎片半径之和）
                let collisionRadius = (fragment1.size + fragment2.size) / 2
                
                // 更严格的碰撞检测，避免重叠
                if distance < collisionRadius && distance > 0.01 {
                    // 发生碰撞
                    handleCollision(fragment1Index: i, fragment2Index: j, dx: dx, dy: dy, distance: distance)
                }
            }
        }
    }
    
    private func handleCollision(fragment1Index: Int, fragment2Index: Int, dx: Double, dy: Double, distance: Double) {
        let fragment1 = fragments[fragment1Index]
        let fragment2 = fragments[fragment2Index]
        
        // 计算碰撞法向量
        let nx = dx / distance
        let ny = dy / distance
        
        // 计算相对速度
        let relativeVx = fragment1.velocity.dx - fragment2.velocity.dx
        let relativeVy = fragment1.velocity.dy - fragment2.velocity.dy
        
        // 计算相对速度在法向量上的投影
        let relativeSpeed = relativeVx * nx + relativeVy * ny
        
        // 如果物体正在分离，不需要处理碰撞
        if relativeSpeed > 0 {
            return
        }
        
        // 获取质量
        let mass1 = fragment1.mass
        let mass2 = fragment2.mass
        let totalMass = mass1 + mass2
        
        // 动态弹性系数（质量越大，弹性越小，整体降低碰撞力度）
        let baseRestitution = 0.05  // 从0.1降低到0.05
        let massRatio = min(mass1, mass2) / max(mass1, mass2)
        let restitution = baseRestitution * (0.3 + massRatio * 0.7)  // 进一步降低
        
        // 计算碰撞冲量（考虑质量和速度）
        let impulse = -(1 + restitution) * relativeSpeed * (2 * mass1 * mass2) / totalMass
        
        // 应用冲量到两个碎片（考虑质量比）
        let impulse1 = impulse / mass1
        let impulse2 = impulse / mass2
        
        fragments[fragment1Index].velocity.dx += impulse1 * nx
        fragments[fragment1Index].velocity.dy += impulse1 * ny
        
        fragments[fragment2Index].velocity.dx -= impulse2 * nx
        fragments[fragment2Index].velocity.dy -= impulse2 * ny
        
        // 分离重叠的碎片（考虑质量比，确保完全分离）
        let overlap = (fragment1.size + fragment2.size) / 2 - distance
        if overlap > 0 {
            let massRatio1 = mass2 / totalMass
            let massRatio2 = mass1 / totalMass
            
            // 强制分离，确保不会重叠
            let separationX = nx * (overlap + 1.0) * massRatio1
            let separationY = ny * (overlap + 1.0) * massRatio1
            
            fragments[fragment1Index].position.x += separationX
            fragments[fragment1Index].position.y += separationY
            
            fragments[fragment2Index].position.x -= nx * (overlap + 1.0) * massRatio2
            fragments[fragment2Index].position.y -= ny * (overlap + 1.0) * massRatio2
        }
    }
    
    // MARK: - 设备方向检测
    private func setupOrientationObserver() {
        NotificationCenter.default.addObserver(
            forName: UIDevice.orientationDidChangeNotification,
            object: nil,
            queue: .main
        ) { _ in
            self.updateGravityDirection()
        }
    }
    
    private func updateGravityDirection() {
        let orientation = UIDevice.current.orientation
        deviceOrientation = orientation
        
        switch orientation {
        case .portrait:
            gravityDirection = CGVector(dx: 0, dy: 1)
        case .portraitUpsideDown:
            gravityDirection = CGVector(dx: 0, dy: -1)
        case .landscapeLeft:
            gravityDirection = CGVector(dx: 1, dy: 0)
        case .landscapeRight:
            gravityDirection = CGVector(dx: -1, dy: 0)
        default:
            break
        }
    }
    
    // MARK: - 运动传感器
    private func setupMotionManager() {
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 0.1
            motionManager.startAccelerometerUpdates(to: .main) { data, error in
                guard let data = data else { return }
                
                // 使用加速度计数据调整重力方向
                let acceleration = data.acceleration
                self.gravityDirection = CGVector(
                    dx: acceleration.x * 0.5,
                    dy: -acceleration.y * 0.5
                )
            }
        }
    }
    
    deinit {
        motionManager.stopAccelerometerUpdates()
        gameTimer?.invalidate()
    }
}

// MARK: - 碎片视图
struct FragmentView: View {
    let fragment: Fragment
    
    var body: some View {
        Image(systemName: fragment.shape.systemName)
            .font(.system(size: fragment.size))
            .foregroundColor(fragment.color)
            .rotationEffect(.degrees(fragment.rotation))
            .position(fragment.position)
            .animation(.linear(duration: 1.0/60.0), value: fragment.position)
    }
}

// MARK: - 游戏控制面板
struct GameControlPanel: View {
    @ObservedObject var viewModel: GravityGameViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            // 游戏状态显示
            HStack {
                Text("碎片数量: \(viewModel.fragments.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("重力方向: \(gravityDirectionText)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // 控制按钮
            HStack(spacing: 12) {
                Button(viewModel.isGameRunning ? "停止" : "开始") {
                    if viewModel.isGameRunning {
                        viewModel.stopGame()
                    } else {
                        viewModel.startGame()
                    }
                }
                .buttonStyle(.borderedProminent)
                
                Button("清空") {
                    viewModel.clearFragments()
                }
                .buttonStyle(.bordered)
                
                Button("添加碎片") {
                    let randomX = CGFloat.random(in: 50...UIScreen.main.bounds.width - 50)
                    let randomY = CGFloat.random(in: 100...UIScreen.main.bounds.height - 150)  // 考虑安全区域
                    viewModel.addFragment(at: CGPoint(x: randomX, y: randomY))
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    private var gravityDirectionText: String {
        let dx = viewModel.gravityDirection.dx
        let dy = viewModel.gravityDirection.dy
        
        if abs(dx) > abs(dy) {
            return dx > 0 ? "右" : "左"
        } else {
            return dy > 0 ? "下" : "上"
        }
    }
}

// MARK: - 主游戏视图
struct GravityFragmentsGame: View {
    @StateObject private var viewModel = GravityGameViewModel()
    @State private var showControls = true
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 背景
                Color(.systemGray6)
                    .ignoresSafeArea()
                
                // 碎片渲染
                ForEach(viewModel.fragments) { fragment in
                    FragmentView(fragment: fragment)
                }
                
                // 控制面板
                VStack {
                    if showControls {
                        GameControlPanel(viewModel: viewModel)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    Spacer()
                }
            }
        }
        .onTapGesture { location in
            // 点击添加碎片
            viewModel.addFragment(at: location)
        }
        .onAppear {
            viewModel.startGame()
        }
        .onDisappear {
            viewModel.stopGame()
        }
        .navigationTitle("重力碎片游戏")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(showControls ? "隐藏控制" : "显示控制") {
                    withAnimation(.spring()) {
                        showControls.toggle()
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        GravityFragmentsGame()
    }
}
