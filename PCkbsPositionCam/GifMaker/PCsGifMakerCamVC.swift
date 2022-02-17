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



class PCsGifMakerCamVC: UIViewController {

    private var camera: BBMetalCamera!
    private var metalView: BBMetalView!
    var canvasBgV: UIView = UIView()
    
    var backBtn = UIButton()
    var takePhotoBtn = UIButton()
    var camPositionBtn = UIButton()
    let filterBar = PCkFilterBar()
    var currentApplyingFilterItem: CamFilterItem?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        camera.start()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        camera.stop()
        
    }

}

extension PCsGifMakerCamVC {
    
    
    func setupView() {
        //
        view.backgroundColor(UIColor(hexString: "F4F4F4")!)
        
        //
        var topOffset: CGFloat = 80
        var leftOffset: CGFloat = 0
        if Device.current.diagonal <= 4.7 || Device.current.diagonal >= 7.0 {
            leftOffset = 30
            topOffset = 50
        }
        let width: CGFloat = UIScreen.main.bounds.width - (leftOffset * 2)
        let height: CGFloat = width / (3/4)
        
        //
        canvasBgV.adhere(toSuperview: view)
        canvasBgV.frame = CGRect(x: leftOffset, y: topOffset, width: width, height: height)
        
        //
        metalView = BBMetalView(frame: CGRect(x: 0, y: 0, width: width, height: height))
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
        
        
        
        //
        let bottomBar = UIView()
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
        let toolBgV = UIView()
        toolBgV.backgroundColor(.white)
            .adhere(toSuperview: view)
        toolBgV.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.bottom.equalTo(bottomBar.snp.top).offset(0)
            $0.height.equalTo(60)
        }
        //
        filterBar.backgroundColor(.white)
        filterBar.adhere(toSuperview: toolBgV)
        filterBar.snp.makeConstraints {
            $0.right.equalToSuperview()
            $0.bottom.equalTo(bottomBar.snp.top).offset(0)
            $0.height.equalTo(60)
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
        
    }
}

extension PCsGifMakerCamVC {
    @objc func configBtnClick(sender: UIButton) {
        
    }
}
