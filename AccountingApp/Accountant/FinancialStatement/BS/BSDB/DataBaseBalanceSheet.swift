//
//  DataBaseBalanceSheet.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/06/14.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift 

// 貸借対照表クラス
class DataBaseBalanceSheet: RObject {
    @objc dynamic var fiscalYear: Int = 0                          //年度

    @objc dynamic var CurrentAssets_total: Int64 = 0            //流動資産　中分類　合計
    @objc dynamic var FixedAssets_total: Int64 = 0               //固定資産　中分類　合計
    @objc dynamic var DeferredAssets_total: Int64 = 0            //繰延資産　中分類　合計 繰延資産
    @objc dynamic var Asset_total: Int64 = 0                       //大分類　合計

    @objc dynamic var CurrentLiabilities_total: Int64 = 0       //流動負債　中分類　合計
    @objc dynamic var FixedLiabilities_total: Int64 = 0         //固定負債　中分類　合計
    @objc dynamic var Liability_total: Int64 = 0                  //大分類　合計

    @objc dynamic var CapitalStock_total: Int64 = 0              //株主資本　中分類　合計
    @objc dynamic var OtherCapitalSurpluses_total: Int64 = 0   //その他の包括利益累計額 評価・換算差額等　中分類　合計
    @objc dynamic var Equity_total: Int64 = 0                     //大分類　合計
    
    let dataBaseTaxonomy = List<DataBaseTaxonomy>()              //表示科目　使用していない　2020/10/09 損益計算書には表示科目の属性がない 2020/11/12 使用する
}
