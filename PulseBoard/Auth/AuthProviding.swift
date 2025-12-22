//
//  AuthProviding.swift
//  PulseBoard
//
//  Created by 권정근 on 12/22/25.
//

import Foundation
import AuthenticationServices


// MARK: - AuthProviding
/// Auth 모듈이 제공해야 하는 기능을 정의한 인터페이스입니다.
///
/// ViewModel은 이 Protocol만 의존하며,
/// Firebase / Apple / Google 등의 실제 구현 디테일은 알 필요가 없습니다.
protocol AuthProviding: AnyObject {
    
    
    // MARK: - Auth state
    
    /// 현재 로그인된 사용자의 UID
    /// (로그아웃 상태라면 nil)
    var currentUserUID: String? { get }
    
    
    /// Firebase Auth의 상태 변화를 관찰합니다.
    ///
    /// Auth는 "한 번 로그인하고 끝"이 아니라
    /// 로그인 / 로그아웃 / 탈퇴에 따라 상태가 변하는 구조이므로
    /// 상태 기반으로 UI를 전환하기 위해 사용합니다.
    func observeAuthState(_ handler: @escaping (String?) -> Void)
    
    
    // MARK: - Login
    
    /// 지정된 SNS Provider로 로그인을 시도합니다.
    ///
    /// - Parameters:
    ///   - provider: 사용자가 선택한 SNS 로그인 방식
    ///   - presentationContext: Apple 로그인 UI를 표시할 기준 View
    ///   - completion: 로그인 시도의 결과
    func login(
        with provider: SocialLoginProvider,
        from presentationContext: ASAuthorizationControllerPresentationContextProviding,
        completion: @escaping (Result<Void, Error>) -> Void
    )
    
    
    // MARK: - Logout / Delete
    
    /// 현재 로그인된 사용자를 로그아웃합니다.
    func logout() throws
    
    /// 현재 로그인된 사용자 계정을 삭제(탈퇴)합니다.
    func deleteAccount() async throws
    
}
