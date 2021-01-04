//
//  TableViewControllerBS.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/06/10.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import UIKit
import GoogleMobileAds // マネタイズ対応
import AudioToolbox // 効果音

// 貸借対照表クラス
class TableViewControllerBS: UITableViewController, UIPrintInteractionControllerDelegate {

    // マネタイズ対応
    // 広告ユニットID
    let AdMobID = "ca-app-pub-7616440336243237/8565070944"
    // テスト用広告ユニットID
    let TEST_ID = "ca-app-pub-3940256099942544/2934735716"
    // true:テスト
    let AdMobTest:Bool = true
    @IBOutlet var gADBannerView: GADBannerView!

    @IBOutlet weak var label_company_name: UILabel!
    @IBOutlet weak var label_title: UILabel!
    @IBOutlet weak var label_closingDate: UILabel!
    @IBOutlet var label_closingDate_previous: UILabel!
    @IBOutlet var label_closingDate_thisYear: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: Selector(("refreshTable")), for: UIControl.Event.valueChanged)
        self.refreshControl = refreshControl
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // 月末、年度末などの決算日をラベルに表示する
        let dataBaseManagerAccountingBooksShelf = DataBaseManagerAccountingBooksShelf()
        let company = dataBaseManagerAccountingBooksShelf.getCompanyName()
        label_company_name.text = company // 社名
        let dataBaseManagerPeriod = DataBaseManagerSettingsPeriod()
        let fiscalYear = dataBaseManagerPeriod.getSettingsPeriodYear()
        let dataBaseManager = DataBaseManagerSettingsPeriod()
        let object = dataBaseManager.getTheDayOfReckoning()
        if object == "12/31" { // 会計期間が年をまたがない場合
            label_closingDate.text = String(fiscalYear) + "年\(object.prefix(2))月\(object.suffix(2))日" // 決算日を表示する
            label_closingDate_previous.text = "前年度\n(" + String(fiscalYear-1) + "年\(object.prefix(2))月\(object.suffix(2))日)" // 前年度　決算日を表示する
            label_closingDate_thisYear.text = "今年度\n(" + String(fiscalYear) + "年\(object.prefix(2))月\(object.suffix(2))日)" // 今年度　決算日を表示する
        }else {
            label_closingDate.text = String(fiscalYear+1) + "年\(object.prefix(2))月\(object.suffix(2))日" // 決算日を表示する
            label_closingDate_previous.text = "前年度\n(" + String(fiscalYear) + "年\(object.prefix(2))月\(object.suffix(2))日)" // 前年度　決算日を表示する
            label_closingDate_thisYear.text = "今年度\n(" + String(fiscalYear+1) + "年\(object.prefix(2))月\(object.suffix(2))日)" // 今年度　決算日を表示する
        }
        label_title.text = "貸借対照表"
        // 貸借対照表　計算
        dataBaseManagerBS.initializeBS()
        // テーブルをスクロールさせる。scrollViewDidScrollメソッドを呼び出して、インセットの設定を行うため。
        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 2), at: UITableView.ScrollPosition.bottom, animated: false)
        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableView.ScrollPosition.bottom, animated: false)
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
        print(tableView.rowHeight)
        // GADBannerView を作成する
        addBannerViewToView(gADBannerView, constant: tableView!.rowHeight * -1)
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
    
    @objc func refreshTable() {
        // 全勘定の合計と残高を計算する
//        let databaseManager = DataBaseManagerTB()
//        databaseManager.setAllAccountTotal()
//        databaseManager.calculateAmountOfAllAccount() // 合計額を計算
        // 貸借対照表　初期化　再計算
        dataBaseManagerBS.initializeBS()
        //精算表　借方合計と貸方合計の計算 (修正記入、損益計算書、貸借対照表)
//        let databaseManagerWS = DataBaseManagerWS()
//        databaseManagerWS.calculateAmountOfAllAccount()
//        databaseManagerWS.calculateAmountOfAllAccountForBS()
//        databaseManagerWS.calculateAmountOfAllAccountForPL()
        // 更新処理
        self.tableView.reloadData()
        // クルクルを止める
        refreshControl?.endRefreshing()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // 資産の部、負債の部、純資産の部
        return 3
    }
    // セクションヘッダーの高さを決める
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30 //セクションヘッダーの高さを設定　セルの高さより高くしてメリハリをつける セル(Row Hight 30)
    }
    // セクションヘッダーの色とか調整する
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        // ダークモード対応
        if (UITraitCollection.current.userInterfaceStyle == .dark) {
            /* ダークモード時の処理 */
            header.textLabel?.textColor = .white
        } else {
            /* ライトモード時の処理 */
            header.textLabel?.textColor = .black
        }
        header.textLabel?.textAlignment = .left
        // システムフォントのサイズを設定
        header.textLabel?.font = UIFont.systemFont(ofSize: 17)
    }
    // セクションヘッダーのテキスト決める
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "資産の部"
        case 1:
            return "負債の部"
        case 2:
            return "純資産の部"
        default:
            return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // データベース DataBaseManagerBSAndPL → DataBaseManagerSettingsTaxonomy 2020/07/22
        let dataBaseManagerSettingsTaxonomy = DataBaseManagerSettingsTaxonomy()
        switch section {
            // 大分類のタイトルはセクションヘッダーに表示する
        case 0://資産の部
            // 階層3　中区分ごとの数を取得
            let objects0100 = dataBaseManagerSettingsTaxonomy.getMiddleCategory(category0: "0",category1: "1",category2: "0",category3: "0") // 流動資産
            let objects0102 = dataBaseManagerSettingsTaxonomy.getMiddleCategory(category0: "0",category1: "1",category2: "0",category3: "2") // 繰延資産
            // 固定資産
            let objects3 = dataBaseManagerSettingsTaxonomy.getSmallCategory(category0: "0",category1: "1",category2: "0",category3: "1",category4: "42") // 有形固定資産3
            let objects4 = dataBaseManagerSettingsTaxonomy.getSmallCategory(category0: "0",category1: "1",category2: "0",category3: "1",category4: "43") // 無形固定資産4
            let objects5 = dataBaseManagerSettingsTaxonomy.getSmallCategory(category0: "0",category1: "1",category2: "0",category3: "1",category4: "44") // 投資その他の資産5
            print("資産の部", 1+6+3+objects0100.count+objects0102.count+objects3.count+objects4.count+objects5.count)
//            objects0100.count + 1 + 1 + objects3.count  + 1 + objects4.count  + 1 + objects5.count  + 1 + 1 + 1 + objects0102.count + 1
            return 1+6+3+objects0100.count+objects0102.count+objects3.count+objects4.count+objects5.count // 大分類合計1・中分類(タイトル、合計)6・小分類(タイトル、合計)6・表示科目の数
        case 1://負債の部
            let objects0114 = dataBaseManagerSettingsTaxonomy.getMiddleCategory(category0: "0",category1: "1",category2: "1",category3: "4") // 流動負債
            let objectsCounts3 = dataBaseManagerSettingsTaxonomy.getMiddleCategory(category0: "0",category1: "1",category2: "1",category3: "5") // 固定負債
            print("負債の部", 1+4+objects0114.count+objectsCounts3.count)
            return 1+4+objects0114.count+objectsCounts3.count
        case 2://純資産の部
            let objects14 = dataBaseManagerSettingsTaxonomy.getMiddleCategory(category0: "0",category1: "1",category2: "2",category3: "9") //株主資本14
            let objects15 = dataBaseManagerSettingsTaxonomy.getMiddleCategory(category0: "0",category1: "1",category2: "2",category3: "10") //評価・換算差額等15
//            0    1    2    11                    新株予約権
//            0    1    2    12                    自己新株予約権
//            0    1    2    13                    非支配株主持分
//            0    1    2    14                    少数株主持分
            let objects16 = dataBaseManagerSettingsTaxonomy.getMiddleCategory(category0: "0",category1: "1",category2: "2",category3: "11")//新株予約権16
            let objects22 = dataBaseManagerSettingsTaxonomy.getMiddleCategory(category0: "0",category1: "1",category2: "2",category3: "13")//非支配株主持分22
            print("純資産の部", 1+4+0+objects14.count+objects15.count+objects16.count+objects22.count+1)
            return 1+4+0+objects14.count+objects15.count+objects16.count+objects22.count+1 //+1は、負債純資産合計　の分
        default:
            return 0
        }
    }

    let dataBaseManagerBS = DataBaseManagerBS()
    let dataBaseManagerTaxonomy = DataBaseManagerTaxonomy()
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // データベース
        let dataBaseManagerSettingsTaxonomy = DataBaseManagerSettingsTaxonomy()
        // 開いている会計帳簿の年度を取得
        let dataBaseManagerPeriod = DataBaseManagerSettingsPeriod()

        switch indexPath.section {
//大区分
        case 0: // 資産の部
            // 階層3　中区分ごとの数を取得
            let objects0100 = dataBaseManagerSettingsTaxonomy.getMiddleCategory(category0: "0",category1: "1",category2: "0",category3: "0") // 流動資産
            let objects0102 = dataBaseManagerSettingsTaxonomy.getMiddleCategory(category0: "0",category1: "1",category2: "0",category3: "2") // 繰延資産
            // 階層4 小区分
            let objects3 = dataBaseManagerSettingsTaxonomy.getSmallCategory(category0: "0",category1: "1",category2: "0",category3: "1",category4: "42") // 有形固定資産3
            let objects4 = dataBaseManagerSettingsTaxonomy.getSmallCategory(category0: "0",category1: "1",category2: "0",category3: "1",category4: "43") // 無形固定資産4
            let objects5 = dataBaseManagerSettingsTaxonomy.getSmallCategory(category0: "0",category1: "1",category2: "0",category3: "1",category4: "44") // 投資その他の資産5
// 中区分
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "middleCategory", for: indexPath)
                cell.textLabel?.text = "  流動資産" // 注意：UITableViewCell内のViewに表示している。AttributesInspectorでHiddenをONにすると見えなくなる。
                print("BS", indexPath.row, "  流動資産"+"★")
                cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
                return cell
            case objects0100.count + 1: // 中区分タイトルの分を1行追加　流動資産に属する勘定科目の数
                let cell = tableView.dequeueReusableCell(withIdentifier: "totalOfMiddleCategory", for: indexPath) as! TableViewCellTotalOfMiddleCategory
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                cell.textLabel?.minimumScaleFactor = 0.05
                cell.textLabel?.adjustsFontSizeToFitWidth = true
                cell.textLabel?.text = "    流動資産合計"
                print("BS", indexPath.row, "    流動資産合計"+"★")
                let text:String = dataBaseManagerBS.getTotalRank0(big5: indexPath.section, rank0: 0, lastYear: false)
                // テキストをカスタマイズするために、NSMutableAttributedStringにする
                let attributeText = NSMutableAttributedString(string: text)
                // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
                attributeText.addAttribute(
                  NSAttributedString.Key.underlineStyle,
                  value: NSUnderlineStyle.single.rawValue,
                  range: NSMakeRange(0, text.count)
                )
                cell.label_totalOfMiddleCategory.attributedText = attributeText
                var textt:String = ""
                if dataBaseManagerPeriod.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                    textt = dataBaseManagerBS.getTotalRank0(big5: indexPath.section, rank0: 0, lastYear: true)
                }else {
                    textt = "-"
                }
                // テキストをカスタマイズするために、NSMutableAttributedStringにする
                let attributeTextt = NSMutableAttributedString(string: textt)
                // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
                attributeTextt.addAttribute(
                  NSAttributedString.Key.underlineStyle,
                  value: NSUnderlineStyle.single.rawValue,
                  range: NSMakeRange(0, textt.count)
                )
                cell.label_totalOfMiddleCategory_previous.attributedText = attributeTextt
                return cell
            case objects0100.count + 1 + 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "middleCategory", for: indexPath)
                cell.textLabel?.text = "  固定資産"
                print("BS", indexPath.row, "  固定資産"+"★")
                cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
                return cell
