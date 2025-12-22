//
//  LoginViewController.swift
//  PulseBoard
//
//  Created by 권정근 on 12/22/25.
//

import UIKit
import AuthenticationServices


// MARK: - LoginViewController

/// 로그인 화면을 담당하는 ViewController입니다.
///
/// 이 화면의 책임은 다음으로 제한됩니다.
/// 1. 로그인 UI 구성 (Apple / SNS 버튼)
/// 2. 사용자의 로그인 선택 이벤트를 ViewModel로 전달
///
/// ❗️실제 인증 로직(Firebase / Apple SDK 호출)은
/// AuthViewModel이 전담하며, 이 ViewController는 관여하지 않습니다.
final class LoginViewController: UIViewController {
    

    // MARK: - Properties
    
    /// 인증 도메인의 비즈니스 로직을 담당하는 ViewModel
    ///
    /// - 로그인 Provider 선택
    /// - 인증 성공 / 실패 판단
    /// - 이후 화면 전환 트리거
    ///
    /// ViewController는 이 객체를 직접 생성하지 않고,
    /// 외부(Coordinator / SceneDelegate 등)에서 주입받습니다.
    private var viewModel: AuthViewModel?
    

    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupAppleLoginButton()
    }
    
    
    // MARK: - Bind
    
    /// AuthViewModel을 바인딩합니다.
    ///
    /// ViewController가 ViewModel을 직접 생성하지 않음으로써
    /// - 테스트 용이성
    /// - 의존성 분리
    /// - 인증 로직 변경에 대한 유연성
    /// 을 확보합니다.
    func bind(viewModel: AuthViewModel) {
        self.viewModel = viewModel
    }
    
}


// MARK: - View Setup

private extension LoginViewController {

    /// 로그인 화면의 기본 UI를 구성합니다.
    ///
    /// 로그인 화면은 앱의 첫 진입점이므로
    /// 시각적으로 단순하고 안정적인 구성을 유지합니다.
    /// (다크모드 미적용 의도)
    func setupView() {
        view.backgroundColor = .white
    }
}


// MARK: - Apple Login Button

private extension LoginViewController {

    /// Apple 로그인 버튼을 생성하고 화면에 배치합니다.
    ///
    /// - Apple HIG에 따라 `ASAuthorizationAppleIDButton`을 그대로 사용합니다.
    /// - 버튼의 내부 텍스트, 로고, 폰트는 커스터마이징하지 않습니다.
    /// - 버튼 크기와 레이아웃만 조정하여 UI 일관성을 맞춥니다.
    func setupAppleLoginButton() {
        let button = makeAppleLoginButton()
        layoutLoginButton(button)
    }

    /// Apple 로그인을 위한 공식 버튼을 생성합니다.
    ///
    /// - `.continue` 타입을 사용하여 로그인 진입 장벽을 낮춥니다.
    /// - `.black` 스타일은 밝은 배경에서 가장 높은 시인성을 제공합니다.
    func makeAppleLoginButton() -> ASAuthorizationAppleIDButton {
        let button = ASAuthorizationAppleIDButton(
            authorizationButtonType: .continue,
            authorizationButtonStyle: .black
        )

        button.addTarget(
            self,
            action: #selector(appleLoginTapped),
            for: .touchUpInside
        )

        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    /// 로그인 버튼의 공통 레이아웃을 정의합니다.
    ///
    /// Apple / Google / Kakao 등
    /// 모든 SNS 로그인 버튼은 동일한 레이아웃 규칙을 사용합니다.
    func layoutLoginButton(_ button: UIView) {
        view.addSubview(button)

        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            button.heightAnchor.constraint(equalToConstant: 52),
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }
}


// MARK: - User Interaction

private extension LoginViewController {

    /// Apple 로그인 버튼 탭 이벤트 처리
    ///
    /// - ViewController는 로그인 방식만 전달합니다.
    /// - 실제 인증 처리 및 결과 판단은 AuthViewModel의 책임입니다.
    @objc func appleLoginTapped() {
        viewModel?.login(provider: .apple, from: self)
    }
}


// MARK: - ASAuthorizationControllerPresentationContextProviding

/// Apple 인증 UI를 표시하기 위해 필요한 프로토콜 구현
///
/// Apple 로그인 시 시스템 인증 화면을
/// 어느 Window 위에 표시할지 결정합니다.
extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {

    /// Apple 인증 UI가 표시될 기준 Window를 반환합니다.
    ///
    /// 일반적으로 현재 ViewController가 속한 Window를 사용합니다.
    func presentationAnchor(
        for controller: ASAuthorizationController
    ) -> ASPresentationAnchor {
        view.window!
    }
}
