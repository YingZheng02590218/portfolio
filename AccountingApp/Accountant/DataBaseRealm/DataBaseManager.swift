//
//  DataBaseManager.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/08/29.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

// データベースマネジャー
class DataBaseManager {

    /**
    * データベース　データベースにモデルが存在するかどうかをチェックするメソッド
    * モデルオブジェクトをデータベースから読み込む。
    * @param DataBase モデルオブジェクト
    * @param fiscalYear 年度
    * @return モデルオブジェクトが存在するかどうか
    */
    func checkInitialising<T>(DataBase: T, fiscalYear: Int) -> Bool {
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているモデルを全て取得する
        if DataBase is DataBaseAccountingBooksShelf {
            let objects = realm.objects(DataBaseAccountingBooksShelf.self) // モデル
            return objects.count > 0 // モデルオブフェクトが1以上ある場合はtrueを返す
        }else if DataBase is DataBaseAccountingBooks {
            var objects = realm.objects(DataBaseAccountingBooks.self)
            objects = objects.filter("fiscalYear == \(fiscalYear)")
            return objects.count > 0 
        }else if DataBase is DataBaseJournals {
            var objects = realm.objects(DataBaseJournals.self)
            objects = objects.filter("fiscalYear == \(fiscalYear)")
            return objects.count > 0
            
        }else if DataBase is DataBaseGeneralLedger {
            var objects = realm.objects(DataBaseGeneralLedger.self)
            objects = objects.filter("fiscalYear == \(fiscalYear)")
            return objects.count > 0
        }else if DataBase is DataBaseFinancialStatements {
            var objects = realm.objects(DataBaseFinancialStatements.self)
            objects = objects.filter("fiscalYear == \(fiscalYear)")
            return objects.count > 0
        }else {
            var objects = realm.objects(DataBaseJournals.self)
            objects = objects.filter("fiscalYear == \(fiscalYear)")
            return objects.count > 0
        }
    }
}