// 小区分
            // 有形固定資産3
            case objects0100.count + 1 + 1 + 1: // 112
                let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
                cell.textLabel?.text = "        "+translateSmallCategory(small_category: 3)
                print("BS", indexPath.row, "        "+translateSmallCategory(small_category: 3)+"★")
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                return cell
            // 無形固定資産
            case objects0100.count + 1 + 1 + 1 + objects3.count + 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
                cell.textLabel?.text = "        "+translateSmallCategory(small_category: 4)
                print("BS", indexPath.row, "        "+translateSmallCategory(small_category: 4)+"★")
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                return cell
            // 投資その他資産　投資その他の資産
            case objects0100.count + 1 + 1 + 1 + objects3.count + 1 + objects4.count + 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
                cell.textLabel?.text = "        "+translateSmallCategory(small_category: 5)
                print("BS", indexPath.row, "        "+translateSmallCategory(small_category: 5)+"★")
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                return cell
            case objects0100.count + 1 + 1 + objects3.count  + 1 + objects4.count  + 1 + objects5.count  + 1 + 1: //最後の行の前
                let cell = tableView.dequeueReusableCell(withIdentifier: "totalOfMiddleCategory", for: indexPath) as! TableViewCellTotalOfMiddleCategory
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                cell.textLabel?.minimumScaleFactor = 0.05
                cell.textLabel?.adjustsFontSizeToFitWidth = true
                cell.textLabel?.text = "    固定資産合計"
                print("BS", indexPath.row, "    固定資産合計"+"★")
                let text:String = dataBaseManagerBS.getTotalRank0(big5: indexPath.section, rank0: 1, lastYear: false)
                // テキストをカスタマイズするために、NSMutableAttributedStringにする
                let attributeText = NSMutableAttributedString(string: text)
                // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
                attributeText.addAttribute(
                  NSAttributedString.Key.underlineStyle,
                  value: NSUnderlineStyle.single.rawValue,
                  range: NSMakeRange(0, text.count)
                )
                cell.label_totalOfMiddleCategory.attributedText = attributeText
                var textt:String = ""
                if dataBaseManagerPeriod.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                    textt = dataBaseManagerBS.getTotalRank0(big5: indexPath.section, rank0: 1, lastYear: true)
                }else {
                    textt = "-"
                }
                // テキストをカスタマイズするために、NSMutableAttributedStringにする
                let attributeTextt = NSMutableAttributedString(string: textt)
                // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
                attributeTextt.addAttribute(
                  NSAttributedString.Key.underlineStyle,
                  value: NSUnderlineStyle.single.rawValue,
                  range: NSMakeRange(0, textt.count)
                )
                cell.label_totalOfMiddleCategory_previous.attributedText = attributeTextt
                return cell
            case objects0100.count + 1 + 1 + objects3.count  + 1 + objects4.count  + 1 + objects5.count  + 1 + 1 + 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "middleCategory", for: indexPath)
                cell.textLabel?.text = "  繰越資産"
                print("BS", indexPath.row, "  繰越資産"+"★")
                cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
                return cell
            case objects0100.count + 1 + 1 + objects3.count  + 1 + objects4.count  + 1 + objects5.count  + 1 + 1 + 1 + objects0102.count + 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "totalOfMiddleCategory", for: indexPath) as! TableViewCellTotalOfMiddleCategory
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                cell.textLabel?.minimumScaleFactor = 0.05
                cell.textLabel?.adjustsFontSizeToFitWidth = true
                cell.textLabel?.text = "    繰越資産合計"
                print("BS", indexPath.row, "    繰越資産合計"+"★")
                let text:String = dataBaseManagerBS.getTotalRank0(big5: indexPath.section, rank0: 2, lastYear: false)
                // テキストをカスタマイズするために、NSMutableAttributedStringにする
                let attributeText = NSMutableAttributedString(string: text)
                // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
                attributeText.addAttribute(
                  NSAttributedString.Key.underlineStyle,
                  value: NSUnderlineStyle.single.rawValue,
                  range: NSMakeRange(0, text.count)
                )
                cell.label_totalOfMiddleCategory.attributedText = attributeText
                var textt:String = ""
                if dataBaseManagerPeriod.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                    textt = dataBaseManagerBS.getTotalRank0(big5: indexPath.section, rank0: 2, lastYear: true)
                }else {
                    textt = "-"
                }
                // テキストをカスタマイズするために、NSMutableAttributedStringにする
                let attributeTextt = NSMutableAttributedString(string: textt)
                // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
                attributeTextt.addAttribute(
                  NSAttributedString.Key.underlineStyle,
                  value: NSUnderlineStyle.single.rawValue,
                  range: NSMakeRange(0, textt.count)
                )
                cell.label_totalOfMiddleCategory_previous.attributedText = attributeTextt
                return cell
            case objects0100.count + 1 + 1 + objects3.count  + 1 + objects4.count  + 1 + objects5.count  + 1 + 1 + 1 + objects0102.count + 1 + 1: //最後の行
                let cell = tableView.dequeueReusableCell(withIdentifier: "totalOfBigCategory", for: indexPath) as! TableViewCellTotalOfBigCategory
                cell.textLabel?.text = "資産合計"
                print("BS", indexPath.row, "資産合計"+"★")
                cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
                let text:String = dataBaseManagerBS.getTotalBig5(big5: 0, lastYear: false)
                // テキストをカスタマイズするために、NSMutableAttributedStringにする
                let attributeText = NSMutableAttributedString(string: text)
                // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
                attributeText.addAttribute(
                  NSAttributedString.Key.underlineStyle,
                  value: NSUnderlineStyle.single.rawValue,
                  range: NSMakeRange(0, text.count)
                )
                cell.label_totalOfBigCategory.attributedText = attributeText
                cell.label_totalOfBigCategory.font = UIFont.boldSystemFont(ofSize: 14)
                var textt:String = ""
                if dataBaseManagerPeriod.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                    textt = dataBaseManagerBS.getTotalBig5(big5: 0, lastYear: true)
                }else {
                    textt = "-"
                }
                // テキストをカスタマイズするために、NSMutableAttributedStringにする
                let attributeTextt = NSMutableAttributedString(string: textt)
                // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
                attributeTextt.addAttribute(
                  NSAttributedString.Key.underlineStyle,
                  value: NSUnderlineStyle.single.rawValue,
                  range: NSMakeRange(0, textt.count)
                )
                cell.label_totalOfBigCategory_previous.attributedText = attributeTextt
                cell.label_totalOfBigCategory_previous.font = UIFont.boldSystemFont(ofSize: 14)
                // 資産合計と純資産負債合計の金額が不一致の場合、文字色を赤
                if dataBaseManagerBS.getTotalBig5(big5: 0, lastYear: false) != dataBaseManagerBS.getTotalBig5(big5: 3, lastYear: false) {
                    cell.label_totalOfBigCategory.textColor = .red
                }else {
                    // ダークモード対応
                    if (UITraitCollection.current.userInterfaceStyle == .dark) {
                        /* ダークモード時の処理 */
                        cell.label_totalOfBigCategory.textColor = .white
                    } else {
                        /* ライトモード時の処理 */
                        cell.label_totalOfBigCategory.textColor = .black
                    }
                }
                return cell
            default:
