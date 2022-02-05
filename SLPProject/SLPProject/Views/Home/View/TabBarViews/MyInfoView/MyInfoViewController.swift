//
//  UserInformationViewController.swift
//  SLPProject
//
//  Created by 노건호 on 2022/01/27.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift
import Toast

class MyInfoViewController: BaseViewController {
    
    let mainView = MyInfoView()
    
    let images = [UIImage(named: "notice"), UIImage(named: "notice"), UIImage(named: "faq"), UIImage(named: "qna"), UIImage(named: "setting_alarm"), UIImage(named: "permit")]
    let data = BehaviorRelay<[String]>(value: ["", "공지사항", "자주 묻는 질문", "1:1 채팅", "알림 설정", "이용 약관"])
    
    var disposeBag = DisposeBag()
    
    override func loadView() {
        super.loadView()
        
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainView.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        mainView.tableView.register(MyInfoTableViewCell.self, forCellReuseIdentifier: MyInfoTableViewCell.identifier)
        // seperator 양쪽 Inset 15씩 줌(top, bottom은 값 상관없음)
        mainView.tableView.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        
        mainView.tableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        data
            .asDriver(onErrorJustReturn: [])
            .drive(mainView.tableView.rx.items) { [weak self] (tableView, row, element) in
                if row == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: MyInfoTableViewCell.identifier) as! MyInfoTableViewCell
                    
                    cell.userName.text = UserModel.shared.nickname.value
                    
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
                    
                    var configuration = cell.defaultContentConfiguration()
                    configuration.text = self?.data.value[row]
                    configuration.image = self?.images[row]
                    
                    cell.contentConfiguration = configuration
                    
                    return cell
                }
                
            }
            .disposed(by: disposeBag)

        mainView.tableView
            .rx.itemSelected
            .filter { $0.row == 0 }    // row 가 0인것만 클릭 가능
            .subscribe { [weak self] _ in
                self?.navigationController?.pushViewController(InformationManagementViewController(), animated: true)
            }
            .disposed(by: disposeBag)
    }
    
}

extension MyInfoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 95
        }
        
        return 74
    }
}

