//
//  HomeViewController.swift
//  PulseBoard
//
//  Created by 권정근 on 12/22/25.
//

import UIKit


final class HomeViewController: UIViewController {
    

    private var viewModel: AuthViewModel?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGreen
        setupLogoutButton()
    }

    
    func bind(viewModel: AuthViewModel) {
        self.viewModel = viewModel
    }
    

    private func setupLogoutButton() {
        let button = UIButton(type: .system)
        button.setTitle("로그아웃", for: .normal)
        button.addTarget(
            self,
            action: #selector(logoutTapped),
            for: .touchUpInside
        )

        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)

        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc private func logoutTapped() {
        viewModel?.logout()
    }
}
