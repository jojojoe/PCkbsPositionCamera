//
//  PCsGifContinePreview.swift
//  PCkbsPositionCam
//
//  Created by JOJO on 2022/2/18.
//

import UIKit

class PCsGifContinePreview: UIView {
    
    var collection: UICollectionView!
    var backBtnClickBlock: (()->Void)?
    var sizeScaleItemClickBlock: ((PCsCamSizeScaleItem)->Void)?
    
    
    var previewPhotos: [UIImage] = []
    
    func closePreviewAction() {
        backBtnClickBlock?()
    }
    
    func updateContentPhotos(photos: [UIImage]) {
        previewPhotos = photos
        collection.reloadData()
        if photos.count >= 1 {
            collection.scrollToItem(at: IndexPath(item: photos.count - 1, section: 0), at: .right, animated: true)
        }
        
    }
    
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
        
        contentV.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.top.bottom.equalToSuperview()
        }
         
        
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
            $0.top.bottom.right.left.equalToSuperview()

        }
        collection.register(cellWithClass: PCsPreviewImgCell.self)
        
        //
    }
    
}

extension PCsGifContinePreview: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: PCsPreviewImgCell.self, for: indexPath)
        let item = previewPhotos[indexPath.item]
        cell.contentImgV.image = item
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return previewPhotos.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
}

extension PCsGifContinePreview: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let left: CGFloat = 20
        let padding: CGFloat = 12
        
        let height: CGFloat = collectionView.bounds.height - 40
        let width: CGFloat = height * 3/4
        
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

extension PCsGifContinePreview: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
    }
}


class PCsPreviewImgCell: UICollectionViewCell {
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
//        selectV.adhere(toSuperview: contentView)
//            .backgroundColor(.clear)
//        selectV.snp.makeConstraints {
//            $0.center.equalToSuperview()
//            $0.left.top.equalTo(contentImgV)
//        }
//        selectV.layer.cornerRadius = 10
//        selectV.layer.borderColor = UIColor(hexString: "#EEAB00")?.cgColor
//        selectV.layer.borderWidth = 2
        
        //
//        proImgV.contentMode = .scaleAspectFill
//        proImgV.clipsToBounds = true
//        contentView.addSubview(proImgV)
//        proImgV.snp.makeConstraints {
//            $0.top.right.equalToSuperview()
//            $0.width.height.equalTo(24)
//        }
        
    }
}

