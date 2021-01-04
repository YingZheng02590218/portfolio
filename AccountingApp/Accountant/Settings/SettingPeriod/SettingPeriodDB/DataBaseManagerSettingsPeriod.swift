//
//  DataBaseManagerSettingsPeriod.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/06/04.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

// 会計期間クラス
class DataBaseManagerSettingsPeriod {

    // データベースにモデルが存在するかどうかをチェックする
    func checkInitialising() -> Bool {
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているモデルを全て取得する
        let objects = realm.objects(DataBaseSettingsPeriod.self)
        return objects.count > 0 // モデルオブフェクトが1以上ある場合はtrueを返す
    }
    // 追加　会計期間
    func addSettingsPeriod() {
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)書き込みトランザクション内でデータを追加する
        // オブジェクトを作成
        let dataBaseSettingsPeriod = DataBaseSettingsPeriod() // 仕訳帳
        try! realm.write {
            let number = dataBaseSettingsPeriod.save() // 自動採番
            realm.add(dataBaseSettingsPeriod)
        }
    }
    // 取得　決算日
    func getTheDayOfReckoning() -> String {
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているモデルを全て取得する
        let object = realm.object(ofType: DataBaseSettingsPeriod.self, forPrimaryKey: 1)
        return object!.theDayOfReckoning
    }
    // 更新　決算日
    func setTheDayOfReckoning(month: Bool, date: String) {
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        var dateChanged = ""
        if date.count < 2 {
           dateChanged = "0" + date
        }else {
            dateChanged = date
        }
        var theDayOfReckoning = ""
        let d = getTheDayOfReckoning()
        if !month {
            theDayOfReckoning = String(d.prefix(2) + "/\(dateChanged)") // 先頭2文字
        }else { // 月
            // 月別に日数を調整する
            var dayChanged = ""
            switch dateChanged {
            case "02":
                if d.suffix(2) == "29" || d.suffix(2) == "30" || d.suffix(2) == "31" {
                    dayChanged = "28"
                    theDayOfReckoning = String("\(dateChanged)/" + dayChanged) // 末尾2文字
                }else {
                    theDayOfReckoning = String("\(dateChanged)/" + d.suffix(2)) // 末尾2文字
                }
                break
            case "04","06","09","11":
                if d.suffix(2) == "31" {
                    dayChanged = "30"
                    theDayOfReckoning = String("\(dateChanged)/" + dayChanged) // 末尾2文字
                }else {
                    theDayOfReckoning = String("\(dateChanged)/" + d.suffix(2)) // 末尾2文字
                }
                break
            default:
                theDayOfReckoning = String("\(dateChanged)/" + d.suffix(2)) // 末尾2文字
                break
            }
        }
        // (2)書き込みトランザクション内でデータを更新する
        try! realm.write {
            // 選択された月または日に更新する
            let value: [String: Any] = ["number": 1, "theDayOfReckoning": theDayOfReckoning]
            realm.create(DataBaseSettingsPeriod.self, value: value, update: .modified) // 一部上書き更新
        }
    }
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
    func getSettingsPeriod(lastYear: Bool) -> DataBaseAccountingBooks { // メソッド名を変更する
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているモデルを全て取得する
        var objects = realm.objects(DataBaseAccountingBooks.self) // モデル
        // 希望の年度の会計帳簿を絞り込む 開いている会計帳簿
        objects = objects.filter("openOrClose == \(true)")
        // 前年度の会計帳簿をし取得する場合
        if lastYear {
            let objectss = realm.objects(DataBaseAccountingBooks.self)
            for i in 0..<objectss.count {
                if objects[0].fiscalYear - 1 == objectss[i].fiscalYear { // 前年度と同じ年の会計帳簿を判断
                    return objectss[i] // 前年度の会計帳簿を返す
                }
            }
        }
        return objects[0] // 今年度の会計帳簿を返す
    }
    // チェック　会計帳簿　前年度の会計帳簿
    func checkSettingsPeriod() -> Bool { // メソッド名を変更する
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているモデルを全て取得する
        var objects = realm.objects(DataBaseAccountingBooks.self) // モデル
        // 希望の年度の会計帳簿を絞り込む 開いている会計帳簿
        objects = objects.filter("openOrClose == \(true)")
        let objectss = realm.objects(DataBaseAccountingBooks.self)
        for i in 0..<objectss.count {
            if objects[0].fiscalYear - 1 == objectss[i].fiscalYear { // 前年度と同じ年の会計帳簿を判断
                return true // 前年度の会計帳簿はある
            }
        }
        return false // 前年度の会計帳簿はない
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