// 勘定科目
                    let cell = tableView.dequeueReusableCell(withIdentifier: "account", for: indexPath) as! TableViewCellAccount
                    cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                    cell.textLabel?.minimumScaleFactor = 0.05
                    cell.textLabel?.adjustsFontSizeToFitWidth = true
                    if       indexPath.row >= 1 &&                           // 流動資産タイトルの1行下 中区分タイトルより下の行から、中区分合計の行より上
                             indexPath.row <  objects0100.count + 1 + 1 {   // 流動資産合計　　　　中区分タイトル + 流動資産 + 合計
                        cell.textLabel?.text = "        "+objects0100[indexPath.row-(1)].category
                        print("BS", indexPath.row, "        "+objects0100[indexPath.row-(1)].category)
                        cell.label_account.text = dataBaseManagerTaxonomy.getTotalOfTaxonomy(numberOfSettingsTaxonomy: objects0100[indexPath.row-(1 )].number, lastYear: false) // 勘定別の合計　計算
                        if dataBaseManagerPeriod.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                            cell.label_account_previous.text = dataBaseManagerTaxonomy.getTotalOfTaxonomy(numberOfSettingsTaxonomy: objects0100[indexPath.row-(1 )].number, lastYear: true) // 勘定別の合計　計算
                        }else {
                            cell.label_account_previous.text = "-"
                        }
                        cell.label_account.textAlignment = .right
                        
                    }else if indexPath.row >= objects0100.count + 1 + 1 + 1 + 1 &&  // 有形固定資産タイトルの1行下
                              indexPath.row <  objects0100.count + 1 + 1 + 1 + objects3.count + 1 { // 無形固定資産
                        cell.textLabel?.text = "        "+objects3[indexPath.row-(objects0100.count + 1 + 1 + 1 + 1)].category
                        print("BS", indexPath.row, "        "+objects3[indexPath.row-(objects0100.count + 1 + 1 + 1 + 1)].category)
                        cell.label_account.text = dataBaseManagerTaxonomy.getTotalOfTaxonomy(numberOfSettingsTaxonomy: objects3[indexPath.row-(objects0100.count + 1 + 1 + 1 + 1)].number, lastYear: false)
                        if dataBaseManagerPeriod.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                            cell.label_account_previous.text = dataBaseManagerTaxonomy.getTotalOfTaxonomy(numberOfSettingsTaxonomy: objects3[indexPath.row-(objects0100.count + 1 + 1 + 1 + 1)].number, lastYear: true)
                        }else {
                            cell.label_account_previous.text = "-"
                        }
                        cell.label_account.textAlignment = .right
                        
                    }else if indexPath.row >= objects0100.count + 1 + 1 + 1 + objects3.count + 1 + 1 && // 無形固定資産タイトルの1行下
                              indexPath.row <  objects0100.count + 1 + 1 + 1 + objects3.count + 1 + objects4.count + 1 { // 投資その他資産
                        cell.textLabel?.text = "        "+objects4[indexPath.row-(objects0100.count + 1 + 1 + 1 + objects3.count + 1 + 1)].category
                        print("BS", indexPath.row, "        "+objects4[indexPath.row-(objects0100.count + 1 + 1 + 1 + objects3.count + 1 + 1)].category)
                        cell.label_account.text = dataBaseManagerTaxonomy.getTotalOfTaxonomy(numberOfSettingsTaxonomy: objects4[indexPath.row-(objects0100.count + 1 + 1 + 1 + objects3.count + 1 + 1)].number, lastYear: false)
                        if dataBaseManagerPeriod.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                            cell.label_account_previous.text = dataBaseManagerTaxonomy.getTotalOfTaxonomy(numberOfSettingsTaxonomy: objects4[indexPath.row-(objects0100.count + 1 + 1 + 1 + objects3.count + 1 + 1)].number, lastYear: true)
                        }else {
                            cell.label_account_previous.text = "-"
                        }
                        cell.label_account.textAlignment = .right
                        
                    }else if indexPath.row >= objects0100.count + 1 + 1 + 1 + objects3.count + 1 + objects4.count + 1 + 1 && // 投資その他資産タイトルの1行下
                              indexPath.row <  objects0100.count + 1 + 1 + objects3.count  + 1 + objects4.count  + 1 + objects5.count  + 1 + 1 { // 固定資産合計
                        cell.textLabel?.text = "        "+objects5[indexPath.row-(objects0100.count + 1 + 1 + 1 + objects3.count + 1 + objects4.count + 1 + 1)].category
                        print("BS", indexPath.row, "        "+objects5[indexPath.row-(objects0100.count + 1 + 1 + 1 + objects3.count + 1 + objects4.count + 1 + 1)].category)
                        cell.label_account.text = dataBaseManagerTaxonomy.getTotalOfTaxonomy(numberOfSettingsTaxonomy: objects5[indexPath.row-(objects0100.count + 1 + 1 + 1 + objects3.count + 1 + objects4.count + 1 + 1)].number, lastYear: false)
                        if dataBaseManagerPeriod.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                            cell.label_account_previous.text = dataBaseManagerTaxonomy.getTotalOfTaxonomy(numberOfSettingsTaxonomy: objects5[indexPath.row-(objects0100.count + 1 + 1 + 1 + objects3.count + 1 + objects4.count + 1 + 1)].number, lastYear: true)
                        }else {
                            cell.label_account_previous.text = "-"
                        }
                        cell.label_account.textAlignment = .right
                    }else if indexPath.row >= objects0100.count + 1 + 1 + objects3.count  + 1 + objects4.count  + 1 + objects5.count  + 1 + 1 + 1 + 1 && // 繰延資産タイトルの1行下
                              indexPath.row < objects0100.count + 1 + 1 + objects3.count  + 1 + objects4.count  + 1 + objects5.count  + 1 + 1 + 1 + objects0102.count + 1 { // 繰延資産合計
                        cell.textLabel?.text = "        "+objects0102[indexPath.row-(objects0100.count + 1 + 1 + objects3.count  + 1 + objects4.count  + 1 + objects5.count  + 1 + 1 + 1 + 1)].category
                        print("BS", indexPath.row, "        "+objects0102[indexPath.row-(objects0100.count + 1 + 1 + objects3.count  + 1 + objects4.count  + 1 + objects5.count  + 1 + 1 + 1 + 1)].category)
                        cell.label_account.text = dataBaseManagerTaxonomy.getTotalOfTaxonomy(numberOfSettingsTaxonomy: objects0102[indexPath.row-(objects0100.count + 1 + 1 + objects3.count  + 1 + objects4.count  + 1 + objects5.count  + 1 + 1 + 1 + 1)].number, lastYear: false)
                        if dataBaseManagerPeriod.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                            cell.label_account_previous.text = dataBaseManagerTaxonomy.getTotalOfTaxonomy(numberOfSettingsTaxonomy: objects0102[indexPath.row-(objects0100.count + 1 + 1 + objects3.count  + 1 + objects4.count  + 1 + objects5.count  + 1 + 1 + 1 + 1)].number, lastYear: true)
                        }else {
                            cell.label_account_previous.text = "-"
                        }
                        cell.label_account.textAlignment = .right
                    }else {
                        cell.textLabel?.text = "default"
                        print("BS", indexPath.row, "default")
                        cell.label_account.text = "default"
                        cell.label_account.textAlignment = .right
                    }
                    return cell
            }
        case 1: // 負債の部
            // 中分類　中分類ごとの数を取得
            let objects0114 = dataBaseManagerSettingsTaxonomy.getMiddleCategory(category0: "0",category1: "1",category2: "1",category3: "4") // 流動負債
            let objectsCounts3 = dataBaseManagerSettingsTaxonomy.getMiddleCategory(category0: "0",category1: "1",category2: "1",category3: "5") // 固定負債
            
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "middleCategory", for: indexPath)
                cell.textLabel?.text = "  流動負債"
                print("BS", indexPath.row, "  流動負債"+"★")
                cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
                return cell
            case objects0114.count + 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "totalOfMiddleCategory", for: indexPath) as! TableViewCellTotalOfMiddleCategory
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                cell.textLabel?.minimumScaleFactor = 0.05
                cell.textLabel?.adjustsFontSizeToFitWidth = true
                cell.textLabel?.text = "    流動負債合計"
                print("BS", indexPath.row, "    流動負債合計"+"★")
                let text:String = dataBaseManagerBS.getTotalRank0(big5: indexPath.section, rank0: 3, lastYear: false)
                // テキストをカスタマイズするために、NSMutableAttributedStringにする
                let attributeText = NSMutableAttributedString(string: text)
                // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
                attributeText.addAttribute(
                  NSAttributedString.Key.underlineStyle,
                  value: NSUnderlineStyle.single.rawValue,
                  range: NSMakeRange(0, text.count)
                )
                cell.label_totalOfMiddleCategory.attributedText = attributeText
                var textt:String = ""
                if dataBaseManagerPeriod.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                    textt = dataBaseManagerBS.getTotalRank0(big5: indexPath.section, rank0: 3, lastYear: true)
                }else {
                    textt = "-"
                }
                // テキストをカスタマイズするために、NSMutableAttributedStringにする
                let attributeTextt = NSMutableAttributedString(string: textt)
                // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
                attributeTextt.addAttribute(
                  NSAttributedString.Key.underlineStyle,
                  value: NSUnderlineStyle.single.rawValue,
                  range: NSMakeRange(0, textt.count)
                )
                cell.label_totalOfMiddleCategory_previous.attributedText = attributeTextt
                return cell
            case objects0114.count + 1 + 1: // 中分類名の分を1行追加 合計の行を追加
                let cell = tableView.dequeueReusableCell(withIdentifier: "middleCategory", for: indexPath)
                cell.textLabel?.text = "  固定負債"
                print("BS", indexPath.row, "  固定負債"+"★")
                cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
                return cell
            case objects0114.count + 1 + 1 + objectsCounts3.count + 1: //最後の行の前 22
                let cell = tableView.dequeueReusableCell(withIdentifier: "totalOfMiddleCategory", for: indexPath) as! TableViewCellTotalOfMiddleCategory
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                cell.textLabel?.minimumScaleFactor = 0.05
                cell.textLabel?.adjustsFontSizeToFitWidth = true
                cell.textLabel?.text = "    固定負債合計"
                print("BS", indexPath.row, "    固定負債合計"+"★")
                let text:String = dataBaseManagerBS.getTotalRank0(big5: indexPath.section, rank0: 4, lastYear: false)
                // テキストをカスタマイズするために、NSMutableAttributedStringにする
                let attributeText = NSMutableAttributedString(string: text)
                // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
                attributeText.addAttribute(
                  NSAttributedString.Key.underlineStyle,
                  value: NSUnderlineStyle.single.rawValue,
                  range: NSMakeRange(0, text.count)
                )
                cell.label_totalOfMiddleCategory.attributedText = attributeText
                var textt:String = ""
                if dataBaseManagerPeriod.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                    textt = dataBaseManagerBS.getTotalRank0(big5: indexPath.section, rank0: 4, lastYear: true)
                }else {
                    textt = "-"
                }
                // テキストをカスタマイズするために、NSMutableAttributedStringにする
                let attributeTextt = NSMutableAttributedString(string: textt)
                // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
                attributeTextt.addAttribute(
                  NSAttributedString.Key.underlineStyle,
                  value: NSUnderlineStyle.single.rawValue,
                  range: NSMakeRange(0, textt.count)
                )
                cell.label_totalOfMiddleCategory_previous.attributedText = attributeTextt
                return cell
            case objects0114.count + 1 + 1 + objectsCounts3.count + 1 + 1: //最後の行
                let cell = tableView.dequeueReusableCell(withIdentifier: "totalOfBigCategory", for: indexPath) as! TableViewCellTotalOfBigCategory
                cell.textLabel?.text = "負債合計"
                print("BS", indexPath.row, "負債合計"+"★")
                cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
                let text:String = dataBaseManagerBS.getTotalBig5(big5: 1, lastYear: false)
                // テキストをカスタマイズするために、NSMutableAttributedStringにする
                let attributeText = NSMutableAttributedString(string: text)
                // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
                attributeText.addAttribute(
                  NSAttributedString.Key.underlineStyle,
                  value: NSUnderlineStyle.single.rawValue,
                  range: NSMakeRange(0, text.count)
                )
                cell.label_totalOfBigCategory.attributedText = attributeText
                cell.label_totalOfBigCategory.font = UIFont.boldSystemFont(ofSize: 14)
                var textt:String = ""
                if dataBaseManagerPeriod.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                    textt = dataBaseManagerBS.getTotalBig5(big5: 1, lastYear: true)
                }else {
                    textt = "-"
                }
                // テキストをカスタマイズするために、NSMutableAttributedStringにする
                let attributeTextt = NSMutableAttributedString(string: textt)
                // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
                attributeTextt.addAttribute(
                  NSAttributedString.Key.underlineStyle,
                  value: NSUnderlineStyle.single.rawValue,
                  range: NSMakeRange(0, textt.count)
                )
                cell.label_totalOfBigCategory_previous.attributedText = attributeTextt
                cell.label_totalOfBigCategory_previous.font = UIFont.boldSystemFont(ofSize: 14)
                // ダークモード対応
                if (UITraitCollection.current.userInterfaceStyle == .dark) {
                    /* ダークモード時の処理 */
                    cell.label_totalOfBigCategory.textColor = .white
                } else {
                    /* ライトモード時の処理 */
                    // 文字色
                    cell.label_totalOfBigCategory.textColor = .black
                }
                return cell
            default:
                    // 勘定科目
                    let cell = tableView.dequeueReusableCell(withIdentifier: "account", for: indexPath) as! TableViewCellAccount
                    cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                    cell.textLabel?.minimumScaleFactor = 0.05
                    cell.textLabel?.adjustsFontSizeToFitWidth = true
                    if       indexPath.row >= 1 &&                     // 流動負債タイトルの1行下
                             indexPath.row <  objects0114.count + 1 {  // 流動負債合計 中区分のタイトルより下の行から、中区分合計の行より上
                        cell.textLabel?.text = "        "+objects0114[indexPath.row-(1)].category
                        print("BS", indexPath.row, "        "+objects0114[indexPath.row-(1)].category)
                        cell.label_account.text = dataBaseManagerTaxonomy.getTotalOfTaxonomy(numberOfSettingsTaxonomy: objects0114[indexPath.row-(1)].number, lastYear: false)
                        if dataBaseManagerPeriod.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                            cell.label_account_previous.text = dataBaseManagerTaxonomy.getTotalOfTaxonomy(numberOfSettingsTaxonomy: objects0114[indexPath.row-(1)].number, lastYear: true)
                        }else {
                            cell.label_account_previous.text = "-"
                        }
                        cell.label_account.textAlignment = .right
                    }else if indexPath.row >= objects0114.count + 1 + 1 + 1 && // 固定負債タイトルの1行下
                              indexPath.row <  objects0114.count + 1 + 1 + objectsCounts3.count + 1 { // 固定負債合計
                        cell.textLabel?.text = "        "+objectsCounts3[indexPath.row-(objects0114.count + 1 + 1 + 1)].category
                        cell.label_account.text = dataBaseManagerTaxonomy.getTotalOfTaxonomy(numberOfSettingsTaxonomy: objectsCounts3[indexPath.row-(objects0114.count + 1 + 1 + 1)].number, lastYear: false)
                        if dataBaseManagerPeriod.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                            cell.label_account_previous.text = dataBaseManagerTaxonomy.getTotalOfTaxonomy(numberOfSettingsTaxonomy: objectsCounts3[indexPath.row-(objects0114.count + 1 + 1 + 1)].number, lastYear: true)
                        }else {
                            cell.label_account_previous.text = "-"
                        }
                        cell.label_account.textAlignment = .right
                    }else {
                        cell.textLabel?.text = "default"
                        print("BS", indexPath.row, "default")
                        cell.label_account.text = "default"
                        cell.label_account.textAlignment = .right
                    }
                    return cell
            }
        case 2: // 純資産の部
            // 中区分　中区分ごとの数を取得
            let objects14 = dataBaseManagerSettingsTaxonomy.getMiddleCategory(category0: "0",category1: "1",category2: "2",category3: "9" ) //株主資本14
            let objects15 = dataBaseManagerSettingsTaxonomy.getMiddleCategory(category0: "0",category1: "1",category2: "2",category3: "10") //評価・換算差額等15
            let objects16 = dataBaseManagerSettingsTaxonomy.getMiddleCategory(category0: "0",category1: "1",category2: "2",category3: "11") //新株予約権16
            //            0    1    2    12                    自己新株予約権
            let objects22 = dataBaseManagerSettingsTaxonomy.getMiddleCategory(category0: "0",category1: "1",category2: "2",category3: "13") //非支配株主持分22
            //            0    1    2    14                    少数株主持分
