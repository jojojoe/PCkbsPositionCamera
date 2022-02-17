//
//  PCkLayoutPopView.swift
//  PCkbsPositionCam
//
//  Created by JOJO on 2022/2/14.
//

import UIKit


class PCkLayoutPopView: UIView {
    
    var collection: UICollectionView!
    var backBtnClickBlock: (()->Void)?
    var layoutItemClickBlock: ((PCpLayoutItem)->Void)?
    var currentLayoutItem: PCpLayoutItem?
    
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
    
    func setupView() {
        backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        //        //
        //        var blurEffect = UIBlurEffect(style: .light)
        //        var blurEffectView = UIVisualEffectView(effect: blurEffect)
        //        blurEffectView.frame = self.frame
        //        addSubview(blurEffectView)
        //        blurEffectView.snp.makeConstraints {
        //            $0.left.right.top.bottom.equalToSuperview()
        //        }
        //
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
        //        contentV.layer.cornerRadius = 0
        //        contentV.layer.masksToBounds = true
        contentV.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.6).cgColor
        contentV.layer.shadowOffset = CGSize(width: 0, height: -1)
        contentV.layer.shadowRadius = 3
        contentV.layer.shadowOpacity = 0.8
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
        collection.adhere(toSuperview: contentV)
        collection.snp.makeConstraints {
            $0.bottom.right.left.equalToSuperview()
            $0.top.equalTo(backBtn.snp.bottom)
        }
        collection.register(cellWithClass: PCkLayoutTypeCell.self)
        
    }
    
}

extension PCkLayoutPopView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: PCkLayoutTypeCell.self, for: indexPath)
        let item = PCpDataManager.default.layoutTypeList[indexPath.item]
        cell.contentImgV.image = UIImage(named: item.thumb)
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return PCpDataManager.default.layoutTypeList.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
}

extension PCkLayoutPopView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = (UIScreen.main.bounds.width - 12 * 5 - 1) / 4
        
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let padding: CGFloat = 12
        
        return UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
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

extension PCkLayoutPopView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = PCpDataManager.default.layoutTypeList[indexPath.item]
        currentLayoutItem = item
        collectionView.reloadData()
        
        layoutItemClickBlock?(item)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
    }
}


class PCkLayoutTypeCell: UICollectionViewCell {
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

