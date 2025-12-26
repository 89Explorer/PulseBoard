//
//  AuthService.swift
//  PulseBoard
//
//  Created by 권정근 on 12/22/25.
//

import Foundation
import AuthenticationServices
import FirebaseAuth


// MARK: - AuthService

/// AuthProviding을 구현하는 실제 Auth 비즈니스 로직 담당 클래스입니다.
///
/// 로그인 방식 선택, Firebase Auth 연동,
/// Auth 상태 감시를 통합적으로 관리합니다.
final class AuthService: AuthProviding {
    
    
    // MARK: - Properties
    
    /// Apple 로그인 전담 핸들러
    private let appleHandler = AppleAuthHandler()
    
    /// Google 로그인 전담 핸들러
    private let googleHandler = GoogleAuthHandler()
    
    /// Kakao 로그인 전담 핸들러
    private let kakaoHandler = KakaoAuthHandler()
    
    /// Firebase Auth 상태 리스너 핸들
    private var authStateHandle: AuthStateDidChangeListenerHandle?
    
    
    // MARK: - Auth State
    
    /// 현재 로그인된 사용자의 UID
    var currentUserUID: String? {
        Auth.auth().currentUser?.uid
    }
    
    /// Firebase Auth 상태 변화를 관찰합니다.
    func observeAuthState(_ handler: @escaping (String?) -> Void) {
        // Firebase Auth 상태 감시
        authStateHandle = Auth.auth().addStateDidChangeListener { _, user in
            let uid = user?.uid
            handler(uid)
        }
    }
    
    
    // MARK: - Login
    
    /// 소셜 로그인 진입점
    ///
    /// ViewModel은 어떤 SDK를 쓰는지 모르고,
    /// 어떤 provider로 로그인할지만 전달합니다.
    func login(
        with provider: SocialLoginProvider,
        from presentationContext: ASAuthorizationControllerPresentationContextProviding,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        // 어떤 로그인 방식을 쓸지 분기
        // Google, Kakao, Naver 추가할 때, handler 만들어 case 추가
        switch provider {
            
        case .apple:
            appleHandler.startLogin(
                presentationContext: presentationContext,
                completion: completion
            )
            
        case .google:
            guard let viewController = presentationContext as? UIViewController else {
                completion(.failure(AuthError.invalidCredential))
                return
            }
            
            googleHandler.startLogin(
                presentingViewController: viewController,
                completion: completion
            )
            
        case .kakao:
            // Kakao 로그인은 async/await 기반이므로 Task로 감싼다.
            
        case .naver:
            completion(.failure(AuthError.unsupportedProvider))
        }
    }
    
    
    // MARK: - Logout
    
    func logout() throws {
        try Auth.auth().signOut()
    }
    
    
    // MARK: - Delete Account
    
    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthError.userNotFound
        }
        try await user.delete()
    }
    
    deinit {
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
}
