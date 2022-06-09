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
    
    // MARK: - member
    
    let realm = try! Realm()
    var isImage: Bool = true
    var isAdd: Bool = true
    var checkItem: CheckItem!
    var list: List<CheckItem>!
    var checkItemList: CheckItemList!
    //= CheckItemList()
    
    // MARK: - lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.list = self.realm.objects(CheckItemList.self).first?.list
        self.titleTextField.text = self.checkItem.title
        if self.checkItem.isImage == false {
            self.segmentedControl.selectedSegmentIndex = 1
            isImage = false
        }
        self.navigationItem.title = self.checkItem.title
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        var docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(self.checkItem.path + "jpg").path
        imageView.image = UIImage(contentsOfFile: docDir)
    }
    
    // MARK: - IBAction
    @IBAction func changedSegmentedControl(_ sender: UISegmentedControl) {
        self.isImage = sender.selectedSegmentIndex == 0 ? true : false
     }
    
    
    @IBAction func handleRegisterButton(_ sender: Any) {
        /*try! realm.write {
            self.checkItem.title = self.titleTextField.text!
            let allTasks = realm.objects(CheckItem.self)
            if allTasks.count != 0 {
                checkItem.id = allTasks.max(ofProperty: "id")! + 1
            }
            self.checkItem.isImage = self.isImage
            self.realm.add(self.checkItem, update: .modified)
        }*/
        try! realm.write {
            self.checkItem.title = self.titleTextField.text!
            /*let allTasks = realm.objects(CheckItem.self)
            if allTasks.count != 0 {
                checkItem.id = allTasks.max(ofProperty: "id")! + 1
            }*/
            self.checkItem.isImage = self.isImage
            if isAdd {
                let uuid = UUID()
                self.checkItem.path = uuid.uuidString
                self.list.append(checkItem)
            }
            self.realm.add(self.checkItem, update: .modified)
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    

}
