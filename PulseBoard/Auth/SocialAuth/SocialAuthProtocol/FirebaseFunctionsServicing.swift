//
//  FirebaseFunctionsServicing.swift
//  PulseBoard
//
//  Created by 권정근 on 12/27/25.
//

import Foundation


// MARK: - FirebaseFunctionsServicing

/// Firebase Functions를 통해 소셜 로그인 인증을 처리하는 인터페이스입니다.
///
/// 이 프로토콜의 책임은 다음과 같습니다:
/// - 소셜 로그인 SDK(Kakao, Naver 등)에서 발급된 accessToken을 전달받아
/// - Firebase Functions를 호출하고
/// - Firebase 인증에 필요한 Custom Token을 응답으로 반환합니다.
///
/// SocialAuthCoordinator는 이 Protocol에만 의존하며,
/// Firebase Functions SDK, 네트워크 호출 방식, Cloud Function 이름 등
/// 구체적인 구현 디테일을 알 필요가 없습니다.
protocol FirebaseFunctionsServicing {

    /// 소셜 로그인 accessToken을 이용해 Firebase Custom Token을 요청합니다.
    ///
    /// - Parameters:
    ///   - accessToken: 소셜 로그인 SDK에서 발급된 accessToken
    ///   - provider: 소셜 로그인 제공자 타입 (kakao, naver 등)
    ///
    /// - Returns: Firebase 인증에 사용할 CustomTokenResponse
    ///
    /// - Throws:
    ///   - 네트워크 오류
    ///   - Firebase Functions 에러
    ///   - 응답 파싱 실패
    func requestCustomToken(
        accessToken: String,
        provider: SocialLoginProvider
    ) async throws -> CustomTokenResponse
}


// MARK: - CustomTokenResponse

/// Firebase Functions에서 반환되는 Custom Token 응답 모델입니다.
///
/// 이 모델은 Functions 호출 결과를 타입 안정적으로 표현하며,
/// Firebase 인증 단계에서 사용되는 Custom Token 값을 담고 있습니다.
///
/// 👉 역할
/// - Firebase Functions 응답 파싱 전용
/// - 인증 플로우 내부 데이터 전달
struct CustomTokenResponse {
    let customToken: String?
}
