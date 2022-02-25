//
//  PCsUserPhotoMakerVC.swift
//  PCkbsPositionCam
//
//  Created by JOJO on 2022/2/24.
//

import UIKit
import Photos
import YPImagePicker
import ZKProgressHUD

class PCsUserPhotoMakerVC: UIViewController, UINavigationControllerDelegate {
    var originalImg: UIImage
    let bottomBar = UIView()
    let toolBgV = UIView()
    var canvasBgV: UIView = UIView()
    var canvasContentBgV: UIImageView = UIImageView()
//    var canvasContentImgV: UIImageView = UIImageView()
    let topContentBgV = UIView()
    let layoutTypeBtn = UIButton()
    var backBtn = UIButton()
    var downloadBtn = UIButton()
    var albumBtn = UIButton()
    let filterBar = PCkFilterBar()
    let layoutTypeBar = PCkLayoutPopView()
    
    var currentApplyingFilterItem: CamFilterItem?
    var didLayoutOnce: Once = Once()
    var currentLayoutTypeItem:  PCpLayoutItem?
    var overlayerImgViews: [PCkOverlayerImgView] = []
    var overlayerLines: [UIView] = []
    
    var cropImgs: [UIImage] = []
    var partFullImgs: [UIImage] = []
    
    
    init(originalImg: UIImage) {
        self.originalImg = originalImg
        
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 用户选择自己的photo
        // 进行切割 然后像相机拍摄的VC一样 逐个显示
        
        currentLayoutTypeItem = PCpDataManager.default.layoutTypeList[1]
        
        setupView()
        setupLayoutTypePopupView()
        processPartImgs()
        
        showsetupLayoutPopupViewView()
        layoutTypeBtn.isSelected = true
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            [weak self] in
            guard let `self` = self else {return}
            self.setupOverlayerLayout()
        }
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
            
            canvasBgV.frame = CGRect(x: leftOffset, y: topOffset, width: cameraWidth, height: cameraHeight)
            
            //
            canvasContentBgV.frame = CGRect(x: 0, y: 0, width: cameraWidth, height: cameraHeight)
            
            
            
            
        }
    }

}

extension PCsUserPhotoMakerVC {
    
    func processPartImgs() {
        
    }
    
    func setupView() {
        //
        view.backgroundColor(UIColor(hexString: "F4F4F4")!)
        //
        canvasBgV.adhere(toSuperview: topContentBgV)
        canvasContentBgV
            .adhere(toSuperview: canvasBgV)
            .backgroundColor(.clear)
        canvasContentBgV.image = originalImg
        //
        bottomBar
            .backgroundColor(.white)
            .adhere(toSuperview: view)
        bottomBar.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            $0.height.equalTo(120)
        }
        //
        
