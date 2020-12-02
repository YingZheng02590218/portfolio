//
//  DataBaseCashFlowStatement.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/06/16.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift 

// キャッシュフロー計算書クラス
class DataBaseCashFlowStatement: RObject {
    @objc dynamic var fiscalYear: Int = 0                                             //年度
    @objc dynamic var CashFlowsFromOperatingActivities: Int = 0                     //Cash flows from operating activities    営業活動からのキャッシュ・フロー
    @objc dynamic var CashFlowsFromInvestingActivities: Int = 0                     //Cash flows from investing activities    投資活動からのキャッシュ・フロー
    @objc dynamic var CashFlowsFromfInancingActivities: Int = 0                     //Cash flows from financing activities    財務活動からのキャッシュ・フロー
    @objc dynamic var EffectOfExchangeRateChangesOnCashAndCashEquivalents: Int = 0 //Effect of exchange rate changes on cash and cash equivalents    為替相場変動の現金及び現金同等物に対する影響額
    @objc dynamic var NetIncreaseInCashAndCashEquivalents: Int = 0                  //Net increase in cash and cash equivalents    現金及び現金同等物純増加額
    @objc dynamic var CashAndCashEquivalentsAtBeginningOfPeriod: Int = 0           //Cash and cash equivalents at beginning of period    現金及び現金同等物期首残高
    @objc dynamic var CashAndCashEquivalentsAtEndOfPeriod: Int = 0                  //Cash and cash equivalents at end of period    現金及び現金同等物四半期末残高
}
