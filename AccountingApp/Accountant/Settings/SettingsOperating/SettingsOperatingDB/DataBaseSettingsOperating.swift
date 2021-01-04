//
//  DataBaseSettingsOperating.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/12/10.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

// 設定操作
class DataBaseSettingsOperating: RObject {
    // 連番　プライマリーキー
    @objc dynamic var EnglishFromOfClosingTheLedger0: Bool = false // 損益振替仕訳
    @objc dynamic var EnglishFromOfClosingTheLedger1: Bool = false // 資本振替仕訳
}
