//
//  ViewController.swift
//  CheckApp
//
//  Created by 河野 裕門 on 2022/06/03.
//

import UIKit
import RealmSwift

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: - IBOutlet
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Private
    
    let realm: Realm = try! Realm()
    
    var list: List<CheckItem>!
    
    var itemNumber: Int = 0
    
    let label: UILabel = UILabel()
    
    var infos: [[UIImagePickerController.InfoKey : Any]] = []
    
    var images: [UIImage] = []
    
    let userDefaults:UserDefaults = UserDefaults.standard
    
    //var checkItemArray = try! Realm().objects(CheckItem.self).sorted(byKeyPath: "checkNumber")
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.userDefaults.bool(forKey: "initialLaunch") != true {
            print("aaa")
            self.userDefaults.set(true, forKey: "initialLaunch")
            self.userDefaults.synchronize()
            self.insertSeedData()
        }
        
        self.list = realm.objects(CheckItemList.self).first?.list
        
        print(self.list)
        
        self.navigationItem.title = "チェックリスト"
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        // 指定したxibファイルを取得
        let nib: UINib = UINib(nibName: "CheckItemTableViewCell", bundle: nil)
        // テーブルビューにnib(カスタムセル)を登録
        self.tableView.register(nib, forCellReuseIdentifier: "Cell")
        
        self.tableView.isEditing = true
        
        self.tableView.separatorColor = .black
        self.tableView.layer.borderWidth = 1.0 //枠線の太さを指定
        self.tableView.layer.borderColor = UIColor.black.cgColor
        
        var editBarButtonItem = UIBarButtonItem(title: "編集", style: .done, target: self, action: #selector(editBarButtonTapped(_:)))
        // ③バーボタンアイテムの追加
        self.navigationItem.leftBarButtonItems = [editBarButtonItem]
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("aaaaaa")
        self.tableView.reloadData()
        print(self.list)
    }
    
    // MARK: - IBAction
    @IBAction func handleDepatureButton(_ sender: Any) {
        itemNumber = 0
        self.generateCamera()
        
    }
    
    // MARK: - Delegate
    
    // セルの数を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.list.count
    }
    
    // セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能なセルがあればそのセル、なければ新しく作ったものを取得
        // PostTavleViewCellに型キャスト
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CheckItemTableViewCell
        //let checkItem = checkItemArray[indexPath.row]
        let checkItem = list[indexPath.row]
        cell.titleLabel.text = checkItem.title
        cell.mediaTypeLabel.text = checkItem.isImage ? "画像": "動画"
        
        return cell
    }
    
    // セルの並べ替えが可能かを返すメソッド
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        try! realm.write {
            let sourceItem = list[sourceIndexPath.row]
            list.remove(at: sourceIndexPath.row)
            list.insert(sourceItem, at: destinationIndexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        // (8)
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
            return false
        }
    
    /*func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .normal,
                                            title: "normal") { (action, view, completionHandler) in
                                              // 何らかのアクション（処理）を実行

                                              // 処理の実行結果に関わらず completionHandler を呼ぶのがポイント
                                              completionHandler(true)
            }
            let configuration = UISwipeActionsConfiguration(actions: [action])
            return configuration
    }*/
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
                    try! realm.write {
                        let item = list[indexPath.row]
                        realm.delete(item)
                    }
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
    }
    
    //各セルを選択したときに実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("ddd")
        performSegue(withIdentifier: "cellSegue",sender: nil)
        /*if let inputViewController = storyboard?.instantiateViewController(withIdentifier: "Input") as? InputViewController {
            inputViewController.checkItem = list[indexPath.row]
            inputViewController.isAdd = false
            inputViewController.modalPresentationStyle = .fullScreen
            self.present(inputViewController, animated: true, completion: nil)
        }*/
    }
    
    // 写真を撮影/選択したときに呼ばれるメソッド
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let documentsDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        if (self.list[itemNumber].isImage){
            if let image = (info[.originalImage] as? UIImage)?.jpegData(compressionQuality: 1.0) {
                do {
                    try image.write(to: documentsDirectoryUrl.appendingPathComponent(self.list[itemNumber].path+"jpg"))
                    print("保存成功！")
                } catch {
                    print("保存失敗", error)
                }
            }
        } else {
            guard let fileUrl = info[UIImagePickerController.InfoKey.mediaURL] as? URL else { return }
            do {
                try FileManager.default.moveItem(at: fileUrl, to: documentsDirectoryUrl.appendingPathComponent(self.list[itemNumber].path+"MOV"))
                print("保存成功！")
            } catch {
                print("保存失敗！")
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
        
        picker.dismiss(animated: true, completion: nil)
        
        self.itemNumber += 1

        if itemNumber == self.list.count {
            return
        }
        // UIImagePickerController画面を閉じる
        
        //self.itemNumber += 1
        self.generateCamera()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // UIImagePickerControllerを閉じる
        // ポップアップを出す
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Prepare
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let inputViewController:InputViewController = segue.destination as? InputViewController else { return }
        // セルを選択した場合
        if segue.identifier == "cellSegue" {
            print("ccc")
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.checkItem = list[indexPath!.row]
            inputViewController.isAdd = false
        } else { //新規作成ボタンを押した場合
            print("bbb")
            let checkItem = CheckItem()
            inputViewController.isAdd = true
            let allItems = realm.objects(CheckItem.self)
            if allItems.count != 0 {
                checkItem.id = allItems.max(ofProperty: "id")! + 1
            }
            
            
            inputViewController.checkItem = checkItem
        }
        
        
    }
    
    
    // MARK: - Private
    
    @objc func editBarButtonTapped(_ sender: UIBarButtonItem) {
            print("【編集】ボタンが押された!")
        }
    
    func insertSeedData() {
            // 空のアプリユーザーを作成
        let checkItemList = CheckItemList()
        
        //var checkItems: [CheckItem] = []
        let defaultItems: [String] = ["ガス", "電気スイッチ", "水道", "窓", "玄関"]
        let defaultIsImage: [String:Bool] = ["ガス": true, "電気スイッチ": true, "水道": true, "窓": true,"玄関": false]
        
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
            //checkItems.append(checkItem)
        }
        try! realm.write {
            //realm.add(checkItems, update: .modified)
            realm.add(checkItemList, update: .modified)
        }
        }
    
    func generateCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            // インスタンスを生成
            //let pickerController = UIImagePickerController()
            let pickerController = UIImagePickerController()
            // デリゲートを指定
            pickerController.delegate = self
            // 画像の取得先を指定
            pickerController.sourceType = .camera
            
            pickerController.mediaTypes = self.list[itemNumber].isImage ? ["public.image"] : ["public.movie"]
            self.label.frame = CGRect(x: 200, y: 170, width: self.view.frame.width, height: 30)
            self.label.text = "\(self.list[itemNumber].title)を撮影してください"
            self.label.textColor = .white
            self.label.center.x = self.view.center.x
            self.label.textAlignment = NSTextAlignment.center
            self.label.alpha = 1.0
            
            // 設定したpickerControllerに遷移する
            self.present(pickerController, animated: true) {
                pickerController.cameraOverlayView = self.label
                UIView.animate(withDuration: 2.0, delay: 3.0, options: [.curveEaseIn], animations: {
                    print("oioioi")
                    self.label.alpha = 0.0
                }, completion: nil)
                
                
            }

            
            
            
        }
    }
}

