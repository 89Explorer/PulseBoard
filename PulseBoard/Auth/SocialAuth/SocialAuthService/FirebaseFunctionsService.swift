//
//  FirebaseFunctionsService.swift
//  PulseBoard
//
//  Created by 권정근 on 12/27/25.
//

import Foundation
import FirebaseFunctions


// MARK: - FirebaseFunctionsService

/// Firebase Cloud Functions를 호출하여
/// 소셜 로그인 인증(Custom Token 발급)을 처리하는 서비스 구현체입니다.
///
/// 이 클래스는 `FirebaseFunctionsServicing` 프로토콜을 구현하며,
/// Firebase SDK(`Functions`)에 직접 의존하는 **인프라 계층**입니다.
///
/// ---
///
/// 📌 **이 클래스의 책임**
/// 1. Firebase Cloud Functions 엔드포인트 호출
/// 2. 요청 파라미터 구성
/// 3. 응답 데이터 파싱
/// 4. Firebase Custom Token 반환
///
/// ---
///
/// ⚠️ **디버깅 관점에서의 중요성**
///
/// 이전에 Firebase Functions 호출이 실패했을 때,
/// 단순한 `INTERNAL (code: 13)` 에러만 반환되어
/// 실제 원인을 파악하기 어려웠습니다.
///
/// 이를 해결하기 위해:
/// - 호출 직전 / 직후
/// - 응답 파싱 단계
/// - 에러 발생 시
///
/// 각 지점에 **명확한 로그 포인트**를 추가하여
/// 문제를 단계별로 추적할 수 있도록 설계되었습니다.
final class FirebaseFunctionsService: FirebaseFunctionsServicing {

    
    // MARK: - Properties

    /// Firebase Cloud Functions 인스턴스
    ///
    /// ⚠️ 반드시 서버와 동일한 리전을 지정해야 합니다.
    /// (예: asia-northeast3 = Seoul)
    private let functions: Functions
    

    // MARK: - Initializer

    /// FirebaseFunctionsService를 초기화합니다.
    ///
    /// Firebase Functions는 리전을 명시하지 않으면
    /// 기본값(us-central1)을 사용하므로,
    /// 서버 리전과 불일치 시 호출 실패가 발생할 수 있습니다.
    init() {
        self.functions = Functions.functions(region: "asia-northeast3")
    }
    

    // MARK: - FirebaseFunctionsServicing

    /// 소셜 로그인 accessToken을 이용해 Firebase Custom Token을 요청합니다.
    ///
    /// 이 메서드는 다음 순서로 동작합니다:
    /// 1. Firebase Functions 호출 파라미터 구성
    /// 2. `socialLogin` Callable Function 호출
    /// 3. 응답 데이터 파싱
    /// 4. Custom Token 반환
    ///
    /// - Parameters:
    ///   - accessToken: Kakao / Naver SDK에서 발급된 accessToken
    ///   - provider: 소셜 로그인 제공자 타입
    ///
    /// - Returns: Firebase 인증에 사용할 `CustomTokenResponse`
    ///
    /// - Throws:
    ///   - AuthError.invalidCredential: 응답 데이터 형식이 잘못된 경우
    ///   - AuthError.invalidCustomToken: Custom Token이 누락된 경우
    ///   - Firebase Functions 관련 에러
    func requestCustomToken(
        accessToken: String,
        provider: SocialLoginProvider
    ) async throws -> CustomTokenResponse {

        let parameters: [String: Any] = [
            "accessToken": accessToken,
            "provider": provider.rawValue
        ]

        LogManager.print(.info, "📡 Calling Firebase Function: socialLogin")
        LogManager.print(.info, "➡️ parameters: \(parameters)")

        do {
            let result = try await functions
                .httpsCallable("socialLogin")
                .call(parameters)

            LogManager.print(.success, "📦 Functions raw result received")

            guard let data = result.data as? [String: Any] else {
                LogManager.print(.error, "❌ result.data casting failed: \(result.data)")
                throw AuthError.invalidCredential
            }

            LogManager.print(.info, "📦 Parsed response data: \(data)")

            guard let customToken = data["customToken"] as? String else {
                LogManager.print(.error, "❌ customToken missing in response")
                throw AuthError.invalidCustomToken
            }

            LogManager.print(
                .success,
                "🎟️ customToken received (length: \(customToken.count))"
            )

            return CustomTokenResponse(customToken: customToken)

        } catch {
            // 🔥 Firebase Functions 호출 실패 지점
            LogManager.print(.error, "❌ Firebase Functions call FAILED")
            LogManager.print(.error, "❌ Error: \(error)")

            // Firebase Functions 에러 상세 정보 출력
            if let nsError = error as NSError? {
                LogManager.print(.error, "❌ domain: \(nsError.domain)")
                LogManager.print(.error, "❌ code: \(nsError.code)")
                LogManager.print(.error, "❌ userInfo: \(nsError.userInfo)")
            }

            throw error
        }
    }
}

