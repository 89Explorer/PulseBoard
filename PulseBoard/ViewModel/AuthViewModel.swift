//
//  AuthViewModel.swift
//  PulseBoard
//
//  Created by 권정근 on 12/22/25.
//

import Foundation
import AuthenticationServices


// MARK: - AuthViewModel

/// Auth 화면과 AuthService 사이를 연결하는 ViewModel입니다.
///
/// - ViewController로부터 사용자 액션(로그인/로그아웃/탈퇴)을 전달받고
/// - AuthService의 결과를 UI가 처리하기 쉬운 형태로 변환하여 외부로 전달합니다.
///
/// 이 ViewModel은 비즈니스 로직을 직접 수행하지 않으며,
/// Auth 상태 변화와 에러 이벤트를 중계하는 역할에 집중합니다.
final class AuthViewModel {
    
    
    // MARK: - Dependencies

    /// Auth 기능을 제공하는 서비스 객체
    private let authService: AuthProviding
    
    
    // MARK: - Outputs

    /// 로그인 / 로그아웃 / 탈퇴 등으로 인해
    /// 인증 상태가 변경될 때 호출됩니다.
    ///
    /// - Parameter uid: 로그인 상태라면 사용자 UID, 로그아웃 상태라면 nil
    var onAuthStateChanged: ((String?) -> Void)?
    
    /// Auth 과정 중 발생한 에러를 외부로 전달합니다.
    var onError: ((Error) -> Void)?

    
    // MARK: - State

    /// 현재 로그인된 사용자의 UID
    ///
    /// RootCoordinator 등 상위 레이어에서
    /// 안전하게 현재 인증 상태를 조회하기 위해 사용됩니다.
    var currentUserUID: String? {
        authService.currentUserUID
    }
    
    
    // MARK: - Initialization
    
    init(authService: AuthProviding = AuthService()) {
        self.authService = authService
        observeAuthState()
    }
    
    
    // MARK: - Private

    /// Firebase Auth 상태 변화를 관찰하고
    /// 상태가 바뀔 때마다 외부로 전달합니다.
    private func observeAuthState() {
        authService.observeAuthState { [weak self] uid in
            self?.onAuthStateChanged?(uid)
        }
    }
    
    
    // MARK: - Actions

    /// 지정된 SNS Provider로 로그인을 시도합니다.
    func login(
        provider: SocialLoginProvider,
        from presentationContext: ASAuthorizationControllerPresentationContextProviding
    ) {
        authService.login(
            with: provider,
            from: presentationContext) { [weak self] result in
                if case let .failure(error) = result {
                    self?.onError?(error)
                }
            }
    }
    
    /// 현재 로그인된 사용자를 로그아웃합니다.
    func logout() {
        do {
            try authService.logout()
        } catch {
            onError?(error)
        }
    }
    
    /// 현재 로그인된 사용자 계정을 삭제(탈퇴)합니다.
    func deleteAccount() async {
        do {
            try await authService.deleteAccount()
        } catch {
            onError?(error)
        }
    }
}
