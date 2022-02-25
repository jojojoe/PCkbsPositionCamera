//
//  PCsGifConfigBar.swift
//  PCkbsPositionCam
//
//  Created by JOJO on 2022/2/18.
//

import UIKit


class PCsGifConfigBar: UIView {
    
    var collection: UICollectionView!
    var backBtnClickBlock: (()->Void)?
    var sizeScaleItemClickBlock: ((PCsCamSizeScaleItem)->Void)?
    var currentSizeItem: PCsCamSizeScaleItem?
    
    var timeSlider: UISlider = UISlider()
    var countSlider: UISlider = UISlider()
    
    var timeSliderValueChangeBlock: ((CGFloat)->Void)?
    var countSliderValueChangeBlock: ((CGFloat)->Void)?
    let backBtn = UIButton(type: .custom)
    let timeValueLabel = UILabel()
    let countValueLabel = UILabel()
    
    func closePreviewAction() {
        backBtnClickBlock?()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        
        setupView()
        setupSlider()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func backBtnClick(sender: UIButton) {
        backBtnClickBlock?()
    }
    
    func setupView() {
        backgroundColor = UIColor.black.withAlphaComponent(0)
         
        //
        let bgBtn = UIButton(type: .custom)
        bgBtn
            .image(UIImage(named: ""))
            .adhere(toSuperview: self)
        bgBtn.addTarget(self, action: #selector(backBtnClick(sender:)), for: .touchUpInside)
        bgBtn.snp.makeConstraints {
            $0.left.right.top.bottom.equalToSuperview()
        }
        
        //
        let contentV = UIView()
            .backgroundColor(UIColor(hexString: "#FFFFFF")!)
            .adhere(toSuperview: self)
       
//        contentV.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.6).cgColor
//        contentV.layer.shadowOffset = CGSize(width: 0, height: -1)
//        contentV.layer.shadowRadius = 3
//        contentV.layer.shadowOpacity = 0.8
        //        contentV.layer.borderWidth = 2
        //        contentV.layer.borderColor = UIColor.black.cgColor
        contentV.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.top.equalTo(self.safeAreaLayoutGuide.snp.bottom).offset(-190)
        }
         
        //
        
        backBtn
            .backgroundColor(UIColor(hexString: "#FFEBF0")!)
            .adhere(toSuperview: contentV)
        backBtn.snp.makeConstraints {
            $0.top.equalTo(contentV.snp.top)
            $0.right.left.equalToSuperview()
            $0.height.equalTo(30)
        }
        backBtn.addTarget(self, action: #selector(backBtnClick(sender:)), for: .touchUpInside)
        
        //
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        collection = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: layout)
        collection.showsVerticalScrollIndicator = false
        collection.showsHorizontalScrollIndicator = false
        collection.backgroundColor = .clear
        collection.delegate = self
        collection.dataSource = self
//        collection.adhere(toSuperview: contentV)
//        collection.snp.makeConstraints {
//            $0.right.left.equalToSuperview()
//            $0.top.equalTo(backBtn.snp.bottom)
//            $0.height.equalTo(60)
//
//        }
        collection.register(cellWithClass: PCsSizeScaleCell.self)
        
        //
    }
    func setupSlider() {
        //
        timeSlider.minimumValue = 0
        timeSlider.maximumValue = 1
        timeSlider.value = 0.1
        timeSlider.setThumbImage(UIImage(named: "sliderpoint"), for: .normal)
        timeSlider.setMinimumTrackImage(UIImage(named: "sliderLeft"), for: .normal)
        timeSlider.setMaximumTrackImage(UIImage(named: "sliderRight"), for: .normal)
        timeSlider.adhere(toSuperview: self)
        timeSlider
            .snp.makeConstraints {
//                $0.top.equalTo(collection.snp.bottom).offset(0)
                $0.top.equalTo(backBtn.snp.bottom).offset(20)
                $0.left.equalTo(65)
                $0.right.equalTo(-65)
                $0.height.greaterThanOrEqualTo(34)
            }
        timeSlider.addTarget(self, action: #selector(timeSliderChange(sender:)), for: .valueChanged)
        //
        let timeIconImgV = UIImageView()
        timeIconImgV.image("editor_rotate")
            .adhere(toSuperview: self)
        timeIconImgV.snp.makeConstraints {
            $0.centerY.equalTo(timeSlider.snp.centerY)
            $0.left.equalToSuperview().offset(20)
            $0.width.height.equalTo(25)
        }
        //
        timeValueLabel.adhere(toSuperview: self)
            .color(UIColor(hexString: "#1D2948")!)
            .fontName(16, "AppleSDGothicNeo-Medium")
            .text("50")
        timeValueLabel.snp.makeConstraints {
            $0.centerY.equalTo(timeSlider.snp.centerY)
            $0.right.equalToSuperview().offset(-16)
            $0.width.height.greaterThanOrEqualTo(1)
        }
        
        //
        countSlider.minimumValue = 3
        countSlider.maximumValue = 20
        countSlider.value = 0.5
        countSlider.setThumbImage(UIImage(named: "sliderpoint"), for: .normal)
        countSlider.setMinimumTrackImage(UIImage(named: "sliderLeft"), for: .normal)
        countSlider.setMaximumTrackImage(UIImage(named: "sliderRight"), for: .normal)
        countSlider.adhere(toSuperview: self)
        countSlider
            .snp.makeConstraints {
                $0.top.equalTo(timeSlider.snp.bottom).offset(0)
                $0.left.equalTo(65)
                $0.right.equalTo(-65)
                $0.height.greaterThanOrEqualTo(34)
            }
        countSlider.addTarget(self, action: #selector(countSliderChange(sender:)), for: .valueChanged)
        //
        let countIconImgV = UIImageView()
        countIconImgV.image("editor_scale")
            .adhere(toSuperview: self)
        countIconImgV.snp.makeConstraints {
            $0.centerY.equalTo(countSlider.snp.centerY)
            $0.left.equalToSuperview().offset(20)
            $0.width.height.equalTo(25)
        }
        //
        countValueLabel.adhere(toSuperview: self)
            .color(UIColor(hexString: "#1D2948")!)
            .fontName(16, "AppleSDGothicNeo-Medium")
            .text("50")
        countValueLabel.snp.makeConstraints {
            $0.centerY.equalTo(countSlider.snp.centerY)
            $0.right.equalToSuperview().offset(-16)
            $0.width.height.greaterThanOrEqualTo(1)
        }
        
    }
 
    
    @objc func timeSliderChange(sender: UISlider) {
        timeSliderValueChangeBlock?(CGFloat(sender.value))
    }
    
    @objc func countSliderChange(sender: UISlider) {
        countSliderValueChangeBlock?(CGFloat(sender.value))
    }
    
}

extension PCsGifConfigBar: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: PCsSizeScaleCell.self, for: indexPath)
        let item = PCpDataManager.default.camSizeScaleTypeList[indexPath.item]
        cell.contentImgV.image = UIImage(named: item.thumb)
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return PCpDataManager.default.camSizeScaleTypeList.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
}

extension PCsGifConfigBar: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let left: CGFloat = 20
        let padding: CGFloat = 12
        let width: CGFloat = (UIScreen.main.bounds.width - left * 2 - padding * (CGFloat(PCpDataManager.default.camSizeScaleTypeList.count) - 1) - 1) / CGFloat(PCpDataManager.default.camSizeScaleTypeList.count)
        let height: CGFloat = 48
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let left: CGFloat = 20
        
