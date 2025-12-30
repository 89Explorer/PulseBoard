//
//  NaverAuthHandler.swift
//  PulseBoard
//
//  Created by 권정근 on 12/30/25.
//

import Foundation
import NidLogin
import NidThirdPartyLogin


/// Naver SDK(NidLogin)를 사용해 실제 로그인 로직을 수행하는 구현체입니다.
///
/// 책임:
/// 1. 네이버 로그인 UX 동작 방식 설정 (앱 우선 / 인앱 브라우저 fallback)
/// 2. Naver SDK를 통한 로그인 요청
/// 3. 로그인 성공 시 accessToken(LoginResult) 반환
///
/// ❗️Firebase, 서버 통신(Custom Token)은 여기서 다루지 않습니다.
///
/// ⚠️ 중요:
/// Naver SDK는 로그인 과정에서
/// - 네이버 앱 실행 또는
/// - 인앱 브라우저(Web 인증)
/// 와 같은 UI 기반 인증 흐름을 사용합니다.
///
/// 이 과정은 UIKit RunLoop 및 Scene 생명주기와 결합되어 있으므로,
/// 본 구현에서는 async/await를 사용하지 않고
/// Naver SDK가 제공하는 callback 기반 API를 그대로 사용합니다.
final class NaverAuthHandler {
    
    
    // MARK: - Typealias
    
    /// Naver 로그인 결과 콜백 타입
    ///
    /// - success: LoginResult (accessToken 포함)
    /// - failure: NidError
    typealias LoginResultCompletion = (Result<LoginResult, NidError>) -> Void
    
    
    // MARK: - Public
    
    /// Naver 로그인 진입점
    ///
    /// 이 메서드는 Naver SDK의 UI 흐름을 보존하기 위해
    /// callback 기반으로 설계되었습니다.
    ///
    /// - Note:
    /// accessToken 획득 이후의 Firebase 인증 및 서버 통신은
    /// 상위 레이어(AuthService / SocialAuthCoordinator)에서 처리합니다.
    func login(completion: @escaping LoginResultCompletion) {
        
        // ⚠️ 반드시 Main Thread에서 Naver SDK 호출
        DispatchQueue.main.async {
            self.configureLoginBehavior()
            self.requestLogin(completion: completion)
        }
    }

    
    deinit {
        print("❌ NaverAuthHandler deinit")
    }

}


// MARK: - Private Config

private extension NaverAuthHandler {
    
    /// Naver 로그인 동작 방식을 설정합니다.
    ///
    /// - appPreferredWithInAppBrowserFallback
    ///   1️⃣ 네이버 앱이 설치되어 있으면 앱 로그인
    ///   2️⃣ 설치되어 있지 않으면 인앱 브라우저 로그인
    func configureLoginBehavior() {
        // 네이버 앱 우선 → 없으면 인앱 브라우저
        NidOAuth.shared.setLoginBehavior(
            .appPreferredWithInAppBrowserFallback
        )
    }
}


// MARK: - Private Login Methods

private extension NaverAuthHandler {
    
    /// Naver SDK에 로그인 요청을 보냅니다.
    ///
    /// 로그인 성공 시 LoginResult 내부의 accessToken을 통해
    /// 토큰 문자열을 획득할 수 있습니다.
    func requestLogin(
        completion: @escaping LoginResultCompletion
    ) {
        NidOAuth.shared.requestLogin { result in
            switch result {
            case .success(let loginResult):
                print("Access Token: ", loginResult.accessToken.tokenString)
                completion(.success(loginResult))

            case .failure(let error):
                print("Error: ", error.localizedDescription)
                completion(.failure(error))
            }
        }
    }
}