        toolBgV.backgroundColor(.white)
            .adhere(toSuperview: view)
        toolBgV.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.bottom.equalTo(bottomBar.snp.top).offset(0)
            $0.height.equalTo(70)
        }
        //
        
        topContentBgV.backgroundColor(.white)
            .adhere(toSuperview: view)
        topContentBgV.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(0)
            $0.bottom.equalTo(toolBgV.snp.top)
        }
        
        //
        
        downloadBtn
            .image(UIImage(named: ""))
            .backgroundColor(.orange)
            .adhere(toSuperview: bottomBar)
        downloadBtn.layer.cornerRadius = 90/2
        downloadBtn.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(90)
        }
        downloadBtn.addTarget(self, action: #selector(downloadBtnClick(sender: )), for: .touchUpInside)
        //
        backBtn
            .image(UIImage(named: ""))
            .backgroundColor(.green)
            .adhere(toSuperview: bottomBar)
        backBtn.addTarget(self, action: #selector(backBtnClick(sender: )), for: .touchUpInside)
        backBtn.snp.makeConstraints {
            $0.centerY.equalTo(bottomBar.snp.centerY)
            $0.left.equalToSuperview().offset(25)
            $0.width.height.equalTo(60)
        }
        //
        albumBtn
            .image(UIImage(named: ""))
            .backgroundColor(.blue)
            .adhere(toSuperview: bottomBar)
        albumBtn.addTarget(self, action: #selector(albumBtnClick(sender: )), for: .touchUpInside)
        albumBtn.snp.makeConstraints {
            $0.centerY.equalTo(bottomBar.snp.centerY)
            $0.right.equalToSuperview().offset(-25)
            $0.width.height.equalTo(60)
        }
        
        //
        let bottomMaskV = UIView()
        bottomMaskV.backgroundColor(.white)
            .adhere(toSuperview: view)
        bottomMaskV.snp.makeConstraints {
            $0.left.right.bottom.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        //
        filterBar.backgroundColor(.white)
        filterBar.adhere(toSuperview: toolBgV)
        filterBar.snp.makeConstraints {
            $0.right.equalToSuperview()
            $0.bottom.equalTo(bottomBar.snp.top).offset(0)
            $0.height.equalTo(70)
            $0.left.equalToSuperview().offset(80)
        }
        filterBar.camFilterBarClickBlock = {
            [weak self] filterItem in
            guard let `self` = self else {return}
            DispatchQueue.main.async {
                self.updateFilterItem(item: filterItem)
            }
        }
        
        //
        layoutTypeBtn.adhere(toSuperview: toolBgV)
            .backgroundColor(.lightGray)
        layoutTypeBtn.snp.makeConstraints {
            $0.left.equalToSuperview().offset(10)
            $0.centerY.equalTo(filterBar.snp.centerY)
            $0.width.height.equalTo(50)
        }
        layoutTypeBtn.addTarget(self, action: #selector(layoutTypeBtnClick(sender: )), for: .touchUpInside)
    }
    
    
    
}

extension PCsUserPhotoMakerVC {
    
    func setupOverlayerLayout() {
        for v in overlayerImgViews {
            v.removeFromSuperview()
        }
        for v in overlayerLines {
            v.removeFromSuperview()
        }
        
        overlayerImgViews = []
        overlayerLines = []
        
        if currentLayoutTypeItem?.layout == "0" {
            // ver 5
            processVerLayout(count: 5)
        } else if currentLayoutTypeItem?.layout == "1" {
            // ver 4
            processVerLayout(count: 4)
        } else if currentLayoutTypeItem?.layout == "2" {
            // ver 3
            processVerLayout(count: 3)
        } else if currentLayoutTypeItem?.layout == "3" {
            // ver 2
            processVerLayout(count: 2)
        } else if currentLayoutTypeItem?.layout == "4" {
            // hor 5
            processHorLayout(count: 5)
        } else if currentLayoutTypeItem?.layout == "5" {
            // hor 4
            processHorLayout(count: 4)
        } else if currentLayoutTypeItem?.layout == "6" {
            // hor 3
            processHorLayout(count: 3)
        } else if currentLayoutTypeItem?.layout == "7" {
            // hor 2
            processHorLayout(count: 2)
        } else if currentLayoutTypeItem?.layout == "8" {
            // CxC
            processRectCxC(countW: 2, countH: 2)
        } else if currentLayoutTypeItem?.layout == "9" {
            // CxC
            processRectCxC(countW: 3, countH: 3)
        } else if currentLayoutTypeItem?.layout == "10" {
            // CxC
            processRectCxC(countW: 2, countH: 3)
        } else {
            processRectCxC(countW: 2, countH: 2)
        }
    }
}

extension PCsUserPhotoMakerVC {
    func processImg() {
        
        guard let fullImg = self.canvasContentBgV.image else { return }
        
        cropImgs = []
        partFullImgs = []
        
        for overlayerV in overlayerImgViews {
            
            let scaleW = fullImg.size.width/self.canvasContentBgV.bounds.width
            let scaleH = fullImg.size.height/self.canvasContentBgV.bounds.height
            let sacle = UIScreen.main.scale
            let orightX: CGFloat = overlayerV.frame.origin.x * scaleW * sacle
            let orightY: CGFloat = overlayerV.frame.origin.y * scaleH * sacle
            let imgWidth: CGFloat = overlayerV.frame.width * scaleW * sacle
            let imgHeight: CGFloat = overlayerV.frame.height * scaleH * sacle
            let cropRect = CGRect(x: orightX, y: orightY, width: imgWidth, height: imgHeight)
            guard let cutImageRef: CGImage = fullImg.cgImage?.cropping(to:cropRect)
            else {
                return
            }
            
            // Return image to UIImage
            let croppedImage: UIImage = UIImage(cgImage: cutImageRef)
            cropImgs.append(croppedImage)
            //
            let partImgBgV = UIView(frame: CGRect(x: 0, y: 0, width: fullImg.size.width, height: fullImg.size.height))
            partImgBgV.backgroundColor(.white)
            //
            for (idx, befaultCutImg) in self.cropImgs.enumerated() {
                let partImgV = UIImageView(image: befaultCutImg)
                let boverlayerImgV = self.overlayerImgViews[idx]
                let borightX: CGFloat = boverlayerImgV.frame.origin.x * scaleW
                let borightY: CGFloat = boverlayerImgV.frame.origin.y * scaleH
                let bimgWidth: CGFloat = boverlayerImgV.frame.width * scaleW
                let bimgHeight: CGFloat = boverlayerImgV.frame.height * scaleH
                let beforeRect = CGRect(x: borightX, y: borightY, width: bimgWidth, height: bimgHeight)
                partImgV.frame = beforeRect
                partImgV.adhere(toSuperview: partImgBgV)
            }
            //
//            let partImgV = UIImageView(image: UIImage(cgImage: cutImageRef))
//            partImgV.frame = CGRect(x: orightX, y: orightY, width: imgWidth, height: imgHeight)
//            partImgV.adhere(toSuperview: partImgBgV)
            
            
            
            if let fullPartImg = partImgBgV.screenshot {
                partFullImgs.append(fullPartImg)
            }
           
            
        }
    }
//    func takePhoto(overlayerV: PCkOverlayerImgView?, completion: @escaping ((UIImage?, UIImage?)->Void)) {
//        if let overlayerV_m = overlayerV {
//            camera.capturePhoto { [weak self] info in
//                switch info.result {
//                case let .success(texture):
//                    DispatchQueue.main.async {
//                        [weak self] in
//                        guard let `self` = self else {return}
//                        if let img = texture.bb_image {
//
//
//                        } else {
//                            completion(nil, nil)
//                        }
//                    }
//                case let .failure(error):
//                    print("Error: \(error)")
//                    completion(nil, nil)
//                }
//            }
//        } else {
//            completion(nil, nil)
//        }
//
//    }
}

extension PCsUserPhotoMakerVC {
    
    @objc func backBtnClick(sender: UIButton) {
        if self.navigationController != nil {
            self.navigationController?.popViewController()
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func downloadBtnClick(sender: UIButton) {
        if layoutTypeBtn.isSelected == true {
            self.layoutTypeBar.backBtnClickBlock?()
        }
        processImg()
        
        let vc = PCsGifSaveConvertVC(photos: partFullImgs, nil, false)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func albumBtnClick(sender: UIButton) {
        checkAlbumAuthorization()
    }
    
    @objc func layoutTypeBtnClick(sender: UIButton) {
        if layoutTypeBtn.isSelected == true {
            self.layoutTypeBar.backBtnClickBlock?()
        } else {
            showsetupLayoutPopupViewView()
        }
        layoutTypeBtn.isSelected = !layoutTypeBtn.isSelected
    }
    
}

extension PCsUserPhotoMakerVC {
    func processVerLayout(count: CGFloat) {
        for itemIdx in 0..<Int(count) {
            let imgV = PCkOverlayerImgView()
            imgV
                .backgroundColor(UIColor.clear)
            imgV.adhere(toSuperview: canvasBgV)
            let height: CGFloat = canvasContentBgV.bounds.height / count
            imgV.frame = CGRect(x: canvasContentBgV.frame.origin.x, y: canvasContentBgV.frame.origin.y + height * CGFloat(itemIdx), width: canvasContentBgV.bounds.width, height: height)
            overlayerImgViews.append(imgV)
        }
        for itemIdx in 0..<Int(count - 1) {
            let baseImgV = overlayerImgViews[itemIdx]
            let line = UIView()
            line.backgroundColor(.lightGray)
                .adhere(toSuperview: canvasBgV)
            line.frame = CGRect(x: 0, y: baseImgV.frame.maxY, width: canvasContentBgV.bounds.width, height: 1)
            overlayerLines.append(line)
        }
    }
    
    func processHorLayout(count: CGFloat) {
        for itemIdx in 0..<Int(count) {
            let imgV = PCkOverlayerImgView()
            imgV
                .backgroundColor(UIColor.clear)
            imgV.adhere(toSuperview: canvasBgV)
            let width: CGFloat = canvasContentBgV.bounds.width / count
            
            imgV.frame = CGRect(x: canvasContentBgV.frame.origin.x + width * CGFloat(itemIdx), y: canvasContentBgV.frame.origin.y, width: width, height: canvasContentBgV.bounds.height)
            overlayerImgViews.append(imgV)
        }
        for itemIdx in 0..<Int(count - 1) {
            let baseImgV = overlayerImgViews[itemIdx]
            let line = UIView()
            line.backgroundColor(.lightGray)
                .adhere(toSuperview: canvasBgV)
            line.frame = CGRect(x: baseImgV.frame.maxX, y: 0, width: 1, height: canvasContentBgV.bounds.height)
            overlayerLines.append(line)
        }
    }
    
    func processRectCxC(countW: CGFloat, countH: CGFloat) {
        
        let all = Int(countW) * Int(countH)
        let width: CGFloat = canvasContentBgV.bounds.width / (countW)
        let height: CGFloat = canvasContentBgV.bounds.height / (countH)
        
        for itemIdx in 0..<all {
            let yushuIndex = CGFloat(itemIdx % Int(countW))
            let chushuLine = CGFloat(itemIdx / Int(countH))
            
            let imgV = PCkOverlayerImgView()
            imgV
                .backgroundColor(UIColor.clear)
            imgV.adhere(toSuperview: canvasBgV)
            imgV.frame = CGRect(x: canvasContentBgV.frame.origin.x + width * yushuIndex, y: canvasContentBgV.frame.origin.y + height * chushuLine, width: width, height: height)
            overlayerImgViews.append(imgV)
        }
        
        let lineWCount: Int = (Int(countW) - 1)
        let lineHCount: Int = (Int(countH) - 1)
        
        for itemIdx in 0..<lineWCount {
            let line = UIView()
            line.backgroundColor(.lightGray)
                .adhere(toSuperview: canvasBgV)
            line.frame = CGRect(x: width * (1 + CGFloat(itemIdx)), y: 0, width: 1, height: canvasContentBgV.bounds.height)
            overlayerLines.append(line)
        }
        for itemIdx in 0..<lineHCount {
            let line = UIView()
            line.backgroundColor(.lightGray)
                .adhere(toSuperview: canvasBgV)
            line.frame = CGRect(x: 0, y: height * (1 + CGFloat(itemIdx)), width: canvasContentBgV.bounds.width, height: 1)
            overlayerLines.append(line)
        }
    }
}

extension PCsUserPhotoMakerVC {
    
    func setupLayoutTypePopupView() {
        
        layoutTypeBar.alpha = 0
        view.addSubview(layoutTypeBar)
        layoutTypeBar.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.bottom.equalTo(toolBgV.snp.top)
            $0.height.equalTo(60)
        }
        
    }

    func showsetupLayoutPopupViewView() {
        // show coin alert
        UIView.animate(withDuration: 0.35) {
            self.layoutTypeBar.alpha = 1
        }
        
        layoutTypeBar.layoutItemClickBlock = {
            [weak self] item in
            guard let `self` = self else {return}
            DispatchQueue.main.async {
                self.currentLayoutTypeItem = item
                self.setupOverlayerLayout()
            }

//            UIView.animate(withDuration: 0.25) {
//                self.layoutTypeBar.alpha = 0
//            } completion: { finished in
//                if finished {
//
//                }
//            }
        }
        
        
        layoutTypeBar.backBtnClickBlock = {
            [weak self] in
            guard let `self` = self else {return}
            UIView.animate(withDuration: 0.25) {
                self.layoutTypeBar.alpha = 0
            } completion: { finished in
                if finished {
                    
                }
            }
        }
    }
}

extension PCsUserPhotoMakerVC {
    func updateFilterItem(item: CamFilterItem) {
//        camera.removeAllConsumers()
        currentApplyingFilterItem = item
        guard let filter = item.filter else {
//            camera.add(consumer: metalView)
//            camera.willTransmitTexture = nil
            
            return
        }
        let processImg = filter.filteredImage(with: originalImg)
        self.canvasContentBgV.image = processImg
        //
//        camera.add(consumer: filter).add(consumer: metalView)
        
    }
    
}


extension PCsUserPhotoMakerVC: UIImagePickerControllerDelegate {
    
    func checkAlbumAuthorization() {
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            if #available(iOS 14, *) {
                PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                    switch status {
                    case .authorized:
                        DispatchQueue.main.async {
//                            self.presentPhotoPickerController()
                            self.presentLimitedPhotoPickerController()
                        }
                    case .limited:
                        DispatchQueue.main.async {
                            self.presentLimitedPhotoPickerController()
                        }
                    case .notDetermined:
                        if status == PHAuthorizationStatus.authorized {
                            DispatchQueue.main.async {
//                                self.presentPhotoPickerController()
                                self.presentLimitedPhotoPickerController()
                            }
                        } else if status == PHAuthorizationStatus.limited {
                            DispatchQueue.main.async {
                                self.presentLimitedPhotoPickerController()
                            }
                        }
                    case .denied:
                        DispatchQueue.main.async {
                            [weak self] in
                            guard let `self` = self else {return}
                            let alert = UIAlertController(title: "Oops", message: "You have declined access to photos, please active it in Settings>Privacy>Photos.", preferredStyle: .alert)
                            let confirmAction = UIAlertAction(title: "Ok", style: .default, handler: { (goSettingAction) in
                                DispatchQueue.main.async {
                                    let url = URL(string: UIApplication.openSettingsURLString)!
                                    UIApplication.shared.open(url, options: [:])
                                }
                            })
                            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
                            alert.addAction(confirmAction)
                            alert.addAction(cancelAction)
                            
                            self.present(alert, animated: true)
                        }
                        
                    case .restricted:
                        DispatchQueue.main.async {
                            [weak self] in
                            guard let `self` = self else {return}
                            let alert = UIAlertController(title: "Oops", message: "You have declined access to photos, please active it in Settings>Privacy>Photos.", preferredStyle: .alert)
                            let confirmAction = UIAlertAction(title: "Ok", style: .default, handler: { (goSettingAction) in
                                DispatchQueue.main.async {
                                    let url = URL(string: UIApplication.openSettingsURLString)!
                                    UIApplication.shared.open(url, options: [:])
                                }
                            })
                            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
                            alert.addAction(confirmAction)
                            alert.addAction(cancelAction)
                            
                            self.present(alert, animated: true)
                        }
                    default: break
                    }
                }
            } else {
                
                PHPhotoLibrary.requestAuthorization { status in
                    switch status {
                    case .authorized:
                        DispatchQueue.main.async {
//                            self.presentPhotoPickerController()
                            self.presentLimitedPhotoPickerController()
                        }
                    case .limited:
                        DispatchQueue.main.async {
                            self.presentLimitedPhotoPickerController()
                        }
                    case .denied:
                        DispatchQueue.main.async {
                            [weak self] in
                            guard let `self` = self else {return}
                            let alert = UIAlertController(title: "Oops", message: "You have declined access to photos, please active it in Settings>Privacy>Photos.", preferredStyle: .alert)
                            let confirmAction = UIAlertAction(title: "Ok", style: .default, handler: { (goSettingAction) in
                                DispatchQueue.main.async {
                                    let url = URL(string: UIApplication.openSettingsURLString)!
                                    UIApplication.shared.open(url, options: [:])
                                }
                            })
                            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
                            alert.addAction(confirmAction)
                            alert.addAction(cancelAction)
                            
                            self.present(alert, animated: true)
                        }
                        
                    case .restricted:
                        DispatchQueue.main.async {
                            [weak self] in
                            guard let `self` = self else {return}
                            let alert = UIAlertController(title: "Oops", message: "You have declined access to photos, please active it in Settings>Privacy>Photos.", preferredStyle: .alert)
                            let confirmAction = UIAlertAction(title: "Ok", style: .default, handler: { (goSettingAction) in
                                DispatchQueue.main.async {
                                    let url = URL(string: UIApplication.openSettingsURLString)!
                                    UIApplication.shared.open(url, options: [:])
                                }
                            })
                            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
                            alert.addAction(confirmAction)
                            alert.addAction(cancelAction)
                            
                            self.present(alert, animated: true)
                        }
                    default: break
                    }
                }
                
            }
        }
    }
    
    func presentLimitedPhotoPickerController() {
        var config = YPImagePickerConfiguration()
        
        config.library.maxNumberOfItems = 1
        config.library.minNumberOfItems = 1
        config.library.mediaType = .photo
        config.screens = [.library]
        config.library.defaultMultipleSelection = false
        config.library.isSquareByDefault = false
        config.library.skipSelectionsGallery = true
        config.showsPhotoFilters = false
        config.library.preselectedItems = nil
        let picker = YPImagePicker(configuration: config)
        picker.view.backgroundColor = UIColor.white
        picker.didFinishPicking { [unowned picker] items, cancelled in
            
            var imgs: [UIImage] = []
            for item in items {
                switch item {
                case .photo(let photo):
                    // 裁剪成3：4图片
                    let width: CGFloat = 1200
                    let height: CGFloat = width / (3/4)
                    if let img = photo.image.scaled(toWidth: width) {
                        debugPrint("imgSize: \(img.size)")
                        let imgBgV = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
                        imgBgV.backgroundColor(.white)
                        var yOffset: CGFloat = 0
                        if img.size.height >= height {
                            yOffset = -(img.size.height - height) / 2
                        } else {
                            yOffset = (height - img.size.height) / 2
                        }
                        let imgV = UIImageView(frame: CGRect(x: 0, y: yOffset, width: width, height: img.size.height))
                        imgV.image = img
                        imgV.contentMode(.scaleAspectFill)
                            .adhere(toSuperview: imgBgV)
                        if let i = imgBgV.screenshot {
                            imgs.append(i)
                        }
                    }
                    print(photo)
                case .video(let video):
                    print(video)
                }
            }
            picker.dismiss(animated: true, completion: nil)
            if !cancelled {
                self.updateContentOriginImage(images: imgs)
            }
        }
        picker.navigationBar.backgroundColor = UIColor.white
//        self.navigationController?.pushViewController(picker, animated: true)
        present(picker, animated: true, completion: nil)
    }
    
     
 
    func presentPhotoPickerController() {
        let myPickerController = UIImagePickerController()
        myPickerController.allowsEditing = false
        myPickerController.delegate = self
        myPickerController.sourceType = .photoLibrary
        self.present(myPickerController, animated: true, completion: nil)

    }
    
    
    func updateContentOriginImage(images: [UIImage]) {
        if let img = images.first {
            self.originalImg = img
            if let filter = currentApplyingFilterItem?.filter {
                let processImg = filter.filteredImage(with: originalImg)
                self.canvasContentBgV.image = processImg
            } else {
                self.canvasContentBgV.image = originalImg
            }
        }
    }

}





