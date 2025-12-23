//
//  GoogleAuthHandler.swift
//  PulseBoard
//
//  Created by 권정근 on 12/23/25.
//

import Foundation
import FirebaseAuth
import GoogleSignIn



// MARK: - GoogleAuthHandler
/// Google 로그인 전담 핸들러
///
/// Google Sign-In SDK를 통해 인증을 수행하고,
/// 획득한 인증 정보를 Firebase Auth와 연동하는 책임을 가집니다.
final class GoogleAuthHandler {

    // MARK: - Login

    /// Google 로그인 플로우를 시작합니다.
    ///
    /// - Parameters:
    ///   - presentingViewController: Google 로그인 UI를 표시할 ViewController
    ///   - completion: 로그인 성공 / 실패 결과
    func startLogin(
        presentingViewController: UIViewController,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        // 최신 GoogleSignIn SDK는 configuration을 직접 전달하지 않음
        GIDSignIn.sharedInstance.signIn(
            withPresenting: presentingViewController
        ) { result, error in

            if let error {
                completion(.failure(error))
                return
            }

            guard
                let user = result?.user,
                let idToken = user.idToken?.tokenString
            else {
                completion(.failure(AuthError.invalidCredential))
                return
            }

            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: user.accessToken.tokenString
            )

            // Firebase Auth와 연동
            Auth.auth().signIn(with: credential) { _, error in
                if let error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    }
}
