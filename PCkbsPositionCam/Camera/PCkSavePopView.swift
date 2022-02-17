//
//  PCkSavePopView.swift
//  PCkbsPositionCam
//
//  Created by JOJO on 2022/2/14.
//

import UIKit


class PCkSavePopView: UIView {
    
    
    var backBtnClickBlock: (()->Void)?
    var saveBtnClickBlock: ((UIImage?)->Void)?
    var shareBtnClickBlock: ((UIImage?)->Void)?
    var contentImgV = UIImageView()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func backBtnClick(sender: UIButton) {
        backBtnClickBlock?()
    }
    @objc func saveBtnClick(sender: UIButton) {
        saveBtnClickBlock?(self.contentImgV.image)
    }
    
    @objc func shareBtnClick(sender: UIButton) {
        shareBtnClickBlock?(self.contentImgV.image)
    }
    
    func setupView() {
        backgroundColor = UIColor.white
        
        //
//        let bgBtn = UIButton(type: .custom)
//        bgBtn
//            .image(UIImage(named: ""))
//            .adhere(toSuperview: self)
//        bgBtn.addTarget(self, action: #selector(backBtnClick(sender:)), for: .touchUpInside)
//        bgBtn.snp.makeConstraints {
//            $0.left.right.top.bottom.equalToSuperview()
//        }
        
        contentImgV.adhere(toSuperview: self)
            .contentMode(.scaleAspectFill)
            .clipsToBounds()
        
        //
        let contentV = UIView()
            .backgroundColor(UIColor(hexString: "#FFFFFF")!)
            .adhere(toSuperview: self)
        //        contentV.layer.cornerRadius = 0
        //        contentV.layer.masksToBounds = true
//        contentV.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.6).cgColor
//        contentV.layer.shadowOffset = CGSize(width: 0, height: -1)
//        contentV.layer.shadowRadius = 3
//        contentV.layer.shadowOpacity = 0.8
        //        contentV.layer.borderWidth = 2
        //        contentV.layer.borderColor = UIColor.black.cgColor
        contentV.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.top.equalTo(self.safeAreaLayoutGuide.snp.bottom).offset(-200)
        }
        
        //
        let backBtn = UIButton(type: .custom)
        backBtn
            .backgroundColor(UIColor.black)
            .adhere(toSuperview: contentV)
        backBtn.snp.makeConstraints {
            $0.left.equalToSuperview().offset(24)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(70)
        }
        backBtn.addTarget(self, action: #selector(backBtnClick(sender:)), for: .touchUpInside)
         
        //
        let saveBtn = UIButton(type: .custom)
        saveBtn
            .backgroundColor(UIColor.black)
            .adhere(toSuperview: contentV)
        saveBtn.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(70)
        }
        saveBtn.addTarget(self, action: #selector(saveBtnClick(sender:)), for: .touchUpInside)
         
        //
        let shareBtn = UIButton(type: .custom)
        shareBtn
            .backgroundColor(UIColor.black)
            .adhere(toSuperview: contentV)
        shareBtn.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-24)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(70)
        }
        shareBtn.addTarget(self, action: #selector(shareBtnClick(sender:)), for: .touchUpInside)
         
    }
    
}
