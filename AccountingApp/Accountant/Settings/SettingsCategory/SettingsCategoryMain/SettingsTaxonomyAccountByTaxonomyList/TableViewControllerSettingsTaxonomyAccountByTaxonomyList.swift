//
//  TableViewControllerCategoryBSAndPLList.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/09/12.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import UIKit
import GoogleMobileAds // マネタイズ対応
import AudioToolbox // 効果音

// 表示科目別勘定科目一覧クラス
class TableViewControllerSettingsTaxonomyAccountByTaxonomyList: UITableViewController {

    // マネタイズ対応
    // 広告ユニットID
    let AdMobID = "ca-app-pub-7616440336243237/8565070944"
    // テスト用広告ユニットID
    let TEST_ID = "ca-app-pub-3940256099942544/2934735716"
    // true:テスト
    let AdMobTest:Bool = true
    @IBOutlet var gADBannerView: GADBannerView!


    // セグメントスイッチ
    @IBOutlet weak var segmentedControl_switch: UISegmentedControl!
    @IBAction func segmentedControl(_ sender: Any) {
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // 要素数が少ないUITableViewで残りの部分や余白を消す
        let tableFooterView = UIView(frame: CGRect.zero)
        tableView.tableFooterView = tableFooterView

        // マネタイズ対応　完了　注意：viewDidLoad()ではなく、viewWillAppear()に実装すること
//        print("Google Mobile Ads SDK version: \(GADRequest.sdkVersion())")
        // GADBannerView を作成する
        gADBannerView = GADBannerView(adSize:kGADAdSizeLargeBanner)
        // GADBannerView プロパティを設定する
        if AdMobTest {
            gADBannerView.adUnitID = TEST_ID
        }
        else{
            gADBannerView.adUnitID = AdMobID
        }
        gADBannerView.rootViewController = self
        // 広告を読み込む
        gADBannerView.load(GADRequest())
        print(tableView.visibleCells[tableView.visibleCells.count-1].frame.height)
        // GADBannerView を作成する
        addBannerViewToView(gADBannerView, constant: tableView.visibleCells[tableView.visibleCells.count-1].frame.height * -1)
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView, constant: CGFloat) {
      bannerView.translatesAutoresizingMaskIntoConstraints = false
      view.addSubview(bannerView)
      view.addConstraints(
        [NSLayoutConstraint(item: bannerView,
                            attribute: .bottom,
                            relatedBy: .equal,
                            toItem: bottomLayoutGuide,
                            attribute: .top,
                            multiplier: 1,
                            constant: constant),
         NSLayoutConstraint(item: bannerView,
                            attribute: .centerX,
                            relatedBy: .equal,
                            toItem: view,
                            attribute: .centerX,
                            multiplier: 1,
                            constant: 0)
        ])
     }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // データベース
        let dataBaseManagerSettingsCategoryBSAndPL = DataBaseManagerSettingsTaxonomy() //データベースマネジャー
        // セクション毎に分けて表示する。indexPath が row と section を持っているので、sectionで切り分ける。ここがポイント
//        let objects = dataBaseManagerSettingsCategoryBSAndPL.getAllSettingsCategoryBSAndPLSwitichON() // どのセクションに表示するセルかを判別するため引数で渡す
        var sheet = 0
        if segmentedControl_switch.selectedSegmentIndex == 0 {
            sheet = 0 // BS
        }else if segmentedControl_switch.selectedSegmentIndex == 1 {
            sheet = 1 // PL
//        }else if segmentedControl_switch.selectedSegmentIndex == 2 {
//            sheet = 4 // CF
        }
        let objects = dataBaseManagerSettingsCategoryBSAndPL.getBigCategoryAll(section: sheet) // どのセクションに表示するセルかを判別するため引数で渡す

