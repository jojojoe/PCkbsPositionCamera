//
//  PCsCameraVC.swift
//  PCkbsPositionCam
//
//  Created by JOJO on 2022/2/9.
//


import UIKit
import BBMetalImage
import AVFoundation
import DeviceKit
import Photos

 
class PCsCameraVC: UIViewController {

    private var camera: BBMetalCamera!
    private var metalView: BBMetalView!
    var canvasBgV: UIView = UIView()
    let topContentBgV = UIView()
    let bottomBar = UIView()
    let toolBgV = UIView()
    let layoutTypeBtn = UIButton()
    var backBtn = UIButton()
    var takePhotoBtn = UIButton()
    var camPositionBtn = UIButton()
    var overlayerImgViews: [PCkOverlayerImgView] = []
    var overlayerLines: [UIView] = []
    let filterBar = PCkFilterBar()
    var partFullImgsList: [UIImage] = []
    var cutImgsList: [UIImage] = []
    let layoutTypeBar = PCkLayoutPopView()
    var currentLayoutTypeItem:  PCpLayoutItem?
    var currentTakingOverImgV: PCkOverlayerImgView?
    var currentTakingOverImgVIndex: Int = 0
    
    let savePopupView = PCkSavePopView()
    
    var currentApplyingFilterItem: CamFilterItem?
    var didLayoutOnce: Once = Once()
    
    var isReadyCamera: Bool = false
    var isCancel: Bool = false
    var isTakingStatus: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentLayoutTypeItem = PCpDataManager.default.layoutTypeList[1]
        
        setupView()
        setupLayoutTypePopupView()
        setupSavePopupView()
        
