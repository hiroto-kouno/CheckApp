//
//  MediaViewController.swift
//  CheckApp
//
//  Created by 河野 裕門 on 2022/06/10.
//

import UIKit
import RealmSwift
import AVFoundation

class MediaViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var movieView: MovieView!
    
    // MARK: - Private
    var itemNumber: Int = 0
    var realm: Realm?
    var list: List<CheckItem>? 
    var moviePlayer: AVPlayer?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Realmのインスタンス化
        self.realm = try? Realm()
        // リストの作成
        self.list = self.realm?.objects(CheckItemList.self).first?.list
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // ドキュメントディレクトリ取得
        guard let documentsDirectoryUrl: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
              let list = self.list else { return }
        // データの保存先取得
        let checkItem: CheckItem = list[self.itemNumber]
        let mediaType: String = checkItem.isImage ? ".jpg" : ".MOV"
        let mediaUrl: URL = documentsDirectoryUrl.appendingPathComponent(checkItem.path + mediaType)
        // メディアの出力
        if(checkItem.isImage) {
            self.imageView.image = UIImage(contentsOfFile: mediaUrl.path)
        } else {
            self.playMovie(movieUrl: mediaUrl)
        }
        
        // ナビゲーションバーのカスタマイズ
        self.navigationItem.title = checkItem.title
    }
    
    // MARK: - Private Method
    // 動画の再生
    func playMovie(movieUrl: URL) {
        // 動画再生後の処理
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        // URLから動画を再生
        let item: AVPlayerItem = AVPlayerItem(url: movieUrl)
        self.moviePlayer = AVPlayer(playerItem: item)
        self.movieView.player = self.moviePlayer
        self.moviePlayer?.play()
    }
    
    // 動画再生後に呼ばれるメソッド(リピート再生用)
    @objc private func playerItemDidReachEnd(_ notification: Notification) {
        // 動画を巻き戻す
        self.moviePlayer?.currentItem?.seek(to: CMTime.zero, completionHandler: nil)
        // 動画を再生
        self.moviePlayer?.play()
    }
}
