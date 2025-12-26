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
final class KakaoAuthHandler: KakaoAuthProviding {
    
    // MARK: - Public
    
    /// Kakao 로그인 진입점
    ///
    /// 카카오톡 설치 여부에 따라
    /// - 설치 O → 카카오톡 로그인
    /// - 설치 X → 카카오 계정 로그인
    func login() async throws -> String {
        if UserApi.isKakaoTalkLoginAvailable() {
            return try await loginWithKakaoTalk()
        } else {
            return try await loginWithKakaoAccount()
        }
    }
}



// MARK: - Private Login Methods

private extension KakaoAuthHandler {
    
    /// 카카오톡 로그인
    ///
    /// Kakao SDK의 callback 기반 API를
    /// Swift async/await 스타일로 래핑합니다.
    func loginWithKakaoTalk() async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            UserApi.shared.loginWithKakaoTalk { oauthToken, error in
                
                // 1️⃣ Kakao SDK 에러 발생
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                // 2️⃣ accessToken 추출 실패
                guard let accessToken = oauthToken?.accessToken else {
                    continuation.resume(throwing: KakaoAuthError.failedToGetToken)
                    return
                }
                
                // 3️⃣ 로그인 성공 → accessToken 반환
                continuation.resume(returning: accessToken)
            }
        }
    }
    
    
    /// 카카오 계정 로그인 (웹 로그인)
    ///
    /// 카카오톡이 설치되어 있지 않은 경우 사용됩니다.
    func loginWithKakaoAccount() async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            UserApi.shared.loginWithKakaoAccount { oauthToken, error in
                
                // 1️⃣ Kakao SDK 에러 발생
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                // 2️⃣ accessToken 추출 실패
                guard let accessToken = oauthToken?.accessToken else {
                    continuation.resume(throwing: KakaoAuthError.failedToGetToken)
                    return
                }
                
                // 3️⃣ 로그인 성공 → accessToken 반환
                continuation.resume(returning: accessToken)
            }
        }
    }
}



// MARK: - KakaoAuthError
/// Kakao 로그인 과정에서 발생할 수 있는 에러 정의
enum KakaoAuthError: Error {
    
    /// accessToken을 정상적으로 얻지 못한 경우
    case failedToGetToken
}
