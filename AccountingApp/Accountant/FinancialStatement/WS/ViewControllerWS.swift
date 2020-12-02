//
//  ViewControllerWS.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/07/10.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import UIKit
import GoogleMobileAds // マネタイズ対応

// 精算表クラス
class ViewControllerWS: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPrintInteractionControllerDelegate {

    // マネタイズ対応
    // 広告ユニットID
    let AdMobID = "ca-app-pub-7616440336243237/8565070944"
    // テスト用広告ユニットID
    let TEST_ID = "ca-app-pub-3940256099942544/2934735716"
    // true:テスト
    let AdMobTest:Bool = false
    @IBOutlet var gADBannerView: GADBannerView!

    @IBOutlet weak var label_company_name: UILabel!
    @IBOutlet weak var label_title: UILabel!
    @IBOutlet weak var label_closingDate: UILabel!
    @IBOutlet weak var TableView_WS: UITableView!
    @IBOutlet weak var view_top: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        TableView_WS.delegate = self
        TableView_WS.dataSource = self
        
//        //精算表　借方合計と貸方合計の計算 (修正記入、損益計算書、貸借対照表)
//        let databaseManagerWS = DataBaseManagerWS()
//        databaseManagerWS.calculateAmountOfAllAccount()
//        databaseManagerWS.calculateAmountOfAllAccountForBS()
//        databaseManagerWS.calculateAmountOfAllAccountForPL()
        // 月末、年度末などの決算日をラベルに表示する
        let dataBaseManagerAccountingBooksShelf = DataBaseManagerAccountingBooksShelf()
        let company = dataBaseManagerAccountingBooksShelf.getCompanyName()
        label_company_name.text = company // 社名
        let dataBaseManagerPeriod = DataBaseManagerPeriod()
        let fiscalYear = dataBaseManagerPeriod.getSettingsPeriodYear()
        // ToDo どこで設定した年度のデータを参照するか考える
        label_closingDate.text = String(fiscalYear+1) + "年3月31日" // 決算日を表示する
        label_title.text = "精算表"
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: Selector(("refreshTable")), for: UIControl.Event.valueChanged)
        self.TableView_WS.refreshControl = refreshControl
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // 要素数が少ないUITableViewで残りの部分や余白を消す
        let tableFooterView = UIView(frame: CGRect.zero)
        TableView_WS.tableFooterView = tableFooterView

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
        addBannerViewToView(gADBannerView, constant: (self.TableView_WS.visibleCells[self.TableView_WS.visibleCells.count-3].frame.height + self.TableView_WS.visibleCells[self.TableView_WS.visibleCells.count-2].frame.height + self.TableView_WS.visibleCells[self.TableView_WS.visibleCells.count-1].frame.height) * -1) // 一番したから3行分のスペースを空ける
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
    
    override func viewDidAppear(_ animated: Bool) {
        // チュートリアル対応　初回起動時　7行を追加
        let ud = UserDefaults.standard
        let firstLunchKey = "firstLunch_WorkSheet"
        if ud.bool(forKey: firstLunchKey) {
            ud.set(false, forKey: firstLunchKey)
            ud.synchronize()
            // チュートリアル対応
            presentAnnotation()
        }
    }
    // チュートリアル対応
    func presentAnnotation() {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Annotation_WorkSheet") as! AnnotationViewController
        viewController.alpha = 0.5
        present(viewController, animated: true, completion: nil)
    }
    
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
        // 更新処理
        self.TableView_WS.reloadData()
        // クルクルを止める
        TableView_WS.refreshControl?.endRefreshing()
    }
    //セルの数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let databaseManagerSettings = DatabaseManagerSettingsTaxonomyAccount()
        let objects = databaseManagerSettings.getSettingsTaxonomyAccountAdjustingSwitch(AdjustingAndClosingEntries: false, switching: true)
        let objectss = databaseManagerSettings.getSettingsTaxonomyAccountAdjustingSwitch(AdjustingAndClosingEntries: true, switching: true)

        return objects.count + 1 + objectss.count + 1 + 1  //+ 試算表合計の行の分+修正記入の行の分+当期純利益+修正記入、損益計算書、貸借対照表の合計の分
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let databaseManagerSettings = DatabaseManagerSettingsTaxonomyAccount()
        let objects = databaseManagerSettings.getSettingsTaxonomyAccountAdjustingSwitch(AdjustingAndClosingEntries: false, switching: true) //期中の仕訳の勘定科目を取得
        let objectss = databaseManagerSettings.getSettingsTaxonomyAccountAdjustingSwitch(AdjustingAndClosingEntries: true, switching: true) //修正記入の勘定科目を取得
        let databaseManager = DataBaseManagerTB()
        // セル　決算整理前残高試算表の行
        if indexPath.row < objects.count {
            //① UI部品を指定
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell_WS", for: indexPath) as! TableViewCellWS
            // 勘定科目をセルに表示する
            cell.label_account.text = "\(objects[indexPath.row].category as String)"
            cell.label_account.textAlignment = NSTextAlignment.center
            // 決算整理前残高試算表
            cell.label_debit.text = setComma(amount:databaseManager.getTotalAmount(account: "\(objects[indexPath.row].category as String)", leftOrRight: 2))
            cell.label_debit.textAlignment = NSTextAlignment.right
            cell.label_credit.text = setComma(amount:databaseManager.getTotalAmount(account: "\(objects[indexPath.row].category as String)", leftOrRight: 3))
            cell.label_credit.textAlignment = NSTextAlignment.right
            cell.label_debit.backgroundColor = .clear
            cell.label_credit.backgroundColor = .clear
            switch Int(objects[indexPath.row].Rank0) {
            case 0,1,2,3,4,5,12: //大分類　貸借対照表：0,1,2
                // 修正記入
                cell.label_debit1.text = setComma(amount:databaseManager.getTotalAmountAdjusting(account: "\(objects[indexPath.row].category as String)", leftOrRight: 0))
                cell.label_debit1.textAlignment = NSTextAlignment.right
                cell.label_credit1.text = setComma(amount:databaseManager.getTotalAmountAdjusting(account: "\(objects[indexPath.row].category as String)", leftOrRight: 1))
                cell.label_credit1.textAlignment = NSTextAlignment.right
                cell.label_debit1.backgroundColor = .clear
                cell.label_credit1.backgroundColor = .clear
                // 損益計算書
                cell.label_debit2.text = ""
                cell.label_credit2.text = ""
                cell.label_debit2.backgroundColor = .lightGray
                cell.label_credit2.backgroundColor = .lightGray
                // 貸借対照表 修正記入の分を差し引きして、表示する　DataBaseManagerWSを作成して処理を記述する
                cell.label_debit3.text = setComma(amount:databaseManager.getTotalAmountAfterAdjusting(account: "\(objects[indexPath.row].category as String)", leftOrRight: 2))
                cell.label_debit3.textAlignment = NSTextAlignment.right
                cell.label_credit3.text = setComma(amount:databaseManager.getTotalAmountAfterAdjusting(account: "\(objects[indexPath.row].category as String)", leftOrRight: 3))
                cell.label_credit3.textAlignment = NSTextAlignment.right
                cell.label_debit3.backgroundColor = .clear
                cell.label_credit3.backgroundColor = .clear
            case 6,7,8,9,10,11: //大分類 損益計算書：3,4
                // 修正記入
                cell.label_debit1.text = setComma(amount:databaseManager.getTotalAmountAdjusting(account: "\(objects[indexPath.row].category as String)", leftOrRight: 0))
                cell.label_debit1.textAlignment = NSTextAlignment.right
                cell.label_credit1.text = setComma(amount:databaseManager.getTotalAmountAdjusting(account: "\(objects[indexPath.row].category as String)", leftOrRight: 1))
                cell.label_credit1.textAlignment = NSTextAlignment.right
                cell.label_debit1.backgroundColor = .clear
                cell.label_credit1.backgroundColor = .clear
                // 損益計算書
                cell.label_debit2.text = setComma(amount:databaseManager.getTotalAmountAfterAdjusting(account: "\(objects[indexPath.row].category as String)", leftOrRight: 2))
                cell.label_debit2.textAlignment = NSTextAlignment.right
                cell.label_credit2.text = setComma(amount:databaseManager.getTotalAmountAfterAdjusting(account: "\(objects[indexPath.row].category as String)", leftOrRight: 3))
                cell.label_credit2.textAlignment = NSTextAlignment.right
                cell.label_debit2.backgroundColor = .clear
                cell.label_credit2.backgroundColor = .clear
                // 貸借対照表
                cell.label_debit3.text = ""
                cell.label_credit3.text = ""
                cell.label_debit3.backgroundColor = .lightGray
                cell.label_credit3.backgroundColor = .lightGray
            default: //大分類　貸借対照表：0,1,2 損益計算書：3,4
                print("a")
            }
            return cell
        }else if indexPath.row == objects.count { // セル　試算表の合計の行
            let dataBaseManagerFinancialStatements = DataBaseManagerFinancialStatements()
            let object = dataBaseManagerFinancialStatements.getFinancialStatements()
            //① UI部品を指定
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell_WS_total", for: indexPath) as! TableViewCellWS
            cell.label_account.text = ""
            // 決算整理前残高試算表
            cell.label_debit.text = setComma(amount:object.compoundTrialBalance!.debit_balance_total)
            cell.label_credit.text = setComma(amount:object.compoundTrialBalance!.credit_balance_total)
            return cell
        }else if indexPath.row < objects.count + 1 + objectss.count { // セル　修正記入の行
            //① UI部品を指定
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell_WS", for: indexPath) as! TableViewCellWS
            // 勘定科目をセルに表示する
            cell.label_account.text = "\(objectss[indexPath.row-(objects.count + 1)].category as String)"
            cell.label_account.textAlignment = NSTextAlignment.center
            // 決算整理前残高試算表
            cell.label_debit.text = ""
            cell.label_credit.text = ""
            cell.label_debit.backgroundColor = .lightGray
            cell.label_credit.backgroundColor = .lightGray
            switch Int(objectss[indexPath.row-(objects.count + 1)].Rank2) {
            case 0,1,2,3,4,5,12: //大分類　貸借対照表：0,1,2
                // 修正記入
                cell.label_debit1.text = setComma(amount:databaseManager.getTotalAmountAdjusting(account: "\(objectss[indexPath.row-(objects.count + 1)].category as String)", leftOrRight: 0))
                cell.label_debit1.textAlignment = NSTextAlignment.right
                cell.label_credit1.text = setComma(amount:databaseManager.getTotalAmountAdjusting(account: "\(objectss[indexPath.row-(objects.count + 1)].category as String)", leftOrRight: 1))
                cell.label_credit1.textAlignment = NSTextAlignment.right
                cell.label_debit1.backgroundColor = .clear
                cell.label_credit1.backgroundColor = .clear
                // 損益計算書
                cell.label_debit2.text = ""
                cell.label_credit2.text = ""
                cell.label_debit2.backgroundColor = .clear
                cell.label_credit2.backgroundColor = .clear
                // 貸借対照表
                cell.label_debit3.text = setComma(amount:databaseManager.getTotalAmountAdjusting(account: "\(objectss[indexPath.row-(objects.count + 1)].category as String)", leftOrRight: 2))
                cell.label_debit3.textAlignment = NSTextAlignment.right
                cell.label_credit3.text = setComma(amount:databaseManager.getTotalAmountAdjusting(account: "\(objectss[indexPath.row-(objects.count + 1)].category as String)", leftOrRight: 3))
                cell.label_credit3.textAlignment = NSTextAlignment.right
                cell.label_debit3.backgroundColor = .clear
                cell.label_credit3.backgroundColor = .clear
            case 6,7,8,9,10,11: //大分類 損益計算書：3,4
                // 修正記入
                cell.label_debit1.text = setComma(amount:databaseManager.getTotalAmountAdjusting(account: "\(objectss[indexPath.row-(objects.count + 1)].category as String)", leftOrRight: 0))
                cell.label_debit1.textAlignment = NSTextAlignment.right
                cell.label_credit1.text = setComma(amount:databaseManager.getTotalAmountAdjusting(account: "\(objectss[indexPath.row-(objects.count + 1)].category as String)", leftOrRight: 1))
                cell.label_credit1.textAlignment = NSTextAlignment.right
                cell.label_debit1.backgroundColor = .clear
                cell.label_credit1.backgroundColor = .clear
                // 損益計算書
                cell.label_debit2.text = setComma(amount:databaseManager.getTotalAmountAdjusting(account: "\(objectss[indexPath.row-(objects.count + 1)].category as String)", leftOrRight: 2))
                cell.label_debit2.textAlignment = NSTextAlignment.right
                cell.label_credit2.text = setComma(amount:databaseManager.getTotalAmountAdjusting(account: "\(objectss[indexPath.row-(objects.count + 1)].category as String)", leftOrRight: 3))
                cell.label_credit2.textAlignment = NSTextAlignment.right
                cell.label_debit2.backgroundColor = .clear
                cell.label_credit2.backgroundColor = .clear
                // 貸借対照表
                cell.label_debit3.text = ""
                cell.label_credit3.text = ""
                cell.label_debit3.backgroundColor = .clear
                cell.label_credit3.backgroundColor = .clear
            default: //大分類　貸借対照表：0,1,2 損益計算書：3,4
                print("aa")
            }
            return cell
        }else if indexPath.row < objects.count + 1 + objectss.count + 1  { // セル　当期純利益の行
            let dataBaseManagerFinancialStatements = DataBaseManagerFinancialStatements()
            let object = dataBaseManagerFinancialStatements.getFinancialStatements()
            //① UI部品を指定
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell_WS", for: indexPath) as! TableViewCellWS
            // 勘定科目をセルに表示する
            cell.label_account.text = "当期純利益"
            cell.label_account.textAlignment = NSTextAlignment.center
            // 決算整理前残高試算表
            cell.label_debit.text = ""
            cell.label_credit.text = ""
            cell.label_debit.backgroundColor = .lightGray
            cell.label_credit.backgroundColor = .lightGray
            // 修正記入
            cell.label_debit1.text = ""
            cell.label_credit1.text = ""
            cell.label_debit1.backgroundColor = .clear
            cell.label_credit1.backgroundColor = .clear
            // 損益計算書
            cell.label_debit2.text = setCommaWith0(amount: object.workSheet!.netIncomeOrNetLossLoss)//0でも空白にしない
            cell.label_debit2.textAlignment = NSTextAlignment.right
            cell.label_credit2.text = setCommaWith0(amount: object.workSheet!.netIncomeOrNetLossIncome)//0でも空白にしない
            cell.label_credit2.textAlignment = NSTextAlignment.right
            cell.label_debit2.backgroundColor = .clear
            cell.label_credit2.backgroundColor = .clear
            // 貸借対照表
            cell.label_debit3.text = setCommaWith0(amount: object.workSheet!.netIncomeOrNetLossIncome)//0でも空白にしない //損益計算書とは反対の方に記入する//0でも空白にしない
            cell.label_debit3.textAlignment = NSTextAlignment.right
            cell.label_credit3.text = setCommaWith0(amount: object.workSheet!.netIncomeOrNetLossLoss)//0でも空白にしない //損益計算書とは反対の方に記入する//0でも空白にしない
            cell.label_credit3.textAlignment = NSTextAlignment.right
            cell.label_debit3.backgroundColor = .clear
            cell.label_credit3.backgroundColor = .clear
            return cell
        }else if indexPath.row < objects.count + 1 + objectss.count + 1 + 1 { // セル　修正記入と損益計算書、貸借対照表の合計の行
            let dataBaseManagerFinancialStatements = DataBaseManagerFinancialStatements()
            let object = dataBaseManagerFinancialStatements.getFinancialStatements()
            //① UI部品を指定
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell_WS_total_2", for: indexPath) as! TableViewCellWS
            cell.label_account.text = ""
            // 決算整理前残高試算表
            cell.label_debit.text = ""
            cell.label_credit.text = ""
            cell.label_debit.backgroundColor = .lightGray
            cell.label_credit.backgroundColor = .lightGray
            // 修正記入
            cell.label_debit1.text = setComma(amount:object.workSheet!.debit_adjustingEntries_balance_total)
            cell.label_debit1.textAlignment = NSTextAlignment.right
            cell.label_credit1.text = setComma(amount:object.workSheet!.credit_adjustingEntries_balance_total)
            cell.label_credit1.textAlignment = NSTextAlignment.right
            // 借方貸方の金額が不一致の場合、文字色を赤
            if cell.label_debit1.text != cell.label_credit1.text {
                cell.label_debit1.textColor = .red
                cell.label_credit1.textColor = .red
            }
            // 損益計算書
            cell.label_debit2.text = setComma(amount:object.workSheet!.debit_PL_balance_total+object.workSheet!.netIncomeOrNetLossLoss)// 当期純利益と合計借方とを足す
            cell.label_debit2.textAlignment = NSTextAlignment.right
            cell.label_credit2.text = setComma(amount:object.workSheet!.credit_PL_balance_total+object.workSheet!.netIncomeOrNetLossIncome)// 当期純損失と合計貸方とを足す
            cell.label_credit2.textAlignment = NSTextAlignment.right
            // 借方貸方の金額が不一致の場合、文字色を赤
            if cell.label_debit2.text != cell.label_credit2.text {
                cell.label_debit2.textColor = .red
                cell.label_credit2.textColor = .red
            }
            // 貸借対照表
            cell.label_debit3.text = setComma(amount:object.workSheet!.debit_BS_balance_total+object.workSheet!.netIncomeOrNetLossIncome) //損益計算書とは反対の方に記入する
            cell.label_debit3.textAlignment = NSTextAlignment.right
            cell.label_credit3.text = setComma(amount:object.workSheet!.credit_BS_balance_total+object.workSheet!.netIncomeOrNetLossLoss) //損益計算書とは反対の方に記入する
            cell.label_credit3.textAlignment = NSTextAlignment.right
            // 借方貸方の金額が不一致の場合、文字色を赤
            if cell.label_debit3.text != cell.label_credit3.text {
                cell.label_debit3.textColor = .red
                cell.label_credit3.textColor = .red
            }
            return cell
        }
        return tableView.dequeueReusableCell(withIdentifier: "cell_WS", for: indexPath) as! TableViewCellWS
    }
    // 画面遷移の準備　勘定科目画面
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // segue.destinationの型はUIViewController
        let controller = segue.destination as! ViewControllerJournalEntry
        // 遷移先のコントローラに値を渡す
        controller.journalEntryType = "AdjustingAndClosingEntries" // セルに表示した仕訳タイプを取得
    }
    // コンマを追加
    func setComma(amount: Int64) -> String {
        //3桁ごとにカンマ区切りするフォーマット
        formatter.numberStyle = NumberFormatter.Style.decimal
        formatter.groupingSeparator = ","
        formatter.groupingSize = 3
        if addComma(string: amount.description) == "0" { //0の場合は、空白を表示する
            return ""
        }else {
            return addComma(string: amount.description)
        }
    }
    //カンマ区切りに変換（表示用）
    let formatter = NumberFormatter() // プロパティの設定はcreateTextFieldForAmountで行う
    func addComma(string :String) -> String{
        if(string != "") { // ありえないでしょう
            let string = removeComma(string: string) // カンマを削除してから、カンマを追加する処理を実行する
            return formatter.string(from: NSNumber(value: Double(string)!))!
        }else{
            return ""
        }
    }
    //カンマ区切りを削除（計算用）
    func removeComma(string :String) -> String{
        let string = string.replacingOccurrences(of: ",", with: "")
        return string
    }
    // コンマを追加
    func setCommaWith0(amount: Int64) -> String {
        //3桁ごとにカンマ区切りするフォーマット
        formatter.numberStyle = NumberFormatter.Style.decimal
        formatter.groupingSeparator = ","
        formatter.groupingSize = 3
        return addComma(string: amount.description)
    }

    var printing: Bool = false // プリント機能を使用中のみたてるフラグ　true:セクションをテーブルの先頭行に固定させない。描画時にセクションが重複してしまうため。
    // disable sticky section header
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if printing {
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) // ここがポイント。画面表示用にインセットを設定した、ステータスバーとナビゲーションバーの高さの分をリセットするために0を設定する。
            // スクロールのオフセットがヘッダー部分のビューとステータスバーの高さ以上　かつ　0以上
            if scrollView.contentOffset.y >= view_top.bounds.height+UIApplication.shared.statusBarFrame.height && scrollView.contentOffset.y >= 0 {
                scrollView.contentInset = UIEdgeInsets(top: -(view_top.bounds.height+UIApplication.shared.statusBarFrame.height+TableView_WS.sectionHeaderHeight), left: 0, bottom: 0, right: 0)
            }
        }else{
            // インセットを設定する　ステータスバーとナビゲーションバーより下からテーブルビューを配置するため
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    var pageSize = CGSize(width: 210 / 25.4 * 72, height: 297 / 25.4 * 72)
    // 精算表画面で押下された場合は、決算整理仕訳とする
    @IBOutlet weak var barButtonItem_add: UIBarButtonItem!//ヘッダー部分の追加ボタン
    @IBOutlet var button_print: UIButton!
    /**
     * 印刷ボタン押下時メソッド
     */
    @IBAction func button_print(_ sender: UIButton) {
        let indexPath = TableView_WS.indexPathsForVisibleRows // テーブル上で見えているセルを取得する
        print("TableView_WS.indexPathsForVisibleRows: \(String(describing: indexPath))")
//        self.TableView_TB.scrollToRow(at: indexPath![0], at: UITableView.ScrollPosition.bottom, animated: false)
        self.TableView_WS.scrollToRow(at: IndexPath(row: indexPath!.count-1, section: 0), at: UITableView.ScrollPosition.bottom, animated: false)// 一度最下行までレイアウトを描画させる
        printing = true
        gADBannerView.isHidden = true
        self.TableView_WS.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableView.ScrollPosition.bottom, animated: false) //ビットマップコンテキストに描画後、画面上のTableViewを先頭にスクロールする

        // 第三の方法
        //余計なUIをキャプチャしないように隠す
        TableView_WS.showsVerticalScrollIndicator = false
        if let tappedIndexPath: IndexPath = self.TableView_WS.indexPathForSelectedRow { // タップされたセルの位置を取得
            TableView_WS.deselectRow(at: tappedIndexPath, animated: true)// セルの選択を解除
        }
//            pageSize = CGSize(width: 210 / 25.4 * 72, height: 297 / 25.4 * 72)//実際印刷用紙サイズ937x1452ピクセル
//        pageSize = CGSize(width: TableView_TB.contentSize.width / 25.4 * 72, height: TableView_TB.contentSize.height / 25.4 * 72)
        pageSize = CGSize(width: 210 / 25.4 * 72, height: 297 / 25.4 * 72)//実際印刷用紙サイズ937x1452ピクセル
        print("TableView_WS.contentSize:\(TableView_WS.contentSize)")
        //viewと同じサイズのコンテキスト（オフスクリーンバッファ）を作成
//        var rect = self.view.bounds
        //p-41 「ビットマップグラフィックスコンテキストを使って新しい画像を生成」
        //1. UIGraphicsBeginImageContextWithOptions関数でビットマップコンテキストを生成し、グラフィックススタックにプッシュします。
        UIGraphicsBeginImageContextWithOptions(pageSize, true, 0.0)
            //2. UIKitまたはCore Graphicsのルーチンを使って、新たに生成したグラフィックスコンテキストに画像を描画します。
//        imageRect.draw(in: CGRect(origin: .zero, size: pageSize))
            //3. UIGraphicsGetImageFromCurrentImageContext関数を呼び出すと、描画した画像に基づく UIImageオブジェクトが生成され、返されます。必要ならば、さらに描画した上で再びこのメソッ ドを呼び出し、別の画像を生成することも可能です。
        //p-43 リスト 3-1 縮小画像をビットマップコンテキストに描画し、その結果の画像を取得する
//        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        let newImage = self.TableView_WS.captureImagee()
        //4. UIGraphicsEndImageContextを呼び出してグラフィックススタックからコンテキストをポップします。
        UIGraphicsEndImageContext()
        printing = false
        gADBannerView.isHidden = false
        self.TableView_WS.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableView.ScrollPosition.bottom, animated: false)// 元の位置に戻す //ビットマップコンテキストに描画後、画面上のTableViewを先頭にスクロールする
        /*
        ビットマップグラフィックスコンテキストでの描画全体にCore Graphicsを使用する場合は、
         CGBitmapContextCreate関数を使用して、コンテキストを作成し、
         それに画像コンテンツを描画します。
         描画が完了したら、CGBitmapContextCreateImage関数を使用し、そのビットマップコンテキストからCGImageRefを作成します。
         Core Graphicsの画像を直接描画したり、この画像を使用して UIImageオブジェクトを初期化することができます。
         完了したら、グラフィックスコンテキストに対 してCGContextRelease関数を呼び出します。
        */
        let myImageView = UIImageView(image: newImage)
        myImageView.layer.position = CGPoint(x: self.view.frame.midY, y: self.view.frame.midY)
        
