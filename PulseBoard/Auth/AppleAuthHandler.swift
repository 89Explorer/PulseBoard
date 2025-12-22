//
//  AppleAuthHandler.swift
//  PulseBoard
//
//  Created by 권정근 on 12/22/25.
//

import Foundation
import AuthenticationServices
import FirebaseAuth


// MARK: - AppleAuthHandler

/// Apple 로그인에 필요한 모든 로직을 전담하는 핸들러입니다.
///
/// nonce 생성, SHA256 해싱, ASAuthorizationControllerDelegate 처리 등
/// Apple 로그인 특유의 복잡도를 AuthService로부터 분리하기 위해 존재합니다.
final class AppleAuthHandler: NSObject {
    
    // MARK: - Properties
    
    /// Apple 로그인 요청과 응답을 연결하기 위한 nonce
    private var currentNonce: String?
    
    /// 로그인 시도의 결과를 AuthService로 전달하기 위한 completion
    private var completion: ((Result<Void, Error>) -> Void)?
    
    
    // MARK: - Login

    /// Apple 로그인 요청을 시작합니다.
    func startLogin(
        presentationContext: ASAuthorizationControllerPresentationContextProviding,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        self.completion = completion
        
        let nonce = CryptoUtils.randomNonceString()   // nonce 만들기 - "이번 요청이 우리 앱이 만든 요청"이라는 증거
        currentNonce = nonce
        
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = CryptoUtils.sha256(nonce)     // Apple 요청에 nonce 해시 넣기
        
        let controller = ASAuthorizationController(
            authorizationRequests: [request]
        )
        
        // Delegate에서 결과 받음
        controller.delegate = self
        controller.presentationContextProvider = presentationContext
        controller.performRequests()
    }
}


// MARK: - ASAuthorizationControllerDelegate

extension AppleAuthHandler: ASAuthorizationControllerDelegate {

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        do {
            guard
                let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
                let nonce = currentNonce,
                let tokenData = credential.identityToken,
                let idTokenString = String(data: tokenData, encoding: .utf8)
            else {
                throw AuthError.invalidCredential
            }

            // Apple 인증 결과를 Firebase에서 인식 가능한 Credential로 변환
            let firebaseCredential = OAuthProvider.appleCredential(
                withIDToken: idTokenString,
                rawNonce: nonce,
                fullName: credential.fullName
            )

            // Firebase에 Signin 요청
            Auth.auth().signIn(with: firebaseCredential) { _, error in
                if let error {
                    self.completion?(.failure(error))
                } else {
                    self.completion?(.success(()))
                }
            }

        } catch {
            completion?(.failure(error))
        }
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        completion?(.failure(error))
    }
}
