//
//  DataBaseJournals.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/06/01.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

// 仕訳帳クラス
// 仕訳帳 は 仕訳データ を 1 個以上持つことができます。
class DataBaseJournals: RObject {
    @objc dynamic var fiscalYear: Int = 0                     // 年度
    let dataBaseJournalEntries = List<DataBaseJournalEntry>() //一対多の関連
    let dataBaseAdjustingEntries = List<DataBaseAdjustingEntry>() //決算整理仕訳
}
