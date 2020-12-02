//
//  TableViewController.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/05/21.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import UIKit
import GoogleMobileAds // マネタイズ対応

// 設定クラス
class TableViewControllerSettings: UITableViewController {
    
    // マネタイズ対応
    // 広告ユニットID
    let AdMobID = "ca-app-pub-7616440336243237/8565070944"
    // テスト用広告ユニットID
    let TEST_ID = "ca-app-pub-3940256099942544/2934735716"
    // true:テスト
    let AdMobTest:Bool = false
    @IBOutlet var gADBannerView: GADBannerView!
    
    
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
        // GADBannerView を作成する
        addBannerViewToView(gADBannerView, constant:  self.tableView.visibleCells[self.tableView.visibleCells.count-1].frame.height * -1) // 一番したから3行分のスペースを空ける
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
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    // セクションヘッダーのテキスト決める
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
//            return "会計期間"
//        case 1:
//            return "勘定科目"
//        case 2:
            return "情報"
        default:
            return ""
        }
    }
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0:
//            return "会計期間を設定することができます。"
//        case 1:
//            return "利用する勘定科目を設定することができます。"
//        case 2:
            return "帳簿情報を設定することができます。"
        default:
            return ""
        }
    }
    //セルを生成して返却するメソッド
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> TableViewCellSettings {
        var cell = TableViewCellSettings()
        switch indexPath.row {
        case 0:
            //① UI部品を指定　TableViewCell
            cell = tableView.dequeueReusableCell(withIdentifier: "cell_user", for: indexPath) as! TableViewCellSettings
            cell.textLabel?.text = "帳簿情報" // 注意：UITableViewCell内のViewに表示している。AttributesInspectorでHiddenをONにすると見えなくなる。
            return cell
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: "cell_list_settings_term", for: indexPath) as! TableViewCellSettings
            cell.textLabel?.text = "会計期間"
            return cell
        case 2:
            cell = tableView.dequeueReusableCell(withIdentifier: "cell_list_settings", for: indexPath) as! TableViewCellSettings
            cell.textLabel?.text = "勘定科目" 
            return cell
        default:
            return cell
        }
    }
// 不採用
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 選択されたセルを取得
//        let cell = tableView.dequeueReusableCell(withIdentifier: "cell_list_settings", for: indexPath) as! TableViewCellSettings
        // セルの選択を解除
        tableView.deselectRow(at: indexPath, animated: true)
        // 別の画面に遷移
//        if indexPath.section == 0 {
//            performSegue(withIdentifier: "identifier_term", sender: nil)
//        }
    }
}
