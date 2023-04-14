//
//  SceneDelegate.swift
//  ModernVideoTemplate
//
//  Created by Alexander Litvinov on 1.4.2023.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else {
            return
        }
        
        let window = UIWindow(windowScene: windowScene)
        
        let templatePresenter = TemplatePresenter()
        
        let templateInteractor = TemplateInteractor(
            templatePresenter: templatePresenter,
            pictureFilter: CutCutFilter(strategy: DefaultFilterStrategy()),
            videoService: MediaService()
            
        )
        
        let templateViewController = TemplateViewController(interactor: templateInteractor, presenter: templatePresenter)
        
        window.rootViewController = templateViewController
        
        self.window = window
        window.makeKeyAndVisible()
    }
}

