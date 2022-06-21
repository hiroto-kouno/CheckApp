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
    @IBOutlet weak var button: UIButton!
    
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
        //　ボタンのカスタマイズ
        button.imageEdgeInsets = UIEdgeInsets(top: 15, left: 10, bottom: 15, right: 18)
        // segmentedControlのカスタマイズ
        let customOrange: UIColor = UIColor(red: 0.918, green: 0.584, blue: 0.427, alpha: 1)
        // 未選択時
        let normalFont = UIFont.systemFont(ofSize: 18)
        let normalAttribute: [NSAttributedString.Key: Any] = [.font: normalFont, .foregroundColor: customOrange]
        self.segmentedControl.setTitleTextAttributes(normalAttribute, for: .normal)
        // 選択時
        let selectedFont = UIFont.boldSystemFont(ofSize: 18)
        let selectedAttribute: [NSAttributedString.Key: Any] = [.font: selectedFont, .foregroundColor: UIColor.white]
        self.segmentedControl.setTitleTextAttributes(selectedAttribute, for: .selected)
        // ナビゲーションバーのカスタマイズ
        self.navigationItem.title = checkItem.title
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: - IBAction
    // SegmentendControlを切り替えたときに呼ばれるメソッド
    @IBAction func changedSegmentedControl(_ sender: UISegmentedControl) {
        // 画像・動画のフラグを切り替え
        self.isImage = sender.selectedSegmentIndex == 0 ? true : false
     }
    // 保存ボタンを押したときに呼ばれるメソッド
    @IBAction func handleRegisterButton(_ sender: Any) {
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
