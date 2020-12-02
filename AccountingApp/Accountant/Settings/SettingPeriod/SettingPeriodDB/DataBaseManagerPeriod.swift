//
//  DataBaseManagerPeriod.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/06/04.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

// 会計期間クラス
class DataBaseManagerPeriod {

    // すべてのモデルオブフェクトの取得
    func getMainBooksAllCount() -> Int {
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているモデルを全て取得する
        var objects = realm.objects(DataBaseAccountingBooks.self) // モデル
        // ソートする        注意：ascending: true とするとモデルオブフェクトのnumberの自動採番がおかしくなる？
        objects = objects.sorted(byKeyPath: "fiscalYear", ascending: true) // 引数:プロパティ名, ソート順は昇順か？
        return objects.count
    }
    // すべてのモデルオブフェクトの取得
    func getMainBooksAll() -> Results<DataBaseAccountingBooks> {
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているモデルを全て取得する
        var objects = realm.objects(DataBaseAccountingBooks.self) // モデル
        // ソートする        注意：ascending: true とするとモデルオブフェクトのnumberの自動採番がおかしくなる？
        objects = objects.sorted(byKeyPath: "fiscalYear", ascending: true) // 引数:プロパティ名, ソート順は昇順か？
        return objects
    }
    // 特定のモデルオブフェクトの取得　会計帳簿
    func getSettingsPeriod() -> DataBaseAccountingBooks { // メソッド名を変更する
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているモデルを全て取得する
        var objects = realm.objects(DataBaseAccountingBooks.self) // モデル
        // 希望の年度の会計帳簿を絞り込む 開いている会計帳簿
        objects = objects.filter("openOrClose == \(true)")
        // (2)データベース内に保存されているモデルをひとつ取得する
        let object = realm.object(ofType: DataBaseAccountingBooks.self, forPrimaryKey: objects[0].number)!
        return object // 会計帳簿を返す
    }
    // 年度の取得　会計帳簿
    func getSettingsPeriodYear() -> Int {
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているモデルを全て取得する
        var objects = realm.objects(DataBaseAccountingBooks.self) // モデル
        // 希望の年度の会計帳簿を絞り込む 開いている会計帳簿
        objects = objects.filter("openOrClose == \(true)")
        // (2)データベース内に保存されているモデルをひとつ取得する
        let object = realm.object(ofType: DataBaseAccountingBooks.self, forPrimaryKey: objects[0].number)!
        return object.fiscalYear // 年度を返す
    }
    // モデルオブフェクトの更新
    func setMainBooksOpenOrClose(tag: Int){
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        //(2)データベース内に保存されているDataBaseAccountingBooksShelfモデルをひとつ取得する
        let object = realm.object(ofType: DataBaseAccountingBooksShelf.self, forPrimaryKey: 1)! // 会計帳簿棚は会社に一つ
        // (2)書き込みトランザクション内でデータを更新する
        try! realm.write {
            // 一括更新　一旦、すべてのチェックマークを外す
            object.setValue(false, forKeyPath: "dataBaseAccountingBooks.openOrClose")
            // そして、選択された年度の会計帳簿にチェックマークをつける
            let value: [String: Any] = ["number": tag, "openOrClose": true]
            realm.create(DataBaseAccountingBooks.self, value: value, update: .modified) // 一部上書き更新
        }
    }
}