        return objects.count
    }
    // セクションヘッダーの高さを決める
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20 //セクションヘッダーの高さを設定　セルの高さより高くしてメリハリをつける セル(Row Hight )
    }
    // セクションヘッダーの色とか調整する
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        // データベース
        let dataBaseManagerSettingsCategoryBSAndPL = DataBaseManagerSettingsTaxonomy() //データベースマネジャー
        var sheet = 0
        if segmentedControl_switch.selectedSegmentIndex == 0 {
            sheet = 0 // BS
        }else if segmentedControl_switch.selectedSegmentIndex == 1 {
            sheet = 1 // PL
//        }else if segmentedControl_switch.selectedSegmentIndex == 2 {
//            sheet = 4 // CF
        }
        let objects = dataBaseManagerSettingsCategoryBSAndPL.getBigCategoryAll(section: sheet) // どのセクションに表示するセルかを判別するため引数で渡す
        let header = view as! UITableViewHeaderFooterView
//        header.textLabel?.textColor = UIColor.gray
        // 階層毎にスペースをつける
        if objects[section].category1 as String == "" {
            header.textLabel?.textAlignment = .left
            header.textLabel?.textColor = UIColor.darkGray
        }else if objects[section].category2 as String == "" {
            header.textLabel?.textAlignment = .left
            header.textLabel?.textColor = UIColor.darkGray
            
        }else if objects[section].category3 as String == "" { // 資産の部　など
            header.textLabel?.textAlignment = .left
            header.textLabel?.textColor = UIColor.gray
        }else if objects[section].category4 as String == "" {
            header.textLabel?.textAlignment = .left
            header.textLabel?.textColor = UIColor.gray
        }else if objects[section].category5 as String == "" {
            header.textLabel?.textAlignment = .left
            header.textLabel?.textColor = UIColor.gray
            
        }else if objects[section].category6 as String == "" {
            header.textLabel?.textAlignment = .left
            header.textLabel?.textColor = UIColor.lightGray
        }else if objects[section].category7 as String == "" {
            header.textLabel?.textAlignment = .left
            header.textLabel?.textColor = UIColor.lightGray
        }else {
            header.textLabel?.textAlignment = .left
            header.textLabel?.textColor = UIColor.lightGray
        }

//        let attributedStr = NSMutableAttributedString(string: header.textLabel?.text)
//        let crossAttr = [NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue]
//        header.textLabel?.text = attributedStr
    }
    // セクションヘッダーのテキスト決める
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // データベース
        let dataBaseManagerSettingsCategoryBSAndPL = DataBaseManagerSettingsTaxonomy() //データベースマネジャー
        // セクション毎に分けて表示する。indexPath が row と section を持っているので、sectionで切り分ける。ここがポイント
//        let objects = dataBaseManagerSettingsCategoryBSAndPL.getAllSettingsCategoryBSAndPLSwitichON() // どのセクションに表示するセルかを判別するため引数で渡す
        var sheet = 0
        if segmentedControl_switch.selectedSegmentIndex == 0 {
            sheet = 0 // BS
        }else if segmentedControl_switch.selectedSegmentIndex == 1 {
            sheet = 1 // PL
//        }else if segmentedControl_switch.selectedSegmentIndex == 2 {
//            sheet = 4 // CF
        }
        let objects = dataBaseManagerSettingsCategoryBSAndPL.getBigCategoryAll(section: sheet) // どのセクションに表示するセルかを判別するため引数で渡す

        // 階層毎にスペースをつける
        if objects[section].category1 as String == "" {
            return "\(objects[section].number), \(objects[section].category as String)"
        }else if objects[section].category2 as String == "" {
            return "\(objects[section].number),   \(objects[section].category as String)"
        }else if objects[section].category3 as String == "" { // 資産の部　など
            return "\(objects[section].number),     \(objects[section].category as String)"
        }else if objects[section].category4 as String == "" {
            return "\(objects[section].number),       \(objects[section].category as String)"
        }else if objects[section].category5 as String == "" {
            return "\(objects[section].number),         \(objects[section].category as String)"
        }else if objects[section].category6 as String == "" {
            return "\(objects[section].number),           \(objects[section].category as String)"
        }else if objects[section].category7 as String == "" {
            return "\(objects[section].number),             \(objects[section].category as String)"
        }else {
            return "\(objects[section].number),               \(objects[section].category as String)"
        }
        // 勘定科目の名称をセルに表示する 丁数(元丁) 勘定名
