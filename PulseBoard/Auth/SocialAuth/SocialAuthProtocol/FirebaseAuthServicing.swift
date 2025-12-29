//
//  FirebaseAuthServicing.swift
//  PulseBoard
//
//  Created by 권정근 on 12/27/25.
//

import Foundation


// MARK: - FirebaseAuthServicing

/// Firebase Auth 인증을 담당하는 인터페이스입니다.
///
/// 이 프로토콜은 Firebase 인증 SDK의 구체적인 구현을 감추고,
/// Custom Token 기반 로그인 기능만을 추상화합니다.
///
/// SocialAuthCoordinator는 이 Protocol에만 의존하며,
/// Firebase Auth SDK(Auth.auth())의 실제 사용 방식은 알 필요가 없습니다.
protocol FirebaseAuthServicing {

    /// Firebase Custom Token을 이용해 로그인을 수행합니다.
    ///
    /// - Parameter token: Firebase Functions에서 발급된 Custom Token
    ///
    /// - Throws:
    ///   - Firebase Auth 인증 실패
    ///   - 네트워크 오류
    func signIn(withCustomToken token: String) async throws
}
