//
//  CheckViewController.swift
//  CheckApp
//
//  Created by 河野 裕門 on 2022/06/09.
//

import UIKit
import RealmSwift
import AVFoundation

class CheckViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    // MARK: - IBOutlet
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Private
    var realm: Realm?
    var list: List<CheckItem>?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Realmのインスタンス化
        self.realm = try? Realm()
        // リストの作成
        self.list = self.realm?.objects(CheckItemList.self).first?.list
        // デリゲート
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        // カスタムセルの登録
        let nib: UINib = UINib(nibName: "CollectionViewCell", bundle: nil)
        self.collectionView.register(nib, forCellWithReuseIdentifier: "CustomCell")
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: collectionView.frame.width, height: 100)
        self.collectionView.collectionViewLayout = layout
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.collectionView.reloadData()
    }
    
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let list = self.list else { return 0 }
        return list.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCell", for: indexPath) as! CollectionViewCell
        guard let list = self.list else { return cell }
        // チェック項目の取得
        let checkItem: CheckItem = list[indexPath.row]
        // タイトルの表示
        cell.titleLabel.text = checkItem.title
        
        if let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            if checkItem.isImage {
                // 画像path取得
                let imagePath: String = docDir.appendingPathComponent(checkItem.path + ".jpg").path
                // 画像表示
                print(imagePath)
                cell.thumbnail.image = UIImage(contentsOfFile: imagePath)
            } else {
                // 動画URL取得
                let videoUrl: URL = docDir.appendingPathComponent(checkItem.path + ".MOV")
                print(videoUrl)
                // 動画を取得
                let video: AVURLAsset = AVURLAsset(url: videoUrl)
                print(video)
                // サムネイルを生成
                let imageGenerator: AVAssetImageGenerator = AVAssetImageGenerator(asset: video)
                /*let capturingTime: CMTime = CMTimeMakeWithSeconds(CMTimeGetSeconds(video.duration) * 0.5, preferredTimescale: 1)*/
                do {
                    
                   
                    let thumbnail: CGImage = try imageGenerator.copyCGImage(at: .zero, actualTime: nil)
                    cell.thumbnail.image = UIImage(cgImage: thumbnail)
                } catch {
                    print(error)
                }
                // サムネイル表示
                
            }
        }
        
        return cell
    }

}
