//
//  PCkFilterBar.swift
//  PCkbsPositionCam
//
//  Created by JOJO on 2022/2/14.
//

import UIKit
 
class PCkFilterBar: UIView {

    var collection: UICollectionView!
    var camFilterBarClickBlock: ((CamFilterItem)->Void)?
    var currentItem: CamFilterItem?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    

}

extension PCkFilterBar {
    func setupView() {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        collection = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: layout)
        collection.showsVerticalScrollIndicator = false
        collection.showsHorizontalScrollIndicator = false
        collection.backgroundColor = .clear
        collection.delegate = self
        collection.dataSource = self
        addSubview(collection)
        collection.snp.makeConstraints {
            $0.top.bottom.right.left.equalToSuperview()
        }
        collection.register(cellWithClass: PSkMagicCamFilterCell.self)
    }
    
    
    
}

extension PCkFilterBar: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: PSkMagicCamFilterCell.self, for: indexPath)
        let item = PCpDataManager.default.filterList[indexPath.item]
        cell.contentView.layer.cornerRadius = 10
        cell.contentView.layer.masksToBounds = true
        cell.contentView
            .backgroundColor(UIColor.clear)
        cell.contentImgV.image = item.processImg(img: UIImage(named: "filter_ori")!)
        
        
        if currentItem?.thumbImgStr == item.thumbImgStr {
            cell.selectV.isHidden = false
        } else {
            cell.selectV.isHidden = true
        }
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return PCpDataManager.default.filterList.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
}

extension PCkFilterBar: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 54, height: 54)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
}

extension PCkFilterBar: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = PCpDataManager.default.filterList[indexPath.item]
        camFilterBarClickBlock?(item)
        currentItem = item
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
    }
}



class PSkMagicCamFilterCell: UICollectionViewCell {
    let contentImgV = UIImageView()
    let selectV = UIView()
    
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
            $0.center.equalToSuperview()
            $0.left.equalToSuperview().offset(0)
            $0.top.equalToSuperview().offset(0)
        }
        contentImgV.layer.cornerRadius = 10
        contentImgV.layer.masksToBounds = true
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
        
        //
//        nameL
//            .fontName(10, "AvenirNext-DemiBold")
//            .adjustsFontSizeToFitWidth()
//            .color(UIColor.white)
//            .adhere(toSuperview: contentView)
//        nameL.snp.makeConstraints {
//            $0.center.equalToSuperview()
//            $0.top.left.equalToSuperview()
//        }
        
    }
}







