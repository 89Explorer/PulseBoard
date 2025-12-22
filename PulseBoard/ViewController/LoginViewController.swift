//
//  LoginViewController.swift
//  PulseBoard
//
//  Created by 권정근 on 12/22/25.
//

import UIKit
import AuthenticationServices

final class LoginViewController: UIViewController {
    

    private var viewModel: AuthViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGreen
        setupAppleButton()
    }
    
    func bind(viewModel: AuthViewModel) {
        self.viewModel = viewModel
    }
    
    
    private func setupAppleButton() {
        let button = ASAuthorizationAppleIDButton()
        button.addTarget(
            self,
            action: #selector(appleLoginTapped),
            for: .touchUpInside
        )
        
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    
    @objc private func appleLoginTapped() {
        viewModel?.login(provider: .apple, from: self)
    }
    
}


extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(
        for controller: ASAuthorizationController
    ) -> ASPresentationAnchor {
        view.window!
    }
}
