//
//  RootCoordinator.swift
//  PulseBoard
//
//  Created by 권정근 on 12/22/25.
//

import Foundation
import UIKit


// MARK: - RootCoordinator

/// 앱의 최상위 진입점을 관리하는 Coordinator입니다.
///
/// RootCoordinator는 인증(Auth) 상태만을 기준으로
/// Login 화면과 Home 화면을 분기하는 역할을 담당합니다.
///
/// ❌ 로그인 구현
/// ❌ Firebase 직접 접근
/// ❌ 비즈니스 로직
///
/// ⭕️ 오직 "현재 사용자가 로그인 상태인가?"만 판단합니다.
final class RootCoordinator {
    
    
    // MARK: - Properties
    
    /// 앱의 rootViewController를 교체하기 위한 UIWindow
    private let window: UIWindow
    
    /// Auth 상태를 관찰하기 위한 ViewModel
    private let authViewModel: AuthViewModel
    

    // MARK: - Initialization
    
    init(
        window: UIWindow,
        authViewModel: AuthViewModel = AuthViewModel()
    ) {
        self.window = window
        self.authViewModel = authViewModel
    }
    
    
    // MARK: - Start
    
    /// Coordinator 시작 지점
    ///
    /// 1. 앱 시작 시 현재 Auth 상태로 한 번 분기
    /// 2. 이후 Auth 상태 변화에 따라 root 화면을 갱신
    func start() {
        
        // 앱 시작 시 현재 상태로 한 번 분기
        switchToRoot(uid: authViewModel.currentUserUID)
        
        // 로그인 / 로그아웃 / 탈퇴 등 Auth 상태 변화 감지
        authViewModel.onAuthStateChanged = { [weak self] uid in
            self?.switchToRoot(uid: uid)
        }
    }
    
    
    // MARK: - Root Switching
    
    /// 인증 상태(uid)에 따라 rootViewController를 교체합니다.
    ///
    /// - Parameter uid:
    ///   - nil  : 로그아웃 상태 → Login 화면
    ///   - value: 로그인 상태 → Home 화면
    private func switchToRoot(uid: String?) {
        let rootVC: UIViewController
        
        if uid == nil {
            rootVC = makeLogin()  // 로그인 화면
        } else {
            rootVC = makeHome()   // 메인 화면 
        }
        
        // root 교체는 항상 메인 스레드에서
        DispatchQueue.main.async {
            self.window.rootViewController = rootVC
            self.window.makeKeyAndVisible()
        }
        
    }
  
    
    // MARK: - Factory Methods
    
    /// 로그인 화면 생성
    ///
    /// AuthViewModel을 주입하여
    /// 로그인 성공 시 Auth 상태 변경을 RootCoordinator가 감지할 수 있도록 합니다.
    private func makeLogin() -> UIViewController {
        let vc = LoginViewController()
        vc.bind(viewModel: authViewModel)
        return vc
    }
    
    /// 메인(Home) 화면 생성
    ///
    /// Login 화면과 동일한 AuthViewModel을 공유함으로써
    /// Auth 상태를 Single Source of Truth로 유지합니다.
    private func makeHome() -> UIViewController {
        let vc = HomeViewController()
        vc.bind(viewModel: authViewModel)
        return vc
    }
}
