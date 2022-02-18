//
//  PCsGifMakerCamVC.swift
//  PCkbsPositionCam
//
//  Created by JOJO on 2022/2/17.
//

import UIKit
import BBMetalImage
import AVFoundation
import DeviceKit
import Photos
import SRCountdownTimer

class PCsGifMakerCamVC: UIViewController {

    private var camera: BBMetalCamera!
    private var metalView: BBMetalView!
    var topContentBgV: UIView = UIView()
    var canvasBgV: UIView = UIView()
    var didLayoutOnce: Once = Once()
    var isReadyCamera: Bool = false
    var backBtn = UIButton()
    var takePhotoBtn = UIButton()
    var camPositionBtn = UIButton()
    let filterBar = PCkFilterBar()
    var currentApplyingFilterItem: CamFilterItem?
    let camConfigBar = PCsGifConfigBar()
    var currentSizeTypeItem: PCsCamSizeScaleItem?
    let photoPreviewBar = PCsGifContinePreview()
    
    
    let countdownLabel = SRCountdownTimer()
    let bottomBar = UIView()
    let toolBgV = UIView()
    
    var timePadding: Double = 2
    var photosCount: Int = 10
    var currentTakingPhotoIndex: Int = 0
    var currentTakingPhotos: [UIImage] = []
    var currentTakingOverBlock: (()->Void)?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupTimerCountLabel()
        setupSizeScalePopupView()
        setupResultPreviewPopupView()
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
}

extension PCsGifMakerCamVC {
    
    
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

        toolBgV.backgroundColor(.white)
            .adhere(toSuperview: view)
        toolBgV.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.bottom.equalTo(bottomBar.snp.top).offset(0)
            $0.height.equalTo(70)
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
        let configBtn = UIButton()
        configBtn.adhere(toSuperview: toolBgV)
            .backgroundColor(.lightGray)
        configBtn.snp.makeConstraints {
            $0.left.equalToSuperview().offset(10)
            $0.centerY.equalTo(filterBar.snp.centerY)
            $0.width.height.equalTo(50)
        }
        configBtn.addTarget(self, action: #selector(configBtnClick(sender: )), for: .touchUpInside)
        
        //
        topContentBgV.backgroundColor(.white)
            .adhere(toSuperview: view)
        topContentBgV.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(0)
            $0.bottom.equalTo(toolBgV.snp.top)
        }
    }
}

extension PCsGifMakerCamVC {
    @objc func configBtnClick(sender: UIButton) {
        if camConfigBar.alpha == 0 {
            showsetupSizeScaleView()
        } else {
            self.camConfigBar.closePreviewAction()
        }
        
    }
}

extension PCsGifMakerCamVC: SRCountdownTimerDelegate {
    func setupTimerCountLabel() {
        
        countdownLabel.labelFont = UIFont(name: "AvenirNext-Bold", size: 34.0)
        countdownLabel.backgroundColor(UIColor.black.withAlphaComponent(0.25))
        countdownLabel.labelTextColor = UIColor.white
        countdownLabel.timerFinishingText = ""
        countdownLabel.lineWidth = 0
        countdownLabel.lineColor = .clear
        countdownLabel.trailLineColor = .clear
        
        countdownLabel.delegate = self
        countdownLabel.adhere(toSuperview: view)
        countdownLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.greaterThanOrEqualTo(50)
        }
        countdownLabel.layer.cornerRadius = 50/2
        countdownLabel.layer.masksToBounds = true
        countdownLabel.isHidden = true
    }
    
   
    
}
extension PCsGifMakerCamVC {
    
    func setupSizeScalePopupView() {
        
        camConfigBar.alpha = 0
        view.addSubview(camConfigBar)
        camConfigBar.snp.makeConstraints {
            $0.left.right.bottom.top.equalToSuperview()
        }
    }

