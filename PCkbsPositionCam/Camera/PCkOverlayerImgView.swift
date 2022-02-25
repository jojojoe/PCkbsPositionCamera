//
//  PCkOverlayerImgView.swift
//  PCkbsPositionCam
//
//  Created by JOJO on 2022/2/11.
//

import UIKit
import SRCountdownTimer
class PCkOverlayerImgView: UIView, SRCountdownTimerDelegate {

    let imgV = UIImageView()
    let countdownLabel = SRCountdownTimer()
    let whiteView = UIView()
    var countdownEndBlock: (()->Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        
        imgV.contentMode(.scaleAspectFill)
            .clipsToBounds()
            .adhere(toSuperview: self)
        imgV.snp.makeConstraints {
            $0.left.right.top.bottom.equalToSuperview()
        }
        
        //
        
        countdownLabel.labelFont = UIFont(name: "AvenirNext-Bold", size: 28.0)
        countdownLabel.backgroundColor(UIColor.black.withAlphaComponent(0.25))
        countdownLabel.labelTextColor = UIColor.white
        countdownLabel.timerFinishingText = ""
        countdownLabel.lineWidth = 0
        countdownLabel.lineColor = .clear
        countdownLabel.trailLineColor = .clear
        
        countdownLabel.delegate = self
        countdownLabel.adhere(toSuperview: self)
        countdownLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.greaterThanOrEqualTo(50)
        }
        countdownLabel.layer.cornerRadius = 50/2
        countdownLabel.layer.masksToBounds = true
//        countdownLabel.layer.shadowColor = UIColor.white.cgColor
//        countdownLabel.layer.shadowOffset = CGSize(width: 0, height: 0)
//        countdownLabel.layer.shadowRadius = 3
//        countdownLabel.layer.shadowOpacity = 0.6
        
        countdownLabel.isHidden = true
        
        //
        whiteView.adhere(toSuperview: self)
            .backgroundColor(.white)
        whiteView.snp.makeConstraints {
            $0.left.right.top.bottom.equalToSuperview()
        }
        whiteView.isHidden = true
        
    }

    func startCounting() {
        countdownLabel.isHidden = false
        countdownLabel.start(beginingValue: 3, interval: 1)
    }
    
    func timerDidEnd(sender: SRCountdownTimer, elapsedTime: TimeInterval) {
        sender.isHidden = true
        countdownEndBlock?()
    }
    
}
