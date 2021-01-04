//
//  TableViewControllerSettingsPeriod.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/06/02.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import UIKit
import GoogleMobileAds // マネタイズ対応

// 会計期間クラス
class TableViewControllerSettingsPeriod: UITableViewController, UIPopoverPresentationControllerDelegate {

    // マネタイズ対応
    // 広告ユニットID
    let AdMobID = "ca-app-pub-7616440336243237/8565070944"
    // テスト用広告ユニットID
    let TEST_ID = "ca-app-pub-3940256099942544/2934735716"
    // true:テスト
    let AdMobTest:Bool = true
    @IBOutlet var gADBannerView: GADBannerView!
    // 広告ユニットID
    let AdMobIDi = "ca-app-pub-7616440336243237/4964823000" // インタースティシャル
    // テスト用広告ユニットID
    let TEST_IDi = "ca-app-pub-3940256099942544/4411468910" // インタースティシャル
    @IBOutlet var interstitial: GADInterstitial!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.allowsMultipleSelection = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        tableView.reloadData()
        // 要素数が少ないUITableViewで残りの部分や余白を消す
        let tableFooterView = UIView(frame: CGRect.zero)
        tableView.tableFooterView = tableFooterView

        // マネタイズ対応　完了　注意：viewDidLoad()ではなく、viewWillAppear()に実装すること
//        print("Google Mobile Ads SDK version: \(GADRequest.sdkVersion())")
        // GADBannerView を作成する
        gADBannerView = GADBannerView(adSize:kGADAdSizeLargeBanner)
        // iPhone X のポートレート決め打ちです　→ 仕訳帳のタブバーの上にバナー広告が表示されるように調整した。
//        print(self.view.frame.size.height)
//        print(gADBannerView.frame.height)
//        gADBannerView.frame.origin = CGPoint(x: 0, y: self.view.frame.size.height - gADBannerView.frame.height + tableView.contentOffset.y) // スクロール時の、広告の位置を固定する
//        gADBannerView.frame.size = CGSize(width: self.view.frame.width, height: gADBannerView.frame.height)
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
//        addBannerViewToView(gADBannerView, constant: 0)
        addBannerViewToView(gADBannerView, constant: tableView.visibleCells[tableView.visibleCells.count-1].frame.height * -1)
        // マネタイズ対応　注意：viewDidLoad()ではなく、viewWillAppear()に実装すること
        // GADBannerView プロパティを設定する
        if AdMobTest {
            // GADInterstitial を作成する
            interstitial = GADInterstitial(adUnitID: TEST_IDi)
        }
        else{
            interstitial = GADInterstitial(adUnitID: AdMobIDi)
        }
        let request = GADRequest()
        interstitial.load(request)
    }
    // インタースティシャル広告を表示　マネタイズ対応
    func showAd() {
        // 年度を追加後に会計期間画面を更新する
        tableView.reloadData()
        // マネタイズ対応
        if self.interstitial.isReady {
            self.interstitial.present(fromRootViewController: self)
        }
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
        let firstLunchKey = "firstLunch_SettingPeriod"
        if ud.bool(forKey: firstLunchKey) {
            ud.set(false, forKey: firstLunchKey)
            ud.synchronize()
            // チュートリアル対応
            presentAnnotation()
        }
    }
    // チュートリアル対応
    func presentAnnotation() {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Annotation_SettingPeriod") as! AnnotationViewControllerSettingPeriod
        viewController.alpha = 0.5
        present(viewController, animated: true, completion: nil)
    }
    // 前準備
    override func prepare (for segue: UIStoryboardSegue, sender: Any?) {
        // セグエで場合分け
        if segue.identifier == "identifier_theDayOfReckoning"{ // 決算日設定
            // segue.destinationの型はUIViewController
            let tableViewControllerSettingsTheDayOfReckoning = segue.destination as! TableViewControllerSettingsTheDayOfReckoning
            // 選択されたセルを取得
            let indexPath: IndexPath = self.tableView.indexPathForSelectedRow! // ※ didSelectRowAtの代わりにこれを使う方がいい　タップされたセルの位置を取得
            // 遷移先のコントローラに値を渡す
            if indexPath.row == 0 {
                tableViewControllerSettingsTheDayOfReckoning.month = true // 決算日　月
            }else if indexPath.row == 1 {
                tableViewControllerSettingsTheDayOfReckoning.month = false // 決算日　日
            }
        }else{
            // セグエのポップオーバー接続先を取得
            let popoverCtrl = segue.destination.popoverPresentationController
            // 呼び出し元がUIButtonの場合
            if sender is UIButton {
                // タップされたボタンの領域を取得
                popoverCtrl?.sourceRect = (sender as! UIButton).bounds
            }
            // デリゲートを自分自身に設定
            popoverCtrl?.delegate = self
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    // セクションヘッダーのテキスト決める
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "決算日"
        case 1:
            return "会計年度"
        default:
            return ""
        }
    }
    // セクションフッターのテキスト決める
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0:
            return "決算日は、財務諸表や仕訳帳、精算表、試算表に表示されます。"
        default:
            return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            // 決算日
            return 2
        case 1:
            // 会計年度
            let dataBaseManager = DataBaseManagerSettingsPeriod()
            let counts = dataBaseManager.getMainBooksAllCount()
            return counts
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            // 決算日
            let cell = tableView.dequeueReusableCell(withIdentifier: "identifier_theDayOfReckoning", for: indexPath)
            let dataBaseManager = DataBaseManagerSettingsPeriod()
            let object = dataBaseManager.getTheDayOfReckoning()
            // 会計帳簿の年度をセルに表示する
            if indexPath.row == 0 {
                cell.textLabel?.text = "月"
                let d = object
                let date = d[d.index(d.startIndex, offsetBy: 0)..<d.index(d.startIndex, offsetBy: 2)] // 日付の9文字目にある日の十の位を抽出
                cell.detailTextLabel?.text = "\(date)"
                print(date)
            }else {
                cell.textLabel?.text = "日"
                let d = object
                let date = d[d.index(d.startIndex, offsetBy: 3)..<d.index(d.startIndex, offsetBy: 5)] // 日付の9文字目にある日の十の位を抽出
                cell.detailTextLabel?.text = "\(date)"
                print(date)
            }
            // 詳細テキストラベル
            cell.detailTextLabel?.textColor = .lightGray
            return cell
        case 1:
            // 会計年度
            let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
            // データベース
            let dataBaseManager = DataBaseManagerSettingsPeriod()
            let objects = dataBaseManager.getMainBooksAll()
            // 会計帳簿の年度をセルに表示する
            cell.textLabel?.text = " \(objects[indexPath.row].fiscalYear as Int)"
            cell.textLabel?.textAlignment = .center
            // 会計帳簿の連番
            cell.tag = objects[indexPath.row].number
            // 開いている帳簿にチェックマークをつける
            if objects[indexPath.row].openOrClose {
                // チェックマークを入れる
                cell.accessoryType = .checkmark
            }else {
                // チェックマークを外す
                cell.accessoryType = .none
            }
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
            return cell
        }
    }
    // セルが選択された時に呼び出される
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            // 会計年度
            let cell = tableView.cellForRow(at:indexPath)
            // チェックマークを入れる
            cell?.accessoryType = .checkmark
            // ここからデータベースを更新する
            pickAccountingBook(tag: cell!.tag) //会計帳簿の連番
            // 年度を選択時に会計期間画面を更新する
            tableView.reloadData()
            break
        default:
            print("")
            break
        }
    }
    // チェックマークの切り替え　データベースを更新
    func pickAccountingBook(tag: Int) {
        // データベース
        let databaseManager = DataBaseManagerSettingsPeriod()
        databaseManager.setMainBooksOpenOrClose(tag: tag)
        // 帳簿の年度を切り替えた場合、設定勘定科目と勘定の勘定科目を比較して、不足している勘定を追加する　2020/11/08
        let dataBaseManagerAccount = DataBaseManagerAccount()
        dataBaseManagerAccount.addGeneralLedgerAccountLack() 
    }
    // セルの選択が外れた時に呼び出される
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            let cell = tableView.cellForRow(at:indexPath)
            // チェックマークを外す
            cell?.accessoryType = .none
        }
    }
    // 削除機能 セルを左へスワイプ
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        print("選択されたセルを取得: \(indexPath.section), \(indexPath.row)") //  1行目 [4, 0] となる　7月の仕訳データはsection4だから
        // スタイルには、normal と　destructive がある
        let action = UIContextualAction(style: .destructive, title: "削除") { (action, view, completionHandler) in
            // なんか処理
            // 確認のポップアップを表示したい
            self.showPopover(indexPath: indexPath)
            completionHandler(true) // 処理成功時はtrue/失敗時はfalseを設定する
        }
        action.image = UIImage(systemName: "trash.fill") // 画像設定（タイトルは非表示になる）
        let configuration = UISwipeActionsConfiguration(actions: [action])
        return configuration
    }
    // 削除機能 アラートのポップアップを表示
    private func showPopover(indexPath: IndexPath) {
        let alert = UIAlertController(title: "削除", message: "会計帳簿を削除しますか？", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            (action: UIAlertAction!) in
            print("OK アクションをタップした時の処理")
            // データベース
            let dataBaseManagerPeriod = DataBaseManagerSettingsPeriod()
            let objects = dataBaseManagerPeriod.getMainBooksAll()
            if objects.count > 1 {
                // 会計帳簿を削除
                let dataBaseManager = DataBaseManagerAccountingBooks()
                let result = dataBaseManager.deleteAccountingBooks(number: objects[indexPath.row].number)
                if result == true {
                    self.tableView.reloadData() // データベースの削除処理が成功した場合、テーブルをリロードする
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    // 表示スタイルの設定
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        // .noneを設定することで、設定したサイズでポップオーバーされる
        return .none
    }
}
