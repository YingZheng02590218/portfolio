//
//  DataBaseWorkSheet.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/06/16.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

// 精算表クラス
// 精算表 は 合計残高試算表(残高試算表部分のみを使用) を 1 つ以上持っています。
class DataBaseWorkSheet: RObject {
    @objc dynamic var fiscalYear: Int = 0                             // 年度
//    @objc dynamic var dataBaseCompoundTrialBalance: DataBaseCompoundTrialBalance? // 合計残高試算表
//    let dataBaseAdjustingEntries = List<DataBaseAdjustingEntry>()          // 決算整理仕訳　一対多の関連
    // 当期純利益は損益計算書に記入する
    @objc dynamic var netIncomeOrNetLossIncome: Int64 = 0                // 当期純利益(損失)
    @objc dynamic var netIncomeOrNetLossLoss: Int64 = 0                // 当期純利益(損失)

    //修正記入
    @objc dynamic var debit_adjustingEntries_total_total: Int64 = 0    //借方　合計　合計
    @objc dynamic var credit_adjustingEntries_total_total: Int64 = 0   //貸方
    @objc dynamic var debit_adjustingEntries_balance_total: Int64 = 0  //借方　残高　合計
    @objc dynamic var credit_adjustingEntries_balance_total: Int64 = 0 //貸方
    //損益計算書
    @objc dynamic var debit_PL_total_total: Int64 = 0                     //借方　合計　合計
    @objc dynamic var credit_PL_total_total: Int64 = 0                    //貸方
    @objc dynamic var debit_PL_balance_total: Int64 = 0                   //借方　残高　合計
    @objc dynamic var credit_PL_balance_total: Int64 = 0                  //貸方
    //貸借対照表
    @objc dynamic var debit_BS_total_total: Int64 = 0                      //借方　合計　合計
    @objc dynamic var credit_BS_total_total: Int64 = 0                     //貸方
    @objc dynamic var debit_BS_balance_total: Int64 = 0                    //借方　残高　合計
    @objc dynamic var credit_BS_balance_total: Int64 = 0                   //貸方
}
