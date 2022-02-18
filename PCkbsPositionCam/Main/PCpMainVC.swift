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
        
        
        let type2CamBtn = UIButton()
        type2CamBtn.adhere(toSuperview: view)
            .backgroundColor(.yellow)
        type2CamBtn.snp.makeConstraints {
            $0.centerY.equalToSuperview().offset(140)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(100)
        }
        type2CamBtn.addTarget(self, action: #selector(type2CamBtnClick(sender: )), for: .touchUpInside)
        
        
    }
    
    
    @objc func type1CamBtnClick(sender: UIButton) {
        let type1Cam = PCsCameraVC()
        self.navigationController?.pushViewController(type1Cam, animated: true)
    }
    
    @objc func type2CamBtnClick(sender: UIButton) {
        let type1Cam = PCsGifMakerCamVC()
        self.navigationController?.pushViewController(type1Cam, animated: true)
    }
    
}






