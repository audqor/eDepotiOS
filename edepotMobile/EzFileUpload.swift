////
////  EzFileUpload.swift
////  edepotMobile
////
////  Created by nocson on 2018. 8. 14..
////  Copyright © 2018년 nocson. All rights reserved.
////
//
//import Foundation
//import Photos
//import PhotosUI
//
////json 구조체
//struct File : Codable {
//    var StaticName : String
//    var FileName : String
//    var FileSize : String
//
//}
//
//
//class EzFileUpload : UICollectionViewController {
//
//
//    var allPhotos: PHFetchResult<PHAsset>!
//    let imageManager = PHCachingImageManager()
//
//
//    func fetchAllPhotos() {
//        let allPhotosOptions = PHFetchOptions()
//        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
//        allPhotos = PHAsset.fetchAssets(with: allPhotosOptions)
//
//        collectionView?.reloadData()
//
//    }
//    
//    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//
//        return allPhotos.count
//
//    }
//
//    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//
//        let assetCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ImageCell
//
//        let asset = allPhotos.object(at: indexPath.item)
//
//        assetCell.representedAssetIdentifier = asset.localIdentifier
//        imageManager.requestImage(for: asset, targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
//
//            if assetCell.representedAssetIdentifier == asset.localIdentifier {
//                assetCell.imageView.image = image
//
//            }
//
//        })
//
//        return assetCell
//
//    }
//}
//
//class ImageCell: UICollectionViewCell {
//
//    var representedAssetIdentifier: String!
//
//}
//
