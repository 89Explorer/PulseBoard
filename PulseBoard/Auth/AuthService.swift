//
//  AuthService.swift
//  PulseBoard
//
//  Created by 권정근 on 12/22/25.
//

import Foundation
import AuthenticationServices
import FirebaseAuth
import NidLogin


// MARK: - AuthService

/// 앱의 인증(Auth) 흐름을 총괄하는 서비스 구현체입니다.
///
/// 이 클래스는 `AuthProviding`을 구현하며,
/// 다음 역할을 수행합니다:
///
/// 1. 로그인 Provider 선택 (Apple / Google / Kakao / Naver)
/// 2. 각 Provider 전담 Handler로 로그인 위임
/// 3. 소셜 로그인 결과를 Firebase 인증으로 변환
/// 4. Firebase Auth 상태 변화 감시
final class AuthService: AuthProviding {
    
    
    // MARK: - Properties
    
    private let socialAuthCoordinator: SocialAuthCoordinating
    
    /// Apple 로그인 전담 핸들러
    private let appleHandler = AppleAuthHandler()
    
    /// Google 로그인 전담 핸들러
    private let googleHandler = GoogleAuthHandler()
    
    /// Kakao 로그인 전담 핸들러
    private let kakaoHandler = KakaoAuthHandler()
    
    private let naverHandler = NaverAuthHandler()
    
    /// Firebase Auth 상태 리스너 핸들
    private var authStateHandle: AuthStateDidChangeListenerHandle?
    
    
    // ✅ 기본 init (앱에서 쓰기 쉽게 기본 조립을 대신 해주는 init)
    convenience init() {
        let functionsService = FirebaseFunctionsService()
        let firebaseAuthService = FirebaseAuthService()
        
        let coordinator = SocialAuthCoordinator(
            functionsService: functionsService,
            authService: firebaseAuthService
        )
        
        self.init(socialAuthCoordinator: coordinator)
    }
    
    // ✅ 지정 init (테스트 / 확장용)
    init(socialAuthCoordinator: SocialAuthCoordinating) {
        self.socialAuthCoordinator = socialAuthCoordinator
    }
    
    
    
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
            kakaoHandler.login { [weak self] result in
                guard let self else { return }
                
                switch result {
                case .success(let accessToken):
                    Task {
                        do {
                            try await self.socialAuthCoordinator.signIn(
                                with: accessToken,
                                provider: .kakao
                            )
                            
                            // UI 업데이트는 반드시 Main Thread
                            DispatchQueue.main.async {
                                completion(.success(()))   // ✅ 반드시 호출
                            }
                        } catch {
                            DispatchQueue.main.async {
                                completion(.failure(error))
                            }
                        }
                    }
                    
                case .failure(let error):
                    completion(.failure(error))
                }
            }

        case .naver:
            naverHandler.login { [weak self] result in
                guard let self else { return }

                switch result {
                case .success(let loginResult):
                    let accessToken = loginResult.accessToken.tokenString

                    Task {
                        do {
                            try await self.socialAuthCoordinator.signIn(
                                with: accessToken,
                                provider: .naver
                            )

                            DispatchQueue.main.async {
                                completion(.success(()))
                            }
                        } catch {
                            DispatchQueue.main.async {
                                completion(.failure(error))
                            }
                        }
                    }

                case .failure(let error):
                    completion(.failure(error))
                }
            }

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
        
        print("💥 AuthService deinit")
        
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
}
