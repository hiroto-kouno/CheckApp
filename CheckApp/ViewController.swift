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
    
    
    // MARK: - Private
    
    var realm: Realm?
    
    var list: List<CheckItem>?
    
    var itemNumber: Int = 0
    
    let label: UILabel = UILabel()
    
    var infos: [[UIImagePickerController.InfoKey : Any]] = []
    
    var images: [UIImage] = []
    
    let userDefaults:UserDefaults = UserDefaults.standard
    
    var deleteButtons: [UIButton] = []
    
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
        print(userDefaults.bool(forKey: "isGoOut"))
        // チェックリストの作成
        self.list = self.realm?.objects(CheckItemList.self).first?.list
        
        print(self.list)
        // デリゲート
        self.tableView.delegate = self
        self.tableView.dataSource = self
        // カスタムセルの登録
        let nib: UINib = UINib(nibName: "CheckItemTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "Cell")
        // 編集モードにする
        self.tableView.isEditing = true

        // TableViewのレイアウト
        self.tableView.separatorColor = .black
        self.tableView.layer.borderWidth = 1.0
        self.tableView.layer.borderColor = UIColor.black.cgColor
        
        //self.tableView.rowHeight = 34
        print(self.tableView.contentSize.height)
        
        //self.scrollView.contentSize.height = 2000
        //self.scrollView.flashScrollIndicators()
        
        // NavigationBarのレイアウト
        self.navigationItem.title = "チェックリスト"
        var editBarButtonItem = UIBarButtonItem(title: "削除", style: .done, target: self, action: #selector(editBarButtonTapped(_:)))
        self.navigationItem.leftBarButtonItems = [editBarButtonItem]
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("aaaaaa")
        for button in deleteButtons {
            button.isHidden = true
        }
        // テーブルの更新
        self.tableView.rowHeight = 50
        self.deleteButtons = []
        self.tableView.reloadData()
        //self.tableViewHeight.constant = CGFloat(self.tableView.contentSize.height)
        self.tableViewHeight.constant = CGFloat(self.tableView.rowHeight * CGFloat(self.list!.count))
        print(self.tableViewHeight.constant)
        print(self.list)
    }
    
    // MARK: - IBAction
    @IBAction func handleDepatureButton(_ sender: Any) {
        // 撮影番号の初期化
        self.itemNumber = 0
        self.generateCamera()
    }
    
    // MARK: - Prepare
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let inputViewController:InputViewController = segue.destination as? InputViewController else { return }
        // セルを選択した場合
        if segue.identifier == "cellSegue", let list = self.list {
            print("ccc")
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.checkItem = list[indexPath!.row]
            inputViewController.isAdd = false
        } else { //新規作成ボタンを押した場合
            print("bbb")
            let checkItem = CheckItem()
            inputViewController.isAdd = true
            if let allItems = self.realm?.objects(CheckItem.self), allItems.count != 0 {
                checkItem.id = allItems.max(ofProperty: "id")! + 1
            }
            inputViewController.checkItem = checkItem
        }
    }
    
    // MARK: - Private Method
    // デフォルトデータを登録する
    func insertSeedData() {
        // インスタンスを生成
        let checkItemList = CheckItemList()
        // デフォルト情報
        let defaultItems: [String] = ["ガス", "電気スイッチ", "水道", "窓", "玄関"]
        let defaultIsImage: [String:Bool] = ["ガス": true, "電気スイッチ": true, "水道": true, "窓": true,"玄関": false]
        // リストにデフォルトを登録
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
        print("999")
        // リストをrealmに書き込み
        try? self.realm?.write {
            self.realm?.add(checkItemList, update: .modified)
        }
    }
    
    @objc func editBarButtonTapped(_ sender: UIBarButtonItem) {
        self.isDelete.toggle()
        self.tableView.reloadData()
        print("【編集】ボタンが押された!")
    }
    
    func generateCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            // インスタンスを生成
            let pickerController = UIImagePickerController()
            // デリゲート
            pickerController.delegate = self
            // 画像の取得先：カメラ
            pickerController.sourceType = .camera
            // メディアタイプの選択
            if let list = self.list {
                pickerController.mediaTypes = list[itemNumber].isImage ? ["public.image"] : ["public.movie"]
                self.label.text = "\(list[itemNumber].title)を撮影してください"
            }
            // ラベルの設定
            self.label.frame = CGRect(x: 200, y: 170, width: self.view.frame.width, height: 30)
            self.label.textColor = .white
            self.label.center.x = self.view.center.x
            self.label.textAlignment = NSTextAlignment.center
            self.label.alpha = 1.0
            // 遷移
            self.present(pickerController, animated: true) {
                //ラベルのアニメーション設定
                pickerController.cameraOverlayView = self.label
                UIView.animate(withDuration: 2.0, delay: 3.0, options: [.curveEaseIn], animations: {
                    self.label.alpha = 0.0
                }, completion: nil)
            }
        }
    }
}
// MARK: - UITableViewDataSource, UITableViewDelegate
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    // セルの数を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let list = self.list else { return 0 }
        return list.count
    }
    
    // セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能なセルがあればそのセル、なければ新しく作ったものを取得
        // PostTavleViewCellに型キャスト
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CheckItemTableViewCell
        //let checkItem = checkItemArray[indexPath.row]
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
        try? self.realm?.write {
            if let list = self.list {
                let sourceItem = list[sourceIndexPath.row]
                list.remove(at: sourceIndexPath.row)
                list.insert(sourceItem, at: destinationIndexPath.row)
            }
        }
        self.tableView.reloadData()
    }
    
    // 編集モードを選択するメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        // (8)
        if isDelete {
            return .delete
        } else {
            return .none
        }
    }
    
    //
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
            return false
        }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            try? self.realm?.write {
                if let item = self.list?[indexPath.row] {
                    self.realm?.delete(item)
                }
            }
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            self.tableViewHeight.constant = CGFloat(self.tableView.contentSize.height)
        }
    }
    
    //各セルを選択したときに実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("ddd")
        performSegue(withIdentifier: "cellSegue",sender: nil)
    }
    
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // 写真を撮影/選択したときに呼ばれるメソッド
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let documentsDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first, let list = self.list else { return }
        
        if (list[itemNumber].isImage){
            if let image = (info[.originalImage] as? UIImage)?.jpegData(compressionQuality: 1.0) {
                do {
                    try image.write(to: documentsDirectoryUrl.appendingPathComponent(list[self.itemNumber].path + ".jpg"))
                    print("保存成功！")
                } catch {
                    print("保存失敗", error)
                }
            }
        } else {
            guard let fileUrl = info[UIImagePickerController.InfoKey.mediaURL] as? URL else { return }
            let saveUrl: URL = documentsDirectoryUrl.appendingPathComponent(list[self.itemNumber].path+".MOV")
            
            do {
                if FileManager.default.fileExists(atPath: saveUrl.path) {
                    // すでに fileUrl2 が存在する場合はファイルを削除する
                    try FileManager.default.removeItem(at: saveUrl)
                }
                try FileManager.default.moveItem(at: fileUrl, to: saveUrl)
                print("保存成功！")
            } catch {
                print("保存失敗！\(error)")
            }
        }
        
        var videoUrls = [URL]()
        
        do {
            // Documentから動画ファイルのURLを取得
            videoUrls = try FileManager.default.contentsOfDirectory(at: documentsDirectoryUrl, includingPropertiesForKeys: nil)
        } catch {
            print("フォルダが空です。")
        }
        
        print("\(videoUrls):323232")

        self.itemNumber += 1
        picker.dismiss(animated: true, completion: nil)
        
        if itemNumber == list.count, let checkViewController = self.storyboard?.instantiateViewController(withIdentifier: "CheckNavigation"),
           let popoverViewController = self.storyboard?.instantiateViewController(withIdentifier: "Popover"){
            
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
            return
        }
        self.generateCamera()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // UIImagePickerControllerを閉じる
        // ポップアップを出す
        self.dismiss(animated: true, completion: nil)
    }
}

