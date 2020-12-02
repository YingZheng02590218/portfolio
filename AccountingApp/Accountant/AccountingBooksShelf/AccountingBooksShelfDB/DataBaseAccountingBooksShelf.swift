//
//  DataBaseAccountingBooksShelf.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/06/04.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

// 会計帳簿棚クラス
// 会計帳簿棚 は 会計帳簿 を 1 個持つことができます。
class DataBaseAccountingBooksShelf: RObject {
    @objc dynamic var companyName: String = ""                                        // 事業者名
    let dataBaseAccountingBooks = List<DataBaseAccountingBooks>()                  //一対多の関連 会計帳簿
}
