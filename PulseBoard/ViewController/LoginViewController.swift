//
//  LoginViewController.swift
//  PulseBoard
//
//  Created by 권정근 on 12/22/25.
//

import UIKit
import AuthenticationServices
import GoogleSignIn


// MARK: - LoginViewController

/// 로그인 화면을 담당하는 ViewController입니다.
///
/// 이 화면의 책임은 다음으로 제한됩니다.
/// 1. 로그인 UI 구성 (Apple / Google 버튼)
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
    
    
    // MARK: - UI
    
    /// Apple 로그인과 SNS 아이콘 로그인 영역을 시각적으로 구분하기 위한 구분선입니다.
    ///
    /// 단순한 divider 역할이며,
    /// 실제 레이아웃 기준점(anchor) 역할도 함께 수행합니다.
    private let seperator: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    /// 구분선 중앙에 표시되는 안내 문구 라벨입니다.
    ///
    /// "SNS 계정으로 시작하기"와 같은 텍스트를 통해
    /// Apple 로그인과 기타 SNS 로그인 영역의 의미를 명확히 구분합니다.
    ///
    /// 배경색을 흰색으로 설정하여
    /// 구분선 위에 겹쳐 보이도록 구성합니다.
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textAlignment = .center
        label.backgroundColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// 전체 로그인 UI를 세로로 배치하는 StackView
    ///
    /// [ Apple 로그인 버튼 ]
    /// [ Google / Kakao / Naver 아이콘 버튼 ]
    private let totalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 36
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    /// SNS 아이콘 로그인 버튼을 가로로 배치하는 StackView
    private let socialIconStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 20
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    

    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()    // 기본 배경 및 뷰 설정
        
        // Apple 로그인 영역과 SNS 로그인 영역을 구분하는 UI 구성
        setupSeperatorLayout()
        setupInfoLabelLayout()
        
        // 로그인 버튼들을 담는 StackView 구성
        setupTotalStackViewLayout()
        
        // 로그인 버튼 추가
        setupAppleLoginButton()
        setupSocialIconButtons()
        
        // 안내 문구 설정
        infoLabel.text = "SNS 계정으로 시작하기"
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
    
    /// 구분선 레이아웃을 구성합니다.
    func setupSeperatorLayout() {
        view.addSubview(seperator)
        
        NSLayoutConstraint.activate([
            seperator.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 48),
            seperator.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -48),
            seperator.heightAnchor.constraint(equalToConstant: 2),
            seperator.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 180)
        ])
    }
    
    func setupInfoLabelLayout() {
        view.addSubview(infoLabel)
        
        NSLayoutConstraint.activate([
            infoLabel.centerXAnchor.constraint(equalTo: seperator.centerXAnchor),
            infoLabel.centerYAnchor.constraint(equalTo: seperator.centerYAnchor)
        ])
    }
    
    /// 전체 로그인 버튼 영역을 구성합니다.
    ///
    /// - Apple 로그인 버튼과
    /// - SNS 아이콘 로그인 버튼 그룹을
    /// 하나의 세로 StackView로 묶어 관리합니다.
    ///
    /// 버튼 추가/제거 시
    /// 개별 레이아웃 수정 없이 StackView 구성만 변경하면 되도록 설계되었습니다.
    func setupTotalStackViewLayout() {
        view.addSubview(totalStackView)

        NSLayoutConstraint.activate([
            totalStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            totalStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 280),
            totalStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 48),
            totalStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -48)
        ])

        totalStackView.addArrangedSubview(socialIconStackView)
    }

}


// MARK: - Apple Login Button

private extension LoginViewController {

    /// Apple 로그인 버튼을 생성하고 화면에 배치합니다.
    ///
    /// - Apple HIG에 따라 `ASAuthorizationAppleIDButton`을 그대로 사용합니다.
    /// - 버튼의 내부 텍스트, 로고, 폰트는 커스터마이징하지 않습니다.
    /// - 버튼 크기와 레이아웃만 조정하여 UI 일관성을 맞춥니다.
    /// - loginButtonStaackView에 추가합니다.
    func setupAppleLoginButton() {
        let button = makeAppleLoginButton()
        totalStackView.insertArrangedSubview(button, at: 0)
        
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 52)
        ])
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

}


private extension LoginViewController {

    /// Google / Kakao / Naver 아이콘 로그인 버튼을 구성합니다.
    func setupSocialIconButtons() {
        socialIconStackView.addArrangedSubview(
            makeSocialIconButton(type: .google, action: #selector(googleLoginTapped))
        )

        socialIconStackView.addArrangedSubview(
            makeSocialIconButton(type: .kakao, action: #selector(kakaoLoginTapped))
        )

        socialIconStackView.addArrangedSubview(
            makeSocialIconButton(type: .naver, action: #selector(naverLoginTapped))
        )
    }

    /// SNS 아이콘 로그인 버튼을 생성하는 공용 팩토리 메서드입니다.
    ///
    /// - Google / Kakao / Naver 로그인 버튼은
    ///   동일한 UI 규칙을 사용하여 생성됩니다.
    /// - 실제 로그인 로직은 ViewModel/AuthService에 위임되며,
    ///   이 버튼은 "어떤 Provider를 선택했는지"만 전달합니다.
    ///
    /// - Parameters:
    ///   - type: 로그인 Provider에 따른 아이콘 타입
    ///   - action: 버튼 탭 시 호출될 Selector
    ///
    /// - Returns: 원형 SNS 아이콘 버튼
    func makeSocialIconButton(
        type: SocialIconType,
        action: Selector
    ) -> UIButton {
        let button = UIButton(type: .custom)

        button.setImage(type.iconImage, for: .normal)
        button.layer.cornerRadius = 28
        button.clipsToBounds = true

        button.imageView?.contentMode = .scaleAspectFit

        // UIButton(type: .custom) 사용 시
        // imageView 레이아웃이 명확하지 않기 때문에
        // imageEdgeInsets를 통해 이미지 영역을 직접 제어합니다.
        button.imageEdgeInsets = UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: 0,
            right: 0
        )

        button.addTarget(self, action: action, for: .touchUpInside)

        button.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 56),
            button.heightAnchor.constraint(equalToConstant: 56)
        ])

        return button
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
    
    /// Google 로그인 버튼 탭 이벤트 처리
    @objc func googleLoginTapped() {
        viewModel?.login(provider: .google, from: self)
    }
    
    
    @objc func kakaoLoginTapped() {
        viewModel?.login(provider: .kakao, from: self)
    }
    
    @objc func naverLoginTapped() {
        viewModel?.login(provider: .naver, from: self)
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


/// 앱에서 지원하는 SNS 아이콘 타입을 정의합니다.
///
/// 각 Provider에 대응하는 아이콘 이미지를 캡슐화하여
/// ViewController에서 분기 로직 없이 사용할 수 있도록 합니다.
enum SocialIconType {
    case google
    case kakao
    case naver

    /// Provider에 대응하는 아이콘 이미지
    ///
    /// 이미지는 Assets.xcassets에 등록되어 있어야 합니다.
    var iconImage: UIImage? {
        switch self {
        case .google:
            return UIImage(named: "google_icon")
        case .kakao:
            return UIImage(named: "kakao_icon")
        case .naver:
            return UIImage(named: "naver_icon")
        }
    }
}
