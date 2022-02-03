//
//  InformationManagementView.swift
//  SLPProject
//
//  Created by 노건호 on 2022/01/27.
//

import UIKit
import SnapKit

class InformationManagerView: UIView, FetchViews {
    
    // 프로필 뷰
    let profileView = ProfileCustomView()
    
    // 성별 선택 뷰
    let selectGenderView = MyInfoGenderSelectView()
    
    // 자주 하는 취미
    let favoriteHabitView = MyInfoFavoriteHabitView()
    
    // 검색 허용
    let phoneSearchView = MyInfoPhoneSearchEnableView()
    
    // 유효 나이
    let searchAgeView = MyInfoSearchAgeView()
    
    // 회원 탈퇴
    let deRegisterView = MyInfoDeRegisterView()
    
    let scrollView = UIScrollView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addViews()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addViews() {
        self.addSubview(scrollView)
        
        [profileView, selectGenderView, favoriteHabitView, phoneSearchView, searchAgeView, deRegisterView].forEach {
            scrollView.addSubview($0)
        }
    }
    
    func makeConstraints() {
        
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.centerX.equalToSuperview()
        }
        
        profileView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
        
        selectGenderView.snp.makeConstraints {
            $0.top.equalTo(profileView.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(60)
            $0.centerX.equalToSuperview()
        }
        
        favoriteHabitView.snp.makeConstraints {
            $0.top.equalTo(selectGenderView.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(60)
            $0.centerX.equalToSuperview()
        }
        
        phoneSearchView.snp.makeConstraints {
            $0.top.equalTo(favoriteHabitView.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(60)
            $0.centerX.equalToSuperview()
        }
        
        searchAgeView.snp.makeConstraints {
            $0.top.equalTo(phoneSearchView.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.centerX.equalToSuperview()
        }
        
        deRegisterView.snp.makeConstraints {
            $0.top.equalTo(searchAgeView.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(60)
            $0.bottom.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
    }
    
}
