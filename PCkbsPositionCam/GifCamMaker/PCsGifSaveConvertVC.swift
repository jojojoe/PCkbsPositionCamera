//
//  PCsGifSaveConvertVC.swift
//  PCkbsPositionCam
//
//  Created by JOJO on 2022/2/18.
//

import UIKit
import AVFoundation
import Photos
import BBMetalImage
import ZKProgressHUD
import Gifer
import SDWebImage


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
    
    
    private var displayLink: CADisplayLink!
    private var uiSource: BBMetalUISource!
    private var videoWriter: BBMetalVideoWriter!
    private var filePath: String!
    private var coverImgfilePath: String!
    var stepCount: Int64 = 0
    var currentShowIndex: Int = 0
    var isStartRecordVideo: Bool = false
//    var isWaitingRecordVideoTwo: Bool = false
    var currentProcessVideoFinishedBlock: (()->Void)?
    var recordMetalV: BBMetalView!
    
    var isWaitingRecord: Bool = false
    var isWillFinishRecord: Bool = false
    
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
        setupContentImgV()
        
        setupRecordUI()
        
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if displayLink != nil {
            displayLink.invalidate()
            displayLink = nil
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
            //防止生成的视频四周出现绿色条 宽高必须是16的倍数
            while Int(cameraWidth) % 16 > 0 {
                cameraWidth -= 1
            }
            while Int(cameraHeight) % 16 > 0 {
                cameraHeight -= 1
            }
            leftOffset = (topContentBgVWidth - cameraWidth) / 2
            topOffset = (topContentBgVHeight - cameraHeight) / 2
            
            debugPrint("canvasWidth: \(cameraWidth)")
            debugPrint("cameraHeight: \(cameraHeight)")
            //
            canvasBgV.adhere(toSuperview: self.topContentBgV)
                .backgroundColor(.clear)
            canvasBgV.frame = CGRect(x: leftOffset, y: topOffset, width: cameraWidth, height: cameraHeight)
            
            //
            let rectFrame: CGRect = CGRect(x: 0, y: 0, width: cameraWidth, height: cameraHeight)
            
            // record ui
            let metalView = BBMetalView(frame: rectFrame)
            metalView.bb_textureContentMode = .aspectRatioFit
            canvasBgV.addSubview(metalView)
            recordMetalV = metalView
            //
            uiSource = BBMetalUISource(view: canvasBgV)
            
            
            let filter = BBMetalCropFilter(rect: BBMetalRect(x: 0, y: 0, width: 1, height: 1))
            
            uiSource
                .add(consumer: filter)
                .add(consumer: metalView)
            
            filePath = NSTemporaryDirectory() + "test.mov"
            let outputUrl = URL(fileURLWithPath: filePath)
            let frameSize = uiSource.renderPixelSize!
            debugPrint("uiSourceFrameSize = \(frameSize)")
            videoWriter = BBMetalVideoWriter(url: outputUrl, frameSize: BBMetalIntSize(width: Int(frameSize.width), height: Int(frameSize.height)), fileType: .mov)
            filter.add(consumer: videoWriter)
            
            do {
                try? FileManager.default.removeItem(at: videoWriter.url)
            } catch {
                
            }
            
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
            .backgroundColor(.lightGray)
        backBtn.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalToSuperview().offset(10)
            $0.width.height.equalTo(44)
        }
        backBtn.addTarget(self, action: #selector(backBtnClick(sender:)), for: .touchUpInside)
        
        
        
        //
        topContentBgV.adhere(toSuperview: view)
        topContentBgV.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.top.equalTo(topBanner.snp.bottom)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-100)
        }
        
        
        //

        bottomBar.adhere(toSuperview: view)
        bottomBar.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.right.left.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-200)
        }
        
        let btnHeight: CGFloat = 70
        
        //
        let toGifBtn = UIButton()
        toGifBtn.backgroundColor(.white)
            .title("Save as GIF")
            .titleColor(UIColor.black)
            .font(18, "AvenirNext-DemiBold")
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
            .font(18, "AvenirNext-DemiBold")
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
            .font(18, "AvenirNext-DemiBold")
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
            .title("Save Photos")
            .titleColor(UIColor.black)
            .font(18, "AvenirNext-DemiBold")
            .adhere(toSuperview: bottomBar)
        savePhotosBtn.snp.makeConstraints {
            $0.top.equalTo(toVideoBtn.snp.top)
            $0.right.equalToSuperview().offset(-20)
            $0.height.equalTo(btnHeight)
            $0.left.equalTo(view.safeAreaLayoutGuide.snp.centerX).offset(10)
        }
        savePhotosBtn.addTarget(self, action: #selector(savePhotosBtnClick(sender:)), for: .touchUpInside)
        
    }
    
    func setupContentImgV() {
        
        for imgItem in continuePhotoData.takePhotos {
            let contentImgV = UIImageView()
            contentImgV.image = imgItem.img
            contentImgV.adhere(toSuperview: canvasBgV)
                .contentMode(.scaleAspectFill)
            contentImgV.snp.makeConstraints {
                $0.left.right.top.bottom.equalToSuperview()
            }
        }
        
    }
    
    func setupRecordUI() {
        if displayLink == nil {
            displayLink = CADisplayLink(target: self, selector: #selector(refreshDisplayLink(_:)))
            displayLink.add(to: .main, forMode: .common)
            displayLink.isPaused = false
        }
    }
}

