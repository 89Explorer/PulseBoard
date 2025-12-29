//
//  SocialAuthCoordinator.swift
//  PulseBoard
//
//  Created by 권정근 on 12/27/25.
//

import Foundation


// MARK: - SocialAuthCoordinator

/// 소셜 로그인(Kakao, Naver)을 Firebase 인증으로 변환하는 Coordinator 구현체입니다.
///
/// 📌 이 클래스의 핵심 목적은
/// "소셜 인증 세계"와 "Firebase 인증 세계"를 분리하는 것입니다.
///
/// 책임:
/// 1. 소셜 SDK에서 발급된 accessToken을 입력으로 받습니다.
/// 2. Firebase Functions를 통해 서버에서 Custom Token을 발급받습니다.
/// 3. 발급된 Custom Token으로 Firebase Auth 인증을 완료합니다.
///
/// ❗️이 클래스는 UI, SDK 호출, 화면 전환을 전혀 알지 않습니다.
/// 오직 "인증 변환(use case)"만 담당합니다.
///
/// AuthService는 이 Coordinator에만 의존하며,
/// Firebase Functions, Custom Token, Firebase Auth의
/// 구체적인 구현 디테일을 알 필요가 없습니다.
///
/// 👉 결과적으로
/// - AuthService는 단순해지고
/// - provider 확장이 쉬워지며
/// - 인증 로직 테스트가 가능해집니다.
final class SocialAuthCoordinator: SocialAuthCoordinating {

    
    // MARK: - Dependencies

    /// Firebase Functions 호출을 담당하는 인터페이스
    private let functionsService: FirebaseFunctionsServicing

    /// Firebase Auth 인증을 담당하는 인터페이스
    private let authService: FirebaseAuthServicing

    
    // MARK: - Initializer

    /// SocialAuthCoordinator를 초기화합니다.
    ///
    /// - Parameters:
    ///   - functionsService: Firebase Functions 호출을 담당하는 서비스
    ///   - authService: Firebase Auth 인증을 담당하는 서비스
    init(
        functionsService: FirebaseFunctionsServicing,
        authService: FirebaseAuthServicing
    ) {
        self.functionsService = functionsService
        self.authService = authService
    }

    
    // MARK: - SocialAuthCoordinating

    /// 소셜 로그인 accessToken을 이용해 Firebase 인증을 수행합니다.
    ///
    /// 이 메서드는 다음 순서로 동작합니다:
    /// 1. 전달받은 provider가 지원되는 소셜 로그인인지 검증합니다.
    /// 2. Firebase Functions를 호출하여 Custom Token을 요청합니다.
    /// 3. 응답에서 Custom Token을 파싱합니다.
    /// 4. Firebase Auth에 Custom Token으로 로그인합니다.
    ///
    /// - Parameters:
    ///   - accessToken: Kakao / Naver SDK에서 발급된 accessToken
    ///   - provider: 소셜 로그인 제공자 타입
    ///
    /// - Throws:
    ///   - AuthError.unsupportedProvider: 지원하지 않는 provider인 경우
    ///   - AuthError.invalidCustomToken: Custom Token 파싱 실패
    ///   - Firebase 관련 에러
    func signIn(
        with accessToken: String,
        provider: SocialLoginProvider
    ) async throws {
        
        // 1️⃣ 지원 Provider 검증
        try validate(provider)

        // 2️⃣ Firebase Functions 호출
        let response = try await functionsService.requestCustomToken(
            accessToken: accessToken,
            provider: provider
        )

        // 3️⃣ Custom Token 파싱
        guard let customToken = response.customToken else {
            throw AuthError.invalidCustomToken
        }

        // 4️⃣ Firebase Auth 로그인
        try await authService.signIn(withCustomToken: customToken)
    }
}


// MARK: - Private Helpers

private extension SocialAuthCoordinator {

    /// 지원 가능한 소셜 로그인 Provider인지 검증합니다.
    ///
    /// - Parameter provider: 소셜 로그인 제공자
    /// - Throws: AuthError.unsupportedProvider
    func validate(_ provider: SocialLoginProvider) throws {
        switch provider {
        case .kakao, .naver:
            return
        default:
            throw AuthError.unsupportedProvider
        }
    }
}

