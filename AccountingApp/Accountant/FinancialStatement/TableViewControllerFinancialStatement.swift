//
//  TableViewControllerFinancialStatement.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/06/10.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import UIKit
import GoogleMobileAds // マネタイズ対応

// 決算書クラス
class TableViewControllerFinancialStatement: UITableViewController {

    // マネタイズ対応
    // 広告ユニットID
    let AdMobID = "ca-app-pub-7616440336243237/8565070944"
    // テスト用広告ユニットID
    let TEST_ID = "ca-app-pub-3940256099942544/2934735716"
    // true:テスト
    let AdMobTest:Bool = false
    @IBOutlet var gADBannerView: GADBannerView!
    
    @IBOutlet var TableViewFS: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // リロード機能
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: Selector(("refreshTable")), for: UIControl.Event.valueChanged)
        self.refreshControl = refreshControl
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
        print(tableView.rowHeight)
        // GADBannerView を作成する
        addBannerViewToView(gADBannerView, constant: self.tableView.visibleCells[self.tableView.visibleCells.count-1].frame.height * -1)
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
        let databaseManagerWS = DataBaseManagerWS()
        databaseManagerWS.calculateAmountOfAllAccount()
        databaseManagerWS.calculateAmountOfAllAccountForBS()
        databaseManagerWS.calculateAmountOfAllAccountForPL()
        // 設定表示科目　初期化
        let dataBaseManagerTaxonomy = DataBaseManagerTaxonomy()
        dataBaseManagerTaxonomy.initializeTaxonomy()
        // 更新処理
        self.tableView.reloadData()
        // クルクルを止める
        refreshControl?.endRefreshing()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            // 貸借対照表、損益計算書、キャッシュフロー計算書
            return 2//3
        case 1:
            // 精算書、試算表、損益勘定
            return 3
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "BS", for: indexPath)
                cell.textLabel?.text = "貸借対照表"
                cell.textLabel?.textAlignment = NSTextAlignment.center
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "PL", for: indexPath)
                cell.textLabel?.text = "損益計算書"
                cell.textLabel?.textAlignment = NSTextAlignment.center
                return cell
//            case 2:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "CF", for: indexPath)
//                cell.textLabel?.text = "キャッシュフロー計算書"
//                cell.textLabel?.textAlignment = NSTextAlignment.center
//                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "", for: indexPath)
                cell.textLabel?.text = ""
                cell.textLabel?.textAlignment = NSTextAlignment.center
                return cell
            }
        }else {
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "WS", for: indexPath)
                cell.textLabel?.text = "精算表"
                cell.textLabel?.textAlignment = NSTextAlignment.center
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "TB", for: indexPath)
                cell.textLabel?.text = "試算表"
                cell.textLabel?.textAlignment = NSTextAlignment.center
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "PLAccount", for: indexPath)
                cell.textLabel?.text = "損益勘定"
                cell.textLabel?.textAlignment = NSTextAlignment.center
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "", for: indexPath)
                cell.textLabel?.text = ""
                cell.textLabel?.textAlignment = NSTextAlignment.center
                return cell
            }
        }
    }
    
    // MARK: - Navigation
    
    // 追加機能　画面遷移の準備の前に入力検証
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        //画面のことをScene（シーン）と呼ぶ。 セグエとは、シーンとシーンを接続し画面遷移を行うための部品である。
//        if IndexPath(row: 2, section: 0) == self.TableViewFS.indexPathForSelectedRow! { //キャッシュ・フロー計算書　未対応
//            return false //false:画面遷移させない
//        }
        return true
    }
    // 画面遷移の準備　貸借対照表画面 損益計算書画面 キャッシュフロー計算書
    var tappedIndexPath: IndexPath?
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // 選択されたセルを取得
        let indexPath: IndexPath = self.TableViewFS.indexPathForSelectedRow! // ※ didSelectRowAtの代わりにこれを使う方がいい　タップされたセルの位置を取得
        switch segue.identifier {
            // 損益勘定
        case "segue_PLAccount": //“セグウェイにつけた名称”:
            // segue.destinationの型はUIViewController
            let viewControllerGenearlLedgerAccount = segue.destination as! ViewControllerGenearlLedgerAccount
            // 遷移先のコントローラに値を渡す
            viewControllerGenearlLedgerAccount.account = "損益勘定" // セルに表示した勘定名を設定
            // 遷移先のコントローラー.条件用の属性 = “条件”
            break
        default:
            break
        }
        // セルの選択を解除
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
