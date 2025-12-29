//
//  KakaoAuthHandler.swift
//  PulseBoard
//
//  Created by 권정근 on 12/26/25.
//

import Foundation
import KakaoSDKAuth
import KakaoSDKUser

// MARK: - KakaoAuthHandler

/// Kakao SDK를 사용해 실제 로그인 로직을 수행하는 구현체입니다.
///
/// 책임:
/// 1. 카카오톡 설치 여부 판단
/// 2. 카카오톡 / 카카오계정 로그인 분기
/// 3. 로그인 성공 시 accessToken 반환
///
/// ❗️Firebase, 서버 통신(Custom Token)은 여기서 다루지 않습니다.
///
/// ⚠️ 중요:
/// Kakao SDK는 로그인 과정에서 외부 앱(카카오톡)을 실행한 뒤
/// 다시 앱으로 복귀하는 UI 기반 인증 흐름을 사용합니다.
///
/// 이 과정은 iOS RunLoop 및 SceneDelegate와 강하게 결합되어 있으므로,
/// Swift Concurrency(async/await)로 래핑할 경우
/// 인증 흐름이 끊기거나 예기치 않은 동작이 발생할 수 있습니다.
///
/// 따라서 본 구현에서는 async/await를 사용하지 않고
/// Kakao SDK가 제공하는 callback 기반 API를 그대로 사용합니다.
final class KakaoAuthHandler {

    
    // MARK: - Public

    /// Kakao 로그인 진입점
    ///
    /// 이 메서드는 Kakao SDK의 UI 흐름을 보존하기 위해
    /// callback 기반으로 설계되었습니다.
    ///
    /// - Note:
    /// accessToken 획득 이후의 Firebase 인증 및 서버 통신은
    /// 상위 레이어(AuthService / SocialAuthCoordinator)에서 처리합니다.
    func login(completion: @escaping (Result<String, Error>) -> Void) {

        // ⚠️ 반드시 Main Thread에서 Kakao SDK 호출
        DispatchQueue.main.async {
            if UserApi.isKakaoTalkLoginAvailable() {
                self.loginWithKakaoTalk(completion: completion)
            } else {
                self.loginWithKakaoAccount(completion: completion)
            }
        }
    }
}


// MARK: - Private Login Methods

private extension KakaoAuthHandler {

    /// 카카오톡 로그인
    ///
    /// 카카오톡 앱을 통해 로그인합니다.
    /// Kakao SDK 내부에서 UIApplication.open(...)이 호출되므로
    /// 반드시 Main Thread에서 실행되어야 합니다.
    func loginWithKakaoTalk(
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        UserApi.shared.loginWithKakaoTalk { oauthToken, error in

            // 1️⃣ Kakao SDK 에러
            if let error = error {
                completion(.failure(error))
                return
            }

            // 2️⃣ accessToken 추출 실패
            guard let accessToken = oauthToken?.accessToken else {
                completion(.failure(KakaoAuthError.failedToGetToken))
                return
            }

            // 3️⃣ 로그인 성공
            completion(.success(accessToken))
        }
    }

    /// 카카오 계정 로그인 (웹 로그인)
    ///
    /// 카카오톡이 설치되어 있지 않은 경우 사용됩니다.
    func loginWithKakaoAccount(
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        UserApi.shared.loginWithKakaoAccount { oauthToken, error in

            // 1️⃣ Kakao SDK 에러
            if let error = error {
                completion(.failure(error))
                return
            }

            // 2️⃣ accessToken 추출 실패
            guard let accessToken = oauthToken?.accessToken else {
                completion(.failure(KakaoAuthError.failedToGetToken))
                return
            }

            // 3️⃣ 로그인 성공
            completion(.success(accessToken))
        }
    }
}


// MARK: - KakaoAuthError

/// Kakao 로그인 과정에서 발생할 수 있는 에러 정의
enum KakaoAuthError: Error {

    /// accessToken을 정상적으로 얻지 못한 경우
    case failedToGetToken
}