// 中区分
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "middleCategory", for: indexPath)
                cell.textLabel?.text = "  株主資本"
                print("BS", indexPath.row, "  株主資本"+"★")
                //                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
                return cell
            case objects14.count + 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "totalOfMiddleCategory", for: indexPath) as! TableViewCellTotalOfMiddleCategory
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                cell.textLabel?.minimumScaleFactor = 0.05
                cell.textLabel?.adjustsFontSizeToFitWidth = true
                cell.textLabel?.text = "    株主資本合計"
                print("BS", indexPath.row, "    株主資本合計"+"★")
                let text:String = dataBaseManagerBS.getTotalRank1(big5: indexPath.section, rank1: 10, lastYear: false) // 中区分の合計を取得
                // テキストをカスタマイズするために、NSMutableAttributedStringにする
                let attributeText = NSMutableAttributedString(string: text)
                // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
                attributeText.addAttribute(
                  NSAttributedString.Key.underlineStyle,
                  value: NSUnderlineStyle.single.rawValue,
                  range: NSMakeRange(0, text.count)
                )
                cell.label_totalOfMiddleCategory.attributedText = attributeText
                var textt:String = ""
                if dataBaseManagerPeriod.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                    textt = dataBaseManagerBS.getTotalRank1(big5: indexPath.section, rank1: 10, lastYear: true) // 中区分の合計を取得
                }else {
                    textt = "-"
                }
                // テキストをカスタマイズするために、NSMutableAttributedStringにする
                let attributeTextt = NSMutableAttributedString(string: textt)
                // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
                attributeTextt.addAttribute(
                  NSAttributedString.Key.underlineStyle,
                  value: NSUnderlineStyle.single.rawValue,
                  range: NSMakeRange(0, textt.count)
                )
                cell.label_totalOfMiddleCategory_previous.attributedText = attributeTextt
                return cell
            case objects14.count + 2: // 中分類名の分を1行追加 合計の行を追加
                let cell = tableView.dequeueReusableCell(withIdentifier: "middleCategory", for: indexPath)
                cell.textLabel?.text = "  その他の包括利益累計額"
                print("BS", indexPath.row, "  その他の包括利益累計額"+"★")
                cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
                return cell
            case objects14.count + 2 + objects15.count + 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "totalOfMiddleCategory", for: indexPath) as! TableViewCellTotalOfMiddleCategory
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                cell.textLabel?.minimumScaleFactor = 0.05
                cell.textLabel?.adjustsFontSizeToFitWidth = true
                cell.textLabel?.text = "    その他の包括利益累計額合計"
                print("BS", indexPath.row, "    その他の包括利益累計額合計"+"★")
                let text:String = dataBaseManagerBS.getTotalRank1(big5: indexPath.section, rank1: 11, lastYear: false) // 中区分の合計を取得
                // テキストをカスタマイズするために、NSMutableAttributedStringにする
                let attributeText = NSMutableAttributedString(string: text)
                // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
                attributeText.addAttribute(
                  NSAttributedString.Key.underlineStyle,
                  value: NSUnderlineStyle.single.rawValue,
                  range: NSMakeRange(0, text.count)
                )
                cell.label_totalOfMiddleCategory.attributedText = attributeText
                var textt:String = ""
                if dataBaseManagerPeriod.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                    textt = dataBaseManagerBS.getTotalRank1(big5: indexPath.section, rank1: 11, lastYear: true) // 中区分の合計を取得
                }else {
                    textt = "-"
                }
                // テキストをカスタマイズするために、NSMutableAttributedStringにする
                let attributeTextt = NSMutableAttributedString(string: textt)
                // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
                attributeTextt.addAttribute(
                  NSAttributedString.Key.underlineStyle,
                  value: NSUnderlineStyle.single.rawValue,
                  range: NSMakeRange(0, textt.count)
                )
                cell.label_totalOfMiddleCategory_previous.attributedText = attributeTextt
                return cell
            case objects14.count + 2 + objects15.count + 1 + 1: //新株予約権16
                let cell = tableView.dequeueReusableCell(withIdentifier: "totalOfMiddleCategory", for: indexPath) as! TableViewCellTotalOfMiddleCategory
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                cell.textLabel?.minimumScaleFactor = 0.05
                cell.textLabel?.adjustsFontSizeToFitWidth = true
                // セルに表示する内容がデータベースに0件しかない場合、エラー回避する　2020/10/19
                guard 0 < objects16.count else { //新株予約権16 が0件の場合
                    let cell = tableView.dequeueReusableCell(withIdentifier: "totalOfMiddleCategory", for: indexPath) as! TableViewCellTotalOfMiddleCategory
                    cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                    cell.textLabel?.minimumScaleFactor = 0.05
                    cell.textLabel?.adjustsFontSizeToFitWidth = true
                    
                    // セルに表示する内容がデータベースに0件しかない場合、エラー回避する　2020/08/03
                    guard 0 < objects22.count else { //非支配株主持分22 が0件の場合
                        let cell = tableView.dequeueReusableCell(withIdentifier: "totalOfBigCategory", for: indexPath) as! TableViewCellTotalOfBigCategory
                        cell.textLabel?.text = "純資産合計"
                        print("BS", indexPath.row, "純資産合計"+"★")
                        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
                        let text:String = dataBaseManagerBS.getTotalBig5(big5: 2, lastYear: false)
                        // テキストをカスタマイズするために、NSMutableAttributedStringにする
                        let attributeText = NSMutableAttributedString(string: text)
                        // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
                        attributeText.addAttribute(
                          NSAttributedString.Key.underlineStyle,
                          value: NSUnderlineStyle.single.rawValue,
                          range: NSMakeRange(0, text.count)
                        )
                        cell.label_totalOfBigCategory.attributedText = attributeText
                        cell.label_totalOfBigCategory.font = UIFont.boldSystemFont(ofSize: 14)
                        var textt:String = ""
                        if dataBaseManagerPeriod.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                            textt = dataBaseManagerBS.getTotalBig5(big5: 2, lastYear: true)
                        }else {
                            textt = "-"
                        }
                        // テキストをカスタマイズするために、NSMutableAttributedStringにする
                        let attributeTextt = NSMutableAttributedString(string: textt)
                        // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
                        attributeTextt.addAttribute(
                          NSAttributedString.Key.underlineStyle,
                          value: NSUnderlineStyle.single.rawValue,
                          range: NSMakeRange(0, textt.count)
                        )
                        cell.label_totalOfBigCategory_previous.attributedText = attributeTextt
                        cell.label_totalOfBigCategory_previous.font = UIFont.boldSystemFont(ofSize: 14)
                        // ダークモード対応
                        if (UITraitCollection.current.userInterfaceStyle == .dark) {
                            /* ダークモード時の処理 */
                            // 文字色
                            cell.label_totalOfBigCategory.textColor = .white
                        } else {
                            /* ライトモード時の処理 */
                            // 文字色
                            cell.label_totalOfBigCategory.textColor = .black
                        }
                        return cell
                    } // 1. array.count（要素数）を利用する
                    
                    cell.textLabel?.text = "  "+objects22[indexPath.row-(objects14.count + 2 + objects15.count + 1 + 1 + objects16.count)].category
                    print("BS", indexPath.row, "  "+objects22[indexPath.row-(objects14.count + 2 + objects15.count + 1 + 1 + objects16.count)].category)
                    let text:String = dataBaseManagerTaxonomy.getTotalOfTaxonomy(numberOfSettingsTaxonomy: objects22[indexPath.row-(objects14.count + 2 + objects15.count + 1 + 1 + objects16.count)].number, lastYear: false)
                    // テキストをカスタマイズするために、NSMutableAttributedStringにする
                    let attributeText = NSMutableAttributedString(string: text)
                    // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
                    attributeText.addAttribute(
                      NSAttributedString.Key.underlineStyle,
                      value: NSUnderlineStyle.single.rawValue,
                      range: NSMakeRange(0, text.count)
                    )
                    cell.label_totalOfMiddleCategory.attributedText = attributeText
                    var textt:String = ""
                    if dataBaseManagerPeriod.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                        textt = dataBaseManagerTaxonomy.getTotalOfTaxonomy(numberOfSettingsTaxonomy: objects22[indexPath.row-(objects14.count + 2 + objects15.count + 1 + 1 + objects16.count)].number, lastYear: true)
                    }else {
                        textt = "-"
                    }
                    // テキストをカスタマイズするために、NSMutableAttributedStringにする
                    let attributeTextt = NSMutableAttributedString(string: textt)
                    // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
                    attributeTextt.addAttribute(
                      NSAttributedString.Key.underlineStyle,
                      value: NSUnderlineStyle.single.rawValue,
                      range: NSMakeRange(0, textt.count)
                    )
                    cell.label_totalOfMiddleCategory_previous.attributedText = attributeTextt
                    return cell
                }
                cell.textLabel?.text = "  "+objects16[indexPath.row-(objects14.count + 2 + objects15.count + 1 + 1)].category
                print("BS", indexPath.row, "  "+objects16[indexPath.row-(objects14.count + 2 + objects15.count + 1 + 1)].category)
                let text:String = dataBaseManagerTaxonomy.getTotalOfTaxonomy(numberOfSettingsTaxonomy: objects16[indexPath.row-(objects14.count + 2 + objects15.count + 1 + 1)].number, lastYear: false)
                // テキストをカスタマイズするために、NSMutableAttributedStringにする
                let attributeText = NSMutableAttributedString(string: text)
                // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
                attributeText.addAttribute(
                    NSAttributedString.Key.underlineStyle,
                    value: NSUnderlineStyle.single.rawValue,
                    range: NSMakeRange(0, text.count)
                )
                cell.label_totalOfMiddleCategory.attributedText = attributeText
                var textt:String = ""
                if dataBaseManagerPeriod.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                    textt = dataBaseManagerTaxonomy.getTotalOfTaxonomy(numberOfSettingsTaxonomy: objects16[indexPath.row-(objects14.count + 2 + objects15.count + 1 + 1)].number, lastYear: true)
                }else {
                    textt = "-"
                }
                // テキストをカスタマイズするために、NSMutableAttributedStringにする
                let attributeTextt = NSMutableAttributedString(string: textt)
                // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
                attributeTextt.addAttribute(
                    NSAttributedString.Key.underlineStyle,
                    value: NSUnderlineStyle.single.rawValue,
                    range: NSMakeRange(0, textt.count)
                )
                cell.label_totalOfMiddleCategory_previous.attributedText = attributeTextt
                return cell
            case objects14.count + 2 + objects15.count + 1 + 1 + objects16.count: //非支配株主持分22
                let cell = tableView.dequeueReusableCell(withIdentifier: "totalOfMiddleCategory", for: indexPath) as! TableViewCellTotalOfMiddleCategory
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                cell.textLabel?.minimumScaleFactor = 0.05
                cell.textLabel?.adjustsFontSizeToFitWidth = true
                // セルに表示する内容がデータベースに0件しかない場合、エラー回避する　2020/10/19
                guard 0 < objects22.count else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "totalOfBigCategory", for: indexPath) as! TableViewCellTotalOfBigCategory
                    cell.textLabel?.text = "純資産合計"
                    print("BS", indexPath.row, "純資産合計"+"★")
                    cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
                    let text:String = dataBaseManagerBS.getTotalBig5(big5: 2, lastYear: false)
                    // テキストをカスタマイズするために、NSMutableAttributedStringにする
                    let attributeText = NSMutableAttributedString(string: text)
                    // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
                    attributeText.addAttribute(
                      NSAttributedString.Key.underlineStyle,
                      value: NSUnderlineStyle.single.rawValue,
                      range: NSMakeRange(0, text.count)
                    )
                    cell.label_totalOfBigCategory.attributedText = attributeText
                    cell.label_totalOfBigCategory.font = UIFont.boldSystemFont(ofSize: 14)
                    var textt:String = ""
                    if dataBaseManagerPeriod.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                        textt = dataBaseManagerBS.getTotalBig5(big5: 2, lastYear: true)
                    }else {
                        textt = "-"
                    }
                    // テキストをカスタマイズするために、NSMutableAttributedStringにする
                    let attributeTextt = NSMutableAttributedString(string: textt)
                    // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
                    attributeTextt.addAttribute(
                      NSAttributedString.Key.underlineStyle,
                      value: NSUnderlineStyle.single.rawValue,
                      range: NSMakeRange(0, textt.count)
                    )
                    cell.label_totalOfBigCategory_previous.attributedText = attributeTextt
                    cell.label_totalOfBigCategory_previous.font = UIFont.boldSystemFont(ofSize: 14)
                    // ダークモード対応
                    if (UITraitCollection.current.userInterfaceStyle == .dark) {
                        /* ダークモード時の処理 */
                        cell.label_totalOfBigCategory.textColor = .white
                    } else {
                        /* ライトモード時の処理 */
                        // 文字色
                        cell.label_totalOfBigCategory.textColor = .black
                    }
                    return cell
                } // 1. array.count（要素数）を利用する
                cell.textLabel?.text = "  "+objects22[indexPath.row-(objects14.count + 2 + objects15.count + 1 + 1 + objects16.count)].category
                print("BS", indexPath.row, "  "+objects22[indexPath.row-(objects14.count + 2 + objects15.count + 1 + 1 + objects16.count)].category)
                let text:String = dataBaseManagerTaxonomy.getTotalOfTaxonomy(numberOfSettingsTaxonomy: objects22[indexPath.row-(objects14.count + 2 + objects15.count + 1 + 1 + objects16.count)].number, lastYear: false)
                // テキストをカスタマイズするために、NSMutableAttributedStringにする
                let attributeText = NSMutableAttributedString(string: text)
                // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
                attributeText.addAttribute(
                  NSAttributedString.Key.underlineStyle,
                  value: NSUnderlineStyle.single.rawValue,
                  range: NSMakeRange(0, text.count)
                )
                cell.label_totalOfMiddleCategory.attributedText = attributeText
                var textt:String = ""
                if dataBaseManagerPeriod.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                    textt = dataBaseManagerTaxonomy.getTotalOfTaxonomy(numberOfSettingsTaxonomy: objects22[indexPath.row-(objects14.count + 2 + objects15.count + 1 + 1 + objects16.count)].number, lastYear: true)
                }else {
                    textt = "-"
                }
                // テキストをカスタマイズするために、NSMutableAttributedStringにする
                let attributeTextt = NSMutableAttributedString(string: textt)
                // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
                attributeTextt.addAttribute(
                  NSAttributedString.Key.underlineStyle,
                  value: NSUnderlineStyle.single.rawValue,
                  range: NSMakeRange(0, textt.count)
                )
                cell.label_totalOfMiddleCategory_previous.attributedText = attributeTextt
                return cell
            case objects14.count + 2 + objects15.count + 1 + 1 + objects16.count + objects22.count: //最後の行
                let cell = tableView.dequeueReusableCell(withIdentifier: "totalOfBigCategory", for: indexPath) as! TableViewCellTotalOfBigCategory
                cell.textLabel?.text = "純資産合計"
                print("BS", indexPath.row, "純資産合計"+"★")
                cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
                let text:String = dataBaseManagerBS.getTotalBig5(big5: 2, lastYear: false)
                // テキストをカスタマイズするために、NSMutableAttributedStringにする
                let attributeText = NSMutableAttributedString(string: text)
                // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
                attributeText.addAttribute(
                  NSAttributedString.Key.underlineStyle,
                  value: NSUnderlineStyle.single.rawValue,
                  range: NSMakeRange(0, text.count)
                )
                cell.label_totalOfBigCategory.attributedText = attributeText
                cell.label_totalOfBigCategory.font = UIFont.boldSystemFont(ofSize: 14)
                var textt:String = ""
                if dataBaseManagerPeriod.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                    textt = dataBaseManagerBS.getTotalBig5(big5: 2, lastYear: true)
                }else {
                    textt = "-"
                }
                // テキストをカスタマイズするために、NSMutableAttributedStringにする
                let attributeTextt = NSMutableAttributedString(string: textt)
                // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
                attributeTextt.addAttribute(
                  NSAttributedString.Key.underlineStyle,
                  value: NSUnderlineStyle.single.rawValue,
                  range: NSMakeRange(0, textt.count)
                )
                cell.label_totalOfBigCategory_previous.attributedText = attributeTextt
                cell.label_totalOfBigCategory_previous.font = UIFont.boldSystemFont(ofSize: 14)
                // ダークモード対応
                if (UITraitCollection.current.userInterfaceStyle == .dark) {
                    /* ダークモード時の処理 */
                    cell.label_totalOfBigCategory.textColor = .white
                } else {
                    /* ライトモード時の処理 */
                    // 文字色
                    cell.label_totalOfBigCategory.textColor = .black
                }
                return cell
            case objects14.count + 2 + objects15.count + 1 + 1 + objects16.count + objects22.count + 1: //最後の行の下
                let cell = tableView.dequeueReusableCell(withIdentifier: "totalOfBigCategory", for: indexPath) as! TableViewCellTotalOfBigCategory
                cell.textLabel?.text = "負債純資産合計"
                print("BS", indexPath.row, "負債純資産合計"+"★")
                cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
