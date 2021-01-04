//
//  TableViewControllerJournals.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/03/20.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import UIKit
import GoogleMobileAds // マネタイズ対応

// 仕訳帳クラス
class TableViewControllerJournals: UITableViewController, UIGestureRecognizerDelegate, UIPrintInteractionControllerDelegate {
    
    // マネタイズ対応
    // 広告ユニットID
    let AdMobID = "ca-app-pub-7616440336243237/8565070944"
    // テスト用広告ユニットID
    let TEST_ID = "ca-app-pub-3940256099942544/2934735716"
    // true:テスト
    let AdMobTest:Bool = true
    @IBOutlet var gADBannerView: GADBannerView!
    
    @IBOutlet var TableView_JournalEntry: UITableView! // アウトレット接続 Referencing Outlets が接続されていないとnilとなるので注意
    @IBOutlet weak var label_company_name: UILabel!
    @IBOutlet weak var label_title: UILabel!
    @IBOutlet weak var label_closingDate: UILabel!
    @IBOutlet var Label_list_date_year: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 更新機能　編集機能
        // UILongPressGestureRecognizer宣言
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(cellLongPressed))// 正解: Selector("somefunctionWithSender:forEvent:") → うまくできなかった。2020/07/26
        // `UIGestureRecognizerDelegate`を設定するのをお忘れなく
        longPressRecognizer.delegate = self
        // tableViewにrecognizerを設定
        tableView.addGestureRecognizer(longPressRecognizer)
//        // アプリ初期化 初期表示画面を仕訳画面に変更したため、初期化処理も移動　2020/12/01
//        let initial = Initial()
//        initial.initialize()
        // 初期表示位置
