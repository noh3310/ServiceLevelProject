//
//  PhoneNumberAuthViewController.swift
//  SLPProject
//
//  Created by 노건호 on 2022/01/18.
//

import UIKit
import RxCocoa
import RxSwift
import Toast
import AnyFormatKit

class PhoneNumberViewAuthViewController: BaseViewController {
    
    let viewModel = PhoneNumberAuthViewModel()
    
    let mainView = PhoneNumberAuthView()
    
    let disposeBag = DisposeBag()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 전화번호 텍스트필드 설정
        setPhoneNumberTextField()
        
        // 인증하기 메시지 버튼 설정
        setAuthMessageButton()
    }
    
    // 전화번호 텍스트필드 설정
    func setPhoneNumberTextField() {
        // 델리게이트 설정
        mainView.phoneNumberTextField.textField.delegate = self

        // TextField값을 정규식으로 체크해서 버튼 상태 변경
        mainView.phoneNumberTextField.textField.rx.text
            .orEmpty
            .map { $0.validPhoneNumber() }
            .bind { [self] value in
                if value {
                    mainView.authMessageButton.backgroundColor = .slpGreen
                } else {
                    mainView.authMessageButton.backgroundColor = .slpGray6
                }
            }
            .disposed(by: disposeBag)
    }
    
    // 인증하기 메시지 버튼 설정
    func setAuthMessageButton() {
        // 인증하기 버튼 클릭했을 경우
        mainView.authMessageButton.rx.tap
            .map { self.mainView.phoneNumberTextField.textField.text!.validPhoneNumber() }
            .bind { [self] state in

                // 번호를 제대로 입력한 경우 전화번호 인증 수행
                if state {
                    view.makeToast("전화번호 인증 시작")
                    viewModel.sendPhoneAuthorization { state in
                        switch state {
                        case .success:
                            view.makeToast("성공")
                            self.navigationController?.pushViewController(AuthNumberViewController(), animated: true)
                        case .tooManyRequests:
                            view.makeToast("많은 요청")
                        case .unknownError:
                            view.makeToast("알 수 없는 오류")
                        }
                    }
                } else { // 만약 형식을 맞추지 않았다면
                    view.makeToast("잘못된 전화번호 형식입니다.")
                }
            }
            .disposed(by: disposeBag)
    }
}

extension PhoneNumberViewAuthViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let text = textField.text else {
            return false
        }
        let characterSet = CharacterSet(charactersIn: string)
        if CharacterSet.decimalDigits.isSuperset(of: characterSet) == false {
            return false
        }

        let formatter = DefaultTextInputFormatter(textPattern: "###-####-####")
        let result = formatter.formatInput(currentText: text, range: range, replacementString: string)
        textField.text = result.formattedText
        viewModel.phoneNumber.accept(textField.text!.replacingOccurrences(of: "-", with: ""))
        mainView.phoneNumberTextField.textField.text = result.formattedText
        let position = textField.position(from: textField.beginningOfDocument, offset: result.caretBeginOffset)!
        textField.selectedTextRange = textField.textRange(from: position, to: position)
        
        // 글자가 13자 이상 입력안되게 설정
        // 만약 유효한 값이라면 버튼값 변경
        let count = textField.text?.count ?? 0
        if count >= 13 && mainView.phoneNumberTextField.textField.text!.validPhoneNumber() {
            mainView.authMessageButton.backgroundColor = .slpGreen
        } else {
            mainView.authMessageButton.backgroundColor = .slpGray6
        }

        return false
    }
}