//PDF
        //p-49 リスト 4-2 ページ単位のコンテンツの描画
            let framePath = NSMutableData()
        //p-45 「PDFコンテキストの作成と設定」
            // PDFグラフィックスコンテキストは、UIGraphicsBeginPDFContextToData関数、
            //  または UIGraphicsBeginPDFContextToFile関数のいずれかを使用して作成します。
            //  UIGraphicsBeginPDFContextToData関数の場合、
            //  保存先はこの関数に渡される NSMutableDataオブジェクトです。
            UIGraphicsBeginPDFContextToData(framePath, myImageView.bounds, nil)
        print(" myImageView.bounds : \(myImageView.bounds)")
        //p-46 「UIGraphicsBeginPDFPage関数は、デフォルトのサイズを使用してページを作成します。」
//            UIGraphicsBeginPDFPage()
//        UIGraphicsBeginPDFPageWithInfo(CGRect(x:0, y:0, width:myImageView.bounds.width, height:myImageView.bounds.width*1.414516129), nil) //高さはA4コピー用紙と同じ比率にするために、幅×1.414516129とする

         /* PDFページの描画
           UIGraphicsBeginPDFPageは、デフォルトのサイズを使用して新しいページを作成します。一方、
           UIGraphicsBeginPDFPageWithInfo関数を利用す ると、ページサイズや、PDFページのその他の属性をカスタマイズできます。
        */
        //p-49 「リスト 4-2 ページ単位のコンテンツの描画」
            // グラフィックスコンテキストを取得する
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
            printInfo.jobName = "Work Sheet"
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
        TableView_WS.showsVerticalScrollIndicator = true
        self.TableView_WS.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableView.ScrollPosition.bottom, animated: false) // 元の位置に戻す
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

