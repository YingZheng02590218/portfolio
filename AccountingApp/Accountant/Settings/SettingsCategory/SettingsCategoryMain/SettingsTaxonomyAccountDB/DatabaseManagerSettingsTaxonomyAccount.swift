//
//  DatabaseManagerSettingsTaxonomyAccount.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/05/22.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

// 設定勘定科目クラス
class DatabaseManagerSettingsTaxonomyAccount  {
    
    // 初期化
    func initializeSettingsTaxonomyAccount(){
        // 勘定科目のスイッチを設定する　表示科目科目が選択されていなければOFFにする
        let objects = getSettingsTaxonomyAccountAll() // 設定勘定科目を全て取得
        for i in 0..<objects.count {
            if objects[i].switching == true { // 設定勘定科目 スイッチ
                if objects[i].numberOfTaxonomy == "" { // 表示科目に紐付けしていない場合
                    updateSettingsCategorySwitching(tag: objects[i].number, isOn: false)
                }
            }else if objects[i].switching == false { // 表示科目科目が選択されていて仕訳データがあればONにする
                if objects[i].numberOfTaxonomy != "" { // 表示科目に紐付けしている場合
                    // 勘定クラス　勘定ないの仕訳を取得
                    let dataBaseManagerAccount = DataBaseManagerAccount()
                    let objectss = dataBaseManagerAccount.getAllJournalEntryInAccountAll(account: objects[i].category) // 全年度の仕訳データを確認する
                    let objectsss = dataBaseManagerAccount.getAllAdjustingEntryInAccountAll(account: objects[i].category) // 全年度の仕訳データを確認する
                    if objectss.count > 0 || objectsss.count > 0 {
                        updateSettingsCategorySwitching(tag: objects[i].number, isOn: true)
                    }
                }
            }
        }
    }
    // チェック
    func checkInitialising() -> Bool {
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているモデルを全て取得する
        let objects = realm.objects(DataBaseSettingsTaxonomyAccount.self)
        return objects.count > 0 // モデルオブフェクトが1以上ある場合はtrueを返す
    }
    // チェック　勘定科目名から大区分が損益計算書の区分かを参照する
    func checkSettingsTaxonomyAccountRank0(account: String) -> Bool {
        let realm = try! Realm()
        var objects = realm.objects(DataBaseSettingsTaxonomyAccount.self)
        objects = objects.sorted(byKeyPath: "number", ascending: true)
        objects = objects.filter("category LIKE '\(account)'") // 勘定科目を絞る
        switch objects[0].Rank0 {
        case "6","7","8","9","10","11":
            return true // 損益計算書の科目である
        default:
            return false // 損益計算書の科目ではない
        }
    }
    // 取得　決算整理仕訳　スイッチ
    func getSettingsTaxonomyAccountAdjustingSwitch(AdjustingAndClosingEntries: Bool, switching: Bool) -> Results<DataBaseSettingsTaxonomyAccount> {
        let realm = try! Realm()
        var objects = realm.objects(DataBaseSettingsTaxonomyAccount.self)
        objects = objects.sorted(byKeyPath: "number", ascending: true)
        objects = objects.filter("AdjustingAndClosingEntries == \(AdjustingAndClosingEntries)")
                            .filter("switching == \(switching)") // 勘定科目がONだけに絞る
        return objects
    }
    // 取得　設定勘定科目　大区分別
    func getSettingsTaxonomyAccount(section: Int) -> Results<DataBaseSettingsTaxonomyAccount> {
        let realm = try! Realm()
        var objects = realm.objects(DataBaseSettingsTaxonomyAccount.self)
        objects = objects.sorted(byKeyPath: "number", ascending: true) // 引数:プロパティ名, ソート順は昇順か？
        objects = objects.filter("Rank0 LIKE '\(section)'")
        return objects
    }
    // 取得 全ての勘定科目
    func getSettingsTaxonomyAccountAll() -> Results<DataBaseSettingsTaxonomyAccount> {
        let realm = try! Realm()
        var objects = realm.objects(DataBaseSettingsTaxonomyAccount.self)
        objects = objects.sorted(byKeyPath: "number", ascending: true)
        return objects
    }
    // 取得 大区分別に、スイッチONの勘定科目
    func getSettingsSwitchingOn(section: Int) -> Results<DataBaseSettingsTaxonomyAccount> {
        let realm = try! Realm()
        var objects = realm.objects(DataBaseSettingsTaxonomyAccount.self)
        objects = objects.sorted(byKeyPath: "number", ascending: true)
        objects = objects.filter("Rank0 LIKE '\(section)'")
                        .filter("switching == \(true)") // 勘定科目がONだけに絞る
        return objects
    }
    // 取得 設定勘定科目 BSとPLで切り分ける　スイッチON
    func getSettingsSwitchingOnBSorPL(BSorPL: Int) -> Results<DataBaseSettingsTaxonomyAccount> {
        let realm = try! Realm()
        var objects = realm.objects(DataBaseSettingsTaxonomyAccount.self)
        objects = objects.sorted(byKeyPath: "number", ascending: true)
        objects = objects.filter("switching == \(true)") // 勘定科目がONだけに絞る
        switch BSorPL {
        case 0: // 貸借対照表　資産 負債 純資産
            objects = objects.filter("Rank0 LIKE '\(0)' OR Rank0 LIKE '\(1)' OR Rank0 LIKE '\(2)' OR Rank0 LIKE '\(3)' OR Rank0 LIKE '\(4)' OR Rank0 LIKE '\(5)' OR Rank0 LIKE '\(12)'")
            break
        case 1: // 損益計算書　費用 収益
            objects = objects.filter("Rank0 LIKE '\(6)' OR Rank0 LIKE '\(7)' OR Rank0 LIKE '\(8)' OR Rank0 LIKE '\(9)' OR Rank0 LIKE '\(10)' OR Rank0 LIKE '\(11)'")
            break
        default:
            print(objects) // ありえない
            break
        }
        return objects
    }
    // 取得
    func getMiddleCategory(category0: String,category1: String,category2: String,category3: String) -> Results<DataBaseSettingsTaxonomyAccount> {
        let realm = try! Realm()
        var objects = realm.objects(DataBaseSettingsTaxonomyAccount.self)
        objects = objects.sorted(byKeyPath: "number", ascending: true) // 引数:プロパティ名, ソート順は昇順か？
        objects = objects.filter("Rank0 LIKE '\(category0)'")
                        .filter("Rank1 LIKE '\(category1)'")
                        .filter("Rank2 LIKE '\(category2)'") // 大区分　資産の部
                        .filter("category3 LIKE '\(category3)'") // 中区分　流動資産
//                        .filter("BSAndPL_category != \(999)") // 仮勘定科目は除外する　貸借対照表に表示しないため
                        .filter("switching == \(true)")
        // セクション　資産の部、負債の部、純資産の部
//        switch mid_category {
//        case 0: // 流動資産
//        case 1: // 固定資産
//        case 2: // 流動負債
//        case 3: // 固定負債
//        case 4: // 株主資本
//        case 5: // 営業費用
//        case 6: // 営業外費用
//        case 7: // 特別損失
//        case 8: // 税等
//        case 9: // 営業収益
//        case 10: // 営業外収益
//        case 11: // 特別利益
        return objects
    }
    // 取得
    func getSmallCategory(category0: String,category1: String,category2: String,category3: String,category4: String,category5: String,category6: String,category7: String) -> Results<DataBaseSettingsTaxonomyAccount> {
        let realm = try! Realm()
        var objects = realm.objects(DataBaseSettingsTaxonomyAccount.self)
        objects = objects.sorted(byKeyPath: "number", ascending: true) // 引数:プロパティ名, ソート順は昇順か？
        // セクション　資産の部、負債の部、純資産の部
        objects = objects.filter("Rank0 LIKE '\(category0)'")
                            .filter("Rank1 LIKE '\(category1)'")
                            .filter("Rank2 LIKE '\(category2)'")
                            .filter("category3 LIKE '\(category3)'") // 小区分
                            // 以下省略
//        switch small_category {
//        case 0: // 当座資産0
//        case 1: // 棚卸資産1
//        case 2: // その他の資産2
//        case 3: // 有形固定資産3
//        case 4: // 無形固定資産4
//        case 5: // 投資その他の資産5
//        case 6: // 仕入債務6
//        case 7: // その他流動負債7
//        case 8: // 売上原価8
//        case 9: // 販売費及び一般管理費9
//        case 10: // 売上高10
//        case 13: // 引当金13
//        case 23: // 減価償却累計額23
//        case 103: // 未収収益103
//        case 100: // 前払費用100
//        case 101: // 前受収益101
//        case 102: // 未払費用102
//        case 15: // 評価・換算差額等15
//        case 21: // 固定資産売却損21
        return objects//.count
    }
    // 取得 設定勘定科目連番　から　表示科目別に勘定科目を取得
    func getSettingsTaxonomyAccountInTaxonomy(number: Int) -> Results<DataBaseSettingsTaxonomyAccount> {
        let realm = try! Realm()
        // 設定勘定科目連番から設定勘定科目を取得
        let object = realm.object(ofType: DataBaseSettingsTaxonomyAccount.self, forPrimaryKey: number)
        // 勘定科目モデルの階層と同じ勘定科目モデルを取得
        var objects = getSettingsTaxonomyAccountInTaxonomy(numberOfTaxonomy: object!.numberOfTaxonomy)
        objects = objects.filter("switching == \(true)") // 勘定科目がONだけに絞る
        print(number, objects)
        return objects
    }
    // 取得 勘定科目の勘定科目名から表示科目連番を取得
    func getNumberOfTaxonomy(category: String) -> Int {
        let realm = try! Realm()
        var objects = realm.objects(DataBaseSettingsTaxonomyAccount.self)
        objects = objects.filter("category LIKE '\(category)'") // 勘定科目を絞る
        return Int(objects[0].numberOfTaxonomy)!
    }
    // 取得 勘定科目連番から表示科目連番を取得
    func getNumberOfTaxonomy(number: Int) -> Int {
        let realm = try! Realm()
        // 勘定科目モデルを取得
        let object = realm.object(ofType: DataBaseSettingsTaxonomyAccount.self, forPrimaryKey: number)
        return Int(object!.numberOfTaxonomy)!
    }
    // 取得 勘定科目の連番から勘定科目を取得
    func getSettingsTaxonomyAccount(number: Int) -> DataBaseSettingsTaxonomyAccount? {
        let realm = try! Realm()
        let object = realm.object(ofType: DataBaseSettingsTaxonomyAccount.self, forPrimaryKey: number)
        return object
    }
    // 取得 設定表示科目連番から表示科目別に設定勘定科目を取得
    func getSettingsTaxonomyAccountInTaxonomy(numberOfTaxonomy: String) -> Results<DataBaseSettingsTaxonomyAccount> {
        let realm = try! Realm()
        var objects = realm.objects(DataBaseSettingsTaxonomyAccount.self)
        objects = objects.sorted(byKeyPath: "number", ascending: true)
        objects = objects.filter("numberOfTaxonomy LIKE '\(numberOfTaxonomy)'")// 表示科目別に絞る
        return objects
    }
    // 取得 設定表示科目別に勘定科目を取得　スイッチON
    func getSettingsTaxonomyAccountSWInTaxonomy(numberOfTaxonomy: String, switching: Bool) -> Results<DataBaseSettingsTaxonomyAccount> {
        let realm = try! Realm()
        var objects = realm.objects(DataBaseSettingsTaxonomyAccount.self)
        objects = objects.sorted(byKeyPath: "number", ascending: true)
        objects = objects.filter("numberOfTaxonomy LIKE '\(numberOfTaxonomy)'")
                        .filter("switching == \(switching)") // 勘定科目がONだけに絞る)
        return objects
    }
    // 更新　スイッチの切り替え
    func updateSettingsCategorySwitching(tag: Int, isOn: Bool){
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)書き込みトランザクション内でデータを更新する
        try! realm.write {
            let value: [String: Any] = ["number": tag, "switching": isOn]
            realm.create(DataBaseSettingsTaxonomyAccount.self, value: value, update: .modified) // 一部上書き更新
        }
    }
    // 更新　勘定科目名を変更
    func updateAccountNameOfSettingsTaxonomyAccount(number: Int, accountName: String){ // すべての影響範囲に修正が必要
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)書き込みトランザクション内でデータを更新する
        try! realm.write {
            let value: [String: Any] = ["number": number, "category": accountName]
            realm.create(DataBaseSettingsTaxonomyAccount.self, value: value, update: .modified) // 一部上書き更新
        }
    }
    // 更新　設定勘定科目　設定勘定科目連番から、紐づける表示科目を変更
    func updateTaxonomyOfSettingsTaxonomyAccount(number: Int, numberOfTaxonomy: String){
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)書き込みトランザクション内でデータを更新する
        try! realm.write {
            let value: [String: Any] = ["number": number, "numberOfTaxonomy": numberOfTaxonomy]
            realm.create(DataBaseSettingsTaxonomyAccount.self, value: value, update: .modified) // 一部上書き更新
        }
    }
    // 追加　設定勘定科目　新規作成
    func addSettingsTaxonomyAccount(Rank0: String, Rank1: String, Rank2: String, numberOfTaxonomy: String, category: String, switching: Bool) -> Int {
        // オブジェクトを作成
        let dataBaseSettingsTaxonomyAccount = DataBaseSettingsTaxonomyAccount()
        var number = 0                                          //プライマリーキー 自動採番にした
        dataBaseSettingsTaxonomyAccount.Rank0 = Rank0
        dataBaseSettingsTaxonomyAccount.Rank1 = Rank1
        dataBaseSettingsTaxonomyAccount.Rank2 = Rank2
        dataBaseSettingsTaxonomyAccount.numberOfTaxonomy = numberOfTaxonomy
        dataBaseSettingsTaxonomyAccount.category = category
//        dataBaseSettingsTaxonomyAccount.dataBaseSettingsTaxonomyAccount.category =  = AdjustingAndClosingEntries
        dataBaseSettingsTaxonomyAccount.switching = switching        // オブジェクトを作成
        let realm = try! Realm()
        try! realm.write {
            number = dataBaseSettingsTaxonomyAccount.save() //　自動採番
            // 設定勘定科目を追加
            realm.add(dataBaseSettingsTaxonomyAccount)
        }
        // オブジェクトを作成 勘定クラス
        let dataBaseManagerAccount = DataBaseManagerAccount()
        dataBaseManagerAccount.addGeneralLedgerAccount(number: number)
        return number
    }
    // 削除　設定勘定科目
    func deleteSettingsTaxonomyAccount(number: Int) -> Bool {
        // 勘定クラス　勘定を削除
        let dataBaseManagerAccount = DataBaseManagerAccount()
        let isInvalidated = dataBaseManagerAccount.deleteAccount(number: number)
        if isInvalidated {
            // (1)Realmのインスタンスを生成する
            let realm = try! Realm()
            // (2)データベース内に保存されているモデルを取得する　プライマリーキーを指定してオブジェクトを取得
            let object = realm.object(ofType: DataBaseSettingsTaxonomyAccount.self, forPrimaryKey: number)!
            try! realm.write {
                // 仕訳が残ってないか
                // 勘定を削除
                realm.delete(object)
            }
            return object.isInvalidated // 成功したら true まだ失敗時の動きは確認していない
        }
        return false // 勘定を削除できたら、設定勘定科目を削除する
    }
}
