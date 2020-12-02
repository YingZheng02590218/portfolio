//
//  Initial.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/06/02.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation

// 初期化クラス
class Initial {
    
    /**
    * 初期化　初期化メソッド
    * 設定勘定科目、会計帳簿棚、表示科目を初期化する。
    */
    func initialize() {
        // 設定画面　設定勘定科目　初期化
        initialiseMasterData()
        // 設定画面　会計帳簿棚　初期化
        initializeAccountingBooksShelf()
        // 表示科目　初期化
        initializeTaxonomy()
    }
    /**
    * 初期化　初期化メソッド
    * 設定勘定科目を初期化する。
    */
    func initialiseMasterData() {
        let databaseManagerSettingsTaxonomyAccount = DatabaseManagerSettingsTaxonomyAccount()
        if !databaseManagerSettingsTaxonomyAccount.checkInitialising() {
            let masterData = MasterData()
            // マスターデータを作成する
            masterData.readMasterDataFromCSVOfTaxonomyAccount()   
        }
        let dataBaseManagerSettingsTaxonomy = DataBaseManagerSettingsTaxonomy()
        if !dataBaseManagerSettingsTaxonomy.checkInitialising() {
            let masterData = MasterData()
            masterData.readMasterDataFromCSVOfTaxonomy()
        }
        // 設定勘定科目　初期化　勘定科目のスイッチを設定する　表示科目が選択されていなければOFFにする
        databaseManagerSettingsTaxonomyAccount.initializeSettingsTaxonomyAccount()
        // 設定表示科目　初期化　表示科目のスイッチを設定する　勘定科目のスイッチONが、ひとつもなければOFFにする
        dataBaseManagerSettingsTaxonomy.initializeSettingsTaxonomy()
    }
    /**
    * 初期化　初期化メソッド
    * 会計帳簿棚を初期化する。
    */
    func initializeAccountingBooksShelf() {
        let dataBaseManager = DataBaseManagerAccountingBooksShelf()
        if !dataBaseManager.checkInitialising(DataBase: DataBaseAccountingBooksShelf(), fiscalYear: 0) {
            let number = dataBaseManager.addAccountingBooksShelf(company: "事業者名")
            print(number)
        }
        // 会計帳簿
        initializeAccountingBooks()
    }
    /**
    * 初期化　年度メソッド
    * 初期値用の年月を取得する。
    */
    func getTheTime() -> Int {
        // 現在時刻を取得
        let now :Date = Date() // UTC時間なので　9時間ずれる

        switch Calendar.current.dateComponents([.month], from: now).month! {
        case 4,5,6,7,8,9,10,11,12:
            return Calendar.current.dateComponents([.year], from: now).year!
//        case 1,2,3:
//            return Calendar.current.date(byAdding: .year, value: -1, to: now)!
        default:
            let lastYear = Calendar.current.dateComponents([.year], from: now).year!
            return lastYear-1 // 1月から3月であれば去年の年に補正する
        }
    }
    /**
    * 初期化　初期化メソッド
    * 会計帳簿を初期化する。
    */
    func initializeAccountingBooks() {
        let dataBaseManager = DataBaseManagerAccountingBooks()
        var fiscalYear = getTheTime()     // デフォルトで現在の年月から今年度の会計帳簿を作成する
        fiscalYear -= 1                     // デフォルトで現在の年月から前年度の会計帳簿を作成する
        if !dataBaseManager.checkInitializing() {
            let number = dataBaseManager.addAccountingBooks(fiscalYear: fiscalYear)
            // 仕訳帳画面　　初期化
            initialiseJournals(number: number,fiscalYear: fiscalYear)
            // 総勘定元帳画面　初期化
            initialiseAccounts(number: number,fiscalYear: fiscalYear)
            // 決算書画面　初期化
            initializeFinancialStatements(number: number,fiscalYear: fiscalYear)
        }
    }
    /**
    * 初期化　初期化メソッド
    * 仕訳帳を初期化する。
    */
    func initialiseJournals(number: Int,fiscalYear: Int){
         let dataBaseManager = DataBaseManagerJournals()
        if !dataBaseManager.checkInitialising(DataBase: DataBaseJournals(), fiscalYear: fiscalYear) {
            dataBaseManager.addJournals(number: number)
        }
    }
    /**
    * 初期化　初期化メソッド
    * 総勘定元帳を初期化する。
    */
    func initialiseAccounts(number: Int,fiscalYear: Int) {
        let dataBaseManager = DataBaseManagerGeneralLedger()
        // データベースに勘定画面の勘定があるかをチェック
        if !dataBaseManager.checkInitialising(DataBase: DataBaseGeneralLedger(), fiscalYear: fiscalYear) {
            dataBaseManager.addGeneralLedger(number: number)
        }
    }
    /**
    * 初期化　初期化メソッド
    * 財務諸表を初期化する。
    */
    func initializeFinancialStatements(number: Int,fiscalYear: Int) {
        let dataBaseManager = DataBaseManagerFinancialStatements()
        // データベースに財務諸表があるかをチェック
        if !dataBaseManager.checkInitialising(DataBase: DataBaseFinancialStatements(), fiscalYear: fiscalYear) {
            dataBaseManager.addFinancialStatements(number: number)
        }
    }
    /**
    * 初期化　初期化メソッド
    * 表示科目を初期化する。
    */
    func initializeTaxonomy() {
        // 表示科目
        let dataBaseManagerTaxonomy = DataBaseManagerTaxonomy()
        let isInvalidated = dataBaseManagerTaxonomy.deleteTaxonomyAll()
        if isInvalidated {
            dataBaseManagerTaxonomy.addTaxonomyAll()
        }else {
            print("deleteTaxonomyAll 失敗")
        }
    }
}
