//
//  SignInViewController.swift
//  RxSwiftTest
//
//  Created by J Oh on 8/2/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class SignInViewController: BaseViewController {
    
    private let emailField: UITextField = {
        let field = UITextField()
        field.placeholder = "이메일을 입력하세요"
        field.borderStyle = .roundedRect
        field.keyboardType = .emailAddress
        return field
    }()
    private let emailValidLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        return label
    }()
    private let passwordField: UITextField = {
        let field = UITextField()
        field.placeholder = "비밀번호를 입력하세요"
        field.borderStyle = .roundedRect
        return field
    }()
    private let passwordValidLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        return label
    }()
    private let phoneField: UITextField = {
        let field = UITextField()
        field.placeholder = "전화번호를 입력하세요"
        field.borderStyle = .roundedRect
        field.keyboardType = .numberPad
        return field
    }()
    private let phoneValidLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        return label
    }()
    private let birthdayPicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .wheels
        picker.locale = Locale(identifier: "ko-KR")
        picker.maximumDate = Date()
        return picker
    }()
    private let birthInfoLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        return label
    }()
    private let signInButton: UIButton = {
        let button = UIButton()
        button.setTitle("가입하기", for: .normal)
        button.backgroundColor = .lightGray
        button.layer.cornerRadius = 10
        return button
    }()
    
    private let disposeBag = DisposeBag()
    private let phoneNumber = BehaviorSubject(value: "010")
    private let birthday = BehaviorSubject(value: Date())
    
    let viewModel = SignInViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        rxBind()
    }
    
}

// RxSwift
extension SignInViewController {
    
    private func rxBind() {
        
        let input = SignInViewModel.Input(email: emailField.rx.text.orEmpty,
                                          password: passwordField.rx.text.orEmpty,
                                          phoneNumber: phoneField.rx.text.orEmpty,
                                          birthday: birthdayPicker.rx.date,
                                          tap: signInButton.rx.tap)
            
        let output = viewModel.transform(input: input)
        
        output.emailValidation
            .bind(with: self) { owner, result in
                owner.emailValidLabel.text = result.text
                owner.emailValidLabel.textColor = result.valid ? .systemBlue : .systemRed
            }
            .disposed(by: disposeBag)
        
        output.passwordValidation
            .bind(with: self) { owner, value in
                owner.passwordValidLabel.text = value.text
                owner.passwordValidLabel.textColor = value.valid ? .systemBlue : .systemRed
            }
            .disposed(by: disposeBag)
        
        output.phoneValidation
            .bind(with: self) { owner, value in
                owner.phoneValidLabel.textColor = value.valid ? .systemBlue : .systemRed
                owner.phoneValidLabel.text = value.text
            }
            .disposed(by: disposeBag)
        
        output.ageValidation
            .bind(with: self) { owner, value in
                owner.birthInfoLabel.text = value.text
                owner.birthInfoLabel.textColor = value.valid ? .systemBlue : .systemRed
            }
            .disposed(by: disposeBag)
        
        output.allValidation
            .bind(with: self) { owner, value in
//                owner.signInButton.rx.isEnabled = value
                owner.signInButton.backgroundColor = value ? .systemBlue : .lightGray
            }
            .disposed(by: disposeBag)
        
        output.tap
            .bind(with: self) { owner, _ in
                owner.showAlert(title: "완료", message: nil)
            }
            .disposed(by: disposeBag)
    }
    
}

// View
extension SignInViewController {
    private func configureView() {
        navigationItem.title = "회원가입"
        
        view.addSubview(emailField)
        view.addSubview(emailValidLabel)
        view.addSubview(passwordField)
        view.addSubview(passwordValidLabel)
        view.addSubview(phoneField)
        view.addSubview(phoneValidLabel)
        view.addSubview(birthInfoLabel)
        view.addSubview(birthdayPicker)
        view.addSubview(signInButton)
        
        emailField.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(30)
            make.height.equalTo(44)
        }
        
        emailValidLabel.snp.makeConstraints { make in
            make.top.equalTo(emailField.snp.bottom).offset(4)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(30)
            make.height.equalTo(15)
        }
        
        passwordField.snp.makeConstraints { make in
            make.top.equalTo(emailValidLabel.snp.bottom).offset(20)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(30)
            make.height.equalTo(44)
        }
        
        passwordValidLabel.snp.makeConstraints { make in
            make.top.equalTo(passwordField.snp.bottom).offset(4)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(30)
            make.height.equalTo(15)
        }
        
        phoneField.snp.makeConstraints { make in
            make.top.equalTo(passwordValidLabel.snp.bottom).offset(20)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(30)
            make.height.equalTo(44)
        }
        
        phoneValidLabel.snp.makeConstraints { make in
            make.top.equalTo(phoneField.snp.bottom).offset(4)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(30)
            make.height.equalTo(15)
        }
        
        birthdayPicker.snp.makeConstraints { make in
            make.top.equalTo(phoneValidLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.height.equalTo(150)
        }
        
        birthInfoLabel.snp.makeConstraints { make in
            make.top.equalTo(birthdayPicker.snp.bottom).offset(8)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(30)
            make.height.equalTo(15)
        }
        
        signInButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-30)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(30)
            make.height.equalTo(44)
        }
    }
}
