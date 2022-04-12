//
//  GenderViewController.swift
//  SLPProject
//
//  Created by 노건호 on 2022/01/23.
//

import UIKit
import RxCocoa
import RxSwift
import RxGesture
import Toast

class GenderSelectViewController: BaseViewController {
    
    let viewModel = UserViewModel()
    
    let mainView = GenderSelectView()
    
    var disposeBag = DisposeBag()
    
    override func loadView() {
        super.loadView()
        
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // API에서 State를 구독
        viewModel.userAPI.state
            .subscribe(onNext: { [weak self] state in
                // 만약 API가 호출&디코딩을 성공적으로 했다면 홈화면으로 이동
                switch state {
                case .success, .alreadyRegister:
                    self?.changeRootView(HomeTabBarController())
                case .noRegister:
                    self?.navigationController?.pushViewController(NicknameViewController(), animated: true)
                case .invalidToken: // 나중에 처리
                    break
                case .invalidNickname:  // 닉네임 부적절할때
                    // 닉네임 뷰컨트롤러로 돌아가는 코드
                    if let vc = self?.navigationController?.viewControllers.last(where: { $0.isKind(of: NicknameViewController.self) }) {
                        vc.view.makeToast("해당 닉네임은 사용할 수 없습니다.")
                        self?.navigationController?.popToViewController(vc, animated: true)
                    }
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
        
        // 성별 탭했을 경우 뷰모델에 바인딩
        bindGenderSelect()
        
        // 성별 탭 했을때 뷰, 버튼색 바꿔줌
        setGenderColor()
        
        // 다음 버튼 클릭했을 때
        setNextButton()
    }
    
    // 성별 탭했을 경우 뷰모델에 바인딩
    private func bindGenderSelect() {
        // 남자를 클릭했을 경우
        mainView.genderView.manView.rx.tapGesture()
            .when(.recognized)
            .subscribe { [self] _ in
                viewModel.user.gender.accept(.man)   // 뷰모델에 값 넣어줌
            }
            .disposed(by: disposeBag)
        
        // 여자를 클릭했을 경우
        mainView.genderView.womanView.rx.tapGesture()
            .when(.recognized)
            .subscribe { [self] _ in
                viewModel.user.gender.accept(.woman) // 뷰모델에 값 넣어줌
            }
            .disposed(by: disposeBag)
    }
    
    // 성별 탭 했을때 뷰, 버튼색 바꿔줌
    private func setGenderColor() {
        viewModel.user.gender
            .filter { $0 != .none }     // none라면 별도로 처리하지 않음
            .bind { [self] gender in
                if gender == .man {
                    mainView.genderView.manView.backgroundColor = .slpWhiteGreen
                    mainView.genderView.womanView.backgroundColor = .slpWhite
                } else {
                    mainView.genderView.manView.backgroundColor = .slpWhite
                    mainView.genderView.womanView.backgroundColor = .slpWhiteGreen
                }
                
                // 버튼 활성화
                mainView.nextButton.backgroundColor = .slpGreen
            }
            .disposed(by: disposeBag)
    }
    
    // 다음 버튼 클릭했을 때
    private func setNextButton() {
        mainView.nextButton.rx.tap
            .map { [self] in viewModel.user.gender.value != .none }
            .bind { [self] state in
                // 회원가입
                viewModel.userAPI.registerUser()
            }
            .disposed(by: disposeBag)
    }
}