//                print(dataBaseManagerBS.getBigCategoryTotal(big_category: 1) )
//                print(dataBaseManagerBS.getBigCategoryTotal(big_category: 2) )
                let text:String = dataBaseManagerBS.getTotalBig5(big5: 3, lastYear: false)
                // テキストをカスタマイズするために、NSMutableAttributedStringにする
                let attributeText = NSMutableAttributedString(string: text)
                // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
                attributeText.addAttribute(
                    NSAttributedString.Key.underlineStyle,
                    value: NSUnderlineStyle.single.rawValue,
                    range: NSMakeRange(0, text.count)
                )
                cell.label_totalOfBigCategory.attributedText = attributeText
                cell.label_totalOfBigCategory.font = UIFont.boldSystemFont(ofSize: 14)
                var textt:String = ""
                if dataBaseManagerPeriod.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                    textt = dataBaseManagerBS.getTotalBig5(big5: 3, lastYear: true)
                }else {
                    textt = "-"
                }
                // テキストをカスタマイズするために、NSMutableAttributedStringにする
                let attributeTextt = NSMutableAttributedString(string: textt)
                // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
                attributeTextt.addAttribute(
                    NSAttributedString.Key.underlineStyle,
                    value: NSUnderlineStyle.single.rawValue,
                    range: NSMakeRange(0, textt.count)
                )
                cell.label_totalOfBigCategory_previous.attributedText = attributeTextt
                cell.label_totalOfBigCategory_previous.font = UIFont.boldSystemFont(ofSize: 14)
                // 資産合計と純資産負債合計の金額が不一致の場合、文字色を赤
                if dataBaseManagerBS.getTotalBig5(big5: 0, lastYear: false) != dataBaseManagerBS.getTotalBig5(big5: 3, lastYear: false) {
                    cell.label_totalOfBigCategory.textColor = .red
                }else {
                    // ダークモード対応
                    if (UITraitCollection.current.userInterfaceStyle == .dark) {
                        /* ダークモード時の処理 */
                        cell.label_totalOfBigCategory.textColor = .white
                    } else {
                        /* ライトモード時の処理 */
                        cell.label_totalOfBigCategory.textColor = .black
                    }
                }
                return cell
            default:
                // 勘定科目
                let cell = tableView.dequeueReusableCell(withIdentifier: "account", for: indexPath) as! TableViewCellAccount
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                cell.textLabel?.minimumScaleFactor = 0.05
                cell.textLabel?.adjustsFontSizeToFitWidth = true
                if       indexPath.row >= 1 &&                       // 株主資本
                         indexPath.row <  objects14.count + 1 {      // 株主資本合計
                    cell.textLabel?.text = "        "+objects14[indexPath.row-1].category
                    print("BS", indexPath.row, "        "+objects14[indexPath.row-1].category)
                    cell.label_account.text = dataBaseManagerTaxonomy.getTotalOfTaxonomy(numberOfSettingsTaxonomy: objects14[indexPath.row-1].number, lastYear: false)
                    if dataBaseManagerPeriod.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                        cell.label_account_previous.text = dataBaseManagerTaxonomy.getTotalOfTaxonomy(numberOfSettingsTaxonomy: objects14[indexPath.row-1].number, lastYear: true)
                    }else {
                        cell.label_account_previous.text = "-"
                    }
                    cell.label_account.textAlignment = .right
                }else if indexPath.row >= objects14.count + 2 + 1 &&                     //その他の包括利益累計額
                          indexPath.row <   objects14.count + 2 + objects15.count + 1 {    //その他の包括利益累計額合計
                    cell.textLabel?.text = "        "+objects15[indexPath.row-(objects14.count + 2 + 1)].category
                    print("BS", indexPath.row, "        "+objects15[indexPath.row-(objects14.count + 2 + 1)].category)
                    cell.label_account.text = dataBaseManagerTaxonomy.getTotalOfTaxonomy(numberOfSettingsTaxonomy: objects15[indexPath.row-(objects14.count + 2 + 1)].number, lastYear: false)
                    if dataBaseManagerPeriod.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                        cell.label_account_previous.text = dataBaseManagerTaxonomy.getTotalOfTaxonomy(numberOfSettingsTaxonomy: objects15[indexPath.row-(objects14.count + 2 + 1)].number, lastYear: true)
                    }else {
                        cell.label_account_previous.text = "-"
                    }
                    cell.label_account.textAlignment = .right
                }else {
                    print("??")
                    let soundIdRing: SystemSoundID = 1000 //鐘
                    AudioServicesPlaySystemSound(soundIdRing)
                }
                return cell
            }
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
            return cell
        }
    }

    func translateSmallCategory(small_category: Int) -> String {
        var small_category_name: String
        switch small_category {
        case 0:
            small_category_name = " 当座資産"
            break
        case 1:
            small_category_name = " 棚卸資産"
            break
        case 2:
            small_category_name = " その他流動資産"
            break
            
            
            
        case 3:
            small_category_name = " 有形固定資産"
            break
        case 4:
            small_category_name = " 無形固定資産"
            break
        case 5:
            small_category_name = " 投資その他資産"
            break
            
            
            
        case 6:
            small_category_name = " 仕入負債" // 仕入債務
            break
        case 7:
            small_category_name = " その他流動負債" // 短期借入金
            break
            
            
            
        case 8:
            small_category_name = " 売上原価"
            break
        case 9:
            small_category_name = " 販売費及び一般管理費"
            break
        case 10:
            small_category_name = " 売上高"
            break
        default:
            small_category_name = " 小分類なし"
            break
        }
        return small_category_name
    }
    
    @IBOutlet weak var view_top: UIView!
    var printing: Bool = false // プリント機能を使用中のみたてるフラグ　true:セクションをテーブルの先頭行に固定させない。描画時にセクションが重複してしまうため。
    // disable sticky section header
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if printing {
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) // ここがポイント。画面表示用にインセットを設定した、ステータスバーとナビゲーションバーの高さの分をリセットするために0を設定する。
            // スクロールのオフセットがヘッダー部分のビューとステータスバーの高さ以上　かつ　0以上
            if scrollView.contentOffset.y >= view_top.bounds.height+UIApplication.shared.statusBarFrame.height && scrollView.contentOffset.y >= 0 {
                // セクションヘッダーの高さをインセットに設定する　セクションヘッダーがテーブル上にとどまらないようにするため
                scrollView.contentInset = UIEdgeInsets(top: -(view_top.bounds.height+UIApplication.shared.statusBarFrame.height+tableView.sectionHeaderHeight), left: 0, bottom: 0, right: 0)
            }
        }else{
            if self.navigationController?.navigationBar.bounds.height != nil {
//                // インセットを設定する　ステータスバーとナビゲーションバーより下からテーブルビューを配置するため
//                scrollView.contentInset = UIEdgeInsets(top: +self.navigationController!.navigationBar.bounds.height+UIApplication.shared.statusBarFrame.height, left: 0, bottom: 0, right: 0)
                // インセットを設定する　ステータスバーとナビゲーションバーより下からテーブルビューを配置するため
                scrollView.contentInset = UIEdgeInsets(top: +(UIApplication.shared.statusBarFrame.height+self.navigationController!.navigationBar.bounds.height), left: 0, bottom: (self.tabBarController?.tabBar.frame.size.height)!, right: 0)
            }
        }
    }
    @IBOutlet var tableView_BS: UITableView!
    var pageSize = CGSize(width: 210 / 25.4 * 72, height: 297 / 25.4 * 72)
    var pageSizee = CGSize(width: 210 / 25.4 * 72, height: 297 / 25.4 * 72)
    var pageSizeee = CGSize(width: 210 / 25.4 * 72, height: 297 / 25.4 * 72)
    @IBOutlet weak var button_print: UIButton!
    /**
     * 印刷ボタン押下時メソッド
     */
    @IBAction func button_print(_ sender: UIButton) {
        printing = true
        gADBannerView.isHidden = true
        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableView.ScrollPosition.top, animated: false)
        // 画面上で印刷したい範囲のViewを全て描画させるために、TableViewを最下部まで段階的にスクロールさせる。＊段階的にしなくてもエラーは出なかった

        // 第三の方法
        //余計なUIをキャプチャしないように隠す
        tableView.showsVerticalScrollIndicator = false
        if let tappedIndexPath: IndexPath = self.tableView.indexPathForSelectedRow { // タップされたセルの位置を取得
            tableView.deselectRow(at: tappedIndexPath, animated: true)// セルの選択を解除
        }
