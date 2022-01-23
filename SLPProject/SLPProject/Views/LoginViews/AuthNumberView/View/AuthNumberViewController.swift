//
//  AuthNumberViewController.swift
//  SLPProject
//
//  Created by 노건호 on 2022/01/20.
//

import UIKit
import RxCocoa
import RxSwift
import Toast

class AuthNumberViewController: BaseViewController {
    
    let viewModel = AuthNumberViewModel()
    
    let mainView = AuthNumberView()
    
    var disposeBag = DisposeBag()
    
    var timer: Timer?
    var timeLeft = 60
    
    override func loadView() {
        super.loadView()
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 타이머 설정
        setTimer()
        
        // 텍스트필드 Rx 설정
        setNumberTextFieldView()
        
        // 인증버튼 설정
        setAuthMessageButton()
        
        // 재전송버튼 설정
        setRetransmitButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 인증번호를 보냈습니다 토스트 띄우기(viewDidLoad에서 쓰면 실행이 안됨)
        setAuthMessageToast()
    }
    
    // 인증번호를 보냈습니다 토스트 띄우기
    private func setAuthMessageToast() {
        if let toastText = viewModel.toastText {
            view.makeToast("\(toastText)")
        }
    }
    
    // 텍스트필드 Rx 설정
    private func setNumberTextFieldView() {
        // 입력값 뷰모델에 바인딩
        mainView.numberTextFieldView.textField.rx.text
            .orEmpty
            .bind(to: viewModel.authNumber)
            .disposed(by: disposeBag)
        
        // 6개 입력하면 버튼색 변경
        mainView.numberTextFieldView.textField.rx.text
            .orEmpty
            .map { $0.count >= 6 }
            .bind { [self] value in
                if value {
                    mainView.authMessageButton.backgroundColor = .slpGreen
                } else {
                    mainView.authMessageButton.backgroundColor = .slpGray6
                }
            }
            .disposed(by: disposeBag)
        
        // TextField 델리게이트 설정
        mainView.numberTextFieldView.textField.delegate = self
    }
    
    // 인증버튼 설정
    private func setAuthMessageButton() {
        mainView.authMessageButton.rx.tap
            .map { [self] in viewModel.authNumber.value.count == 6 }
            .map { [self] in $0 && timeLeft != 0 }  // 6개 입력하고 시간이 남아있는지
            .bind { [self] valid in
                if valid {
                    viewModel.authToken { state in
                        switch state {
                        case .success:
//                            view.makeToast("성공")
                            navigationController?.pushViewController(NicknameViewController(), animated: true)
                        case .tooManyRequests:
                            view.makeToast("많은 요청")
                        case .unknownError:
                            view.makeToast("알수 없는 오류")
                        }
                    }
                } else {
                    view.makeToast("전화번호 인증 실패")
                }
            }
            .disposed(by: disposeBag)
    }
    
    // 재전송버튼 설정
    private func setRetransmitButton() {
        // 재전송 버튼 클릭했을 때 우선적으로 타이머만 초기화해줌(계속 요청하면 안될거같아서....)
        mainView.timeButton.rx.tap
            .bind { [self] _ in
                
//                PhoneNumberAuthViewModel().sendPhoneAuthorization { state in
//                    // 여기서 처리
//                }
                
                // 타이머가 nil이 아니라면 시간만 60초로 초기화 해줌
                if timer != nil {
                    timeLeft = 60
                } else {    // timer가 nil이라면 새롭게 설정해줌
                    timeLeft = 60  // 시간 초기화
                    // 새롭게 스케줄 걸어줌
                    setTimer()
                }
            }
            .disposed(by: disposeBag)
    }
    
    // 타이머 설정
    private func setTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(authTimer), userInfo: nil, repeats: true)
    }
    
    // 타이머 1초씩 줄어듬
    @objc private func authTimer()
    {
        timeLeft -= 1
        let addString = timeLeft % 60 < 10 ? "0": ""
        mainView.timeLabel.text = "00:\(addString)\(timeLeft % 60)"
        if timeLeft <= 0 {
            timer?.invalidate()
            timer = nil
        }
    }
}

extension AuthNumberViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // 입력값 6개 이상일 경우 또는 입력값이 문자인 경우 입력안되게 막음
        if (((textField.text?.count ?? 0) >= 6 || Int(string) == nil) && string != "") {
            return false
        }
        
        return true
    }
}
