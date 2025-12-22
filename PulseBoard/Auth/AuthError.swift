//
//  AuthError.swift
//  PulseBoard
//
//  Created by 권정근 on 12/22/25.
//

import Foundation


// MARK: - Auth Error
/// Auth 도메인에서 발생할 수 있는 에러를 의미 단위로 정의합니다.
///
/// Firebase / Apple SDK 에러를 그대로 노출하지 않고,
/// "우리 서비스 관점에서 해석 가능한 에러"로 감싸기 위한 목적입니다.
enum AuthError: Error {

    /// 현재 로그인된 사용자가 없는 상태
    /// (예: 로그아웃 상태에서 탈퇴를 시도한 경우)
    case userNotFound

    /// 아직 구현되지 않은 SNS 로그인 Provider를 선택한 경우
    case unsupportedProvider

    /// 로그인에 필요한 인증 정보를 생성할 수 없는 상태
    /// (예: Apple identityToken 없음, nonce 유실 등)
    case invalidCredential
}



// MARK: - Localized Erro
extension AuthError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .userNotFound:
            return "로그인된 사용자를 찾을 수 없습니다."
        case .unsupportedProvider:
            return "아직 지원하지 않는 로그인 방식입니다."
        case .invalidCredential:
            return "인증 정보를 확인할 수 없습니다."
        }
    }
}