//        return "\(objects[section].category as String)"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // データベース　表示科目
        let dataBaseManagerSettingsCategoryBSAndPL = DataBaseManagerSettingsTaxonomy() //データベースマネジャー
        // セクション毎に分けて表示する。indexPath が row と section を持っているので、sectionで切り分ける。ここがポイント
//        let objects = dataBaseManagerSettingsCategoryBSAndPL.getAllSettingsCategoryBSAndPLSwitichON() // どのセクションに表示するセルかを判別するため引数で渡す
        var sheet = 0
        if segmentedControl_switch.selectedSegmentIndex == 0 {
            sheet = 0 // BS
        }else if segmentedControl_switch.selectedSegmentIndex == 1 {
            sheet = 1 // PL
//        }else if segmentedControl_switch.selectedSegmentIndex == 2 {
//            sheet = 4 // CF
        }
        let objects = dataBaseManagerSettingsCategoryBSAndPL.getBigCategoryAll(section: sheet) // どのセクションに表示するセルかを判別するため引数で渡す

        // データベース　勘定科目
        let databaseManagerSettings = DatabaseManagerSettingsTaxonomyAccount() //データベースマネジャー
        // セクション毎に分けて表示する。indexPath が row と section を持っているので、sectionで切り分ける。ここがポイント
        let objectss = databaseManagerSettings.getSettingsTaxonomyAccountInTaxonomy(numberOfTaxonomy: String(objects[section].number))
        return objectss.count
    }
    //セルを生成して返却するメソッド
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> TableViewCellCategoryList {
            // データベース　表示科目
            let dataBaseManagerSettingsCategoryBSAndPL = DataBaseManagerSettingsTaxonomy() //データベースマネジャー
            var sheet = 0
            if segmentedControl_switch.selectedSegmentIndex == 0 {
                sheet = 0 // BS
            }else if segmentedControl_switch.selectedSegmentIndex == 1 {
                sheet = 1 // PL
            }else if segmentedControl_switch.selectedSegmentIndex == 2 {
                sheet = 4 // CF
            }
            let objectssss = dataBaseManagerSettingsCategoryBSAndPL.getBigCategoryAll(section: sheet) // どのセクションに表示するセルかを判別するため引数で渡す

            // データベース 勘定科目
            let databaseManagerSettings = DatabaseManagerSettingsTaxonomyAccount()
            let objects = databaseManagerSettings.getSettingsTaxonomyAccountInTaxonomy(numberOfTaxonomy: String(objectssss[indexPath.section].number))
            //① UI部品を指定　TableViewCellCategory
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell_list_category_BSandPL", for: indexPath) as! TableViewCellCategoryList
            // 勘定科目の名称をセルに表示する 丁数(元丁) 勘定名
            cell.textLabel?.text = " \(objects[indexPath.row].number). \(objects[indexPath.row].category as String)"
    //        cell.label_category.text = " \(objects[indexPath.row].category as String)"
            cell.textLabel?.textAlignment = NSTextAlignment.center
            // 勘定科目の連番
            cell.tag = objects[indexPath.row].number
            // 勘定科目の有効無効
            cell.ToggleButton.isOn = objects[indexPath.row].switching
            // 勘定科目の有効無効　変更時のアクションを指定
            cell.ToggleButton.addTarget(self, action: #selector(hundleSwitch), for: UIControl.Event.valueChanged)
            // モデルオブフェクトの取得 勘定別に取得
            let dataBaseManagerAccount = DataBaseManagerAccount()
            let objectss = dataBaseManagerAccount.getAllJournalEntryInAccountAll(account: objects[indexPath.row].category as String)//通常仕訳
            let objectsss = dataBaseManagerAccount.getAllAdjustingEntryInAccountAll(account: objects[indexPath.row].category as String)//決算整理仕訳
            // 仕訳データが存在する場合、トグルスイッチはOFFにできないように、無効化する
            if objectss.count <= 0 && objectsss.count <= 0 {
                //UIButtonを有効化
                cell.ToggleButton.isEnabled = true
            }else {
                //UIButtonを無効化
                cell.ToggleButton.isEnabled = false
            }
            return cell
    }
    // 勘定科目の有効無効　変更時のアクション TableViewの中のどのTableViewCellに配置されたトグルスイッチかを探す
    @objc func hundleSwitch(sender: UISwitch) {
        // UISwitchが配置されたセルを探す
        var hoge = sender.superview // 親ビュー
        while(hoge!.isKind(of: TableViewCellCategoryList.self) == false) {
            hoge = hoge!.superview
        }
        let cell = hoge as! TableViewCellCategoryList
        // ここからデータベースを更新する
        print(cell.tag)
        changeSwitch(tag: cell.tag, isOn: sender.isOn) // 引数：連番、トグルスイッチ.有効無効
        //UIButtonを有効化
        sender.isEnabled = true
//        tableView.reloadData() // 不要　注意：ここでリロードすると、トグルスイッチが深緑色となり元の緑色に戻らなくなる
    }
    // トグルスイッチの切り替え　データベースを更新
    func changeSwitch(tag: Int, isOn: Bool) {
        // 勘定科目のスイッチを設定する 末端科目が一つも存在しない表示科目はスイッチOFFとなり、表示科目をOFFにできない。2020/09/12
        let databaseManagerSettingsCategory = DatabaseManagerSettingsTaxonomyAccount() //データベースマネジャー
        databaseManagerSettingsCategory.updateSettingsCategorySwitching(tag: tag, isOn: isOn)
        // 表示科目のスイッチを設定する　勘定科目がひとつもなければOFFにする
        let dataBaseSettingsCategoryBSAndPL = DataBaseManagerSettingsTaxonomy() //データベースマネジャー
        dataBaseSettingsCategoryBSAndPL.updateSettingsCategoryBSAndPLSwitching(number: tag)
    }
    // 画面遷移の準備　勘定科目画面
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // 選択されたセルを取得
        let indexPath: IndexPath = self.tableView.indexPathForSelectedRow! // ※ didSelectRowAtの代わりにこれを使う方がいい　タップされたセルの位置を取得
        // 表示科目
        let dataBaseManagerSettingsCategoryBSAndPL = DataBaseManagerSettingsTaxonomy()
//        let objects = dataBaseManagerSettingsCategoryBSAndPL.getAllSettingsCategoryBSAndPLSwitichON() // どのセクションに表示するセルかを判別するため引数で渡す
        var sheet = 0
        if segmentedControl_switch.selectedSegmentIndex == 0 {
            sheet = 0 // BS
        }else if segmentedControl_switch.selectedSegmentIndex == 1 {
            sheet = 1 // PL
        }else if segmentedControl_switch.selectedSegmentIndex == 2 {
            sheet = 4 // CF
        }
        let objectssss = dataBaseManagerSettingsCategoryBSAndPL.getBigCategoryAll(section: sheet)
        // 勘定科目
        let databaseManagerSettings = DatabaseManagerSettingsTaxonomyAccount()
//        let objects = databaseManagerSettings.getSettingsTaxonomyAccountInTaxonomy(numberOfTaxonomy: String(objectssss[indexPath.row].number))
        let objects = databaseManagerSettings.getSettingsTaxonomyAccountInTaxonomy(numberOfTaxonomy: String(objectssss[indexPath.section].number))
        // segue.destinationの型はUIViewController
        let tableViewControllerSettingsCategoryDetail = segue.destination as! TableViewControllerSettingsCategoryDetail
        // 遷移先のコントローラに値を渡す
        tableViewControllerSettingsCategoryDetail.numberOfAccount = objects[indexPath.row].number // セルに表示した勘定科目を取得
        // セルの選択を解除
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
