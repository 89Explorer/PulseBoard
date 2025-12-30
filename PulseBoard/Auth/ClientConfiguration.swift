//
//  ClientConfiguration.swift
//  PulseBoard
//
//  Created by 권정근 on 12/30/25.
//

import Foundation


// MARK: - Naver Login 키 - 값 호출
enum ClientConfiguration {
    static var appName: String { plist("NAVER_APP_NAME") }
    static var clientID: String { plist("NAVER_CLIENT_ID") }
    static var clientSecret: String { plist("NAVER_CLIENT_SECRET") }
    static var urlScheme: String { plist("NAVER_URL_SCHEME") }

    private static func plist(_ key: String) -> String {
        guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? String,
              value.isEmpty == false,
              value.hasPrefix("$(") == false  // 치환 실패 방지용
        else {
            fatalError("Missing or invalid Info.plist key: \(key)")
        }
        return value
    }
}
