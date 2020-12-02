//
//  DataBaseSettingsTaxonomy.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/07/19.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift 

// 設定表記名クラス
//class DataBaseSettingsCategoryBSAndPL: RObject {
//    // モデル定義
//    @objc dynamic var big_category: Int = 0        //大分類
//    @objc dynamic var mid_category: Int = 0        //中分類
//    @objc dynamic var small_category: Int = 0      //小分類
//    @objc dynamic var BSAndPL_category: Int = 0   //表記名の番号
//    @objc dynamic var category: String = ""        //決算書上の表記名
//    @objc dynamic var switching: Bool = false      //有効無効
//}

// 設定表示科目クラス
class DataBaseSettingsTaxonomy: RObject {
    // モデル定義
    // 連番　プライマリーキー
    @objc dynamic var category0: String = "" // 階層0
    @objc dynamic var category1: String = "" // 階層1
    @objc dynamic var category2: String = "" // 階層2  大分類　資産の部　など
    @objc dynamic var category3: String = "" // 階層3
    @objc dynamic var category4: String = "" // 階層4
    @objc dynamic var category5: String = "" // 階層5
    @objc dynamic var category6: String = "" // 階層6
    @objc dynamic var category7: String = "" // 階層7
    @objc dynamic var category: String = ""  //表示科目名
    @objc dynamic var abstract: Bool = false //抽象区分
    @objc dynamic var switching: Bool = false //有効無効

}
