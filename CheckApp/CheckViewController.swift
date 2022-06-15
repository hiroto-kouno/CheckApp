//
//  CheckViewController.swift
//  CheckApp
//
//  Created by 河野 裕門 on 2022/06/09.
//

import UIKit
import RealmSwift
import AVFoundation

class CheckViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var goHomeButton: UIButton!
    
    // MARK: - Private
    var realm: Realm?
    var list: List<CheckItem>?
    let userDefaults:UserDefaults = UserDefaults.standard
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Realmのインスタンスを生成
        self.realm = try? Realm()
        // リストの作成
        self.list = self.realm?.objects(CheckItemList.self).first?.list
        // デリゲート
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        // カスタムセルの登録
        let nib: UINib = UINib(nibName: "CollectionViewCell", bundle: nil)
        self.collectionView.register(nib, forCellWithReuseIdentifier: "CustomCell")
        // コレクションビューのセルサイズ指定
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: self.collectionView.frame.width, height: 100)
        layout.minimumLineSpacing = 15
        self.collectionView.collectionViewLayout = layout
        // 帰宅ボタンのカスタマイズ
        self.goHomeButton.layer.masksToBounds = false
        self.goHomeButton.layer.shadowColor = UIColor.black.cgColor
        self.goHomeButton.layer.shadowOffset = CGSize(width: 0.5, height: 3.5)
        self.goHomeButton.layer.shadowOpacity = 0.3
        self.goHomeButton.layer.shadowRadius = 3.5
        // ナビゲーションバーのカスタマイズ
        self.navigationItem.title = self.userDefaults.string(forKey: "date")
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // コレクションビューを更新
        self.collectionView.reloadData()
        guard let popoverViewController = self.storyboard?.instantiateViewController(withIdentifier: "Popover") else { return }
        self.present(popoverViewController, animated: true, completion: nil)
    }
    
    // MARK: - IBAction
    // 帰宅ボタンを押したときに呼ばれるメソッド
    @IBAction func handleGoHomeButton(_ sender: Any) {
        // チェックリスト,ドキュメントディレクトリを取得
        guard let list = self.list, let documentsDirectoryUrl: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        // 保存先のパスを削除
        for checkItem in list {
            let mediaType: String = checkItem.isImage ? ".jpg" : ".MOV"
            let path: String = documentsDirectoryUrl.appendingPathComponent(checkItem.path + mediaType).path
            do {
                try FileManager.default.removeItem(atPath: path)
            } catch {
                print(error)
            }
        }
        // チェックリスト画面に戻る
        if let listNavigation = self.storyboard?.instantiateViewController(withIdentifier: "ListNavigation") {
            self.present(listNavigation, animated: true)
        }
        
        var videoUrls = [URL]()

        do {
            // Documentから動画ファイルのURLを取得
            videoUrls = try FileManager.default.contentsOfDirectory(at: documentsDirectoryUrl, includingPropertiesForKeys: nil)
        } catch {
            print("フォルダが空です。")
        }
        // 起動時の画面をチェックリスト画面に切り替え
        self.userDefaults.set(false, forKey: "isGoOut")
        self.userDefaults.synchronize()
        
        print("\(videoUrls):video")
    }
    
    // MARK: - prepare
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // indexpathを遷移先に渡す
        if let mediaViewController = segue.destination as? MediaViewController,
            let indexPath = self.collectionView.indexPathsForSelectedItems?.first?.row {
            mediaViewController.itemNumber = indexPath
        }
    }
}
    
// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension CheckViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    // セルの数を返すメソッド
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // チェックリストの項目数を返す
        guard let list = self.list else { return 0 }
        return list.count
    }
    // セルの内容を返すメソッド
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: CollectionViewCell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCell", for: indexPath) as! CollectionViewCell
        // ???
        guard let list = self.list  else {
            print("リストが存在しません。")
            return cell
        }
        // チェック項目の取得
        let checkItem: CheckItem = list[indexPath.row]
        // タイトルの表示
        cell.titleLabel.text = checkItem.title
        // 保存先のURLを取得
        let mediaType: String = checkItem.isImage ? ".jpg" : ".MOV"
        guard let mediaUrl: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(checkItem.path + mediaType) else { return cell }
        // サムネイル画像を表示
        if checkItem.isImage {
            print(mediaUrl.path)
            cell.thumbnail.image = UIImage(contentsOfFile: mediaUrl.path)
        } else {
            // 動画を取得
            let video: AVURLAsset = AVURLAsset(url: mediaUrl)
            print(video)
            // サムネイルジェネレーター
            let imageGenerator: AVAssetImageGenerator = AVAssetImageGenerator(asset: video)
            // サムネイルを縦向きにする
            imageGenerator.appliesPreferredTrackTransform = true
            /*let capturingTime: CMTime = CMTimeMakeWithSeconds(CMTimeGetSeconds(video.duration) * 0.5, preferredTimescale: 1)*/
            // サムネイルを生成・表示
            do {
                let thumbnail: CGImage = try imageGenerator.copyCGImage(at: .zero, actualTime: nil)
                cell.thumbnail.image = UIImage(cgImage: thumbnail)
            } catch {
                print(error)
            }
        }
        return cell
    }
    /// セルがタップされたときに呼ばれるメソッド
    ///
    /// - Parameters:
    ///   - collectionView: UICollectionView
    ///   - indexPath: IndexPath
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        // 遷移処理
        performSegue(withIdentifier: "MediaSegue",sender: nil)
    }
}