extension PCsGifSaveConvertVC {
    @objc private func refreshDisplayLink(_ link: CADisplayLink) {
        let duration: Int64 = 20
        
        if isWaitingRecord == true {
            for (indx, imV) in canvasBgV.subviews.enumerated() {
                if indx == currentShowIndex {
                    imV.alpha = 1
                } else {
                    imV.alpha = 0
                }
            }
            
            return
        }
        
        if isStartRecordVideo {
            if isWillFinishRecord {
                self.finishePorcessVideo()
                isWillFinishRecord = false
            } else {
                let yushu = stepCount % duration
                if yushu == 0 {
                    if currentShowIndex >= continuePhotoData.takePhotos.count {
                        currentShowIndex = 0
                        for (indx, imV) in canvasBgV.subviews.enumerated() {
                            if indx == currentShowIndex {
                                imV.alpha = 1
                            } else {
                                imV.alpha = 0
                            }
                        }
                        
                        isWillFinishRecord = true
                    } else {
                        currentShowIndex += 1
                        for (indx, imV) in canvasBgV.subviews.enumerated() {
                            
                            if indx == currentShowIndex {
                                imV.alpha = 1
                            } else {
                                imV.alpha = 0
                            }
                        }
                    }
                }
            }
        } else {
            let yushu = stepCount % duration
            if yushu == 0 {
                if currentShowIndex >= continuePhotoData.takePhotos.count - 1 {
                    currentShowIndex = 0
                } else {
                    currentShowIndex += 1
                }
                for (indx, imV) in canvasBgV.subviews.enumerated() {
                    
                    if indx == currentShowIndex {
                        imV.alpha = 1
                    } else {
                        imV.alpha = 0
                    }
                }
            }
        }
        
        stepCount += 1
        
        let maxCount: Int = Int(duration) * continuePhotoData.takePhotos.count
        if isStartRecordVideo {
            uiSource.transmitTexture(with: CMTime(value: stepCount, timescale: 60))
        }
    }
    
    
}

