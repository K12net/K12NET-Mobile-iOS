//
//  SceneDelegate.swift
//  K12Net Mobile
//
//  Created by Ilhami Sisnelioglu on 18.09.2025.
//  Copyright © 2025 K12Net. All rights reserved.
//

// SceneDelegate.swift
import UIKit

class SceneDelegate: UIResponder, UISceneDelegate {

    var window: UIWindow?

    @available(iOS 13.0, *)
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        let storyboard = UIStoryboard(name: "login", bundle: nil)
                let rootVC = storyboard.instantiateInitialViewController()
                window.rootViewController = rootVC
        self.window = window
        window.makeKeyAndVisible()
    }

    @available(iOS 13.0, *)
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Scene aktif olduğunda yapılacaklar
    }

    @available(iOS 13.0, *)
    func sceneWillResignActive(_ scene: UIScene) {
        // Scene arka plana geçerken yapılacaklar
    }

    // Diğer UISceneDelegate metodları...
}
