//
//  MediaViewController.swift
//  CheckApp
//
//  Created by 河野 裕門 on 2022/06/06.
//

import UIKit
import RealmSwift

class MediaViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var label: UILabel!
    var list: List<CheckItem>!
    
    var itemNumber = 0
    
    let realm: Realm = try! Realm()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.list = realm.objects(CheckItemList.self).first?.list
        //self.generateCamera()
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        self.generateCamera()
    }
    
    // MARK: - Private
    
    func generateCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            // インスタンスを生成
            let pickerController = UIImagePickerController()
            // デリゲートを指定
            pickerController.delegate = self
            // 画像の取得先を指定
            pickerController.sourceType = .camera
            
            pickerController.mediaTypes = self.list[itemNumber].isImage ? ["public.image"] : ["public.movie"]
            // 設定したpickerControllerに遷移する
            self.present(pickerController, animated: true, completion: nil)
            //ボタンを作成

            //作成したボタンをカメラ画面に重ねる
            //pickerController.cameraOverlayView = label
        }
    }
    
    // MARK: - Delegate
    
    // 写真を撮影/選択したときに呼ばれるメソッド
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // UIImagePickerController画面を閉じる
        picker.dismiss(animated: true, completion: nil)
        self.itemNumber += 1
        self.generateCamera()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // UIImagePickerControllerを閉じる
        self.dismiss(animated: true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
