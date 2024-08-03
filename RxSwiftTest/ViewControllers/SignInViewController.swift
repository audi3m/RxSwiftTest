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
    
    let passwordField: UITextField = {
        let field = UITextField()
        field.placeholder = "비밀번호를 입력하세요"
        field.borderStyle = .roundedRect
        return field
    }()
    let passwordValidLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        return label
    }()
    let phoneField: UITextField = {
        let field = UITextField()
        field.placeholder = "전화번호를 입력하세요"
        field.borderStyle = .roundedRect
        field.keyboardType = .numberPad
        return field
    }()
    let phoneValidLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        return label
    }()
    let birthInfoLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        return label
    }()
    let birthDayPicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .wheels
        picker.locale = Locale(identifier: "ko-KR")
        picker.maximumDate = Date()
        return picker
    }()
    let signInButton: UIButton = {
        let button = UIButton()
        button.setTitle("가입하기", for: .normal)
        button.backgroundColor = .lightGray
        button.layer.cornerRadius = 10
        return button
    }()
    
    let disposeBag = DisposeBag()
    let phoneNumber = BehaviorSubject(value: "010")
    let birthday = BehaviorSubject(value: Date())
    let allValid = BehaviorSubject(value: false)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        rxBind()
    }
}

// RxSwift
extension SignInViewController {
    
    private func rxBind() {
        
        let passwordValid = passwordField.rx.text.orEmpty
            .map { $0.count >= 8 }
        
        let phoneCountValid = phoneField.rx.text.orEmpty
            .map { $0.count >= 10 }
        
        let birthdayValid = birthDayPicker.rx.date
            .map { self.is17Years(date: $0) }
        
        phoneNumber
            .bind(to: phoneField.rx.text)
            .disposed(by: disposeBag)
        
        birthday
            .bind(to: birthDayPicker.rx.date)
            .disposed(by: disposeBag)
        
        birthDayPicker.rx.date
            .bind(with: self) { owner, date in
                owner.birthInfoLabel.text = owner.formatDate(date: date)
            }
            .disposed(by: disposeBag)
        
        passwordValid
            .bind(with: self) { owner, value in
                owner.passwordValidLabel.text = value ? "유효한 비밀번호입니다" : "8자리 이상 입력하세요"
                owner.passwordValidLabel.textColor = value ? .systemBlue : .systemRed
            }
            .disposed(by: disposeBag)
        
        phoneCountValid
            .bind(with: self) { owner, value in
                owner.phoneValidLabel.text = value ? "유효한 전화번호입니다" : "10자리 이상 입력하세요"
                owner.phoneValidLabel.textColor = value ? .systemBlue : .systemRed
            }
            .disposed(by: disposeBag)
        
        birthdayValid
            .bind(with: self) { owner, value in
                owner.birthInfoLabel.text = value ? "가능한 생일입니다." : "만 17세 이상만 가능합니다"
            }
            .disposed(by: disposeBag)
        
        signInButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.showAlert(title: "완료", message: nil)
            }
            .disposed(by: disposeBag)
    }
    
}

extension SignInViewController {
    func is17Years(date: Date) -> Bool {
        let calendar = Calendar.current
        let birthdayComponent = calendar.dateComponents([.year], from: date, to: Date())
        if let age = birthdayComponent.year {
            return age >= 17
        }
        return false
    }
    
    func formatDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월 d일"
        return formatter.string(from: date)
    }

}

// View
extension SignInViewController {
    private func configureView() {
        navigationItem.title = "회원가입"
        
        view.addSubview(passwordField)
        view.addSubview(passwordValidLabel)
        view.addSubview(phoneField)
        view.addSubview(phoneValidLabel)
        view.addSubview(birthInfoLabel)
        view.addSubview(birthDayPicker)
        view.addSubview(signInButton)
        
        passwordField.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(30)
            make.height.equalTo(50)
        }
        
        passwordValidLabel.snp.makeConstraints { make in
            make.top.equalTo(passwordField.snp.bottom).offset(4)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(30)
            make.height.equalTo(20)
        }
        
        phoneField.snp.makeConstraints { make in
            make.top.equalTo(passwordValidLabel.snp.bottom).offset(20)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(30)
            make.height.equalTo(50)
        }
        
        phoneValidLabel.snp.makeConstraints { make in
            make.top.equalTo(phoneField.snp.bottom).offset(4)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(30)
            make.height.equalTo(20)
        }
        
        birthInfoLabel.snp.makeConstraints { make in
            make.top.equalTo(phoneValidLabel.snp.bottom).offset(20)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(30)
            make.height.equalTo(20)
        }
        
        birthDayPicker.snp.makeConstraints { make in
            make.top.equalTo(birthInfoLabel.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
        
        signInButton.snp.makeConstraints { make in
            make.top.equalTo(birthDayPicker.snp.bottom).offset(10)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(30)
            make.height.equalTo(50)
        }
    }
}