    func showsetupSizeScaleView() {
        // show coin alert
        UIView.animate(withDuration: 0.35) {
            self.camConfigBar.alpha = 1
        }
        
        camConfigBar.sizeScaleItemClickBlock = {
            [weak self] item in
            guard let `self` = self else {return}
              
            self.currentSizeTypeItem = item
            
            
        }
        
        camConfigBar.backBtnClickBlock = {
            [weak self] in
            guard let `self` = self else {return}
            UIView.animate(withDuration: 0.25) {
                self.camConfigBar.alpha = 0
            } completion: { finished in
                if finished {
                    
                }
            }
        }
    }
}


extension PCsGifMakerCamVC {
    
    func setupResultPreviewPopupView() {
        
        photoPreviewBar.alpha = 0
        view.addSubview(photoPreviewBar)
        photoPreviewBar.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.bottom.equalTo(bottomBar.snp.bottom)
            $0.top.equalTo(toolBgV.snp.top)
        }
        
    }

    func showResultPreview() {
        // show coin alert
        UIView.animate(withDuration: 0.35) {
            self.photoPreviewBar.alpha = 1
        }
         
        photoPreviewBar.backBtnClickBlock = {
            [weak self] in
            guard let `self` = self else {return}
            UIView.animate(withDuration: 0.25) {
                self.photoPreviewBar.alpha = 0
            } completion: { finished in
                if finished {
                    
                }
            }
        }
    }
}




extension PCsGifMakerCamVC {
    
    @objc func backBtnClick(sender: UIButton) {
        if self.navigationController != nil {
            self.navigationController?.popViewController()
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }

    @objc func takePhotoBtnClick(sender: UIButton) {
        // show taking status
        showResultPreview()
        
        takePhotoWithPosition {
            [weak self] in
            guard let `self` = self else {return}
            DispatchQueue.main.async {
                self.camera.stop()
                debugPrint("take photo over")
                self.showSaveConvertVC()
            }
            
        }
        
        
        
    }
    
    @objc func camPositionBtnClick(sender: UIButton) {
        camera.switchCameraPosition()
    }
       
}

extension PCsGifMakerCamVC {
    func showSaveConvertVC() {
        let vc = PCsGifSaveConvertVC(photos: self.currentTakingPhotos)
        self.navigationController?.pushViewController(vc, animated: true)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            self.photoPreviewBar.closePreviewAction()
        }
    }
    
    func timerDidEnd(sender: SRCountdownTimer, elapsedTime: TimeInterval) {
        
        if currentTakingPhotoIndex < photosCount {
            currentTakingPhotoIndex += 1
            takePhoto {
                [weak self] img in
                guard let `self` = self else {return}
                if let img_m = img {
                    self.currentTakingPhotos.append(img_m)
                    self.photoPreviewBar.updateContentPhotos(photos: self.currentTakingPhotos)
                    self.countdownLabel.start(beginingValue: self.timePadding, interval: 0.1)
                }
            }
        } else {
            // Take over
            countdownLabel.isHidden = true
            currentTakingOverBlock?()
        }
        
        
    }
    
    func takePhotoWithPosition(completion: @escaping (()->Void)) {
        currentTakingPhotos = []
        currentTakingPhotoIndex = 0
        currentTakingOverBlock = completion
        countdownLabel.isHidden = false
        if timePadding <= 1 {
            countdownLabel.backgroundColor(UIColor.clear.withAlphaComponent(0.25))
            countdownLabel.labelTextColor = UIColor.clear
        } else {
            countdownLabel.backgroundColor(UIColor.black.withAlphaComponent(0.25))
            countdownLabel.labelTextColor = UIColor.white
        }
        countdownLabel.start(beginingValue: timePadding, interval: 0.1)
        
    }
    
    func takePhoto(completion: @escaping ((UIImage?)->Void)) {
        
            camera.capturePhoto { [weak self] info in
                switch info.result {
                case let .success(texture):
                    DispatchQueue.main.async {
                        [weak self] in
                        guard let `self` = self else {return}
                        if let img = texture.bb_image {
                            let fullImg = self.takePhotoProcess(image: img)
                                completion(fullImg)
                            
                        } else {
                            completion(nil)
                        }
                    }
                case let .failure(error):
                    print("Error: \(error)")
                    completion(nil)
                }
            }
        
        
    }
    
}

extension PCsGifMakerCamVC {
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
