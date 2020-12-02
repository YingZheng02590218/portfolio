//
//  MasterData.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/05/22.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

// マスターデータクラス
class MasterData {

    func toBoolean(string:String) -> Bool {
        switch string {
        case "TRUE", "True", "true", "YES", "Yes", "yes", "1":
            return true
        case "FALSE", "False", "false", "NO", "No", "no", "0":
            return false
        default:
            return false
        }
    }
    
    // CSVファイルを読み込み、Realmデータベースにモデルオブフェクトを登録して、マスターデータを作成
    func readMasterDataFromCSVOfTaxonomyAccount() {
        if let csvPath = Bundle.main.path(forResource: "TaxonomyAccount", ofType: "csv") {
            var csvString = ""
            do{
                csvString = try NSString(contentsOfFile: csvPath, encoding: String.Encoding.utf8.rawValue) as String
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            csvString.enumerateLines { (line, stop) -> () in
                // 保存先のパスを出力しておく
                print("保存先のパス: \(Realm.Configuration.defaultConfiguration.fileURL!))")
                // モデルオブフェクトを生成
                let dataBaseSettingsTaxonomyAccount = DataBaseSettingsTaxonomyAccount()
                var number = 0 // 自動採番にした
                dataBaseSettingsTaxonomyAccount.Rank0 = line.components(separatedBy:",")[0] // 大区分
                dataBaseSettingsTaxonomyAccount.Rank1 = line.components(separatedBy:",")[1] // 中区分
                dataBaseSettingsTaxonomyAccount.Rank2 = line.components(separatedBy:",")[2] // 小区分
                dataBaseSettingsTaxonomyAccount.numberOfTaxonomy = line.components(separatedBy:",")[3] // 紐づけた表示科目
                dataBaseSettingsTaxonomyAccount.category = line.components(separatedBy:",")[4] // 勘定科目名
                dataBaseSettingsTaxonomyAccount.switching = self.toBoolean(string: line.components(separatedBy:",")[5]) // スイッチ
                // 書き込み
                let realm = try! Realm()
                try! realm.write {
                    number = dataBaseSettingsTaxonomyAccount.save() // 連番　自動採番
                    realm.add(dataBaseSettingsTaxonomyAccount)
                }
                print("連番: \(number), \(dataBaseSettingsTaxonomyAccount.numberOfTaxonomy)")
            }
        }
    }
    // CSVファイルを読み込み、Realmデータベースにモデルオブフェクトを登録して、マスターデータを作成
    func readMasterDataFromCSVOfTaxonomy() {
        if let csvPath = Bundle.main.path(forResource: "taxonomy", ofType: "csv") {
            var csvString = ""
            do{
                csvString = try NSString(contentsOfFile: csvPath, encoding: String.Encoding.utf8.rawValue) as String
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            csvString.enumerateLines { (line, stop) -> () in
                // 保存先のパスを出力しておく
                print("保存先のパス: \(Realm.Configuration.defaultConfiguration.fileURL!))")
                // モデルオブフェクトを生成
                let dataBaseSettingsCategoryTaxonomy = DataBaseSettingsTaxonomy()
                var number = 0 // 自動採番にした
                dataBaseSettingsCategoryTaxonomy.category0 = line.components(separatedBy:",")[0]
                dataBaseSettingsCategoryTaxonomy.category1 = line.components(separatedBy:",")[1]
                dataBaseSettingsCategoryTaxonomy.category2 = line.components(separatedBy:",")[2]
                dataBaseSettingsCategoryTaxonomy.category3 = line.components(separatedBy:",")[3]
                dataBaseSettingsCategoryTaxonomy.category4 = line.components(separatedBy:",")[4]
                dataBaseSettingsCategoryTaxonomy.category5 = line.components(separatedBy:",")[5]
                dataBaseSettingsCategoryTaxonomy.category6 = line.components(separatedBy:",")[6]
                dataBaseSettingsCategoryTaxonomy.category7 = line.components(separatedBy:",")[7]
                dataBaseSettingsCategoryTaxonomy.category = line.components(separatedBy:",")[8]//表示科目
                dataBaseSettingsCategoryTaxonomy.abstract = self.toBoolean(string: line.components(separatedBy:",")[9])
                dataBaseSettingsCategoryTaxonomy.switching = self.toBoolean(string: line.components(separatedBy:",")[10])
                // 書き込み
                let realm = try! Realm()
                try! realm.write {
                    number = dataBaseSettingsCategoryTaxonomy.save() // 連番　自動採番
                    realm.add(dataBaseSettingsCategoryTaxonomy)
                }
                print("連番: \(number)")
            }
        }
    }
}
