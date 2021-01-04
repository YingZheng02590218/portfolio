//
//  ViewControllerGenearlLedgerAccount.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/05/27.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import UIKit
import GoogleMobileAds // マネタイズ対応

// 勘定クラス
class ViewControllerGenearlLedgerAccount: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPrintInteractionControllerDelegate {
    
    // マネタイズ対応
    // 広告ユニットID
    let AdMobID = "ca-app-pub-7616440336243237/8565070944"
    // テスト用広告ユニットID
    let TEST_ID = "ca-app-pub-3940256099942544/2934735716"
    // true:テスト
    let AdMobTest:Bool = true
    @IBOutlet var gADBannerView: GADBannerView!
    
    @IBOutlet weak var view_top: UIView!
    @IBOutlet weak var TableView_account: UITableView!
    @IBOutlet weak var label_date_year: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        TableView_account.delegate = self
        TableView_account.dataSource = self
        // ヘッダー部分　勘定名を表示
        label_list_heading.text = account
        if (UITraitCollection.current.userInterfaceStyle == .dark) {
            /* ダークモード時の処理 */
            label_list_heading.textColor = .white
        } else {
            /* ライトモード時の処理 */
            label_list_heading.textColor = .black
        }
        // データベース
        let dataBaseManager = DataBaseManagerSettingsPeriod()
        let fiscalYear = dataBaseManager.getSettingsPeriodYear()
        // ToDo どこで設定した年度のデータを参照するか考える
        label_date_year.text = fiscalYear.description + "年" 
        //3桁ごとにカンマ区切りするフォーマット
        formatter.numberStyle = NumberFormatter.Style.decimal
        formatter.groupingSeparator = ","
        formatter.groupingSize = 3
        // 差引残高　計算
        dataBaseManagerGeneralLedgerAccountBalance.calculateBalance(account: account) // 毎回、計算は行わない
        // リロード機能は使用不可のため不要
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // UIViewControllerの表示画面を更新・リロード 注意：iPadの画面ではレイアウトが合わなくなる。リロードしなければ問題ない。仕訳帳ではリロードしても問題ない。
//        self.loadView()
//        self.viewDidLoad()
        // 仕訳データが0件の場合、印刷ボタンを不活性にする
        // 空白行対応
        let dataBaseManagerAccount = DataBaseManagerAccount()
        if account == "損益勘定" || account == "繰越利益" {
            let objectsss = dataBaseManagerAccount.getAllAdjustingEntryInPLAccountWithRetainedEarningsCarriedForward(account: account) // 決算整理仕訳　勘定別　損益勘定のみ　繰越利益を含む

            if objectsss.count >= 1 {
                button_print.isEnabled = true
            }else {
                button_print.isEnabled = false
            }
        }else{
            let objects = dataBaseManagerAccount.getAllJournalEntryInAccount(account: account) // 通常仕訳　勘定別
            let objectss = dataBaseManagerAccount.getAllAdjustingEntryInAccount(account: account) // 決算整理仕訳　勘定別　損益勘定以外
            if objects.count + objectss.count >= 1 {
                button_print.isEnabled = true
            }else {
                button_print.isEnabled = false
            }
        }
        // 要素数が少ないUITableViewで残りの部分や余白を消す
        let tableFooterView = UIView(frame: CGRect.zero)
        TableView_account.tableFooterView = tableFooterView

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
        print(TableView_account.rowHeight)
        // GADBannerView を作成する
        addBannerViewToView(gADBannerView, constant: TableView_account!.rowHeight * -1)
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
    }
    
    // セクションの数を設定する
    func numberOfSections(in tableView: UITableView) -> Int {
        // 空白行対応
        let dataBaseManagerAccount = DataBaseManagerAccount()
        let objects = dataBaseManagerAccount.getAllJournalEntryInAccount(account: account) // 通常仕訳　勘定別
        let objectss = dataBaseManagerAccount.getAllAdjustingEntryInAccount(account: account) // 決算整理仕訳　勘定別　損益勘定以外
        if objects.count + objectss.count <= 45 {
            return 2 // 空白行を表示するためセクションを1つ追加
        }else {
            return 1
        }
    }
    //セルの数を、モデル(仕訳)の数に指定
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // データベース
        let dataBaseManagerAccount = DataBaseManagerAccount()
        let objects = dataBaseManagerAccount.getJournalEntryInAccount(account: account) // 通常仕訳　勘定別に月別に取得
        let objectss = dataBaseManagerAccount.getAdjustingJournalEntryInAccount(account: account) // 決算整理仕訳　勘定別に取得
