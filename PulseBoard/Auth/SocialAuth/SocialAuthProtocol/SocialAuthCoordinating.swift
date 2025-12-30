//
//  SocialAuthCoordinating.swift
//  PulseBoard
//
//  Created by 권정근 on 12/26/25.
//

import Foundation


// MARK: - SocialAuthCoordinating

/// 소셜 로그인(Kakao, Naver)을 Firebase 인증으로 연결하는 Coordinator 인터페이스입니다.
///
/// 이 Coordinator는
/// - Kakao / Naver SDK에서 발급된 accessToken을 전달받아
/// - Firebase Auth (또는 Firebase Functions)를 통해
///   공용 인증 플로우를 수행하는 책임을 가집니다.
///
/// AuthService는 이 Protocol에만 의존하며,
/// 각 소셜 로그인 SDK의 구현 디테일을 알 필요가 없습니다.
///
/// 👉 역할 요약
/// - 소셜 로그인 Provider 간 분기 처리
/// - Firebase 인증 공통 로직 캡슐화
/// - AuthService와 소셜 SDK 사이의 중간 계층
protocol SocialAuthCoordinating {
    func signIn(
        with accessToken: String,
        provider: SocialLoginProvider
    ) async throws
}

