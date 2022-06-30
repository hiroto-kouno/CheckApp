//
//  ViewController.swift
//  CheckApp
//
//  Created by 河野 裕門 on 2022/06/03.
//

import UIKit
import RealmSwift

class ViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var goOutButton: Button!
    
    // MARK: - Private
    var realm: Realm?
    var list: List<CheckItem>?
    var itemNumber: Int = 0
    let cameraLabel: UILabel = CameraLabel()
    let cameraView: UIView = CameraView()
    let isNotExistCellLabel: UILabel = UILabel()
    let userDefaults:UserDefaults = UserDefaults.standard
    var isDelete: Bool = false
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Realmのインスタンス化
        self.realm = try? Realm()
        // 初回起動の判定
        if self.userDefaults.bool(forKey: "isInitialLaunch") != true {
            self.userDefaults.set(true, forKey: "isInitialLaunch")
            self.userDefaults.set(false, forKey: "isGoOut")
            self.userDefaults.synchronize()
            self.insertSeedData()
        }
        // チェックリストの作成
        self.list = self.realm?.objects(CheckItemList.self).first?.list
        // 全メディアファイルの削除
        self.deleteMedia()
        // デリゲート
        self.tableView.delegate = self
        self.tableView.dataSource = self
        // カスタムセルの登録
        let nib: UINib = UINib(nibName: "CheckItemTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "Cell")
        // 編集モードにする
        self.tableView.isEditing = true
        // チェックリストが空の時用のラベルを設定
        self.setIsNotExistCellLabel()
        // 出発ボタンのカスタマイズ
        goOutButton.imageEdgeInsets = UIEdgeInsets(top: 17, left: 0, bottom: 17, right: 0)
        goOutButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 90)
        // NavigationBarのカスタマイズ
        self.navigationItem.title = "チェックリスト"
        let editBarButtonItem = UIBarButtonItem(title: "削除", style: .plain, target: self, action: #selector(editBarButtonTapped(_:)))
        self.navigationItem.leftBarButtonItems = [editBarButtonItem]
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // リストの取得
        guard let list = self.list else { return }
        // リストが空の場合、ラベルを表示し、追加ボタンのみを有効にする。
        if list.count == 0 {
            self.isNotExistCellLabel.isHidden = false
            self.goOutButton.isEnabled = false
            self.navigationItem.leftBarButtonItems?[0].isEnabled = false
            self.goOutButton.alpha = 0.4
        } else {
            self.goOutButton.isEnabled = true
            self.isNotExistCellLabel.isHidden = true
            self.navigationItem.leftBarButtonItems?[0].isEnabled = true
            self.goOutButton.alpha = 1
        }
        // 削除ボタンの再設定
        self.navigationItem.leftBarButtonItems?[0].title = "削除"
        self.navigationItem.leftBarButtonItems?[0].style = .plain
        // テーブルの高さの設定
        self.tableView.rowHeight = 60
        self.tableView.reloadData()
        self.tableViewHeight.constant = self.tableView.rowHeight * CGFloat(list.count) - CGFloat(0.8)
        // 削除モードをオフにする
        self.isDelete = false
        self.tableView.allowsSelectionDuringEditing = true
        showDocumentDirectory()
    }
    
    // MARK: - IBAction
    @IBAction func handleDepatureButton(_ sender: Any) {
        // 撮影番号の初期化
        self.itemNumber = 0
        // アラートの設定
        let alert = UIAlertController(title: "チェック項目の撮影を開始します。\nよろしいですか？", message: "", preferredStyle: .alert)
        // 撮影へ
        let yesAction = UIAlertAction(title: "はい", style: .default) { (UIAlertAction) in
            self.generateCamera()
        }
        let noAction = UIAlertAction(title: "いいえ", style: .default) { (UIAlertAction) in
            
        }
        alert.addAction(noAction)
        alert.addAction(yesAction)
        // アラートの表示
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Prepare
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let inputViewController:InputViewController = segue.destination as? InputViewController else { return }
        // セルを選択した場合、該当データを渡す
        if segue.identifier == "cellSegue", let list = self.list ,
           let indexPath = self.tableView.indexPathForSelectedRow {
            inputViewController.checkItem = list[indexPath.row]
            inputViewController.isAdd = false
        } else { // 新規作成ボタンを押した場合、新規データを渡す
            let checkItem = CheckItem()
            inputViewController.isAdd = true
            if let allItems = self.realm?.objects(CheckItem.self), allItems.count != 0 {
                checkItem.id = allItems.max(ofProperty: "id")! + 1
            }
            inputViewController.checkItem = checkItem
        }
    }
    
    // MARK: - Private Method
    // 初回起動時に呼ばれ、初期データを登録するメソッド
    func insertSeedData() {
        // インスタンスを生成
        let checkItemList = CheckItemList()
        // 初期データとなる情報
        let defaultItems: [String] = ["ガス", "電気スイッチ", "水道", "窓", "玄関"]
        let defaultIsImage: [String:Bool] = ["ガス": true, "電気スイッチ": true, "水道": true, "窓": true,"玄関": false]
        // リストに初期データを登録
        for (index, item) in defaultItems.enumerated() {
            let checkItem = CheckItem()
            checkItem.id = index
            checkItem.title = item
            let uuid = UUID()
            checkItem.path = uuid.uuidString
            if let isImage = defaultIsImage[item] {
                checkItem.isImage = isImage
            }
            checkItemList.list.append(checkItem)
        }
        // リストをrealmに書き込み
        try? self.realm?.write {
            self.realm?.add(checkItemList, update: .modified)
        }
    }
    // テーブルが空の場合のラベルの設定
    func setIsNotExistCellLabel() {
        self.isNotExistCellLabel.text = "チェック項目がありません。"
        self.isNotExistCellLabel.frame = CGRect(x: 200, y: 170, width: self.view.frame.width, height: self.view.frame.height / 2)
        self.isNotExistCellLabel.textColor = .black
        self.isNotExistCellLabel.center.x = self.view.center.x
        self.isNotExistCellLabel.textAlignment = NSTextAlignment.center
        self.isNotExistCellLabel.alpha = 1.0
        self.view.addSubview(self.isNotExistCellLabel)
        self.isNotExistCellLabel.isHidden = true
    }
    // メディアを削除するメソッド
    func deleteMedia() {
        // チェックリスト,ドキュメントディレクトリを取得
        guard let list = self.list, let documentsDirectoryUrl: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        // 保存先のパスを削除
        for checkItem in list {
            let mediaType: String = checkItem.isImage ? ".jpg" : ".MOV"
            let path: String = documentsDirectoryUrl.appendingPathComponent(checkItem.path + mediaType).path
            do {
                if FileManager.default.fileExists(atPath: path) {
                    try FileManager.default.removeItem(atPath: path)
                    print("\(path)の削除")
                } else {
                    print("該当データなし")
                }
            } catch {
                print(error)
            }
        }
        // コンソール用
        showDocumentDirectory()
    }
    
    // 削除ボタンをタップしたときに呼ばれるメソッド
    @objc func editBarButtonTapped(_ sender: UIBarButtonItem) {
        guard let count = self.list?.count else { return }
        if count == 0 { return }

        var alpha: CGFloat = 1.0
        // ボタンタップ時に文言を変更する。
        if(sender.title == "削除") {
            sender.title = "完了"
            sender.style = .done
            alpha = 0.4
        } else {
            sender.title = "削除"
            sender.style = .plain
        }
        // 削除モード・テーブル選択可能を切り替え
        self.isDelete.toggle()
        self.tableView.allowsSelectionDuringEditing.toggle()
        // ボタン使用可能の切り替え
        self.goOutButton.isEnabled.toggle()
        UIView.animate(withDuration: 0.2) {
            self.goOutButton.alpha = alpha
        }
        // テーブルを更新
        self.tableView.reloadData()
    }
    
    // 撮影前に毎回呼ばれるメソッド
    func generateCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            // インスタンスを生成
            let pickerController = UIImagePickerController()
            // デリゲート
            pickerController.delegate = self
            // 画像の取得先：カメラ
            pickerController.sourceType = .camera
            // 撮影メディアタイプの選択
            guard let list = self.list else { return }
            pickerController.mediaTypes = list[itemNumber].isImage ? ["public.image"] : ["public.movie"]
            // ラベルの位置・設定
            self.cameraLabel.text = "\(list[itemNumber].title)を撮影してください"
            self.cameraLabel.sizeToFit()
            self.cameraView.alpha = 1.0
            self.cameraView.frame = CGRect(x: 200, y: 180, width: self.cameraLabel.frame.width + 50, height: 30)
            self.cameraView.center.x = self.view.center.x
            self.cameraLabel.center = CGPoint(x: cameraView.frame.size.width / 2,
                                              y: cameraView.frame.size.height / 2)
            self.cameraView.addSubview(self.cameraLabel)
            // カメラを開く
            self.present(pickerController, animated: true) {
                //ラベルのアニメーション設定
                pickerController.cameraOverlayView = self.cameraView
                UIView.animate(withDuration: 2.0, delay: 3.0, options: [.curveEaseIn], animations: {
                    self.cameraView.alpha = 0.0
                }, completion: nil)
            }
        }
    }
    
    // 全ての撮影完了時に呼ばれるメソッド
    func completionPhotographing() {
        guard let checkViewController = self.storyboard?.instantiateViewController(withIdentifier: "CheckNavigation"),
              let popoverViewController = self.storyboard?.instantiateViewController(withIdentifier: "Popover") else { return }
            let date: Date = Date()
            let formatter: DateFormatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/dd"
            let dateString: String = formatter.string(from: date)
            self.userDefaults.set(dateString, forKey: "date")
            self.userDefaults.synchronize()
            self.userDefaults.set(true, forKey: "isGoOut")
            self.userDefaults.synchronize()
            
            self.present(checkViewController, animated: true) {
                checkViewController.present(popoverViewController, animated: true, completion: nil)
            }
    }
    
    func showDocumentDirectory () {
        guard let documentsDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        var videoUrls = [URL]()
        do {
            // Documentから動画ファイルのURLを取得
            videoUrls = try FileManager.default.contentsOfDirectory(at: documentsDirectoryUrl, includingPropertiesForKeys: nil)
        } catch {
            print("フォルダが空です。")
        }
        print("\(videoUrls):VIDEOURL")
    }
}
// MARK: - UITableViewDataSource, UITableViewDelegate
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    // セルの数を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // チェックリストの項目数を返す
        guard let list = self.list else { return 0 }
        return list.count
    }
    
    // セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CheckItemTableViewCell
        // リストからデータを取得しセルに表示
        if let checkItem = list?[indexPath.row] {
            cell.titleLabel.text = "\(indexPath.row + 1). \(checkItem.title)"
            cell.mediaTypeLabel.text = checkItem.isImage ? "画像": "動画"
        }
        return cell
    }
    
    // セルの並べ替えが可能かを返すメソッド
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // 並び替えが行われた時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // 並び替えをRealmのリストに反映
        try? self.realm?.write {
            guard let list = self.list else { return }
            let sourceItem = list[sourceIndexPath.row]
            list.remove(at: sourceIndexPath.row)
            list.insert(sourceItem, at: destinationIndexPath.row)
        }
        // テーブルを更新
        self.tableView.reloadData()
    }
    
    // 編集モードを選択するメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        // 削除ボタンの押下で判定
        if isDelete {
            return .delete
        } else {
            return .none
        }
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    // Deleteボタン押下時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // 該当データをRealmから削除
        if editingStyle == .delete {
            try? self.realm?.write {
                guard let item = self.list?[indexPath.row] else { return }
                self.realm?.delete(item)
            }
            guard let count = self.list?.count else { return }
            // リストが空になった場合の処理
            if count == 0 {
                self.isNotExistCellLabel.isHidden = false
                self.goOutButton.isEnabled = false
                self.goOutButton.alpha = 0.4
                self.navigationItem.leftBarButtonItems?[0].title = "削除"
                self.navigationItem.leftBarButtonItems?[0].style = .plain
                self.navigationItem.leftBarButtonItems?[0].isEnabled = false
            }
            // テーブルから該当データを削除
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            // 削除アニメーション用
            DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                self.tableViewHeight.constant = self.tableView.rowHeight * CGFloat(count) - CGFloat(0.8)
                self.tableView.reloadData()
            }
        }
    }
    
    //各セルを選択したときに実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("セルの選択が行われた")
        performSegue(withIdentifier: "cellSegue",sender: nil)
    }
    
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // 写真を撮影したときに呼ばれるメソッド
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // ドキュメントディレクトリをを取得
        guard let documentsDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first, let list = self.list else { return }
        // メディアタイプが画像の場合
        if (list[itemNumber].isImage){
            guard let image = (info[.originalImage] as? UIImage)?.jpegData(compressionQuality: 1.0) else { return }
            do {
                try image.write(to: documentsDirectoryUrl.appendingPathComponent(list[self.itemNumber].path + ".jpg"))
                print("保存成功！")
            } catch {
                print("保存失敗", error)
            }
        } else { // メディアタイプが動画の場合
            guard let fileUrl = info[UIImagePickerController.InfoKey.mediaURL] as? URL else { return }
            let saveUrl: URL = documentsDirectoryUrl.appendingPathComponent(list[self.itemNumber].path+".MOV")
            
            do {
                if FileManager.default.fileExists(atPath: saveUrl.path) {
                    // すでに動画が存在する場合はファイルを削除する
                    try FileManager.default.removeItem(at: saveUrl)
                }
                try FileManager.default.moveItem(at: fileUrl, to: saveUrl)
                print("保存成功！")
            } catch {
                print("保存失敗！\(error)")
            }
        }
        
        // ファイルの確認(削除・保存処理チェック用)
        self.showDocumentDirectory()

        self.itemNumber += 1
        picker.dismiss(animated: true, completion: nil)
        
        if itemNumber == list.count {
            completionPhotographing()
        } else {
            self.generateCamera()
        }
    }
    
    // キャンセルボタンが押されたときに呼ばれるメソッド
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // アラートの設定
        let alert = UIAlertController(title: "チェックリスト画面に戻ります。\nよろしいですか？", message: "ここまで撮影したメディアは全て削除されます。", preferredStyle: .alert)
        // 「はい」→pickerを閉じて、データを削除
        let yesAction = UIAlertAction(title: "はい", style: .default) { (UIAlertAction) in
            self.dismiss(animated: true, completion: nil)
            self.deleteMedia()
        }
        let noAction = UIAlertAction(title: "いいえ", style: .default) { (UIAlertAction) in
        }
        alert.addAction(noAction)
        alert.addAction(yesAction)
        picker.present(alert, animated: true, completion: nil)
        
    }
}

