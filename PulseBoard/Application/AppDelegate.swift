//
//  AppDelegate.swift
//  PulseBoard
//
//  Created by 권정근 on 12/17/25.
//

import UIKit
import FirebaseCore
import KakaoSDKCommon
import NidThirdPartyLogin
import NidLogin


@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        // MARK: - FireBase 초기화
        
        FirebaseApp.configure()
        
        
        // MARK: - Kakao 로그인
        
        if let kakaoAppKey = Bundle.main.object(
            forInfoDictionaryKey: "KAKAO_NATIVE_APP_KEY"
        ) as? String {
            KakaoSDK.initSDK(appKey: kakaoAppKey)
        }
        
        
        // MARK: - Naver 로그인
        
        // 초기화 값 검증 로그
        LogManager.print(.success, "[NaverConfig] appName: \(ClientConfiguration.appName)")
        LogManager.print(.success, "[NaverConfig] clientID:: \(ClientConfiguration.clientID)")
        LogManager.print(.success, "[NaverConfig] urlScheme: \(ClientConfiguration.urlScheme)")
        LogManager.print(.success, "[NaverConfig] clientSecret: \(ClientConfiguration.clientSecret)")
        
        NidOAuth.shared.initialize(
            appName: ClientConfiguration.appName,
            clientId: ClientConfiguration.clientID,
            clientSecret: ClientConfiguration.clientSecret,
            urlScheme: ClientConfiguration.urlScheme
        )
        print("NAVER_URL_SCHEME(plist) =", Bundle.main.object(forInfoDictionaryKey: "NAVER_URL_SCHEME") ?? "nil")

        LogManager.print(.success, "[NaverConfig] NidOAuth initialized")
        return true
    }

    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
}