//        CGRectMake(0, 0, tableView.contentSize.width, tableView.contentSize.height)
        //A4, 210x297mm, 8.27x11.68インチ,595x841ピクセル
        pageSize = CGSize(width: 210 / 25.4 * 72, height: 297 / 25.4 * 72)//実際印刷用紙サイズ937x1452ピクセル
        pageSizee = CGSize(width: 210 / 25.4 * 72, height: tableView.contentSize.height / 25.4 * 72)
        pageSizeee = CGSize(width: tableView.contentSize.width / 25.4 * 72, height: tableView.contentSize.height+self.navigationController!.navigationBar.bounds.height+(self.tabBarController?.tabBar.frame.size.height)! / 25.4 * 72)
//        pageSizeee = CGSize(width: tableView.contentSize.width, height: tableView.contentSize.height)

        //viewと同じサイズのコンテキスト（オフスクリーンバッファ）を作成
//        var rect = self.view.bounds
        //p-41 「ビットマップグラフィックスコンテキストを使って新しい画像を生成」
        //1. UIGraphicsBeginImageContextWithOptions関数でビットマップコンテキストを生成し、グラフィックススタックにプッシュします。
        UIGraphicsBeginImageContextWithOptions(pageSize, false, 0.0)
        //2. UIKitまたはCore Graphicsのルーチンを使って、新たに生成したグラフィックスコンテキストに画像を描画します。
