//
//  DataBaseManagerSettingsOperating.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/12/10.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

// 設定操作クラス
class DataBaseManagerSettingsOperating {

    // データベースにモデルが存在するかどうかをチェックする
    func checkInitialising() -> Bool {
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているモデルを全て取得する
        let objects = realm.objects(DataBaseSettingsOperating.self)
        return objects.count > 0 // モデルオブフェクトが1以上ある場合はtrueを返す
    }
    // モデルオブフェクトの追加　仕訳帳
    func addSettingsOperating() {
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)書き込みトランザクション内でデータを追加する
        // オブジェクトを作成
        let dataBaseSettingsOperating = DataBaseSettingsOperating() // 仕訳帳
        try! realm.write {
            let number = dataBaseSettingsOperating.save() // 自動採番
            realm.add(dataBaseSettingsOperating)
        }
    }
    // 取得
    func getSettingsOperating() -> DataBaseSettingsOperating? {
        let realm = try! Realm()
        let object = realm.object(ofType: DataBaseSettingsOperating.self, forPrimaryKey: 1)
        return object
    }
    // 更新　スイッチの切り替え
    func updateSettingsOperating(EnglishFromOfClosingTheLedger: String, isOn: Bool){
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)書き込みトランザクション内でデータを更新する
        try! realm.write {
            let value: [String: Any] = ["number": 1, "\(EnglishFromOfClosingTheLedger)": isOn]
            realm.create(DataBaseSettingsOperating.self, value: value, update: .modified) // 一部上書き更新
        }
    }

}
