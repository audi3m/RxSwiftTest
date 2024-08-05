//
//  SignInViewModel.swift
//  RxSwiftTest
//
//  Created by J Oh on 8/5/24.
//

import Foundation
import RxSwift
import RxCocoa

final class SignInViewModel {
    
    func transform(input: Input) -> Output {
        let emailValidation = input.email.map { email in
            let valid = self.isValidEmail(email: email)
            let info = valid ? "유효한 이메일입니다." : "이메일 형식을 맞춰주세요. ex) a@a.aa"
            return ValidationResult(valid: valid, text: info)
        }
        let passwordValidation = input.password.map { password in
            let valid = password.count >= 8
            let info = valid ? "유효한 비밀번호입니다." : "8자리 이상 입력하세요."
            return ValidationResult(valid: valid, text: info)
        }
        let phoneValidation = input.phoneNumber.map { phone in
            let countValid = phone.count >= 10
            let numValid = Int(phone) != nil
            let info = numValid ? countValid ? "유효한 전화번호입니다." : "10자리 이상 입력하세요." : "숫자만 입력하세요." 
            return ValidationResult(valid: countValid && numValid, text: info)
        }
        let ageValidation = input.birthday.map { birthday in
            let valid = self.is17Years(birthday: birthday)
            let info = valid ? "가입 가능한 나이입니다." : "만 17세 이상만 가입 가능합니다."
            return ValidationResult(valid: valid, text: info)
        }
        let allValidation = Observable.combineLatest(emailValidation, passwordValidation, phoneValidation, ageValidation)
            .map { email, password, phone, age in
                email.valid && password.valid && phone.valid && age.valid
            }
        
        return Output(emailValidation: emailValidation,
                      passwordValidation: passwordValidation,
                      phoneValidation: phoneValidation,
                      ageValidation: ageValidation,
                      allValidation: allValidation,
                      tap: input.tap)
    }
}

extension SignInViewModel {
    
    struct ValidationResult {
        let valid: Bool
        let text: String
    }
    
    struct Input {
        let email: ControlProperty<String>
        let password: ControlProperty<String>
        let phoneNumber: ControlProperty<String>
        let birthday: ControlProperty<Date>
        let tap: ControlEvent<Void>
    }
    
    struct Output {
        let emailValidation: Observable<ValidationResult>
        let passwordValidation: Observable<ValidationResult>
        let phoneValidation: Observable<ValidationResult>
        let ageValidation: Observable<ValidationResult>
        let allValidation: Observable<Bool>
        let tap: ControlEvent<Void>
    }
}

extension SignInViewModel {
    
    private func formatDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월 d일"
        return formatter.string(from: date)
    }
    
    private func isValidEmail(email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func is17Years(birthday: Date) -> Bool {
        let calendar = Calendar.current
        let birthdayComponent = calendar.dateComponents([.year], from: birthday, to: Date())
        if let age = birthdayComponent.year {
            return age >= 17
        }
        return false
    }
}
    
//    enum PhoneValidationError: Error {
//        case numError
//        case lengthError
//    }
//    
//    struct ValidationResult {
//        let text: String
//        let valid: Bool
//    }
//    
//    private func phoneValidation(num: String) -> ValidationResult {
//        do {
//            try isValidateInput(phoneNumber: num)
//            return ValidationResult(text: "사용할 수 있는 비밀번호입니다.", valid: true)
//        } catch PhoneValidationError.numError {
//            return ValidationResult(text: "숫자만 입력해주세요.", valid: false)
//        } catch PhoneValidationError.lengthError {
//            return ValidationResult(text: "10자리 이상 입력해주세요", valid: false)
//        } catch {
//            fatalError()
//        }
//    }
//    
//    @discardableResult
//    private func isValidateInput(phoneNumber: String) throws -> Bool {
//        guard Int(phoneNumber) != nil else { throw PhoneValidationError.numError }
//        guard phoneNumber.count >= 10 else { throw PhoneValidationError.lengthError }
//        return true
//    }

