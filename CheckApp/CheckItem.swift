//
//  CheckItem.swift
//  CheckApp
//
//  Created by 河野 裕門 on 2022/06/03.
//
import RealmSwift

class CheckItem: Object {
    
    // プライマリーキー
    @objc dynamic var id = 0
    
    // タイトル
    @objc dynamic var title: String = ""
    
    // 画像or動画のフラグ
    @objc dynamic var isImage: Bool = true
    
    // パス名
    @objc dynamic var path: String = ""
    
    // id をプライマリーキーとして設定
    override static func primaryKey() -> String? {
        return "id"
    }
}
