//
//  SceneDelegate.swift
//  PulseBoard
//
//  Created by 권정근 on 12/17/25.
//

import UIKit
import KakaoSDKAuth
import NidThirdPartyLogin


class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    /// 앱의 루트 흐름을 관리하는 Coordinator
    private var rootCoordinator: RootCoordinator?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
       
        guard let windowScene = scene as? UIWindowScene else { return }
        
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        let coordinator = RootCoordinator(window: window)
        self.rootCoordinator = coordinator
        coordinator.start()
    }
    
    func scene(
        _ scene: UIScene,
        openURLContexts URLContexts: Set<UIOpenURLContext>
    ) {
        guard let url = URLContexts.first?.url else { return }
        
        print("🔗 [SceneDelegate] incoming url:", url.absoluteString)

        // ✅ Kakao 로그인 URL이면 여기서 완전히 처리하고 끝
        if AuthApi.isKakaoTalkLoginUrl(url) {
            AuthController.handleOpenUrl(url: url)
            return   // 🔥 이 return 이 핵심
        }

        // ✅ Naver 로그인 URL 처리 (최신 SDK)
        if (NidOAuth.shared.handleURL(url) == true) {
            print("🟢 Naver handled")
            return
        }
        
        print("⚠️ Unknown URL:", url.absoluteString)
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