extension PCsGifSaveConvertVC {
    @objc func backBtnClick(sender: UIButton) {
        try? FileManager.default.removeItem(at: videoWriter.url)
        if self.navigationController != nil {
            self.navigationController?.popViewController()
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension PCsGifSaveConvertVC {
    func processAndSaveGif() {
         
        Gifer.createGifFromVideo(videoWriter.url, frameRate: 30, loopCount: 0, startTime: 0, size: CGSize(width: self.canvasBgV.bounds.width, height: self.canvasBgV.bounds.height)) {[weak self] gifUrl, error in
            
            guard let `self` = self else {return}
            if (error == nil) {
                DispatchQueue.main.async {
                    self.saveGifToAlbum(gifUrl: gifUrl)
                }
            }
        }
    }
    
    func saveGifToAlbum(gifUrl: URL?) {
        guard let url = gifUrl else { return }
        checkPhotoAuthorizeStatus {
            [weak self] in
            guard let `self` = self else {return}
            do {
                let gifData = try Data.init(contentsOf: url)
                self.saveGif(data: gifData) { success in
                    DispatchQueue.main.async {
                        if success {
                            ZKProgressHUD.dismiss()
                            ZKProgressHUD.showSuccess("保存GIF成功", maskStyle: nil, onlyOnceFont: nil, autoDismissDelay: 1, completion: nil)
                        } else {
                            
                        }
                    }
                }
            } catch {
                
            }
        }
    }
    
    func saveGif(data: Data, completion: @escaping (_ success: Bool) -> ()) {

        PHPhotoLibrary.shared().performChanges({
            PHAssetCreationRequest.forAsset().addResource(with: .photo, data: data, options: nil)
        }) { (success, error) in completion(success) }
    }
     
}

extension PCsGifSaveConvertVC {
    
    func processLivePhotoAndSave() {
        
        checkPhotoAuthorizeStatus {
            [weak self] in
            guard let `self` = self else {return}
            DispatchQueue.main.async {
                self.saveLivePhoto { success in
                    if success {
                        DispatchQueue.main.async {
                            ZKProgressHUD.dismiss()
                            ZKProgressHUD.showSuccess("保存LivePhoto成功", maskStyle: nil, onlyOnceFont: nil, autoDismissDelay: 1, completion: nil)
                        }
                    } else {
                        ZKProgressHUD.dismiss()
                        ZKProgressHUD.showError("保存LivePhoto失败")
                    }
                }
            }

            
        }
        
         
        
    }
    
    func saveLivePhoto(completion: @escaping (_ success: Bool) -> ()) {
        let firstItem = continuePhotoData.takePhotos.first
        let converImg = firstItem?.img
        if let converImg_m = converImg {
            coverImgfilePath = NSTemporaryDirectory() + "testCoverImg.jpg"
            let photoUrl = URL(fileURLWithPath: coverImgfilePath)
            do {
                try converImg_m.jpegData(compressionQuality: 0.9)?.write(to: photoUrl)
            } catch {
                debugPrint("error - \(error)")
            }
            LivePhotoConverter.sharedInstance().saveLivePhotoAsset(withVideoURL: videoWriter.url, imageURL: photoUrl) { error in
                debugPrint("error = \(error)")
                if error == nil {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }
}
extension PCsGifSaveConvertVC {
    
    func saveVideoToAlbum() {
         
        saveVideoToAlbum(videoUrl: videoWriter.url) { success in
            if success {
                DispatchQueue.main.async {
                    ZKProgressHUD.dismiss()
                    ZKProgressHUD.showSuccess("保存视频成功", maskStyle: nil, onlyOnceFont: nil, autoDismissDelay: 1, completion: nil)
                }
            } else {
                let title = ""
                let message = "Save failed, please try it again."
                let okText = "OK"
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                let okButton = UIAlertAction(title: okText, style: .cancel, handler: { (alert) in
                })
                alert.addAction(okButton)

                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    func finishePorcessVideo() {
        
        self.isStartRecordVideo = false
 
         
        self.videoWriter.finish { [weak self] in
            DispatchQueue.main.async {
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.currentProcessVideoFinishedBlock?()
                    debugPrint("videoUrl: \(self.videoWriter.url)")
                    self.recordMetalV.isHidden = true
 
                }
            }
        }
        
    }
    
    func processVideo(completion: @escaping (()->Void)) {
        
        self.currentProcessVideoFinishedBlock = completion
        try? FileManager.default.removeItem(at: videoWriter.url)
        
        stepCount = 0
        currentShowIndex = 0
        recordMetalV.isHidden = false
        
        isWaitingRecord = true
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            [weak self] in
            guard let `self` = self else {return}
            self.isWaitingRecord = false
            
            self.isStartRecordVideo = true
            self.videoWriter.start()
        }
    }
}

extension PCsGifSaveConvertVC {
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
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
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

extension PCsGifSaveConvertVC {
    
    func checkPhotoAuthorizeStatus(authorizedBlock: @escaping (()->Void)) {
        let status = PHPhotoLibrary.authorizationStatus()
        if status == PHAuthorizationStatus.authorized {
            authorizedBlock()
            
        } else if (status == PHAuthorizationStatus.restricted || status == PHAuthorizationStatus.denied) {
            self.albumPermissionsAlet()
        } else {
            PHPhotoLibrary.requestAuthorization {
                [weak self] status in
                guard let `self` = self else {return}
                
                if status == PHAuthorizationStatus.authorized {
                    DispatchQueue.main.async {
                        authorizedBlock()
                    }
                    
                    
                }
            }
        }
    }
    
    func saveVideoToAlbum(videoUrl: URL, completion: @escaping ((Bool)->Void)) {
        checkPhotoAuthorizeStatus {
            [weak self] in
            guard let `self` = self else {return}
            DispatchQueue.main.async {
                self.finishedSaveVideo(videoUrl: videoUrl, completion: completion)
            }
            
        }
        
    }
    
    func finishedSaveVideo(videoUrl: URL, completion: @escaping ((Bool)->Void)) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoUrl)

        }) { (isSuccess: Bool, error: Error?) in
            if isSuccess {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    
}

extension PCsGifSaveConvertVC {
    @objc func toGifBtnClick(sender: UIButton) {
        ZKProgressHUD.show("processing", maskStyle: nil, onlyOnceFont: nil)
        if FileManager.default.fileExists(atPath: filePath) {
            processAndSaveGif()
        } else {
            processVideo {
                [weak self] in
                guard let `self` = self else {return}
                DispatchQueue.main.async {
                    self.processAndSaveGif()
                }
            }
        }
    }
    
    @objc func toVideoBtnClick(sender: UIButton) {
        ZKProgressHUD.show("processing", maskStyle: nil, onlyOnceFont: nil)
        if FileManager.default.fileExists(atPath: filePath) {
            saveVideoToAlbum()
        } else {
            processVideo {
                [weak self] in
                guard let `self` = self else {return}
                DispatchQueue.main.async {
                    self.saveVideoToAlbum()
                }
                
            }
        }
        
    }
    
    
    @objc func toLivePhotoBtnClick(sender: UIButton) {
        ZKProgressHUD.show("processing", maskStyle: nil, onlyOnceFont: nil)
        if FileManager.default.fileExists(atPath: filePath) {
            processLivePhotoAndSave()
        } else {
            processVideo {
                [weak self] in
                guard let `self` = self else {return}
                DispatchQueue.main.async {
                    self.processLivePhotoAndSave()
                }
                
            }
        }
        
        
        
    }
    
    @objc func savePhotosBtnClick(sender: UIButton) {
        ZKProgressHUD.show("processing", maskStyle: nil, onlyOnceFont: nil)
        var imgs: [UIImage] = []
        for item in continuePhotoData.takePhotos {
            imgs.append(item.img)
        }
        saveImgsToAlbum(imgs: imgs)
        
    }
    
}