        showsetupLayoutPopupViewView()
        layoutTypeBtn.isSelected = true
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            [weak self] in
            guard let `self` = self else {return}
            self.setupOverlayerLayout()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isReadyCamera == true {
            camera.start()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        camera.stop()
        
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
            canvasBgV.frame = CGRect(x: leftOffset, y: topOffset, width: cameraWidth, height: cameraHeight)
            
            //
            metalView = BBMetalView(frame: CGRect(x: 0, y: 0, width: cameraWidth, height: cameraHeight))
            metalView.adhere(toSuperview: canvasBgV)
            metalView.backgroundColor(.clear)
            //
            camera = BBMetalCamera(sessionPreset: .hd1920x1080)
            camera.add(consumer: metalView)
            /*
             hd4K3840x2160
             let topOffsety: Float = ((3840 - 2160) / 2) / 3840
             let heightP: Float = 2160 / 3840
             */
            camera.start()
            isReadyCamera = true
            
        }
    }
    
    func setupView() {
        //
        view.backgroundColor(UIColor(hexString: "F4F4F4")!)
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
        takePhotoBtn
            .image(UIImage(named: ""))
            .backgroundColor(.orange)
            .adhere(toSuperview: bottomBar)
        takePhotoBtn.layer.cornerRadius = 90/2
        takePhotoBtn.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(90)
        }
        takePhotoBtn.addTarget(self, action: #selector(takePhotoBtnClick(sender: )), for: .touchUpInside)
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
        camPositionBtn
            .image(UIImage(named: ""))
            .backgroundColor(.blue)
            .adhere(toSuperview: bottomBar)
        camPositionBtn.addTarget(self, action: #selector(camPositionBtnClick(sender: )), for: .touchUpInside)
        camPositionBtn.snp.makeConstraints {
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

extension PCsCameraVC {
    
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

extension PCsCameraVC {
    func processVerLayout(count: CGFloat) {
        for itemIdx in 0..<Int(count) {
            let imgV = PCkOverlayerImgView()
            imgV
                .backgroundColor(UIColor.clear)
            imgV.adhere(toSuperview: canvasBgV)
            let height: CGFloat = metalView.bounds.height / count
            imgV.frame = CGRect(x: metalView.frame.origin.x, y: metalView.frame.origin.y + height * CGFloat(itemIdx), width: metalView.bounds.width, height: height)
            overlayerImgViews.append(imgV)
        }
        for itemIdx in 0..<Int(count - 1) {
            let baseImgV = overlayerImgViews[itemIdx]
            let line = UIView()
            line.backgroundColor(.lightGray)
                .adhere(toSuperview: canvasBgV)
            line.frame = CGRect(x: 0, y: baseImgV.frame.maxY, width: metalView.bounds.width, height: 1)
            overlayerLines.append(line)
        }
    }
    
    func processHorLayout(count: CGFloat) {
        for itemIdx in 0..<Int(count) {
            let imgV = PCkOverlayerImgView()
            imgV
                .backgroundColor(UIColor.clear)
            imgV.adhere(toSuperview: canvasBgV)
            let width: CGFloat = metalView.bounds.width / count
            
            imgV.frame = CGRect(x: metalView.frame.origin.x + width * CGFloat(itemIdx), y: metalView.frame.origin.y, width: width, height: metalView.bounds.height)
            overlayerImgViews.append(imgV)
        }
        for itemIdx in 0..<Int(count - 1) {
            let baseImgV = overlayerImgViews[itemIdx]
            let line = UIView()
            line.backgroundColor(.lightGray)
                .adhere(toSuperview: canvasBgV)
            line.frame = CGRect(x: baseImgV.frame.maxX, y: 0, width: 1, height: metalView.bounds.height)
            overlayerLines.append(line)
        }
    }
    
    func processRectCxC(countW: CGFloat, countH: CGFloat) {
        
        let all = Int(countW) * Int(countH)
        let width: CGFloat = metalView.bounds.width / (countW)
        let height: CGFloat = metalView.bounds.height / (countH)
        
        for itemIdx in 0..<all {
            let yushuIndex = CGFloat(itemIdx % Int(countW))
            let chushuLine = CGFloat(itemIdx / Int(countH))
            
            let imgV = PCkOverlayerImgView()
            imgV
                .backgroundColor(UIColor.clear)
            imgV.adhere(toSuperview: canvasBgV)
            imgV.frame = CGRect(x: metalView.frame.origin.x + width * yushuIndex, y: metalView.frame.origin.y + height * chushuLine, width: width, height: height)
            overlayerImgViews.append(imgV)
        }
        
        let lineWCount: Int = (Int(countW) - 1)
        let lineHCount: Int = (Int(countH) - 1)
        
        for itemIdx in 0..<lineWCount {
            let line = UIView()
            line.backgroundColor(.lightGray)
                .adhere(toSuperview: canvasBgV)
            line.frame = CGRect(x: width * (1 + CGFloat(itemIdx)), y: 0, width: 1, height: metalView.bounds.height)
            overlayerLines.append(line)
        }
        for itemIdx in 0..<lineHCount {
            let line = UIView()
            line.backgroundColor(.lightGray)
                .adhere(toSuperview: canvasBgV)
            line.frame = CGRect(x: 0, y: height * (1 + CGFloat(itemIdx)), width: metalView.bounds.width, height: 1)
            overlayerLines.append(line)
        }
    }
}

extension PCsCameraVC {
    @objc func layoutTypeBtnClick(sender: UIButton) {
        if layoutTypeBtn.isSelected == true {
            self.layoutTypeBar.backBtnClickBlock?()
        } else {
            showsetupLayoutPopupViewView()
        }
        layoutTypeBtn.isSelected = !layoutTypeBtn.isSelected
    }
    
    
    
}

extension PCsCameraVC {
    
    func setupSavePopupView() {
        
        savePopupView.alpha = 0
        view.addSubview(savePopupView)
        savePopupView.snp.makeConstraints {
            $0.left.right.bottom.top.equalToSuperview()
        }
    }

    func showSavePopupViewView() {
        // show coin alert
        let img = self.processSaveImg()
        let saveVC = PCsGifSaveConvertVC(photos: partFullImgsList, img, true)
        self.navigationController?.pushViewController(saveVC, animated: true)
        
//
//        self.savePopupView.contentImgV.frame = self.canvasBgV.frame
//        self.savePopupView.contentImgV.image = img
//
//        UIView.animate(withDuration: 0.35) {
//            self.savePopupView.alpha = 1
//        }
//        savePopupView.saveBtnClickBlock = {
//            [weak self] img in
//            guard let `self` = self else {return}
//            self.saveAlertSaveAction(img: img)
//        }
//        savePopupView.shareBtnClickBlock = {
//            [weak self] img in
//            guard let `self` = self else {return}
//            self.saveAlertShareAction(img: img)
//        }
//
//        savePopupView.backBtnClickBlock = {
//            [weak self] in
//            guard let `self` = self else {return}
//            UIView.animate(withDuration: 0.25) {
//                self.savePopupView.alpha = 0
//            } completion: { finished in
//                if finished {
//                    self.saveAlertBackAction()
//                }
//            }
//        }
    }
}

extension PCsCameraVC {
    func saveAlertBackAction() {
        self.camera.start()
        self.resetOverlayerStatus()
    }
    
    func saveAlertSaveAction(img: UIImage?) {
        if let saveImg = img {
            saveImgsToAlbum(imgs: [saveImg])
        }
        
    }
    
    func saveAlertShareAction(img: UIImage?) {
        
        if let saveImg = img {
            let ac = UIActivityViewController(activityItems: [saveImg], applicationActivities: nil)
            ac.modalPresentationStyle = .fullScreen
            ac.completionWithItemsHandler = {
                (type, flag, array, error) -> Void in
                if flag == true {
                     
                } else {
                    
                }
            }
            self.present(ac, animated: true, completion: nil)
        }
    }
}

extension PCsCameraVC {
    
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


extension PCsCameraVC {
    func updateFilterItem(item: CamFilterItem) {
        camera.removeAllConsumers()
        currentApplyingFilterItem = item
        guard let filter = item.filter else {
            camera.add(consumer: metalView)
            camera.willTransmitTexture = nil
            return
        }
        //
        camera.add(consumer: filter).add(consumer: metalView)
        
    }
    
    func takePhotoProcess(image: UIImage) -> UIImage {
        //
        var finalImg: UIImage = image
        if camera.position == .front {
            // flip
            let mirrorFilter = BBMetalFlipFilter(horizontal: true, vertical: false)
            if let img = mirrorFilter.filteredImage(with: finalImg) {
                finalImg = img
            }
        }
        
        
        // crop
        let imgWH: Float = 3/4
        
        let topOffsety: Float = ((1920 - (1080/imgWH)) / 2) / 1920
        let heightP: Float = (1080/imgWH) / 1920
        let cropFilter = BBMetalCropFilter(rect: BBMetalRect(x: 0, y: topOffsety, width: 1, height: heightP))
        
        if let img = cropFilter.filteredImage(with: finalImg) {
            if let applyFilter = currentApplyingFilterItem?.makeFilter(), let filteredImg = applyFilter.filteredImage(with: img) {
                return filteredImg
//                self.showCamEditVC(img: filteredImg)
            } else {
                return img
//                self.showCamEditVC(img: img)
            }
        } else {
            return finalImg
        }
    }
     
    
    
}

extension PCsCameraVC {
    
    func resetOverlayerStatus() {
        for overImgV in overlayerImgViews {
            overImgV.imgV.image = nil
        }
        
    }
    
    func showIsTakingPhotoStatus(isTaking: Bool) {
        
        
        
        if isTaking {
            backBtn.isHidden = true
            camPositionBtn.isHidden = true
            isTakingStatus = true
        } else {
            backBtn.isHidden = false
            camPositionBtn.isHidden = false
            isTakingStatus = false
        }
        
        
         
    }
    
    func takePhotoWithPosition(completion: @escaping (()->Void)) {
       
        func processBlock() {
            
            self.currentTakingOverImgV?.startCounting()
            self.currentTakingOverImgV?.countdownEndBlock = {
                [weak self] in
                guard let `self` = self else {return}
                self.takePhoto(overlayerV: self.currentTakingOverImgV) {[weak self] cutImg, partFullImg in
                    guard let `self` = self else {return}
                    if let partFullImg_m = partFullImg {
                        self.partFullImgsList.append(partFullImg_m)
                    }
                    if let cutImg_m = cutImg {
                        self.cutImgsList.append(cutImg_m)
                    }
                    
                    self.currentTakingOverImgV?.imgV.image = cutImg
                    self.currentTakingOverImgVIndex += 1
                    
                    if self.currentTakingOverImgVIndex >= self.overlayerImgViews.count {
                        completion()
                    } else {
                        self.currentTakingOverImgV = self.overlayerImgViews[self.currentTakingOverImgVIndex]
                        if self.isCancel == true {
                            self.isCancel = false
                        } else {
                            processBlock()
                        }
                    }
                }
            }
        }
        
        processBlock()
        
    }
    
    
    func takePhoto(overlayerV: PCkOverlayerImgView?, completion: @escaping ((UIImage?, UIImage?)->Void)) {
        if let overlayerV_m = overlayerV {
            camera.capturePhoto { [weak self] info in
                switch info.result {
                case let .success(texture):
                    DispatchQueue.main.async {
                        [weak self] in
                        guard let `self` = self else {return}
                        if let img = texture.bb_image {
                            let fullImg = self.takePhotoProcess(image: img)
                            
                            let scaleW = fullImg.size.width/self.canvasBgV.bounds.width
                            let scaleH = fullImg.size.height/self.canvasBgV.bounds.height
                            
                            let orightX: CGFloat = overlayerV_m.frame.origin.x * scaleW
                            let orightY: CGFloat = overlayerV_m.frame.origin.y * scaleH
                            let imgWidth: CGFloat = overlayerV_m.frame.width * scaleW
                            let imgHeight: CGFloat = overlayerV_m.frame.height * scaleH
                            let cropRect = CGRect(x: orightX, y: orightY, width: imgWidth, height: imgHeight)
                            guard let cutImageRef: CGImage = fullImg.cgImage?.cropping(to:cropRect)
                            else {
                                completion(nil, nil)
                                return
                            }
                            
                            // Return image to UIImage
                            let croppedImage: UIImage = UIImage(cgImage: cutImageRef)
                            //
                            let partImgBgV = UIView(frame: CGRect(x: 0, y: 0, width: fullImg.size.width, height: fullImg.size.height))
                            partImgBgV.backgroundColor(.white)
                            //
                            for (idx, befaultCutImg) in self.cutImgsList.enumerated() {
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
                            let partImgV = UIImageView(image: UIImage(cgImage: cutImageRef))
                            partImgV.frame = CGRect(x: orightX, y: orightY, width: imgWidth, height: imgHeight)
                            partImgV.adhere(toSuperview: partImgBgV)
                            
                            
                            var fullPartImg: UIImage? = nil
                            fullPartImg = partImgBgV.screenshot
                           
                            completion(croppedImage, fullPartImg)
                            
                        } else {
                            completion(nil, nil)
                        }
                    }
                case let .failure(error):
                    print("Error: \(error)")
                    completion(nil, nil)
                }
            }
        } else {
            completion(nil, nil)
        }
        
    }
    
    func processSaveImg() -> UIImage? {
        let scale: CGFloat = 3
        
        let saveBgV = UIView()
        saveBgV.frame = CGRect(x: 0, y: 0, width: self.canvasBgV.bounds.width * scale, height: self.canvasBgV.bounds.height * scale)
        for overlayer in overlayerImgViews {
            let imgV = UIImageView(frame: CGRect(x: overlayer.frame.origin.x * scale, y: overlayer.frame.origin.y * scale, width: overlayer.frame.width * scale, height: overlayer.frame.height * scale))
            imgV.adhere(toSuperview: saveBgV)
            imgV.image = overlayer.imgV.image
        }
        let saveImg = saveBgV.screenshot
        return saveImg
        
    }
    
}

extension PCsCameraVC {
    
    @objc func backBtnClick(sender: UIButton) {
        if self.navigationController != nil {
            self.navigationController?.popViewController()
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }

    @objc func takePhotoBtnClick(sender: UIButton) {
        // show taking status
        if layoutTypeBtn.isSelected == true {
            self.layoutTypeBar.backBtnClickBlock?()
        }
        
        
        if isTakingStatus == false {
            showIsTakingPhotoStatus(isTaking: true)
            
            takePhotoWithPosition {
                [weak self] in
                guard let `self` = self else {return}
                DispatchQueue.main.async {
                    self.camera.stop()
                    self.showIsTakingPhotoStatus(isTaking: false)
                    self.showSavePopupViewView()
                }
                
            }
        } else {
            isCancel = true
            
        }
        
        partFullImgsList = []
        cutImgsList = []
        currentTakingOverImgVIndex = 0
        currentTakingOverImgV = overlayerImgViews.first
        
        
        
        
    }
    
    @objc func camPositionBtnClick(sender: UIButton) {
        camera.switchCameraPosition()
    }
       
}

 
extension PCsCameraVC {
    
    func saveImgsToAlbum(imgs: [UIImage]) {
        HUD.hide()
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .authorized {
            saveToAlbumPhotoAction(images: imgs)
        } else if status == .notDetermined {
            PHPhotoLibrary.requestAuthorization({[weak self] (status) in
                guard let `self` = self else {return}
                DispatchQueue.main.async {
                    if status != .authorized {
                        return
                    }
                    self.saveToAlbumPhotoAction(images: imgs)
                }
            })
        } else {
            // 权限提示
            albumPermissionsAlet()
        }
    }
    
    func saveToAlbumPhotoAction(images: [UIImage]) {
        DispatchQueue.main.async(execute: {
            PHPhotoLibrary.shared().performChanges({
                [weak self] in
                guard let `self` = self else {return}
                for img in images {
                    PHAssetChangeRequest.creationRequestForAsset(from: img)
                }
                DispatchQueue.main.async {
                    [weak self] in
                    guard let `self` = self else {return}
                    self.showSaveSuccessAlert()
                }
                
            }) { (finish, error) in
                if error != nil {
                    HUD.error("Sorry! please try again")
                }
            }
        })
    }
    
    func showSaveSuccessAlert() {
        DispatchQueue.main.async {
            let title = ""
            let message = "Photo saved successfully!"
            let okText = "OK"
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okButton = UIAlertAction(title: okText, style: .cancel, handler: { (alert) in
                 DispatchQueue.main.async {
                 }
            })
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    func albumPermissionsAlet() {
        let alert = UIAlertController(title: "Ooops!", message: "You have declined access to photos, please active it in Settings>Privacy>Photos.", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default) { [weak self] (actioin) in
            self?.openSystemAppSetting()
        }
        let cancelButton = UIAlertAction(title: "Cancel".localized(), style: .cancel) { (action) in
            
        }
        alert.addAction(okButton)
        alert.addAction(cancelButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    func openSystemAppSetting() {
        let url = NSURL.init(string: UIApplication.openSettingsURLString)
        let canOpen = UIApplication.shared.canOpenURL(url! as URL)
        if canOpen {
            UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
        }
    }
 
}






