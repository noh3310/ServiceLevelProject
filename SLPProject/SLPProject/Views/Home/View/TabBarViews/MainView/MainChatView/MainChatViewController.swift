//
//  MainChatViewController.swift
//  SLPProject
//
//  Created by 노건호 on 2022/02/18.
//

import UIKit
import SnapKit
import GrowingTextView
import RxSwift
import RxCocoa
import RxGesture
import Toast

class MainChatViewController: BaseViewController {
    
    let mainView = MainChatView()
    
    var disposeBag = DisposeBag()
    
    var viewModel = MainViewModel()
    
//    let chatSocket = ChatSocket()
    
    override func loadView() {
        super.loadView()
        
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SocketIOManager.shared.establishConnection()
//        chatSocket.establishConnection()
        
        mainView.settingView.isHidden.toggle()
        
//        chatSocket.establishConnection()
        
        setNavigationBar() 
        
        setTableView()
        
        setTextView()
        
        setSettingView()
        
        mainView.chatView.sendButton.rx.tap
            .subscribe { [self] _ in
                switch mainView.chatView.sendButtonState {
                case .enable:
                    let text = mainView.chatView.textView.text!
                    SocketIOManager.shared.sendMessage(message: text, nickname: "nick")
                    var array = ChatViewModel.shared.chatData.value
                    array.append(ChatData(state: .my, chat: text))
                    ChatViewModel.shared.chatData.accept(array)
                    mainView.chatView.textView.text = ""
                    mainView.chatView.sendButtonState = .disable
                case .disable:
                    break
                }
            }
            .disposed(by: disposeBag)
        
        ChatViewModel.shared.chatData.subscribe { _ in
            self.mainView.tableView.reloadData()
        }
        .disposed(by: disposeBag)
    }
    
    private func setTableView() {
        mainView.tableView.delegate = self
        mainView.tableView.dataSource = self
    }
    
    private func setTextView() {
        mainView.chatView.textView.delegate = self
    }
    
    private func setNavigationBar() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "three_dots"), style: .plain, target: self, action: #selector(dotsButtonClicked(_:)))
    }
    
    @objc private func dotsButtonClicked(_ sender: UIButton) {
        mainView.settingView.isHidden.toggle()
    }
    
    private func setSettingView() {
        mainView.settingView.cancelPromiseView.rx.tapGesture()
            .when(.recognized)
            .withUnretained(self)
            .subscribe { (owner, _) in
                owner.viewModel.queueAPI.dodgeQueue()
            }
            .disposed(by: disposeBag)
    }
}

extension MainChatViewController: GrowingTextViewDelegate {
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        
        mainView.chatView.snp.updateConstraints {
            $0.height.equalTo(height + 15)
        }
        
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        mainView.chatView.sendButtonState = textView.text == "" ? .disable : .enable
    }
}

extension MainChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ChatViewModel.shared.chatData.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let chatData = ChatViewModel.shared.chatData.value[indexPath.row]
        if chatData.state == .my {
            let cell = tableView.dequeueReusableCell(withIdentifier: MainMyChatTableViewCell.identifier, for: indexPath) as! MainMyChatTableViewCell
            
            cell.chatView.text.text = chatData.chat
            cell.readState = .read
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: MainFriendChatTableViewCell.identifier, for: indexPath) as! MainFriendChatTableViewCell
            
            cell.chatView.text.text = chatData.chat
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIImageView()
        view.image = UIImage(named: "notice.header")
        view.contentMode = .scaleAspectFit
        return view
    }
}
