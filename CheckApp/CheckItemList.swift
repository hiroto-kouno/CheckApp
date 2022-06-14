//
//  CheckItemList.swift
//  CheckApp
//
//  Created by 河野 裕門 on 2022/06/05.
//

import RealmSwift

class CheckItemList: Object {
    // プライマリーキー
    @objc dynamic var id = 0
    // チェック項目のデータを格納するリスト
    let list = List<CheckItem>()
    // id をプライマリーキーとして設定
    override static func primaryKey() -> String? {
        return "id"
    }
}