//        imageRect.draw(in: CGRect(origin: .zero, size: pageSize))
        //3. UIGraphicsGetImageFromCurrentImageContext関数を呼び出すと、描画した画像に基づく UIImageオブジェクトが生成され、返されます。必要ならば、さらに描画した上で再びこのメソッ ドを呼び出し、別の画像を生成することも可能です。
        //p-43 リスト 3-1 縮小画像をビットマップコンテキストに描画し、その結果の画像を取得する
//        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        let newImage = self.tableView.captureImagee()
        //4. UIGraphicsEndImageContextを呼び出してグラフィックススタックからコンテキストをポップします。
        UIGraphicsEndImageContext()
        printing = false
        gADBannerView.isHidden = false
        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableView.ScrollPosition.bottom, animated: false) //ビットマップコンテキストに描画後、画面上のTableViewを先頭にスクロールする
        /*
        ビットマップグラフィックスコンテキストでの描画全体にCore Graphicsを使用する場合は、
         CGBitmapContextCreate関数を使用して、コンテキストを作成し、
         それに画像コンテンツを描画します。
         描画が完了したら、CGBitmapContextCreateImage関数を使用し、そのビットマップコンテキストからCGImageRefを作成します。
         Core Graphicsの画像を直接描画したり、この画像を使用して UIImageオブジェクトを初期化することができます。
         完了したら、グラフィックスコンテキストに対 してCGContextRelease関数を呼び出します。
        */
        let myImageView = UIImageView(image: newImage)
        myImageView.layer.position = CGPoint(x: self.view.frame.midX, y: self.view.frame.midY)
//PDF
        //p-49 リスト 4-2 ページ単位のコンテンツの描画
            let framePath = NSMutableData()
        //p-45 「PDFコンテキストの作成と設定」
            // PDFグラフィックスコンテキストは、UIGraphicsBeginPDFContextToData関数、
            //  または UIGraphicsBeginPDFContextToFile関数のいずれかを使用して作成します。
            //  UIGraphicsBeginPDFContextToData関数の場合、
            //  保存先はこの関数に渡される NSMutableDataオブジェクトです。
            UIGraphicsBeginPDFContextToData(framePath, myImageView.bounds, nil)
        //p-46 「UIGraphicsBeginPDFPage関数は、デフォルトのサイズを使用してページを作成します。」