//        let objectsss = dataBaseManagerAccount.getPLAccount(section: section)
        // 空白行対応
        if section == 1 { // 空白行
            let dataBaseManagerAccount = DataBaseManagerAccount()
            let objects = dataBaseManagerAccount.getAllJournalEntryInAccount(account: account) // 通常仕訳　勘定別
            let objectss = dataBaseManagerAccount.getAllAdjustingEntryInAccount(account: account) // 決算整理仕訳　勘定別　損益勘定以外
            if objects.count + objectss.count <= 45 {
                return 45 - (objects.count + objectss.count) // 空白行を表示するため30行に満たない不足分を追加
            }else {
                return 0 // 39件以上ある場合　不足分は0
            }
        }else {
            return objects.count + objectss.count //月別の仕訳データ数
        }
    }
    
    var account :String = "" // 勘定名
    let dataBaseManagerGeneralLedgerAccountBalance = DataBaseManagerGeneralLedgerAccountBalance()
    @IBOutlet weak var label_list_heading: UILabel!
    //セルを生成して返却するメソッド
//    var indexPathForAutoScroll: IndexPath = IndexPath(row: 0, section: 0)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //① UI部品を指定　TableViewCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell_list_generalLedger_account", for: indexPath) as! TableViewCellGeneralLedgerAccount

        if indexPath.section == 1 { // 空白行
            cell.backgroundColor = .white // 目印を消す
            cell.label_list_date_month.text = ""    // 「月」注意：空白を代入しないと、変な値が入る。
            cell.label_list_date_day.text = ""     // 末尾2文字の「日」         //日付
            cell.label_list_summary.text = ""      //摘要　相手方勘定なので借方
            cell.label_list_number.text = ""       // 丁数　相手方勘定なので貸方
            cell.label_list_debit.text = ""        //借方金額 注意：空白を代入しないと、変な値が入る。
            cell.label_list_credit.text = ""       //貸方金額
            cell.label_list_balance.text = ""      //差引残高
            cell.label_list_debitOrCredit.text = ""// 借又貸
            // セルの選択不可にする
//            cell.selectionStyle = .none
        }else { // 空白行ではない場合
            let dataBaseManagerAccount = DataBaseManagerAccount()
            let objects = dataBaseManagerAccount.getJournalEntryInAccount(account: account) // 勘定別に取得
            let objectsss = dataBaseManagerAccount.getAllAdjustingEntryInAccount(account: account) // 勘定別に損益の仕訳以外を取得
            let object =  dataBaseManagerAccount.getAllAdjustingEntryInPLAccountWithRetainedEarningsCarriedForward(account: account) // 勘定別に損益の仕訳のみを取得
            var objectss = objectsss
            print("通常仕訳     :\(objects.count)")
            print("決算整理仕訳  :\(objectsss.count)")
            print(indexPath.row)
            var indexPathRowFixed = indexPath.row-objects.count
            if indexPath.row >= objects.count { // 決算整理仕訳 通常仕訳の数以上の場合
                if indexPath.row >= objects.count + objectsss.count { // 決算整理仕訳 通常仕訳と決算整理仕訳(損益以外)の数以上の場合
                    objectss = object
                    indexPathRowFixed = indexPath.row - (objects.count + objectsss.count)
                }
                cell.backgroundColor = .lightGray // 目印
                //② todo 借方の場合は左寄せ、貸方の場合は右寄せ。小書きは左寄せ。
                print(indexPathRowFixed, objectss)
                let d = "\(objectss[indexPathRowFixed].date)" // 日付
                // 月別のセクションのうち、日付が一番古いものに月欄に月を表示し、それ以降は空白とする。
                if indexPath.row > 0 {
                    if indexPathRowFixed > 0 { // 二行目以降は月の先頭のみ、月を表示する
                        // 一行上のセルに表示した月とこの行の月を比較する
                        let upperCellMonth = "\(objectss[indexPathRowFixed - 1].date)" // 日付
                        let dateMonth = d[d.index(d.startIndex, offsetBy: 5)..<d.index(d.startIndex, offsetBy: 6)] // 日付の6文字目にある月の十の位を抽出
                        if dateMonth == "0" { // 日の十の位が0の場合は表示しない
                            if upperCellMonth[upperCellMonth.index(upperCellMonth.startIndex, offsetBy: 5)..<upperCellMonth.index(upperCellMonth.startIndex, offsetBy: 7)] != "\(d[d.index(d.startIndex, offsetBy: 5)..<d.index(d.startIndex, offsetBy: 7)])" {
                                cell.label_list_date_month.text = "\(d[d.index(d.startIndex, offsetBy: 6)..<d.index(d.startIndex, offsetBy: 7)])" // 「月」
                            }else{
                                cell.label_list_date_month.text = "" // 注意：空白を代入しないと、変な値が入る。
                            }
                        }else{
                            print(upperCellMonth[upperCellMonth.index(upperCellMonth.startIndex, offsetBy: 5)..<upperCellMonth.index(upperCellMonth.startIndex, offsetBy: 7)])
                            print("\(d[d.index(d.startIndex, offsetBy: 5)..<d.index(d.startIndex, offsetBy: 7)])")
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
                let date = d[d.index(d.startIndex, offsetBy: 8)..<d.index(d.startIndex, offsetBy: 9)] // 日付の9文字目にある日の十の位を抽出
                if date == "0" { // 日の十の位が0の場合は表示しない
                    cell.label_list_date_day.text = "\(objectss[indexPathRowFixed].date.suffix(1))" // 末尾1文字の「日」         //日付
                }else{
                    cell.label_list_date_day.text = "\(objectss[indexPathRowFixed].date.suffix(2))" // 末尾2文字の「日」         //日付
                }
                cell.label_list_date_day.textAlignment = NSTextAlignment.right
//        cell.label_list_summary_debit.text = " (\(objectss[indexPath.row].debit_category))"     //借方勘定
//        cell.label_list_summary_debit.textAlignment = NSTextAlignment.left
//        cell.label_list_summary_credit.text = "(\(objectss[indexPath.row].credit_category)) "   //貸方勘定
//        cell.label_list_summary_credit.textAlignment = NSTextAlignment.right
                if account == "\(objectss[indexPathRowFixed].debit_category)" { // 借方勘定の場合                      //この勘定が借方の場合
                    cell.label_list_summary.text = "\(objectss[indexPathRowFixed].credit_category) "             //摘要　相手方勘定なので貸方
                    cell.label_list_summary.textAlignment = NSTextAlignment.right
                    if objectss[indexPathRowFixed].credit_category == "損益勘定" { // 損益勘定の場合
                        // 勘定の仕丁は、相手方勘定の丁数ではない。仕訳帳の丁数である。 2020/07/27
                        cell.label_list_number.text = ""//numberOfAccount.description                               // 丁数　相手方勘定なので貸方
                    }else {
                        let numberOfAccount = dataBaseManagerAccount.getNumberOfAccount(accountName: "\(objectss[indexPathRowFixed].credit_category)")// 損益勘定の場合はエラーになる
                        // 勘定の仕丁は、相手方勘定の丁数ではない。仕訳帳の丁数である。 2020/07/27
                        cell.label_list_number.text = numberOfAccount.description                               // 丁数　相手方勘定なので貸方
                    }
                    cell.label_list_debit.text = "\(addComma(string: String(objectss[indexPathRowFixed].debit_amount))) "        //借方金額
                    cell.label_list_credit.text = ""                                                                        //貸方金額 注意：空白を代入しないと、変な値が入る。
                }else if account == "\(objectss[indexPathRowFixed].credit_category)" {  // 貸方勘定の場合
                    cell.label_list_summary.text = "\(objectss[indexPathRowFixed].debit_category) "              //摘要　相手方勘定なので借方
                    cell.label_list_summary.textAlignment = NSTextAlignment.left
                    if objectss[indexPathRowFixed].debit_category == "損益勘定" { // 損益勘定の場合
                        // 勘定の仕丁は、相手方勘定の丁数ではない。仕訳帳の丁数である。 2020/07/27
                        cell.label_list_number.text = ""//numberOfAccount.description                               // 丁数　相手方勘定なので貸方
                    }else {
                        let numberOfAccount = dataBaseManagerAccount.getNumberOfAccount(accountName: "\(objectss[indexPathRowFixed].debit_category)")// 損益勘定の場合はエラーになる
                        // 勘定の仕丁は、相手方勘定の丁数ではない。仕訳帳の丁数である。 2020/07/27
                        cell.label_list_number.text = numberOfAccount.description                               // 丁数　相手方勘定なので貸方
                    }
                    cell.label_list_debit.text = ""                                                                         //借方金額 注意：空白を代入しないと、変な値が入る。
                    cell.label_list_credit.text = "\(addComma(string: String(objectss[indexPathRowFixed].credit_amount))) "      //貸方金額
                }
                // 差引残高　差引残高クラスで計算した計算結果を取得
                var balanceAmount:Int64 = 0
                var balanceDebitOrCredit:String = ""
                if account == "損益勘定" { // 損益勘定の場合
                    balanceAmount = dataBaseManagerGeneralLedgerAccountBalance.getBalanceAmountAdjustingInPLAccount(indexPath: IndexPath(row: indexPathRowFixed, section: indexPath.section))
                    cell.label_list_balance.text = "\(addComma(string: balanceAmount.description))"                           //差引残高
                    balanceDebitOrCredit = dataBaseManagerGeneralLedgerAccountBalance.getBalanceDebitOrCreditAdjustingInPLAccount(indexPath: IndexPath(row: indexPathRowFixed, section: indexPath.section))
                }else if account == "繰越利益" {
                    balanceAmount = dataBaseManagerGeneralLedgerAccountBalance.getBalanceAmountAdjustingWithRetainedEarningsCarriedForward(indexPath: IndexPath(row: indexPathRowFixed, section: indexPath.section))
                    cell.label_list_balance.text = "\(addComma(string: balanceAmount.description))"                           //差引残高
                    balanceDebitOrCredit = dataBaseManagerGeneralLedgerAccountBalance.getBalanceDebitOrCreditAdjustingWithRetainedEarningsCarriedForward(indexPath: IndexPath(row: indexPathRowFixed, section: indexPath.section))
                }else{
//                    && account != "繰越利益" { // 繰越利益　は損益勘定から振替える以外に、仕訳する方法はあるのか？　2020/10/10
                    balanceAmount = dataBaseManagerGeneralLedgerAccountBalance.getBalanceAmountAdjusting(indexPath: IndexPath(row: indexPathRowFixed, section: indexPath.section))
                    cell.label_list_balance.text = "\(addComma(string: balanceAmount.description))"                           //差引残高
                    balanceDebitOrCredit = dataBaseManagerGeneralLedgerAccountBalance.getBalanceDebitOrCreditAdjusting(indexPath: IndexPath(row: indexPathRowFixed, section: indexPath.section))
                }
                cell.label_list_debitOrCredit.text = balanceDebitOrCredit                                                 // 借又貸
                // セルの選択を許可
                cell.selectionStyle = .default
            }else { // 通常仕訳
                //② todo 借方の場合は左寄せ、貸方の場合は右寄せ。小書きは左寄せ。
                cell.backgroundColor = .white // 目印を消す
                let d = "\(objects[indexPath.row].date)" // 日付
                // 月別のセクションのうち、日付が一番古いものに月欄に月を表示し、それ以降は空白とする。
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
                let date = d[d.index(d.startIndex, offsetBy: 8)..<d.index(d.startIndex, offsetBy: 9)] // 日付の9文字目にある日の十の位を抽出
                if date == "0" { // 日の十の位が0の場合は表示しない
                    cell.label_list_date_day.text = "\(objects[indexPath.row].date.suffix(1))" // 末尾1文字の「日」         //日付
                }else{
                    cell.label_list_date_day.text = "\(objects[indexPath.row].date.suffix(2))" // 末尾2文字の「日」         //日付
                }
                cell.label_list_date_day.textAlignment = NSTextAlignment.right
//        cell.label_list_summary_debit.text = " (\(objects[indexPath.row].debit_category))"     //借方勘定
//        cell.label_list_summary_debit.textAlignment = NSTextAlignment.left
//        cell.label_list_summary_credit.text = "(\(objects[indexPath.row].credit_category)) "   //貸方勘定
//        cell.label_list_summary_credit.textAlignment = NSTextAlignment.right
                if account == "\(objects[indexPath.row].debit_category)" { // 借方勘定の場合                      //この勘定が借方の場合
                    cell.label_list_summary.text = "\(objects[indexPath.row].credit_category) "             //摘要　相手方勘定なので貸方
                    cell.label_list_summary.textAlignment = NSTextAlignment.right
                    if objects[indexPath.row].credit_category == "損益勘定" { // 損益勘定の場合
                        // 勘定の仕丁は、相手方勘定の丁数ではない。仕訳帳の丁数である。 2020/07/27
                        cell.label_list_number.text = ""//numberOfAccount.description                               // 丁数　相手方勘定なので貸方
                    }else {
                        let numberOfAccount = dataBaseManagerAccount.getNumberOfAccount(accountName: "\(objects[indexPath.row].credit_category)")// 損益勘定の場合はエラーになる
                        // 勘定の仕丁は、相手方勘定の丁数ではない。仕訳帳の丁数である。 2020/07/27
                        cell.label_list_number.text = numberOfAccount.description                               // 丁数　相手方勘定なので貸方
                    }
                    cell.label_list_debit.text = "\(addComma(string: String(objects[indexPath.row].debit_amount))) "        //借方金額
                    cell.label_list_credit.text = ""                                                                        //貸方金額 注意：空白を代入しないと、変な値が入る。
                }else if account == "\(objects[indexPath.row].credit_category)" {  // 貸方勘定の場合
                    cell.label_list_summary.text = "\(objects[indexPath.row].debit_category) "              //摘要　相手方勘定なので借方
                    cell.label_list_summary.textAlignment = NSTextAlignment.left
                    if objects[indexPath.row].debit_category == "損益勘定" { // 損益勘定の場合
                        // 勘定の仕丁は、相手方勘定の丁数ではない。仕訳帳の丁数である。 2020/07/27
                        cell.label_list_number.text = ""//numberOfAccount.description                               // 丁数　相手方勘定なので貸方
                    }else {
                        let numberOfAccount = dataBaseManagerAccount.getNumberOfAccount(accountName: "\(objects[indexPath.row].debit_category)")// 損益勘定の場合はエラーになる
                        // 勘定の仕丁は、相手方勘定の丁数ではない。仕訳帳の丁数である。 2020/07/27
                        cell.label_list_number.text = numberOfAccount.description                               // 丁数　相手方勘定なので貸方
                    }
                    cell.label_list_debit.text = ""                                                                         //借方金額 注意：空白を代入しないと、変な値が入る。
                    cell.label_list_credit.text = "\(addComma(string: String(objects[indexPath.row].credit_amount))) "      //貸方金額
                }
                // 差引残高　差引残高クラスで計算した計算結果を取得
                let balanceAmount = dataBaseManagerGeneralLedgerAccountBalance.getBalanceAmount(indexPath: indexPath)
                cell.label_list_balance.text = "\(addComma(string: balanceAmount.description))"                           //差引残高
                let balanceDebitOrCredit = dataBaseManagerGeneralLedgerAccountBalance.getBalanceDebitOrCredit(indexPath: indexPath)
                cell.label_list_debitOrCredit.text = balanceDebitOrCredit                                                 // 借又貸
                // セルの選択を許可
                cell.selectionStyle = .default
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
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
    func addComma(string :String) -> String {
        if(string != "") { // ありえないでしょう
            return formatter.string(from: NSNumber(value: Double(string)!))!
        }else{
            return ""
        }
    }
    var printing: Bool = false // プリント機能を使用中のみたてるフラグ　true:セクションをテーブルの先頭行に固定させない。描画時にセクションが重複してしまうため。
    // disable sticky section header
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if printing {
            print("scrollView.contentOffset.y   : \(scrollView.contentOffset.y)")
            print("scrollView.contentInset      : \(scrollView.contentInset)")
            print("view_top.bounds.height       : \(view_top.bounds.height)")
            print("TableView_account.bounds.height   : \(TableView_account.bounds.height)")
            if scrollView.contentOffset.y >= view_top.bounds.height && scrollView.contentOffset.y >= 0 { // viewの重複を防ぐ
                scrollView.contentInset = UIEdgeInsets(top: (view_top.bounds.height) * -1, left: 0, bottom: 0, right: 0) //注意：view_top.bounds.heightを指定するとテーブルの最下行が表示されなくなる
            }
        }else{
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) //注意：view_top.bounds.heightを指定するとテーブルの最下行が表示されなくなる
        }
    }
    var pageSize = CGSize(width: 210 / 25.4 * 72, height: 297 / 25.4 * 72)
    @IBOutlet weak var button_print: UIButton!
    /**
     * 印刷ボタン押下時メソッド
     */
    @IBAction func button_print(_ sender: UIButton) {
        let indexPath = TableView_account.indexPathsForVisibleRows // テーブル上で見えているセルを取得する
        print("TableView_account.indexPathsForVisibleRows: \(String(describing: indexPath))")
        self.TableView_account.scrollToRow(at: indexPath![0], at: UITableView.ScrollPosition.top, animated: false)
        self.TableView_account.scrollToRow(at: indexPath![0], at: UITableView.ScrollPosition.bottom, animated: false)
//        self.TableView_account.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableView.ScrollPosition.top, animated: false) //ビットマップコンテキストに描画後、画面上のTableViewを先頭にスクロールする
        // 第三の方法
        //余計なUIをキャプチャしないように隠す
        TableView_account.showsVerticalScrollIndicator = false
        button_print.isHidden = true
        if let tappedIndexPath: IndexPath = self.TableView_account.indexPathForSelectedRow { // タップされたセルの位置を取得
            TableView_account.deselectRow(at: tappedIndexPath, animated: true)// セルの選択を解除
        }
            pageSize = CGSize(width: 210 / 25.4 * 72, height: 297 / 25.4 * 72)//実際印刷用紙サイズ937x1452ピクセル
//        pageSize = CGSize(width: TableView_account.contentSize.width / 25.4 * 72, height: TableView_account.contentSize.height+view_top.bounds.height / 25.4 * 72) //先頭行の高さを考慮する
//        print("TableView_account.contentSize:\(TableView_account.contentSize)")
        //viewと同じサイズのコンテキスト（オフスクリーンバッファ）を作成
//        var rect = self.view.bounds
        //p-41 「ビットマップグラフィックスコンテキストを使って新しい画像を生成」
        //1. UIGraphicsBeginImageContextWithOptions関数でビットマップコンテキストを生成し、グラフィックススタックにプッシュします。
        UIGraphicsBeginImageContextWithOptions(pageSize, true, 0.0)
            //2. UIKitまたはCore Graphicsのルーチンを使って、新たに生成したグラフィックスコンテキストに画像を描画します。
//        imageRect.draw(in: CGRect(origin: .zero, size: pageSize))
            //3. UIGraphicsGetImageFromCurrentImageContext関数を呼び出すと、描画した画像に基づく UIImageオブジェクトが生成され、返されます。必要ならば、さらに描画した上で再びこのメソッ ドを呼び出し、別の画像を生成することも可能です。
        printing = true
        gADBannerView.isHidden = true
        //p-43 リスト 3-1 縮小画像をビットマップコンテキストに描画し、その結果の画像を取得する
//        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        let newImage = self.TableView_account.captureImagee()
        //4. UIGraphicsEndImageContextを呼び出してグラフィックススタックからコンテキストをポップします。
        UIGraphicsEndImageContext()
        printing = false
        gADBannerView.isHidden = false
       self.TableView_account.scrollToRow(at: indexPath![0], at: UITableView.ScrollPosition.bottom, animated: false) //ビットマップコンテキストに描画後、画面上のTableViewを先頭にスクロールする
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
//            guard let currentContext = UIGraphicsGetCurrentContext() else { return }
//            myImageView.layer.render(in: currentContext)
//            if myImageView.bounds.height > myImageView.bounds.width*1.414516129 {
//    //2ページ目
//           UIGraphicsBeginPDFPageWithInfo(CGRect(x:0, y:-myImageView.bounds.width*1.414516129, width:myImageView.bounds.width, height:myImageView.bounds.width*1.414516129), nil) //高さはA4コピー用紙と同じ比率にするために、幅×1.414516129とする
//            // グラフィックスコンテキストを取得する
//            guard let currentContext2 = UIGraphicsGetCurrentContext() else { return }
//            myImageView.layer.render(in: currentContext2)
//            }
//            if myImageView.bounds.height > (myImageView.bounds.width*1.414516129)*2 {
//    //3ページ目
//            UIGraphicsBeginPDFPageWithInfo(CGRect(x:0, y:-(myImageView.bounds.width*1.414516129)*2, width:myImageView.bounds.width, height:myImageView.bounds.width*1.414516129), nil) //高さはA4コピー用紙と同じ比率にするために、幅×1.414516129とする
//             // グラフィックスコンテキストを取得する
//             guard let currentContext3 = UIGraphicsGetCurrentContext() else { return }
//             myImageView.layer.render(in: currentContext3)
//            }
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
            printInfo.jobName = "Account"
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
        TableView_account.showsVerticalScrollIndicator = true
        button_print.isHidden = false
        self.TableView_account.scrollToRow(at: indexPath![0], at: UITableView.ScrollPosition.bottom, animated: false) //ビットマップコンテキストに描画後、画面上のTableViewを先頭にスクロールする

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
//    // セルが画面に表示される直前に表示される
//    var scroll = false   // flag 初回起動後かどうかを判定する (viewDidLoadでON, viewDidAppearでOFF)
//    var scroll_adding = false   // flag 入力ボタン押下後かどうかを判定する (autoScrollでON, viewDidAppearでOFF)
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        var indexPath_local = IndexPath(row: 0, section: 0)
//        if scroll || scroll_adding {     // 初回起動時の場合 入力ボタン押下時の場合
//            for s in 0..<TableView_account.numberOfSections-1 {            //セクション数　ゼロスタート補正
//                if TableView_account.numberOfRows(inSection: s) > 0 {
//                    let r = TableView_account.numberOfRows(inSection: s)-1 //セル数　ゼロスタート補正
//                    indexPath_local = IndexPath(row: r, section: s)
//                    self.TableView_account.scrollToRow(at: indexPath_local, at: UITableView.ScrollPosition.top, animated: false) // topでないとタブバーの裏に隠れてしまう　animatedはありでもよい
//                }
//            }
//        }
//        if scroll_adding {     // 入力ボタン押下時の場合
//            // 新規追加した仕訳データのセルを作成するために、最後の行までスクロールする　→ セルを作成時に位置を覚える
//            if indexPath == indexPath_local { // 最後のセルまで表示しされたかどうか
//                self.TableView_account.scrollToRow(at: indexPathForAutoScroll, at: UITableView.ScrollPosition.bottom, animated: false) // 追加した仕訳データの行を画面の下方に表示する
//                // 入力ボタン押下時の表示位置 OFF
//                scroll_adding = false
//            }
//        }
//    }
}
