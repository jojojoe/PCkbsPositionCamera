//
//  PCpMainVC.swift
//  PCkbsPositionCam
//
//  Created by JOJO on 2022/2/9.
//

import UIKit
import SwifterSwift
import SnapKit

class PCpMainVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    
 

}

extension PCpMainVC {
    func setupView() {
        view
            .backgroundColor(.white)
        //
        
        let type1CamBtn = UIButton()
        type1CamBtn.adhere(toSuperview: view)
            .backgroundColor(.yellow)
        type1CamBtn.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(100)
        }
        type1CamBtn.addTarget(self, action: #selector(type1CamBtnClick(sender: )), for: .touchUpInside)
        
        
        
        
    }
    
    
    @objc func type1CamBtnClick(sender: UIButton) {
        let type1Cam = PCsCameraVC()
        self.navigationController?.pushViewController(type1Cam, animated: true)
    }
    
    
    
}