//            UIGraphicsBeginPDFPage()
        // 新しいページを開始する
        // ビューイメージを全て印刷できるページ数を用意する
        var pageCounts: CGFloat = 0
        while myImageView.bounds.height > (myImageView.bounds.width*1.414516129) * pageCounts {
            //            if myImageView.bounds.height > (myImageView.bounds.width*1.414516129)*2 {
            UIGraphicsBeginPDFPageWithInfo(CGRect(x:0, y:-(myImageView.bounds.width*1.414516129)*pageCounts, width:myImageView.bounds.width, height:myImageView.bounds.width*1.414516129), nil) //高さはA4コピー用紙と同じ比率にするために、幅×1.414516129とする
            // グラフィックスコンテキストを取得する
            guard let currentContext = UIGraphicsGetCurrentContext() else { return }
            myImageView.layer.render(in: currentContext)
            // ページを増加
            pageCounts += 1
        }
        //描画が終了したら、UIGraphicsEndPDFContextを呼び出して、PDFグラフィックスコンテキストを閉じます。
            UIGraphicsEndPDFContext()
            
//ここからプリントです
        //p-63 リスト 5-1 ページ範囲の選択が可能な単一のPDFドキュメント
        let pic = UIPrintInteractionController.shared
        if UIPrintInteractionController.canPrint(framePath as Data) {
            //pic.delegate = self;
            pic.delegate = self
            
            let printInfo = UIPrintInfo.printInfo()
            printInfo.outputType = .general
            printInfo.jobName = "Balance Sheet"
            printInfo.duplex = .none
            pic.printInfo = printInfo
            //'showsPageRange' was deprecated in iOS 10.0: Pages can be removed from the print preview, so page range is always shown.
            pic.printingItem = framePath
    
            let completionHandler: (UIPrintInteractionController, Bool, NSError) -> Void = { (pic: UIPrintInteractionController, completed: Bool, error: Error?) in
                
                if !completed && (error != nil) {
                    print("FAILED! due to error in domain %@ with error code %u \(String(describing: error))")
                }
            }
            //p-79 印刷インタラクションコントローラを使って印刷オプションを提示
            //UIPrintInteractionControllerには、ユーザに印刷オプションを表示するために次の3つのメソッ ドが宣言されており、それぞれアニメーションが付属しています。
            if UIDevice.current.userInterfaceIdiom == .pad {
                //これらのうちの2つは、iPadデバイス上で呼び出されることを想定しています。
                //・presentFromBarButtonItem:animated:completionHandler:は、ナビゲーションバーまたは ツールバーのボタン(通常は印刷ボタン)からアニメーションでPopover Viewを表示します。
//                print("通過・printButton.frame -> \(button_print.frame)")
//                print("通過・printButton.bounds -> \(button_print.bounds)")
                //UIBarButtonItemの場合
                //pic.present(from: printUIButton, animated: true, completionHandler: nil)
                //・presentFromRect:inView:animated:completionHandler:は、アプリケーションのビューの任意の矩形からアニメーションでPopover Viewを表示します。
                pic.present(from: CGRect(x: 0, y: 0, width: 0, height: 0), in: self.view, animated: true, completionHandler: nil)
                print("iPadです")
            } else {
                //モーダル表示
                //・presentAnimated:completionHandler:は、画面の下端からスライドアップするページをアニ メーション化します。これはiPhoneおよびiPod touchデバイス上で呼び出されることを想定しています。
                pic.present(animated: true, completionHandler: completionHandler as? UIPrintInteractionController.CompletionHandler)
                print("iPhoneです")
            }
        }
        //余計なUIをキャプチャしないように隠したのを戻す
        tableView.showsVerticalScrollIndicator = true
        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableView.ScrollPosition.bottom, animated: false) //ビットマップコンテキストに描画後、画面上のTableViewを先頭にスクロールする

    }
    /**
     * 印刷メソッド
     */
    func printToPrinter(printer: UIPrinter) {
        //　プリント設定を行う
        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.jobName = "Accounting Print"
        printInfo.orientation = .portrait
        printInfo.outputType = .grayscale
        // プリンターコントローラーを生成
        let printInteractionController = UIPrintInteractionController.shared
        printInteractionController.printInfo = printInfo
        // 印刷内容設定
        //  (a) 画像もしくはPDFに変換する この方法では画面上に写っている範囲のみ印刷可能
//        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0.0);
//        view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
//        let image = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        printInteractionController.printingItem = image
        //  (b) printPageRendererを設定する
        //printInteractionController.printingItem = view.viewPrintFormatter()//UIImage(named: "flower.jpg")
        let viewPrintFormatter = view.viewPrintFormatter()
        let renderer = PrintPageRendererBS()
//        let renderer = UIPrintPageRenderer()
//        let renderer = UISimpleTextPrintFormatter() //プレインテキストドキュメントを自動的に描画、レイアウト します。テキストのグローバルプロパティ(フォント、色、配置、改行モードなど)も設定でき ます。
        //renderer.jobTitle = printInfo.jobName
        renderer.addPrintFormatter(viewPrintFormatter, startingAtPageAt: 0)
        printInteractionController.printPageRenderer = renderer

        printInteractionController.print(to: printer) { (controller:UIPrintInteractionController, completed:Bool, error:Error?) in
            if error == nil {
                print("Print Completed.")
            }
        }
//        printInteractionController.print(to: printer, completionHandler: {
//            controller, completed, error in
//        })
        
    }
    
    // MARK: - UIImageWriteToSavedPhotosAlbum
    
    @objc func didFinishWriteImage(_ image: UIImage, error: NSError?, contextInfo: UnsafeMutableRawPointer) {
        if let error = error {
        print("Image write error: \(error)")
        }
    }

    func printInteractionController ( _ printInteractionController: UIPrintInteractionController, choosePaper paperList: [UIPrintPaper]) -> UIPrintPaper {
        print("printInteractionController")
        for i in 0..<paperList.count {
            let paper: UIPrintPaper = paperList[i]
        print(" paperListのビクセル is \(paper.paperSize.width) \(paper.paperSize.height)")
        }
        //ピクセル
        print(" pageSizeピクセル    -> \(pageSize)")
        let bestPaper = UIPrintPaper.bestPaper(forPageSize: pageSize, withPapersFrom: paperList)
        //mmで用紙サイズと印刷可能範囲を表示
        print(" paperSizeミリ      -> \(bestPaper.paperSize.width / 72.0 * 25.4), \(bestPaper.paperSize.height / 72.0 * 25.4)")
        print(" bestPaper         -> \(bestPaper.printableRect.origin.x / 72.0 * 25.4), \(bestPaper.printableRect.origin.y / 72.0 * 25.4), \(bestPaper.printableRect.size.width / 72.0 * 25.4), \(bestPaper.printableRect.size.height / 72.0 * 25.4)\n")
        return bestPaper
    }
}

class PrintPageRendererBS: UIPrintPageRenderer {
    
}

extension UIView {
    // オフスクリーン画像を作成
    func captureImage() -> UIImage? {
        print("captureImage")
        // ①オフスクリーンを作成
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
        print(" bounds.size: \(bounds.size)")
        // 設定されているCGContextを取り出す
        guard let context: CGContext = UIGraphicsGetCurrentContext() else { return nil }

        self.layer.render(in: context)
        // オフスクリーンを画像として取り出す
        let capturedImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()

        return capturedImage
    }
}

extension UITableView {

    var contentBottom: CGFloat {
        return contentSize.height - bounds.height
    }
    
    func captureImagee() -> UIImage? {
        print("captureImagee")
        // オフスクリーン保持用のプロパティ
        let images = captureImages()
        
        // Concatenate images
        
        print(" contentSize: \(contentSize)\n")
        UIGraphicsBeginImageContext(contentSize);
        
        // ①画像を描画
        // ②スケーリングさせないUIImageの描画
        var y: CGFloat = 0
        for image in images {
            print("images.count: \(images.count)")
            image.draw(at: CGPoint(x: 0, y: y))
            print(" y : \(y)")
            y = min(y + bounds.height, contentBottom) // calculate layer diff
            print(" y + bounds.height, contentBottom :  \(y) + \(bounds.height), \(contentBottom)")
        }
        let concatImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        return concatImage
    }
    
    func captureImages() -> [UIImage] {
        print("captureImages")
        // オフスクリーン保持用のプロパティ
        var images: [UIImage?] = []
        
        while true {

            images.append(superview?.captureImage()) // not work in self.view

            if contentOffset.y < (contentBottom - bounds.height) { //スクロール高さ<コンテント高さー座標高さー座標高さ
                // iPadを横向きで実行するとこのパスを通る
                print("if contentOffset.y < (contentBottom - bounds.height)")
                print(" images.count     : \(images.count)")
                print(" contentOffset.y  : \(contentOffset.y)")
                contentOffset.y += bounds.height
                print(" contentOffset.y  : \(contentOffset.y)")
                print(" bounds.height    : \(bounds.height)")
                print(" contentBottom    : \(contentBottom)")
//                print(" contentBottom - bounds.height : \(contentBottom - bounds.height)")
                print(" contentSize.height: \(contentSize.height) - bounds.height: \(bounds.height) = \(contentSize.height - bounds.height)\n")
            } else {
                // contentBottomの座標からセクションの高さを引く?　※セクションは残ったままとなる
                contentOffset.y = contentBottom
                print(" images.count     : \(images.count)")
                print(" contentOffset.y  : \(contentOffset.y)")
                print(" bounds.height    : \(bounds.height)")
                print(" contentBottom    : \(contentBottom)")
//                print(" contentBottom - bounds.height : \(contentBottom - bounds.height)")
                print(" contentSize.height: \(contentSize.height) - bounds.height: \(bounds.height) = \(contentSize.height - bounds.height)\n")
                images.append(superview?.captureImage()) // not work in self.view
                break
            }
        }
        return images.flatMap{ $0 } // exclude nil
    }
}

