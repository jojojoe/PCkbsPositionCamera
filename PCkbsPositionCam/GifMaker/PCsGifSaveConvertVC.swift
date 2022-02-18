//
//  PCsGifSaveConvertVC.swift
//  PCkbsPositionCam
//
//  Created by JOJO on 2022/2/18.
//

import UIKit

class ContinuePhotosItem {
    var img: UIImage
    var isTaking: Bool // 是否是从前面拍照而来
    init(img: UIImage, isTaking: Bool) {
        self.img = img
        self.isTaking = isTaking
    }
}
class PCsGifContinuePhotosData {
    
    var takePhotos: [ContinuePhotosItem] = []
    
}

class PCsGifSaveConvertVC: UIViewController {
    
    let continuePhotoData = PCsGifContinuePhotosData()
    
    let topBanner = UIView()
    let backBtn = UIButton()
    let bottomBar = UIView()
    var topContentBgV: UIView = UIView()
    var canvasBgV: UIView = UIView()
    var didLayoutOnce: Once = Once()
    
    
    init(photos: [UIImage]) {
        super.init(nibName: nil, bundle: nil)
        
        for photo in photos {
            let item = ContinuePhotosItem(img: photo, isTaking: true)
            continuePhotoData.takePhotos.append(item)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        didLayoutOnce.run {
            //
            var topOffset: CGFloat = 0
            var leftOffset: CGFloat = 0
            
            let topContentBgVWidth: CGFloat = self.topContentBgV.width
            let topContentBgVHeight: CGFloat = self.topContentBgV.height
            
            let topWH = topContentBgVWidth / topContentBgVHeight
            let cameraWH: CGFloat = 3/4
            var cameraWidth: CGFloat = 1
            var cameraHeight: CGFloat = 1
            if topWH > cameraWH {
                cameraWidth = topContentBgVHeight * cameraWH
                cameraHeight = topContentBgVHeight
                topOffset = 0
                leftOffset = (topContentBgVWidth - cameraWidth) / 2
            } else {
                cameraWidth = topContentBgVWidth
                cameraHeight = topContentBgVWidth / cameraWH
                topOffset = (topContentBgVHeight - cameraHeight) / 2
                leftOffset = 0
            }
            
            //
            canvasBgV.adhere(toSuperview: view)
                .backgroundColor(.lightGray)
            canvasBgV.frame = CGRect(x: leftOffset, y: topOffset, width: cameraWidth, height: cameraHeight)
            
             
            
        }
    }
}

extension PCsGifSaveConvertVC {
    func setupView() {
        view.backgroundColor(.white)
        view.clipsToBounds()
        //
        
        topBanner.backgroundColor(.white)
            .adhere(toSuperview: view)
        topBanner.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.height.equalTo(44)
        }
        //

        backBtn.adhere(toSuperview: topBanner)
        backBtn.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalToSuperview().offset(10)
            $0.width.height.equalTo(44)
        }
        
        //
        topContentBgV.adhere(toSuperview: view)
        topContentBgV.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.top.equalTo(topBanner.snp.bottom)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-200)
        }
        
        
        //

        bottomBar.adhere(toSuperview: view)
        bottomBar.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.right.left.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-200)
        }
        
        var btnHeight: CGFloat = 70
        
        //
        let toGifBtn = UIButton()
        toGifBtn.backgroundColor(.white)
            .title("Save as GIF")
            .titleColor(UIColor.black)
            .font(20, "AvenirNext-DemiBold")
            .adhere(toSuperview: bottomBar)
        toGifBtn.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.left.equalToSuperview().offset(20)
            $0.height.equalTo(btnHeight)
            $0.right.equalTo(view.safeAreaLayoutGuide.snp.centerX).offset(-10)
        }
        toGifBtn.addTarget(self, action: #selector(toGifBtnClick(sender: )), for: .touchUpInside)
        
        //
        let toLivePhotoBtn = UIButton()
        toLivePhotoBtn.backgroundColor(.white)
            .title("Save as LivePhoto")
            .titleColor(UIColor.black)
            .font(20, "AvenirNext-DemiBold")
            .adhere(toSuperview: bottomBar)
        toLivePhotoBtn.snp.makeConstraints {
            $0.top.equalTo(toGifBtn.snp.top)
            $0.right.equalToSuperview().offset(-20)
            $0.height.equalTo(btnHeight)
            $0.left.equalTo(view.safeAreaLayoutGuide.snp.centerX).offset(10)
        }
        toLivePhotoBtn.addTarget(self, action: #selector(toLivePhotoBtnClick(sender:)), for: .touchUpInside)
        
        //
        let toVideoBtn = UIButton()
        toVideoBtn.backgroundColor(.white)
            .title("Save as Video")
            .titleColor(UIColor.black)
            .font(20, "AvenirNext-DemiBold")
            .adhere(toSuperview: bottomBar)
        toVideoBtn.snp.makeConstraints {
            $0.top.equalTo(toGifBtn.snp.bottom).offset(20)
            $0.left.equalTo(toGifBtn.snp.left)
            $0.height.equalTo(btnHeight)
            $0.right.equalTo(view.safeAreaLayoutGuide.snp.centerX).offset(-10)
        }
        toVideoBtn.addTarget(self, action: #selector(toVideoBtnClick(sender: )), for: .touchUpInside)
        
        //
        let savePhotosBtn = UIButton()
        savePhotosBtn.backgroundColor(.white)
            .title("Save 8 Photos")
            .titleColor(UIColor.black)
            .font(20, "AvenirNext-DemiBold")
            .adhere(toSuperview: bottomBar)
        savePhotosBtn.snp.makeConstraints {
            $0.top.equalTo(toVideoBtn.snp.top)
            $0.right.equalToSuperview().offset(-20)
            $0.height.equalTo(btnHeight)
            $0.left.equalTo(view.safeAreaLayoutGuide.snp.centerX).offset(10)
        }
        savePhotosBtn.addTarget(self, action: #selector(savePhotosBtnClick(sender:)), for: .touchUpInside)
        
    }
}

extension PCsGifSaveConvertVC {
    @objc func toGifBtnClick(sender: UIButton) {
        
    }
    
    @objc func toVideoBtnClick(sender: UIButton) {
        
    }
    
    @objc func toLivePhotoBtnClick(sender: UIButton) {
        
    }
    
    @objc func savePhotosBtnClick(sender: UIButton) {
        
    }
    
}



