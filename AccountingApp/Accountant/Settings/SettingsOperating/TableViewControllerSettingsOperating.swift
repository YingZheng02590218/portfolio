//
//  TableViewControllerSettingsOperating.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/12/06.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import UIKit
import GoogleMobileAds // マネタイズ対応

// 操作設定クラス
class TableViewControllerSettingsOperating: UITableViewController {

    // マネタイズ対応
    // 広告ユニットID
    let AdMobID = "ca-app-pub-7616440336243237/8565070944"
    // テスト用広告ユニットID
    let TEST_ID = "ca-app-pub-3940256099942544/2934735716"
    // true:テスト
    let AdMobTest:Bool = true
    @IBOutlet var gADBannerView: GADBannerView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // 年度を追加後に会計期間画面を更新する
        tableView.reloadData()
        // 要素数が少ないUITableViewで残りの部分や余白を消す
        let tableFooterView = UIView(frame: CGRect.zero)
        tableView.tableFooterView = tableFooterView

        // マネタイズ対応　完了　注意：viewDidLoad()ではなく、viewWillAppear()に実装すること
//        print("Google Mobile Ads SDK version: \(GADRequest.sdkVersion())")
        // GADBannerView を作成する
        gADBannerView = GADBannerView(adSize:kGADAdSizeMediumRectangle)
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
    // ビューが表示された後に呼ばれる
    override func viewDidAppear(_ animated: Bool){
        // チュートリアル対応　初回起動時　7行を追加
        let ud = UserDefaults.standard
        let firstLunchKey = "firstLunch_SettingsJournals"
        if ud.bool(forKey: firstLunchKey) {
            ud.set(false, forKey: firstLunchKey)
            ud.synchronize()
            // チュートリアル対応
//            presentAnnotation()
        }
    }
    // チュートリアル対応
    func presentAnnotation() {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Annotation_SettingsCategory") as! AnnotationViewControllerSettingsCategory
        viewController.alpha = 0.5
        present(viewController, animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        default:
            return 0
        }
    }
    // セクションヘッダーのテキスト決める
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "決算振替仕訳"
        default:
            return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
//        case 0:
//            return "使用する勘定科目を設定することができます。"
        default:
            return ""
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 設定操作
        let dataBaseManagerSettingsOperating = DataBaseManagerSettingsOperating()
        let object = dataBaseManagerSettingsOperating.getSettingsOperating() // 決算整理仕訳 損益振替仕訳 資本振替仕訳
        switch indexPath.row {
        case 0:
            //① UI部品を指定
            let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! TableViewCellCategoryList
            cell.textLabel?.text = "損益振替仕訳を表示"
            // 勘定科目の有効無効
            cell.ToggleButton.isOn = object?.EnglishFromOfClosingTheLedger0 as! Bool
            // 勘定科目の有効無効　変更時のアクションを指定
            cell.ToggleButton.addTarget(self, action: #selector(hundleSwitch), for: UIControl.Event.valueChanged)
            cell.ToggleButton.tag = 0
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! TableViewCellCategoryList
            cell.textLabel?.text = "資本振替仕訳を表示"
            // 勘定科目の有効無効
            cell.ToggleButton.isOn = object?.EnglishFromOfClosingTheLedger1 as! Bool
            // 勘定科目の有効無効　変更時のアクションを指定
            cell.ToggleButton.addTarget(self, action: #selector(hundleSwitch), for: UIControl.Event.valueChanged)
            cell.ToggleButton.tag = 1
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! TableViewCellCategoryList
            cell.textLabel?.text =   ""
            return cell
        }
    }
    // 有効無効　変更時のアクション
    @objc func hundleSwitch(sender: UISwitch) {
        // 設定操作
        let dataBaseManagerSettingsOperating = DataBaseManagerSettingsOperating()

        if sender.tag == 0 { // 損益振替仕訳
            dataBaseManagerSettingsOperating.updateSettingsOperating(EnglishFromOfClosingTheLedger: "EnglishFromOfClosingTheLedger0", isOn: sender.isOn)
        }else if sender.tag == 1 { // 資本振替仕訳
            dataBaseManagerSettingsOperating.updateSettingsOperating(EnglishFromOfClosingTheLedger: "EnglishFromOfClosingTheLedger1", isOn: sender.isOn)
        }
    }
}
