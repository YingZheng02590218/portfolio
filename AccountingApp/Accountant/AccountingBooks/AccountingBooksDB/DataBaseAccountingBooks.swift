//
//  DataBaseAccountingBooks.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/06/02.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift 

// 会計帳簿クラス
// 会計帳簿 は 主要簿　と　補助簿 を 持つことができます。
class DataBaseAccountingBooks: RObject {
    @objc dynamic var fiscalYear: Int = 0                                    // 年度
    @objc dynamic var dataBaseJournals: DataBaseJournals? // 仕訳帳
    // = DataBaseJournals() と書くのは誤り
    @objc dynamic var dataBaseGeneralLedger: DataBaseGeneralLedger?       // 総勘定元帳
//    @objc dynamic var dataBaseSubsidiaryLedger: DataBaseSubsidiaryLedger? // 補助元簿
    @objc dynamic var dataBaseFinancialStatements: DataBaseFinancialStatements?   // 財務諸表
    @objc dynamic var openOrClose: Bool = false                             // 会計帳簿を開いているかどうか
}
