//
//  DataBaseProfitAndLossStatement.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/06/16.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

// 損益計算書クラス
class DataBaseProfitAndLossStatement: RObject {
    @objc dynamic var fiscalYear: Int = 0                                     //年度
    
    @objc dynamic var NetSales: Int64 = 0                                     //売上高 Net sales
    @objc dynamic var CostOfGoodsSold: Int64 = 0                             //商品売上原価 Cost of goods sold
    @objc dynamic var GrossProfitOrLoss: Int64 = 0                           //売上総利益（損失）Gross profit (loss)
    
    @objc dynamic var SellingGeneralAndAdministrativeExpenses: Int64 = 0 //販売費及び一般管理費 Selling, general and administrative expenses
    @objc dynamic var OtherCapitalSurpluses_total: Int64 = 0               //営業利益（損失）⇒ Operating income (loss)
    
    @objc dynamic var NonOperatingIncome: Int64 = 0                         //営業外収益 ⇒ Non-operating income
    @objc dynamic var NonOperatingExpenses: Int64 = 0                       //営業外費用 ⇒ Non-operating expenses
    @objc dynamic var OrdinaryIncomeOrLoss: Int64 = 0                       //経常利益（損失）⇒ Ordinary income (loss)
    
    @objc dynamic var ExtraordinaryIncome: Int64 = 0                        //特別利益 ⇒ Extraordinary income
    @objc dynamic var ExtraordinaryLosses: Int64 = 0                        //特別損失 ⇒ Extraordinary losses
    @objc dynamic var IncomeOrLossBeforeIncomeTaxes: Int64 = 0            //税引前当期純利益（損失）⇒ Income (loss) before income taxes
    
    @objc dynamic var IncomeTaxes: Int64 = 0                                 //法人税等 ⇒ Income taxes
    @objc dynamic var NetIncomeOrLoss: Int64 = 0                             //当期純利益（損失）⇒ Net income (loss)
}
