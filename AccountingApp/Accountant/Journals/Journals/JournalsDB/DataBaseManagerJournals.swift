//
//  DataBaseManagerJournals.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/06/01.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

// 仕訳帳クラス
class DataBaseManagerJournals: DataBaseManager {
    
    /**
    * データベース　データベースにモデルが存在するかどうかをチェックするメソッド
    * モデルオブジェクトをデータベースから読み込む。
    * @param DataBase モデルオブジェクト
    * @param fiscalYear 年度
    * @return モデルオブジェクトが存在するかどうか
    */
    func checkInitialising(DataBase: DataBaseJournals, fiscalYear: Int) -> Bool {
        super.checkInitialising(DataBase: DataBase, fiscalYear: fiscalYear)
    }
    // モデルオブフェクトの追加　仕訳帳
    func addJournals(number: Int) {
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // 会計帳簿　のオブジェクトを取得
        let object = realm.object(ofType: DataBaseAccountingBooks.self, forPrimaryKey: number)!
        // オブジェクトを作成
        let dataBaseJournals = DataBaseJournals() // 仕訳帳
        dataBaseJournals.fiscalYear = object.fiscalYear
        // (2)書き込みトランザクション内でデータを追加する
        try! realm.write {
            let number = dataBaseJournals.save() //ページ番号(一年で1ページ)　自動採番
            print("addJournals",number)
            // 年度　の数だけ増える
            object.dataBaseJournals = dataBaseJournals
        }
    }
    // モデルオブフェクトの削除
    func deleteJournals(number: Int) -> Bool {
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているモデルを取得する　プライマリーキーを指定してオブジェクトを取得
        let object = realm.object(ofType: DataBaseJournals.self, forPrimaryKey: number)!
        try! realm.write {
            realm.delete(object.dataBaseJournalEntries) //仕訳
            realm.delete(object.dataBaseAdjustingEntries) //決算整理仕訳
            realm.delete(object) // 仕訳帳
        }
        return object.isInvalidated // 成功したら true まだ失敗時の動きは確認していない
    }
}
