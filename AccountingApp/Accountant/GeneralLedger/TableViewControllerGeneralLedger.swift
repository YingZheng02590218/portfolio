//
//  TableViewControllerGeneralRedger.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/03/23.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import UIKit
import GoogleMobileAds // マネタイズ対応

// 総勘定元帳クラス
class TableViewControllerGeneralLedger: UITableViewController {

    // マネタイズ対応
    // 広告ユニットID
    let AdMobID = "ca-app-pub-7616440336243237/8565070944"
    // テスト用広告ユニットID
    let TEST_ID = "ca-app-pub-3940256099942544/2934735716"
    // true:テスト
    let AdMobTest:Bool = true
    @IBOutlet var gADBannerView: GADBannerView!
    
    @IBOutlet var TableView_generalLedger: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // リロード機能
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: Selector(("refreshTable")), for: UIControl.Event.valueChanged)
        self.refreshControl = refreshControl
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // 総勘定元帳を開いた後で、設定画面の勘定科目のON/OFFを変えるとエラーとなるのでリロードする
        tableView.reloadData()
        
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
    // リロード機能
    @objc func refreshTable() {
        // 全勘定の合計と残高を計算する
        let databaseManager = DataBaseManagerTB()
        databaseManager.setAllAccountTotal()
        databaseManager.calculateAmountOfAllAccount() // 合計額を計算
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
        return 12
    }
    // セクションヘッダーのテキスト決める
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return    "流動資産"
        case 1: return    "固定資産"
        case 2: return    "繰延資産"
        case 3: return    "流動負債"
        case 4: return    "固定負債"
        case 5: return    "資本"
        case 6: return    "売上"
        case 7: return    "売上原価"
        case 8: return    "販売費及び一般管理費"
        case 9: return    "営業外損益"
        case 10: return    "特別損益"
        case 11: return    "税金"

//        case 0: return    "当座資産"
//        case 1: return    "棚卸資産"
//        case 2: return    "その他の流動資産"
//        case 3: return    "有形固定資産"
//        case 4: return    "無形固定資産"
//        case 5: return    "投資その他の資産"
//        case 6: return    "繰延資産"
//        case 7: return    "仕入債務"
//        case 8: return    "その他の流動負債"
//        case 9: return    "長期債務"
//        case 10: return    "株主資本"
//        case 11: return    "評価・換算差額等"
//        case 12: return    "新株予約権"
//        case 13: return    "売上原価"
//        case 14: return    "製造原価"
//        case 15: return    "営業外収益"
//        case 16: return    "営業外費用"
//        case 17: return    "特別利益"
//        case 18: return    "特別損失"
        default:
            return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let databaseManagerSettings = DatabaseManagerSettingsTaxonomyAccount()
        let objects = databaseManagerSettings.getSettingsSwitchingOn(section: section) // どのセクションに表示するセルかを判別するため引数で渡す
        return objects.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let databaseManagerSettings = DatabaseManagerSettingsTaxonomyAccount()
        let objects = databaseManagerSettings.getSettingsSwitchingOn(section: indexPath.section) // どのセクションに表示するセルかを判別するため引数で渡す
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell_list_generalLedger", for: indexPath)
        // 勘定科目の名称をセルに表示する
        cell.textLabel?.text = "\(objects[indexPath.row].category as String)"
        cell.textLabel?.textAlignment = NSTextAlignment.center
        // 仕訳データがない勘定の表示名をグレーアウトする
        let dataBaseManagerAccount = DataBaseManagerAccount()
        let objectss = dataBaseManagerAccount.getAllJournalEntryInAccount(account: "\(objects[indexPath.row].category as String)") // 仕訳
        let objectsss = dataBaseManagerAccount.getAllAdjustingEntryInAccount(account: "\(objects[indexPath.row].category as String)") // 決算整理仕訳
        let objectssss = dataBaseManagerAccount.getAllAdjustingEntryInPLAccountWithRetainedEarningsCarriedForward(account: "\(objects[indexPath.row].category as String)") // 損益勘定
        let objectsssss = dataBaseManagerAccount.getAllAdjustingEntryWithRetainedEarningsCarriedForward(account: "\(objects[indexPath.row].category as String)") // 繰越利益
        if objectss.count > 0 || objectsss.count > 0 || objectssss.count > 0 || objectsssss.count > 0 {
            // ダークモード対応
            if (UITraitCollection.current.userInterfaceStyle == .dark) {
                /* ダークモード時の処理 */
                cell.textLabel?.textColor = .white
            } else {
                /* ライトモード時の処理 */
                cell.textLabel?.textColor = .black
            }
        }else {
            cell.textLabel?.textColor = .lightGray
        }
        return cell
    }
//    var account :String = "" // 勘定名
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        // 選択されたセルを取得
//        let cell = tableView.dequeueReusableCell(withIdentifier: "cell_list_generalLedger", for: indexPath) as! TableViewCellGeneralLedger
//        account = String(cell.textLabel!.text!) // セルに表示した勘定名を取得
//        // セルの選択を解除
//        tableView.deselectRow(at: indexPath, animated: true)
//        // 別の画面に遷移
//        performSegue(withIdentifier: "identifier_generalLedger", sender: nil)
//    }
    // 画面遷移の準備　勘定科目画面
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // 選択されたセルを取得
        let indexPath: IndexPath = self.TableView_generalLedger.indexPathForSelectedRow! // ※ didSelectRowAtの代わりにこれを使う方がいい　タップされたセルの位置を取得
        let databaseManagerSettings = DatabaseManagerSettingsTaxonomyAccount() //データベースマネジャー
        let objects = databaseManagerSettings.getSettingsSwitchingOn(section: indexPath.section) // どのセクションに表示するセルかを判別するため引数で渡す
        // segue.destinationの型はUIViewController
        let viewControllerGenearlLedgerAccount = segue.destination as! ViewControllerGenearlLedgerAccount
        // 遷移先のコントローラに値を渡す
        viewControllerGenearlLedgerAccount.account = "\(objects[indexPath.row].category as String)" // セルに表示した勘定名を取得
        // セルの選択を解除
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