//        scroll = true
        //3桁ごとにカンマ区切りするフォーマット
        formatter.numberStyle = NumberFormatter.Style.decimal
        formatter.groupingSeparator = ","
        formatter.groupingSize = 3
        // リロード機能
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: Selector(("refreshTable")), for: UIControl.Event.valueChanged)
        self.refreshControl = refreshControl
    }
    // ビューが表示される直前に呼ばれる
    override func viewWillAppear(_ animated: Bool){
    //通常、このメソッドは遷移先のViewController(仕訳画面)から戻る際には呼ばれないので、遷移先のdismiss()のクロージャにこのメソッドを指定する
//        presentingViewController?.beginAppearanceTransition(false, animated: animated)
        super.viewWillAppear(animated)
        // UIViewControllerの表示画面を更新・リロード
//        self.loadView() // エラー発生　2020/07/31　Thread 1: EXC_BAD_ACCESS (code=1, address=0x600022903198)
        self.tableView.reloadData() // エラーが発生しないか心配
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
        }else {
            label_closingDate.text = String(fiscalYear+1) + "年\(object.prefix(2))月\(object.suffix(2))日" // 決算日を表示する
        }
        label_title.text = "仕訳帳"
        // データベース　注意：Initialより後に記述する
        Label_list_date_year.text = fiscalYear.description + "年"
        // 仕訳データが0件の場合、印刷ボタンを不活性にする
        // 空白行対応
        let dataBaseManagerAccount = DataBaseManagerAccount()
        let objects = dataBaseManagerAccount.getJournalEntryAll() // 通常仕訳　全
        let objectss = dataBaseManagerAccount.getAdjustingEntryAll() // 決算整理仕訳　全
        if objects.count + objectss.count >= 1 {
            button_print.isEnabled = true
        }else {
            button_print.isEnabled = false
        }
        // 仕訳帳画面を表示する際に、インセットを設定する。top: ステータスバーとナビゲーションバーの高さより下からテーブルを描画するため
        tableView.contentInset = UIEdgeInsets(top: +(view_top.bounds.height+UIApplication.shared.statusBarFrame.height+self.navigationController!.navigationBar.bounds.height), left: 0, bottom: 0, right: 0)
        // 要素数が少ないUITableViewで残りの部分や余白を消す
        let tableFooterView = UIView(frame: CGRect.zero)
        tableView.tableFooterView = tableFooterView
        // マネタイズ対応　注意：viewDidLoad()ではなく、viewWillAppear()に実装すること
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
    // ビューが表示された後に呼ばれる
    override func viewDidAppear(_ animated: Bool){
        // 初期表示位置 OFF
        scroll = false
        let indexPath = tableView.indexPathsForVisibleRows // テーブル上で見えているセルを取得する
        print("tableView.indexPathsForVisibleRows: \(String(describing: indexPath))")
        // テーブルをスクロールさせる。scrollViewDidScrollメソッドを呼び出して、インセットの設定を行うため。
        if indexPath != nil && indexPath!.count > 0 {
            self.tableView.scrollToRow(at: indexPath![indexPath!.count-1], at: UITableView.ScrollPosition.bottom, animated: false) //最下行
            self.tableView.scrollToRow(at: indexPath![0], at: UITableView.ScrollPosition.bottom, animated: false) //最上行
            // タグを設定する　チュートリアル対応
            tableView.visibleCells[0].tag = 33
            // チュートリアル対応　初回起動時　7行を追加
            let ud = UserDefaults.standard
            let firstLunchKey = "firstLunch_Journals"
            if ud.bool(forKey: firstLunchKey) {
                ud.set(false, forKey: firstLunchKey)
                ud.synchronize()
                // チュートリアル対応
                presentAnnotation()
            }
        }
    }
    // チュートリアル対応
    func presentAnnotation() {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Annotation_Journals") as! AnnotationViewControllerJournals
        viewController.alpha = 0.5
        present(viewController, animated: true, completion: nil)
    }
    // リロード機能
    @objc func refreshTable() {
        // 全勘定の合計と残高を計算する　注意：決算日設定機能で決算日を変更後に損益勘定と繰越利益の日付を更新するために必要な処理である
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
    // 編集機能　長押しした際に呼ばれるメソッド
    @objc func cellLongPressed(recognizer: UILongPressGestureRecognizer) {
        // 押された位置でcellのPathを取得
        let point = recognizer.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        if indexPath?.section == 1 {
            print("空白行を長押し")
        }else {
            if indexPath == nil {
                
            } else if recognizer.state == UIGestureRecognizer.State.began  {
                // 長押しされた場合の処理
                print("長押しされたcellのindexPath:\(String(describing: indexPath?.row))")
                // ロングタップされたセルの位置をフィールドで保持する
                self.tappedIndexPath = indexPath
                // 別の画面に遷移 仕訳画面
                performSegue(withIdentifier: "longTapped", sender: nil)
            }
        }
    }
    // 追加機能　画面遷移の準備の前に入力検証
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        //画面のことをScene（シーン）と呼ぶ。 セグエとは、シーンとシーンを接続し画面遷移を行うための部品である。
        if identifier == "longTapped" { // segueがタップ
            if self.tappedIndexPath != nil { // ロングタップの場合はセルの位置情報を代入しているのでnilではない
                if let _:IndexPath = self.tappedIndexPath { //代入に成功したら、ロングタップだと判断できる
                    return true //true: 画面遷移させる
                }
            }
        }else if identifier == "buttonTapped" {
            return true
        }
        return false //false:画面遷移させない
    }
    // 追加機能　画面遷移の準備　勘定科目画面
    var tappedIndexPath: IndexPath?
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // segue.destinationの型はUIViewController
        let controller = segue.destination as! ViewControllerJournalEntry
        // 遷移先のコントローラに値を渡す
        if segue.identifier == "buttonTapped" {
            controller.journalEntryType = "JournalEntries" // セルに表示した仕訳タイプを取得
        }else if segue.identifier == "longTapped" {
            if tappedIndexPath != nil { // nil:ロングタップではない
                controller.journalEntryType = "JournalEntriesFixing" // セルに表示した仕訳タイプを取得
                controller.tappedIndexPath = self.tappedIndexPath!//アンラップ // ロングタップされたセルの位置をフィールドで保持したものを使用
                self.tappedIndexPath = nil // 一度、画面遷移を行なったらセル位置の情報が残るのでリセットする
            }
        }
    }
    
    // MARK: - Table view data source

    // スクロール
    var Number = 0
    func autoScroll(number: Int) {
        // TabBarControllerから遷移してきした時のみ、テーブルビューの更新と初期表示位置を指定
        scroll_adding = true
        Number = number
        // 仕訳入力後に仕訳帳を更新する
        TableView_JournalEntry.reloadData()
    }
    // セクションの数を設定する
    override func numberOfSections(in tableView: UITableView) -> Int {
        // 空白行対応
        let dataBaseManagerAccount = DataBaseManagerAccount()
        let objects = dataBaseManagerAccount.getJournalEntryAll() // 通常仕訳　全
        let objectss = dataBaseManagerAccount.getAdjustingEntryAll() // 決算整理仕訳　全
        if objects.count + objectss.count <= 12 {
            return 2 // 空白行を表示するためセクションを1つ追加
        }else {
            return 1     // セクションの数はreturn 12 で 12ヶ月分に設定します。
        }
    }
    //セルの数を、モデル(仕訳)の数に指定
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // データベース
        let dataBaseManager = DataBaseManagerJournalEntry()
        let objects = dataBaseManager.getJournalEntry(section: section) // 通常仕訳
        // 設定操作
        let dataBaseManagerSettingsOperating = DataBaseManagerSettingsOperating()
        let object = dataBaseManagerSettingsOperating.getSettingsOperating()
        let objectss = dataBaseManager.getJournalAdjustingEntry(section: section, EnglishFromOfClosingTheLedger0: object!.EnglishFromOfClosingTheLedger0, EnglishFromOfClosingTheLedger1: object!.EnglishFromOfClosingTheLedger1) // 決算整理仕訳 損益振替仕訳 資本振替仕訳
        // 空白行対応
        if section == 1 { // 空白行
            let dataBaseManagerAccount = DataBaseManagerAccount()
            let objects = dataBaseManagerAccount.getJournalEntryAll() // 通常仕訳　全
            let objectss = dataBaseManagerAccount.getAdjustingEntryAll() // 決算整理仕訳　全
            if objects.count + objectss.count <= 20 {
                return 20 - (objects.count + objectss.count) // 空白行を表示するため30行に満たない不足分を追加
            }else {
                return 0 // 8件以上ある場合　不足分は0
            }
        }else {
            return objects.count + objectss.count //月別の仕訳データ数
        }
    }
    //セルを生成して返却するメソッド
    var indexPathForAutoScroll: IndexPath = IndexPath(row: 0, section: 0)
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 { // 空白行
            //① UI部品を指定　TableViewCell
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell_list_journalEntry", for: indexPath) as! TableViewCellJournals
            cell.backgroundColor = .white // 目印を消す
            cell.label_list_date_month.text = ""    // 「月」注意：空白を代入しないと、変な値が入る。
            cell.label_list_date.text = ""     // 末尾2文字の「日」         //日付
            cell.label_list_summary_debit.text = ""     //借方勘定
            cell.label_list_summary_credit.text = ""   //貸方勘定
            cell.label_list_summary.text = ""      //小書き
            cell.label_list_number_left.text = ""       // 丁数
            cell.label_list_number_right.text = ""
            cell.label_list_debit.text = ""        //借方金額 注意：空白を代入しないと、変な値が入る。
            cell.label_list_credit.text = ""       //貸方金額
            // セルの選択不可にする
//            cell.selectionStyle = .none
            return cell
        }else { // 空白行ではない場合
            //① UI部品を指定　TableViewCell
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell_list_journalEntry", for: indexPath) as! TableViewCellJournals
            
            let dataBaseManager = DataBaseManagerJournalEntry()
            let objects = dataBaseManager.getJournalEntry(section: indexPath.section)
            
            if indexPath.row >= objects.count { // 決算整理仕訳
                // 設定操作
                let dataBaseManagerSettingsOperating = DataBaseManagerSettingsOperating()
                let object = dataBaseManagerSettingsOperating.getSettingsOperating()
                let objectss = dataBaseManager.getJournalAdjustingEntry(section: indexPath.section, EnglishFromOfClosingTheLedger0: object!.EnglishFromOfClosingTheLedger0, EnglishFromOfClosingTheLedger1: object!.EnglishFromOfClosingTheLedger1) // 決算整理仕訳 損益振替仕訳 資本振替仕訳
                cell.backgroundColor = .lightGray // 目印
                //② todo 借方の場合は左寄せ、貸方の場合は右寄せ。小書きは左寄せ。
                // メソッドの引数 indexPath の変数 row には、セルのインデックス番号が設定されています。インデックス指定に利用する。
                if Number == objectss[indexPath.row-objects.count].number { // 自動スクロール　入力ボタン押下時の戻り値と　仕訳番号が一致した場合
                    indexPathForAutoScroll = indexPath                              // セルの位置　を覚えておく
                }
                let d = "\(objectss[indexPath.row-objects.count].date)" // 日付
                // 月別のセクションのうち、日付が一番古いものに月欄に月を表示し、それ以降は空白とする。
                if indexPath.section == 0 {
                    if indexPath.row > 0 {
                        if indexPath.row-objects.count > 0 { // 二行目以降は月の先頭のみ、月を表示する
                            // 一行上のセルに表示した月とこの行の月を比較する
                            let upperCellMonth = "\(objectss[indexPath.row-objects.count - 1].date)" // 日付
                            let dateMonth = d[d.index(d.startIndex, offsetBy: 5)..<d.index(d.startIndex, offsetBy: 6)] // 日付の6文字目にある月の十の位を抽出
                            if dateMonth == "0" { // 日の十の位が0の場合は表示しない
                                if upperCellMonth[upperCellMonth.index(upperCellMonth.startIndex, offsetBy: 5)..<upperCellMonth.index(upperCellMonth.startIndex, offsetBy: 7)] != "\(d[d.index(d.startIndex, offsetBy: 5)..<d.index(d.startIndex, offsetBy: 7)])" {
                                    cell.label_list_date_month.text = "\(d[d.index(d.startIndex, offsetBy: 6)..<d.index(d.startIndex, offsetBy: 7)])" // 「月」
                                }else{
                                    cell.label_list_date_month.text = "" // 注意：空白を代入しないと、変な値が入る。
                                }
                            }else{
                                if upperCellMonth[upperCellMonth.index(upperCellMonth.startIndex, offsetBy: 5)..<upperCellMonth.index(upperCellMonth.startIndex, offsetBy: 7)] != "\(d[d.index(d.startIndex, offsetBy: 5)..<d.index(d.startIndex, offsetBy: 7)])" {
                                    cell.label_list_date_month.text = "\(d[d.index(d.startIndex, offsetBy: 5)..<d.index(d.startIndex, offsetBy: 7)])" // 「月」
                                }else{
                                    cell.label_list_date_month.text = "" // 注意：空白を代入しないと、変な値が入る。
                                }
                            }
                        }else { // 先頭行は月を表示
                            let dateMonth = d[d.index(d.startIndex, offsetBy: 5)..<d.index(d.startIndex, offsetBy: 6)] // 日付の6文字目にある月の十の位を抽出
                            if dateMonth == "0" { // 日の十の位が0の場合は表示しない
                                cell.label_list_date_month.text = "\(d[d.index(d.startIndex, offsetBy: 6)..<d.index(d.startIndex, offsetBy: 7)])" // 「月」
                            }else{
                                cell.label_list_date_month.text = "\(d[d.index(d.startIndex, offsetBy: 5)..<d.index(d.startIndex, offsetBy: 7)])" // 「月」
                            }
                        }
                    }else { // 先頭行は月を表示
                        let dateMonth = d[d.index(d.startIndex, offsetBy: 5)..<d.index(d.startIndex, offsetBy: 6)] // 日付の6文字目にある月の十の位を抽出
                        if dateMonth == "0" { // 日の十の位が0の場合は表示しない
                            cell.label_list_date_month.text = "\(d[d.index(d.startIndex, offsetBy: 6)..<d.index(d.startIndex, offsetBy: 7)])" // 「月」
                        }else{
                            cell.label_list_date_month.text = "\(d[d.index(d.startIndex, offsetBy: 5)..<d.index(d.startIndex, offsetBy: 7)])" // 「月」
                        }
                    }
                }else{
                    cell.label_list_date_month.text = "" // 注意：空白を代入しないと、変な値が入る。
                }
                let date = d[d.index(d.startIndex, offsetBy: 8)..<d.index(d.startIndex, offsetBy: 9)] // 日付の9文字目にある日の十の位を抽出
                if date == "0" { // 日の十の位が0の場合は表示しない
                    cell.label_list_date.text = "\(objectss[indexPath.row-objects.count].date.suffix(1))" // 末尾1文字の「日」         //日付
                }else{
                    cell.label_list_date.text = "\(objectss[indexPath.row-objects.count].date.suffix(2))" // 末尾2文字の「日」         //日付
                }
                cell.label_list_date.textAlignment = NSTextAlignment.right
                cell.label_list_summary_debit.text = " (\(objectss[indexPath.row-objects.count].debit_category))"     //借方勘定
                cell.label_list_summary_debit.textAlignment = NSTextAlignment.left
                cell.label_list_summary_credit.text = "(\(objectss[indexPath.row-objects.count].credit_category)) "   //貸方勘定
                cell.label_list_summary_credit.textAlignment = NSTextAlignment.right
                cell.label_list_summary.text = "\(objectss[indexPath.row-objects.count].smallWritting) "              //小書き
                cell.label_list_summary.textAlignment = NSTextAlignment.left
                if objectss[indexPath.row-objects.count].debit_category == "損益勘定" { // 損益勘定の場合
                    cell.label_list_number_left.text = ""
                }else{
                    let numberOfAccount_left = dataBaseManager.getNumberOfAccount(accountName: "\(objectss[indexPath.row-objects.count].debit_category)")  // 丁数を取得 エラー2020/11/08
                    cell.label_list_number_left.text = numberOfAccount_left.description                                     // 丁数　借方
                }
                if objectss[indexPath.row-objects.count].credit_category == "損益勘定" { // 損益勘定の場合
                    cell.label_list_number_right.text = ""
                }else{
                    let numberOfAccount_right = dataBaseManager.getNumberOfAccount(accountName: "\(objectss[indexPath.row-objects.count].credit_category)")    // 丁数を取得　エラー2020/11/08
                    cell.label_list_number_right.text = numberOfAccount_right.description                                   // 丁数　貸方
                }
                cell.label_list_debit.text = "\(addComma(string: String(objectss[indexPath.row-objects.count].debit_amount))) "        //借方金額
                cell.label_list_credit.text = "\(addComma(string: String(objectss[indexPath.row-objects.count].credit_amount))) "      //貸方金額
                // セルの選択を許可
                cell.selectionStyle = .default
                return cell
            }else { // 通常仕訳
                //① UI部品を指定　TableViewCell
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell_list_journalEntry", for: indexPath) as! TableViewCellJournals
                cell.backgroundColor = .white // 目印を消す
                //② todo 借方の場合は左寄せ、貸方の場合は右寄せ。小書きは左寄せ。
                // メソッドの引数 indexPath の変数 row には、セルのインデックス番号が設定されています。インデックス指定に利用する。
                if Number == objects[indexPath.row].number { // 自動スクロール　入力ボタン押下時の戻り値と　仕訳番号が一致した場合
                    indexPathForAutoScroll = indexPath                              // セルの位置　を覚えておく
                }
                let d = "\(objects[indexPath.row].date)" // 日付
                // 月別のセクションのうち、日付が一番古いものに月欄に月を表示し、それ以降は空白とする。
                if indexPath.section == 0 {
                    if indexPath.row > 0 { // 二行目以降は月の先頭のみ、月を表示する
                        // 一行上のセルに表示した月とこの行の月を比較する
                        let upperCellMonth = "\(objects[indexPath.row - 1].date)" // 日付
                        let dateMonth = d[d.index(d.startIndex, offsetBy: 5)..<d.index(d.startIndex, offsetBy: 6)] // 日付の6文字目にある月の十の位を抽出
                        if dateMonth == "0" { // 日の十の位が0の場合は表示しない
                            if upperCellMonth[upperCellMonth.index(upperCellMonth.startIndex, offsetBy: 5)..<upperCellMonth.index(upperCellMonth.startIndex, offsetBy: 7)] != "\(d[d.index(d.startIndex, offsetBy: 5)..<d.index(d.startIndex, offsetBy: 7)])" {
                                cell.label_list_date_month.text = "\(d[d.index(d.startIndex, offsetBy: 6)..<d.index(d.startIndex, offsetBy: 7)])" // 「月」
                            }else{
                                cell.label_list_date_month.text = "" // 注意：空白を代入しないと、変な値が入る。
                            }
                        }else{
                            if upperCellMonth[upperCellMonth.index(upperCellMonth.startIndex, offsetBy: 5)..<upperCellMonth.index(upperCellMonth.startIndex, offsetBy: 7)] != "\(d[d.index(d.startIndex, offsetBy: 5)..<d.index(d.startIndex, offsetBy: 7)])" {
                                cell.label_list_date_month.text = "\(d[d.index(d.startIndex, offsetBy: 5)..<d.index(d.startIndex, offsetBy: 7)])" // 「月」
                            }else{
                                cell.label_list_date_month.text = "" // 注意：空白を代入しないと、変な値が入る。
                            }
                        }
                    }else { // 先頭行は月を表示
                        let dateMonth = d[d.index(d.startIndex, offsetBy: 5)..<d.index(d.startIndex, offsetBy: 6)] // 日付の6文字目にある月の十の位を抽出
                        if dateMonth == "0" { // 日の十の位が0の場合は表示しない
                            cell.label_list_date_month.text = "\(d[d.index(d.startIndex, offsetBy: 6)..<d.index(d.startIndex, offsetBy: 7)])" // 「月」
                        }else{
                            cell.label_list_date_month.text = "\(d[d.index(d.startIndex, offsetBy: 5)..<d.index(d.startIndex, offsetBy: 7)])" // 「月」
                        }
                    }
                }else{
                    cell.label_list_date_month.text = "" // 注意：空白を代入しないと、変な値が入る。
                }
                let date = d[d.index(d.startIndex, offsetBy: 8)..<d.index(d.startIndex, offsetBy: 9)] // 日付の9文字目にある日の十の位を抽出
                if date == "0" { // 日の十の位が0の場合は表示しない
                    cell.label_list_date.text = "\(objects[indexPath.row].date.suffix(1))" // 末尾1文字の「日」         //日付
                }else{
                    cell.label_list_date.text = "\(objects[indexPath.row].date.suffix(2))" // 末尾2文字の「日」         //日付
                }
                cell.label_list_date.textAlignment = NSTextAlignment.right
                cell.label_list_summary_debit.text = " (\(objects[indexPath.row].debit_category))"     //借方勘定
                cell.label_list_summary_debit.textAlignment = NSTextAlignment.left
                cell.label_list_summary_credit.text = "(\(objects[indexPath.row].credit_category)) "   //貸方勘定
                cell.label_list_summary_credit.textAlignment = NSTextAlignment.right
                cell.label_list_summary.text = "\(objects[indexPath.row].smallWritting) "              //小書き
                cell.label_list_summary.textAlignment = NSTextAlignment.left
                if objects[indexPath.row].debit_category == "損益勘定" { // 損益勘定の場合
                    cell.label_list_number_left.text = ""
                }else{
                    print(objects[indexPath.row].debit_category)
                    let numberOfAccount_left = dataBaseManager.getNumberOfAccount(accountName: "\(objects[indexPath.row].debit_category)")  // 丁数を取得
                    cell.label_list_number_left.text = numberOfAccount_left.description                                     // 丁数　借方
                }
                if objects[indexPath.row].credit_category == "損益勘定" { // 損益勘定の場合
                    cell.label_list_number_right.text = ""
                }else{
                    print(objects[indexPath.row].credit_category)
                    let numberOfAccount_right = dataBaseManager.getNumberOfAccount(accountName: "\(objects[indexPath.row].credit_category)")    // 丁数を取得
                    cell.label_list_number_right.text = numberOfAccount_right.description                                   // 丁数　貸方
                }
                cell.label_list_debit.text = "\(addComma(string: String(objects[indexPath.row].debit_amount))) "        //借方金額
                cell.label_list_credit.text = "\(addComma(string: String(objects[indexPath.row].credit_amount))) "      //貸方金額
                // セルの選択を許可
                cell.selectionStyle = .default
                return cell
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        switch indexPath.section {
            // 選択不可にしたい場合は"nil"を返す
        case 1:
                return nil
            default:
                return indexPath
        }
    }
    //カンマ区切りに変換（表示用）
    let formatter = NumberFormatter() // プロパティの設定はviewDidLoadで行う
    func addComma(string :String) -> String{
        if(string != "") { // ありえないでしょう
            return formatter.string(from: NSNumber(value: Double(string)!))!
        }else{
            return ""
        }
    }
    // セルが画面に表示される直前に表示される ※セルが0個の場合は呼び出されない
    var scroll = false   // flag 初回起動後かどうかを判定する (viewDidLoadでON, viewDidAppearでOFF)
    var scroll_adding = false   // flag 入力ボタン押下後かどうかを判定する (autoScrollでON, viewDidAppearでOFF)
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        var indexPath_local = IndexPath(row: 0, section: 0)
        if scroll || scroll_adding {     // 初回起動時の場合 入力ボタン押下時の場合
//            print(TableView_JournalEntry.numberOfSections)
            for s in 0..<TableView_JournalEntry.numberOfSections {            //セクション数　ゼロスタート補正は不要
                if TableView_JournalEntry.numberOfRows(inSection: s) > 0 {
                    let r = TableView_JournalEntry.numberOfRows(inSection: s)-1 //セル数　ゼロスタート補正
                    indexPath_local = IndexPath(row: r, section: s)
                    self.tableView.scrollToRow(at: indexPath_local, at: UITableView.ScrollPosition.top, animated: false) // topでないとタブバーの裏に隠れてしまう　animatedはありでもよい
                }
            }
        }
        if scroll_adding {     // 入力ボタン押下時の場合
            // 新規追加した仕訳データのセルを作成するために、最後の行までスクロールする　→ セルを作成時に位置を覚える
            if indexPath == indexPath_local { // 最後のセルまで表示しされたかどうか
                self.tableView.scrollToRow(at: indexPathForAutoScroll, at: UITableView.ScrollPosition.bottom, animated: false) // 追加した仕訳データの行を画面の下方に表示する
                // 入力ボタン押下時の表示位置 OFF
                scroll_adding = false
            }
        }
    }
    // 削除機能 セルを左へスワイプ
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.section != 1 {
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
        }else { // 空白行をスワイプした場合
            let configuration = UISwipeActionsConfiguration(actions: [])
            configuration.performsFirstActionWithFullSwipe = false
            return configuration
        }
    }
    // 削除機能 アラートのポップアップを表示
    private func showPopover(indexPath: IndexPath) {
        let alert = UIAlertController(title: "削除", message: "仕訳データを削除しますか？", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            (action: UIAlertAction!) in
            print("OK アクションをタップした時の処理")
            // データベース
            let dataBaseManager = DataBaseManagerJournalEntry()
            // セクション毎に分けて表示する。indexPath が row と section を持っているので、sectionで切り分ける。ここがポイント
            let objects = dataBaseManager.getJournalEntry(section: indexPath.section) // 何月のセクションに表示するセルかを判別するため引数で渡す
            print(objects)
            if indexPath.row >= objects.count {
                // 設定操作
                let dataBaseManagerSettingsOperating = DataBaseManagerSettingsOperating()
                let object = dataBaseManagerSettingsOperating.getSettingsOperating()
                let objectss = dataBaseManager.getJournalAdjustingEntry(section: indexPath.section, EnglishFromOfClosingTheLedger0: object!.EnglishFromOfClosingTheLedger0, EnglishFromOfClosingTheLedger1: object!.EnglishFromOfClosingTheLedger1) // 決算整理仕訳 損益振替仕訳 資本振替仕訳
                // 決算整理仕訳データを削除
                let result = dataBaseManager.deleteAdjustingJournalEntry(number: objectss[indexPath.row-objects.count].number)
                if result == true {
                    self.tableView.reloadData() // データベースの削除処理が成功した場合、テーブルをリロードする
                }
            }else {
                // 仕訳データを削除
                let result = dataBaseManager.deleteJournalEntry(number: objects[indexPath.row].number)
                if result == true {
                    self.tableView.reloadData() // データベースの削除処理が成功した場合、テーブルをリロードする
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBOutlet weak var view_top: UIView!
    var printing: Bool = false // プリント機能を使用中のみたてるフラグ　true:セクションをテーブルの先頭行に固定させない。描画時にセクションが重複してしまうため。
    // disable sticky section header
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if printing {
            if scrollView.contentOffset.y >= view_top.bounds.height+UIApplication.shared.statusBarFrame.height+self.navigationController!.navigationBar.bounds.height && scrollView.contentOffset.y >= 0 {
                // セクションヘッダーの高さをインセットに設定する　セクションヘッダーがテーブル上にとどまらないようにするため
                scrollView.contentInset = UIEdgeInsets(top: -(view_top.bounds.height+UIApplication.shared.statusBarFrame.height+self.navigationController!.navigationBar.bounds.height+tableView.sectionHeaderHeight), left: 0, bottom: 0, right: 0)
            }
        }else{
            // インセットを設定する　ステータスバーとナビゲーションバーより下からテーブルビューを配置するため
//            scrollView.contentInset = UIEdgeInsets(top: +self.navigationController!.navigationBar.bounds.height+UIApplication.shared.statusBarFrame.height, left: 0, bottom: 0, right: 0)
            // インセットを設定する　ステータスバーとナビゲーションバーより下からテーブルビューを配置するため
            scrollView.contentInset = UIEdgeInsets(top: +(UIApplication.shared.statusBarFrame.height+self.navigationController!.navigationBar.bounds.height), left: 0, bottom: (self.tabBarController?.tabBar.frame.size.height)!, right: 0)
        }
    }
    
    var pageSize = CGSize(width: 210 / 25.4 * 72, height: 297 / 25.4 * 72)
    @IBOutlet weak var barButtonItem_add: UIBarButtonItem!//ヘッダー部分の追加ボタン
    @IBOutlet weak var button_print: UIButton!
    /**
     * 印刷ボタン押下時メソッド
     * 仕訳帳画面　Extend Edges: Under Top Bar, Under Bottom Bar のチェックを外すと,仕訳データの行が崩れてしまう。
     */
    @IBAction func button_print(_ sender: UIButton) {
        let indexPath = tableView.indexPathsForVisibleRows // テーブル上で見えているセルを取得する
//        print("tableView.indexPathsForVisibleRows: \(String(describing: indexPath))")
        self.tableView.scrollToRow(at: indexPath![0], at: UITableView.ScrollPosition.top, animated: false)//セルが存在する行を指定しないと0行だとエラーとなる //ビットマップコンテキストに描画後、画面上のTableViewを先頭にスクロールする
        self.tableView.scrollToRow(at: indexPath![0], at: UITableView.ScrollPosition.bottom, animated: false)//セルが存在する行を指定しないと0行だとエラーとなる //ビットマップコンテキストに描画後、画面上のTableViewを先頭にスクロールする
        // 第三の方法
        //余計なUIをキャプチャしないように隠す
        tableView.showsVerticalScrollIndicator = false
        if let tappedIndexPath: IndexPath = self.tableView.indexPathForSelectedRow {// タップされたセルの位置を取得
            // nilでない場合
            tableView.deselectRow(at: tappedIndexPath, animated: true)// セルの選択を解除
        }
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        printing = true
        gADBannerView.isHidden = true
            pageSize = CGSize(width: 210 / 25.4 * 72, height: 297 / 25.4 * 72)//実際印刷用紙サイズ937x1452ピクセル
//        pageSize = CGSize(width: tableView.contentSize.width / 25.4 * 72, height: tableView.contentSize.height / 25.4 * 72)
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
        let newImage = self.tableView.captureImagee()
        //4. UIGraphicsEndImageContextを呼び出してグラフィックススタックからコンテキストをポップします。
        UIGraphicsEndImageContext()
        printing = false
        gADBannerView.isHidden = false
        self.tableView.scrollToRow(at: indexPath![0], at: UITableView.ScrollPosition.bottom, animated: false)//セルが存在する行を指定しないと0行だとエラーとなる //ビットマップコンテキストに描画後、画面上のTableViewを先頭にスクロールする
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
        print(" myImageView.bounds : \(myImageView.bounds)")
        //p-46 「UIGraphicsBeginPDFPage関数は、デフォルトのサイズを使用してページを作成します。」
//            UIGraphicsBeginPDFPage()
//        UIGraphicsBeginPDFPageWithInfo(CGRect(x:0, y:0, width:myImageView.bounds.width, height:myImageView.bounds.width*1.414516129), nil) //高さはA4コピー用紙と同じ比率にするために、幅×1.414516129とする

         /* PDFページの描画
           UIGraphicsBeginPDFPageは、デフォルトのサイズを使用して新しいページを作成します。一方、
           UIGraphicsBeginPDFPageWithInfo関数を利用す ると、ページサイズや、PDFページのその他の属性をカスタマイズできます。
        */
        //p-49 「リスト 4-2 ページ単位のコンテンツの描画」
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
            printInfo.jobName = "Journals"
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
        // インセットを設定する　ステータスバーとナビゲーションバーより下からテーブルビューを配置するため
        tableView.contentInset = UIEdgeInsets(top: +self.navigationController!.navigationBar.bounds.height+UIApplication.shared.statusBarFrame.height, left: 0, bottom: 0, right: 0)
        //ビットマップコンテキストに描画後、画面上のTableViewを先頭にスクロールする
        self.tableView.scrollToRow(at: indexPath![0], at: UITableView.ScrollPosition.bottom, animated: false)//セルが存在する行を指定しないと0行だとエラーとなる //ビットマップコンテキストに描画後、画面上のTableViewを先頭にスクロールする
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
