//
//  CustomButton.swift
//  SLPProject
//
//  Created by 노건호 on 2022/01/18.
//

import UIKit
import SnapKit

class CustomButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layer.cornerRadius = 10
        tintColor = .white
        backgroundColor = .slpGreen
        
        self.snp.makeConstraints {
            $0.height.equalTo(50)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
