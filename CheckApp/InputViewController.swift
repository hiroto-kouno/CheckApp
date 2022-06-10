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
    //var checkItemList: CheckItemList!
    
    // MARK: - lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.realm = try? Realm()
        self.list = self.realm?.objects(CheckItemList.self).first?.list
        guard let checkItem = self.checkItem else { return }
        self.titleTextField.text = checkItem.title
        if checkItem.isImage == false {
            self.segmentedControl.selectedSegmentIndex = 1
            isImage = false
        }
        self.navigationItem.title = checkItem.title
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: - IBAction
    @IBAction func changedSegmentedControl(_ sender: UISegmentedControl) {
        self.isImage = sender.selectedSegmentIndex == 0 ? true : false
     }
    
    
    @IBAction func handleRegisterButton(_ sender: Any) {
        guard let checkItem = self.checkItem else { return }
        try? self.realm?.write {
            checkItem.title = self.titleTextField.text!
            checkItem.isImage = self.isImage
            if isAdd, let list = self.list {
                let uuid = UUID()
                checkItem.path = uuid.uuidString
                list.append(checkItem)
            }
            self.realm?.add(checkItem, update: .modified)
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    

}
