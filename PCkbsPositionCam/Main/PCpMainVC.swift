//
//  PCpMainVC.swift
//  PCkbsPositionCam
//
//  Created by JOJO on 2022/2/9.
//

import UIKit
import SwifterSwift
import SnapKit
import Photos
import YPImagePicker
import ZKProgressHUD



class PCpMainVC: UIViewController, UINavigationControllerDelegate {

    var isLockVC = false
    var maxPhotoCount: Int = 20
    var minPhotoCount: Int = 1
    var isShowSignlePhotoMaker = false
    
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
            $0.width.height.equalTo(80)
        }
        type1CamBtn.addTarget(self, action: #selector(type1CamBtnClick(sender: )), for: .touchUpInside)
        
        
        let type2CamBtn = UIButton()
        type2CamBtn.adhere(toSuperview: view)
            .backgroundColor(.yellow)
        type2CamBtn.snp.makeConstraints {
            $0.centerY.equalToSuperview().offset(140)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(80)
        }
        type2CamBtn.addTarget(self, action: #selector(type2CamBtnClick(sender: )), for: .touchUpInside)
        
        let type3CamBtn = UIButton()
        type3CamBtn.adhere(toSuperview: view)
            .backgroundColor(.yellow)
        type3CamBtn.snp.makeConstraints {
            $0.centerY.equalToSuperview().offset(-140)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(80)
        }
        type3CamBtn.addTarget(self, action: #selector(type3CamBtnClick(sender: )), for: .touchUpInside)
        
        let type4CamBtn = UIButton()
        type4CamBtn.adhere(toSuperview: view)
            .backgroundColor(.yellow)
        type4CamBtn.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.centerX.equalToSuperview().offset(-100)
            $0.width.height.equalTo(80)
        }
        type4CamBtn.addTarget(self, action: #selector(type4CamBtnClick(sender: )), for: .touchUpInside)
        
    }
    
    
    @objc func type1CamBtnClick(sender: UIButton) {
        let type1Cam = PCsCameraVC()
        self.navigationController?.pushViewController(type1Cam, animated: true)
    }
    
    @objc func type2CamBtnClick(sender: UIButton) {
        let type1Cam = PCsGifMakerCamVC()
        self.navigationController?.pushViewController(type1Cam, animated: true)
    }
    
    @objc func type3CamBtnClick(sender: UIButton) {
        maxPhotoCount = 20
        maxPhotoCount = 1
        isShowSignlePhotoMaker = false
        checkAlbumAuthorization()
    }
    
    @objc func type4CamBtnClick(sender: UIButton) {
        maxPhotoCount = 1
        maxPhotoCount = 1
        isShowSignlePhotoMaker = true
        checkAlbumAuthorization()
    }
    
}






extension PCpMainVC: UIImagePickerControllerDelegate {
    
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
        
        config.library.maxNumberOfItems = maxPhotoCount
        config.library.minNumberOfItems = minPhotoCount
        config.library.mediaType = .photo
        config.screens = [.library]

        config.library.defaultMultipleSelection = !isShowSignlePhotoMaker
        config.library.isSquareByDefault = false
        config.library.skipSelectionsGallery = true
        config.showsPhotoFilters = false
        config.library.preselectedItems = nil
        let picker = YPImagePicker(configuration: config)
        picker.view.backgroundColor = UIColor.white
        picker.didFinishPicking { [unowned picker] items, cancelled in
            if self.isShowSignlePhotoMaker {
                // 单一照片编辑不限制个数
            } else {
                if items.count < 3 {
                    ZKProgressHUD.showMessage("Please select limit 3 photos", maskStyle: nil, onlyOnceFont: nil, autoDismissDelay: 1.5, completion: nil)
                    return
                }
            }
            
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
                self.showEditVC(images: imgs)
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
    
    
    func showEditVC(images: [UIImage]) {
        
        if isLockVC == true {
             
        } else {
            isLockVC = true
            if isShowSignlePhotoMaker == true {
                if let img = images.first {
                    let vc = PCsUserPhotoMakerVC(originalImg: img)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            } else {
                let vc = PCsGifSaveConvertVC(photos: images)
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
            self.isLockVC = false
            
        }
    }

}
