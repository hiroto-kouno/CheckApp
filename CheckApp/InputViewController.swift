//
//  InputViewController.swift
//  CheckApp
//
//  Created by 河野 裕門 on 2022/06/03.
//

import UIKit
import RealmSwift

class InputViewController: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    // MARK: - Private
    var realm: Realm?
    var isImage: Bool = true
    var isAdd: Bool = true
    var checkItem: CheckItem?
    var list: List<CheckItem>?
    
    // MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Realmのインスタンスを生成
        self.realm = try? Realm()
        // リストの取得
        self.list = self.realm?.objects(CheckItemList.self).first?.list
        // 入力項目に既存データを反映
        guard let checkItem = self.checkItem else { return }
        self.titleTextField.text = checkItem.title
        if checkItem.isImage == false {
            self.segmentedControl.selectedSegmentIndex = 1
            isImage = false
        }
        // ナビゲーションバーのカスタマイズ
        self.navigationItem.title = checkItem.title
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: - IBAction
    // SegmentendControlを切り替えたときに呼ばれるメソッド
    @IBAction func changedSegmentedControl(_ sender: UISegmentedControl) {
        self.isImage = sender.selectedSegmentIndex == 0 ? true : false
     }
    // 保存ボタンを押したときに呼ばれるメソッド
    @IBAction func handleRegisterButton(_ sender: Any) {
        print("呼ばれたよ")
        // ボタン押下時のデータをrealmに保存
        guard let checkItem = self.checkItem else { return }
        try? self.realm?.write {
            checkItem.title = self.titleTextField.text!
            checkItem.isImage = self.isImage
            // 新規データ保存の場合の処理
            if isAdd, let list = self.list {
                let uuid = UUID()
                checkItem.path = uuid.uuidString
                list.append(checkItem)
            }
            self.realm?.add(checkItem, update: .modified)
        }
        // チェックリストに戻る
        self.navigationController?.popViewController(animated: true)
    }
    
    

}