        return UIEdgeInsets(top: 0, left: left, bottom: 0, right: left)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        let padding: CGFloat = 12
        return padding
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        let padding: CGFloat = 12
        return padding
    }
    
}

extension PCsGifConfigBar: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = PCpDataManager.default.camSizeScaleTypeList[indexPath.item]
        currentSizeItem = item
        collectionView.reloadData()
        sizeScaleItemClickBlock?(item)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
    }
}


class PCsSizeScaleCell: UICollectionViewCell {
    let contentImgV = UIImageView()
    let selectV = UIView()
    let proImgV = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        contentImgV.contentMode = .scaleAspectFill
        contentImgV.clipsToBounds = true
        contentView.addSubview(contentImgV)
        contentImgV.snp.makeConstraints {
            $0.top.right.bottom.left.equalToSuperview()
        }
        
        //
        selectV.adhere(toSuperview: contentView)
            .backgroundColor(.clear)
        selectV.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.left.top.equalTo(contentImgV)
        }
        selectV.layer.cornerRadius = 10
        selectV.layer.borderColor = UIColor(hexString: "#EEAB00")?.cgColor
        selectV.layer.borderWidth = 2
        
        //
        proImgV.contentMode = .scaleAspectFill
        proImgV.clipsToBounds = true
        contentView.addSubview(proImgV)
        proImgV.snp.makeConstraints {
            $0.top.right.equalToSuperview()
            $0.width.height.equalTo(24)
        }
        
    }
}

