//
//  SocialLoginProvider.swift
//  PulseBoard
//
//  Created by 권정근 on 12/22/25.
//

import Foundation


// MARK: - Social Loginn Provider
/// 앱에서 지원하는 SNS 로그인 타입을 정의합니다.
///
/// View / ViewModel 레벨에서는
/// "Apple 인지, Google 인지"만 구분하면 되도록 하기 위한 추상화입니다.
///
/// 실제 로그인 구현 여부와는 무관하며,
/// 아직 구현되지 않은 Provider도 enum 레벨에서는 미리 정의해둘 수 있습니다.
enum SocialLoginProvider {
    case apple
    case google
    case kakao
    case naver
}
