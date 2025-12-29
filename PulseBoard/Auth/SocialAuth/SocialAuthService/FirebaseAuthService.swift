//
//  FirebaseAuthService.swift
//  PulseBoard
//
//  Created by 권정근 on 12/27/25.
//

import Foundation
import FirebaseAuth


// MARK: - FirebaseAuthService

/// Firebase Auth SDK를 사용하여 인증을 수행하는 서비스 구현체입니다.
///
/// 이 클래스는 `FirebaseAuthServicing` 프로토콜을 구현하며,
/// Firebase Auth SDK(`Auth`)에 직접 의존하는 인프라 계층입니다.
///
/// 👉 책임
/// - Firebase Custom Token 기반 로그인 수행
final class FirebaseAuthService: FirebaseAuthServicing {

    
    // MARK: - Properties

    /// Firebase Auth 인스턴스
    private let auth: Auth

    
    // MARK: - Initializer

    /// FirebaseAuthService를 초기화합니다.
    ///
    /// - Parameter auth: Firebase Auth 인스턴스
    ///   (기본값은 `Auth.auth()` 입니다.)
    init(auth: Auth = Auth.auth()) {
        self.auth = auth
    }

    
    // MARK: - FirebaseAuthServicing

    /// Firebase Custom Token을 이용해 로그인을 수행합니다.
    ///
    /// 이 메서드는 Firebase Functions에서 발급된 Custom Token을 사용하여
    /// Firebase 인증을 완료합니다.
    ///
    /// - Parameter token: Firebase Custom Token
    ///
    /// - Throws:
    ///   - Firebase Auth 인증 실패
    ///   - 네트워크 오류
    func signIn(withCustomToken token: String) async throws {
        try await auth.signIn(withCustomToken: token)
        
        print("🔥 Firebase signIn(withCustomToken) success")
    }
}
