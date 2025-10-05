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
    
    init(position: CGPoint, color: Color, size: CGFloat) {
        self.position = position
        self.velocity = CGVector(dx: Double.random(in: -50...50), dy: 0)
        self.color = color
        self.size = size
        self.shape = FragmentShape.allCases.randomElement() ?? .circle
        self.rotation = Double.random(in: 0...360)
        self.rotationSpeed = Double.random(in: -180...180)
    }
}

// MARK: - 碎片形状枚举
enum FragmentShape: CaseIterable {
    case circle
    case square
    case triangle
    case diamond
    case star
    
    var systemName: String {
        switch self {
        case .circle: return "circle.fill"
        case .square: return "square.fill"
        case .triangle: return "triangle.fill"
        case .diamond: return "diamond.fill"
        case .star: return "star.fill"
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
    private let maxFragments = 20 // 性能考虑，限制碎片数量
    
    // 颜色池
    private let colors: [Color] = [
        .red, .blue, .green, .yellow, .orange, .purple, .pink, .cyan, .mint, .indigo
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
        // 性能优化：限制碎片数量
        if fragments.count >= maxFragments {
            fragments.removeFirst() // 移除最旧的碎片
        }
        
        let newFragment = Fragment(
            position: location,
            color: colors.randomElement() ?? .blue,
            size: CGFloat.random(in: 20...40)
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
        let gravity = 500.0 // 重力强度
        let friction = 0.98 // 摩擦力
        
        for i in fragments.indices {
            // 应用重力
            fragments[i].velocity.dx += gravityDirection.dx * gravity * deltaTime
            fragments[i].velocity.dy += gravityDirection.dy * gravity * deltaTime
            
            // 应用摩擦力
            fragments[i].velocity.dx *= friction
            fragments[i].velocity.dy *= friction
            
            // 更新位置
            fragments[i].position.x += fragments[i].velocity.dx * deltaTime
            fragments[i].position.y += fragments[i].velocity.dy * deltaTime
            
            // 更新旋转
            fragments[i].rotation += fragments[i].rotationSpeed * deltaTime
            
            // 边界检测和反弹
            let screenBounds = UIScreen.main.bounds
            let fragmentSize = fragments[i].size
            
            // 左右边界
            if fragments[i].position.x < fragmentSize/2 {
                fragments[i].position.x = fragmentSize/2
                fragments[i].velocity.dx = -fragments[i].velocity.dx * 0.8
            } else if fragments[i].position.x > screenBounds.width - fragmentSize/2 {
                fragments[i].position.x = screenBounds.width - fragmentSize/2
                fragments[i].velocity.dx = -fragments[i].velocity.dx * 0.8
            }
            
            // 上下边界
            if fragments[i].position.y < fragmentSize/2 {
                fragments[i].position.y = fragmentSize/2
                fragments[i].velocity.dy = -fragments[i].velocity.dy * 0.8
            } else if fragments[i].position.y > screenBounds.height - fragmentSize/2 {
                fragments[i].position.y = screenBounds.height - fragmentSize/2
                fragments[i].velocity.dy = -fragments[i].velocity.dy * 0.8
            }
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
                    let randomY = CGFloat.random(in: 50...UIScreen.main.bounds.height - 50)
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
