//
//  TableViewControllerSettingsCategoryDetail.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/09/21.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import UIKit
import GoogleMobileAds // マネタイズ対応

// 勘定科目詳細クラス
class TableViewControllerSettingsCategoryDetail: UITableViewController, UITextFieldDelegate {

    // マネタイズ対応
    // 広告ユニットID
    let AdMobID = "ca-app-pub-7616440336243237/8565070944"
    // テスト用広告ユニットID
    let TEST_ID = "ca-app-pub-3940256099942544/2934735716"
    // true:テスト
    let AdMobTest:Bool = true
    @IBOutlet var gADBannerView: GADBannerView!
    
    var big = ""
    var mid = ""
    var small = ""
    var accountname = ""
    var taxonomyname = ""
    var big_num = ""
    var mid_num = ""
    var small_num = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 登録ボタンの　表示　非表示
        if addAccount {
            Button_input.isHidden = false
            Button_input.isEnabled = true
        }else {
            Button_input.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // 表示科目を変更後に勘定科目詳細画面を更新する
        tableView.reloadData()
        // テキストフィールドを初期化
        if addAccount { // 勘定科目追加の場合
            createTextFieldForCategory()
        }
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
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            // 大区分
            // 中区分
            // 小区分 コメントアウト
            // 勘定科目名
            return 3//4
        }else {
            // 表示科目
            return 1
        }
    }
    // セクションヘッダーのテキスト決める
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "勘定科目"
        case 1:
            return "表示科目"
        default:
            return ""
        }
    }
    // セクションフッターのテキスト決める
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 1:
            return "勘定科目を決算書上に表記される表示科目に紐付けることができます。"
        default:
            return ""
        }
    }
    var numberOfAccount :Int = 0 // 勘定科目番号
    var numberOfTaxonomy :Int = 0 // 表示科目番号
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! TableViewCellSettingAccountDetailTaxonomy
        cell.accessoryType = .none
        cell.label.text = "-"
        // セルの選択不可にする
        cell.selectionStyle = .none
        // 新規で設定勘定科目を追加する場合　addButtonを押下
        if addAccount { // 新規追加
            if indexPath.section == 0 { // 勘定科目
                switch indexPath.row {
                case 0:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "identifier_category_big", for: indexPath) as! TableViewCellSettingAccountDetail
                    cell.accessoryType = .none
                    // セルの選択
                    cell.selectionStyle = .none
                    cell.textLabel?.textColor = .lightGray
                    cell.textLabel?.textAlignment = NSTextAlignment.left
                    print(cell.textLabel?.font.pointSize)// = .systemFont(ofSize: 15))
                    cell.textLabel?.font = .systemFont(ofSize: 14)
                    // 勘定科目の名称をセルに表示する
                    cell.textLabel?.text = "大区分"
                    if cell.textField_AccountDetail_big.text != "選択してください" && cell.textField_AccountDetail_big.text != "" {
                    }else {
                        cell.textField_AccountDetail_big.text = "選択してください"
                        cell.textField_AccountDetail_big.textColor = .lightGray
                        cell.textField_AccountDetail_big.textAlignment = NSTextAlignment.center
                    }
                    return cell
                case 1:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "identifier_category_big", for: indexPath) as! TableViewCellSettingAccountDetail
                    cell.accessoryType = .none
                    // セルの選択
                    cell.selectionStyle = .none
                    cell.textLabel?.textColor = .lightGray
                    cell.textLabel?.textAlignment = NSTextAlignment.left
                    cell.textLabel?.font = .systemFont(ofSize: 14)
                    cell.textLabel?.text = "中区分"
                    if cell.textField_AccountDetail_big.text != "選択してください" && cell.textField_AccountDetail_big.text != "" {
                    }else {
                        cell.textField_AccountDetail_big.text = "選択してください"
                        cell.textField_AccountDetail_big.textColor = .lightGray
                        cell.textField_AccountDetail_big.textAlignment = NSTextAlignment.center
                    }
                    return cell
                case 2:
//                    let cell = tableView.dequeueReusableCell(withIdentifier: "identifier_category", for: indexPath) as! TableViewCellSettingAccountDetail
//                    // セルの選択
//                    cell.selectionStyle = .none
//                    cell.textLabel?.textColor = .darkGray
//                    cell.textLabel?.textAlignment = NSTextAlignment.left
//                    cell.textLabel?.text = "小区分"
//                    if cell.textField_AccountDetail.text != "選択してください" && cell.textField_AccountDetail.text != "" {
//                    }else {
//                        cell.textField_AccountDetail.text = "選択してください"
//                        cell.textField_AccountDetail.textColor = .lightGray
//                        cell.textField_AccountDetail.textAlignment = NSTextAlignment.center
//                    }
//                    return cell
//                case 3:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "identifier_Account", for: indexPath) as! TableViewCellSettingAccountDetailAccount
                    cell.accessoryType = .none
                    // セルの選択
                    cell.selectionStyle = .none
                    cell.textLabel?.font = .systemFont(ofSize: 14)
                    cell.textLabel?.text = "勘定科目名"
                    cell.textLabel?.textColor = .lightGray
                    if cell.textField_AccountDetail_Account.text != "入力してください" && cell.textField_AccountDetail_Account.text != "" {
                    }else {
                        cell.textField_AccountDetail_Account.text = "入力してください"
                        cell.textField_AccountDetail_Account.textColor = .lightGray
                        cell.textField_AccountDetail_Account.textAlignment = NSTextAlignment.center
                    }
                    return cell
                default:
                    //
                    return cell
                }
            }else { // タクソノミ　表示科目
                let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! TableViewCellSettingAccountDetailTaxonomy
                cell.accessoryType = .disclosureIndicator
                // セルの選択
                cell.selectionStyle = .default
                cell.textLabel?.text = "表示科目名"
                cell.textLabel?.textColor = .lightGray
                cell.textLabel?.font = .systemFont(ofSize: 14)
                // 表示科目名
//                let cell_taxonomy = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as! TableViewCellSettingAccountDetailTaxonomy
                if self.numberOfTaxonomy != 0 {
//                    taxonomyname = cell_taxonomy.label.text!
//                    cell.label.text = taxonomyname
//                if cell.label.text != "表示科目を選択してください" && cell.label.text != "" {
                    let dataBaseManagerSettingsTaxonomy = DataBaseManagerSettingsTaxonomy()
                    let object = dataBaseManagerSettingsTaxonomy.getSettingsTaxonomy(numberOfTaxonomy: self.numberOfTaxonomy)
                    cell.label.text! = "\(object!.number), \(object!.category)"
                    // ダークモード対応
                    if (UITraitCollection.current.userInterfaceStyle == .dark) {
                        /* ダークモード時の処理 */
                        cell.label.textColor = .white
                    } else {
                        /* ライトモード時の処理 */
                        // 文字色
                        cell.label.textColor = .black
                    }
                }else {
                    cell.label.text = "表示科目を選択してください"
                    cell.label.textColor = .lightGray
                }
                cell.label.textAlignment = NSTextAlignment.center
                return cell
            }
        }else { // 新規追加　以外
            let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! TableViewCellSettingAccountDetailTaxonomy
            cell.accessoryType = .none
            // セルの選択
            cell.selectionStyle = .none
            // 勘定科目の連番から勘定科目を取得　紐づけた表示科目の連番を知るため
            let databaseManagerSettingsTaxonomyAccount = DatabaseManagerSettingsTaxonomyAccount()
            let object = databaseManagerSettingsTaxonomyAccount.getSettingsTaxonomyAccount(number: numberOfAccount) // 勘定科目
            cell.label.text = "-"
            if indexPath.section == 0 { // 勘定科目
                switch indexPath.row {
                case 0:
                    // 勘定科目の名称をセルに表示する
                    cell.textLabel?.text = "大区分"
                    cell.textLabel?.textColor = .lightGray
                    cell.textLabel?.textAlignment = NSTextAlignment.left
                    cell.textLabel?.font = .systemFont(ofSize: 14)
                    switch object?.Rank0 {
                    case "0": cell.label.text =   "流動資産"
                        break
                    case "1": cell.label.text =   "固定資産"
                        break
                    case "2": cell.label.text =   "繰延資産"
                        break
                    case "3": cell.label.text =   "流動負債"
                        break
                    case "4": cell.label.text =   "固定負債"
                        break
                    case "5": cell.label.text =   "資本"
                        break
                    case "6": cell.label.text =   "売上"
                        break
                    case "7": cell.label.text =   "売上原価"
                        break
                    case "8": cell.label.text =   "販売費及び一般管理費"
                        break
                    case "9": cell.label.text =   "営業外損益"
                        break
                    case "10": cell.label.text =   "特別損益"
                        break
                    case "11": cell.label.text =   "税金"
                        break
                    default:
                        cell.label.text = "-"
                        cell.label.textColor = .lightGray
                        break
                    }
                    cell.label.textAlignment = NSTextAlignment.center
                    break
                case 1:
                    cell.textLabel?.text = "中区分"
                    cell.textLabel?.textColor = .lightGray
                    cell.textLabel?.textAlignment = NSTextAlignment.left
                    cell.textLabel?.font = .systemFont(ofSize: 14)
                    switch object?.Rank1 {
                    case "0": cell.label.text =   "当座資産"
                        break
                    case "1": cell.label.text =   "棚卸資産"
                        break
                    case "2": cell.label.text =   "その他の流動資産"
                        break
                    case "3": cell.label.text =   "有形固定資産"
                        break
                    case "4": cell.label.text =   "無形固定資産"
                        break
                    case "5": cell.label.text =   "投資その他の資産"
                        break
                    case "6": cell.label.text =   "繰延資産"
                        break
                    case "7": cell.label.text =   "仕入債務"
                        break
                    case "8": cell.label.text =   "その他の流動負債"
                        break
                    case "9": cell.label.text =   "長期債務"
                        break
                    case "10": cell.label.text =   "株主資本"
                        break
                    case "11": cell.label.text =   "評価・換算差額等"
                        break
                    case "12": cell.label.text =   "新株予約権"
                        break
                    case "13": cell.label.text =   "売上原価"
                        break
                    case "14": cell.label.text =   "製造原価"
                        break
                    case "15": cell.label.text =   "営業外収益"
                        break
                    case "16": cell.label.text =   "営業外費用"
                        break
                    case "17": cell.label.text =   "特別利益"
                        break
                    case "18": cell.label.text =   "特別損失"
                        break
                    default:
                        cell.label.text = "-"
                        cell.label.textColor = .lightGray
                        break
                    }
                    cell.label.textAlignment = NSTextAlignment.center
                    break
                case 2:
//                    cell.textLabel?.text = "小区分"
//                    cell.textLabel?.textColor = .darkGray
//                    cell.textLabel?.textAlignment = NSTextAlignment.left
//                    cell.label.textAlignment = NSTextAlignment.center
//                    break
//                case 3: // 勘定科目
                    cell.textLabel?.text = "勘定科目名"
                    cell.textLabel?.textColor = .lightGray
                    cell.textLabel?.textAlignment = NSTextAlignment.left
                    cell.textLabel?.font = .systemFont(ofSize: 14)
                    //勘定科目
                    if object!.category != "" {
                        cell.label.text = object!.category
                        // ダークモード対応
                        if (UITraitCollection.current.userInterfaceStyle == .dark) {
                            /* ダークモード時の処理 */
                            cell.label.textColor = .white
                        } else {
                            /* ライトモード時の処理 */
                            // 文字色
                            cell.label.textColor = .black
                        }
                    }else {
                        cell.label.text = "入力してください"
                        cell.label.textColor = .lightGray
                    }
                    cell.label.textAlignment = NSTextAlignment.center
                    break
                default:
                    //
                    break
                }
            }else { // タクソノミ　表示科目
                cell.accessoryType = .disclosureIndicator
                // セルの選択
                cell.selectionStyle = .default
                cell.textLabel?.text = "表示科目名"
                cell.textLabel?.textColor = .lightGray
                cell.textLabel?.textAlignment = NSTextAlignment.left
                cell.textLabel?.font = .systemFont(ofSize: 14)
                // 表示科目の連番から表示科目を取得　勘定科目の詳細情報を得るため
                let dataBaseManagerSettingsTaxonomy = DataBaseManagerSettingsTaxonomy()
                if "" != object?.numberOfTaxonomy {
                    let objectt = dataBaseManagerSettingsTaxonomy.getSettingsTaxonomy(numberOfTaxonomy: Int(object!.numberOfTaxonomy)!) // 表示科目
                    cell.label.text = "\(objectt!.number), \(objectt!.category)"
                    // ダークモード対応
                    if (UITraitCollection.current.userInterfaceStyle == .dark) {
                        /* ダークモード時の処理 */
                        cell.label.textColor = .white
                    } else {
                        /* ライトモード時の処理 */
                        // 文字色
                        cell.label.textColor = .black
                    }
                }else {
                    cell.label.text = "表示科目を選択してください"
                    cell.label.textColor = .lightGray
                }
                cell.label.textAlignment = NSTextAlignment.center
            }
            return cell
        }
    }
    // TextField作成
    func createTextFieldForCategory() {
        // 大区分
        let cell_big = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! TableViewCellSettingAccountDetail
            cell_big.textField_AccountDetail_big.setup(identifier: "identifier_category_big")
        // 中区分
        let cell = self.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! TableViewCellSettingAccountDetail
            cell.textField_AccountDetail_big.setup(identifier: "identifier_category")// switch文でdefaultケースに通すため
//        // 小区分
//        let cell_small = self.tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as! TableViewCellSettingAccountDetail
//        cell_small.textField_AccountDetail.setup(identifier: "identifier_category_small", component0: 0)
        // 勘定科目名
        let cell_category = self.tableView.cellForRow(at: IndexPath(row: 2/*3*/, section: 0)) as! TableViewCellSettingAccountDetailAccount
        
        // TextFieldに入力された値に反応
        // 入力開始
//        cell_big.textField_AccountDetail_big.addTarget(self, action: #selector(textFieldEditingDidBegin),for: UIControl.Event.editingDidBegin)
        // 入力終了
        cell_big.textField_AccountDetail_big.addTarget(self, action: #selector(textFieldEditingDidEnd),for: UIControl.Event.editingDidEnd)
        cell.textField_AccountDetail_big.addTarget(self, action: #selector(textFieldEditingDidEnd),for: UIControl.Event.editingDidEnd)
//        cell_small.textField_AccountDetail.addTarget(self, action: #selector(textFieldEditingDidEnd),for: UIControl.Event.editingDidEnd)
        cell_category.textField_AccountDetail_Account.addTarget(self, action: #selector(textFieldEditingDidEnd),for: UIControl.Event.editingDidEnd)
    }
    // テキストフィールへの入力が終了したとき
    @objc func textFieldEditingDidEnd(_ textField: UITextField) {
        // 文字色をグレーアウトとする
        textField.textColor = .lightGray
        // 取得　TextField 入力テキスト
        
        // 勘定科目区分選択　の場合
        if textField is PickerTextFieldAccountDetail {
            // 大区分
            let cell_big = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! TableViewCellSettingAccountDetail
            // 中区分
            let cell = self.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! TableViewCellSettingAccountDetail
            if textField.tag == 0 {
//            // String型の番号に変換してあげる
//            big = cell_big.textField_AccountDetail_big.text!
//            cell_big.textField_AccountDetail_big.textColor = UIColor.black // 文字色をブラックとする
//            // String型の番号に変換してあげる tagに大区分の番号を保持しておいたものを取得
//            big_num = String(cell_big.textField_AccountDetail_big.tag)
                big = cell_big.textField_AccountDetail_big.AccountDetail_big
                big_num = cell_big.textField_AccountDetail_big.selectedRank0
                mid = cell_big.textField_AccountDetail_big.AccountDetail
                mid_num = cell_big.textField_AccountDetail_big.selectedRank1
            }else if textField.tag == 1 {
                big = cell.textField_AccountDetail_big.AccountDetail_big
                big_num = cell.textField_AccountDetail_big.selectedRank0
                mid = cell.textField_AccountDetail_big.AccountDetail
                mid_num = cell.textField_AccountDetail_big.selectedRank1
            }
//            print(big)
            cell_big.textField_AccountDetail_big.text = big
            if cell_big.textField_AccountDetail_big.text != "選択してください" {
                // ダークモード対応
                if (UITraitCollection.current.userInterfaceStyle == .dark) {
                    /* ダークモード時の処理 */
                    cell_big.textField_AccountDetail_big.textColor = .white
                } else {
                    /* ライトモード時の処理 */
                    // 文字色
                    cell_big.textField_AccountDetail_big.textColor = .black // 文字色をブラックとする
                }
            }else {
                cell_big.textField_AccountDetail_big.textColor = .lightGray
            }
//            print(mid)
            cell.textField_AccountDetail_big.text = mid
            if cell.textField_AccountDetail_big.text != "選択してください" {
                // ダークモード対応
                if (UITraitCollection.current.userInterfaceStyle == .dark) {
                    /* ダークモード時の処理 */
                    cell.textField_AccountDetail_big.textColor = .white
                } else {
                    /* ライトモード時の処理 */
                    // 文字色
                    cell.textField_AccountDetail_big.textColor = .black
                }
            }else {
                cell.textField_AccountDetail_big.textColor = .lightGray
            }
        }
//        // 中区分
//        let cell = self.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! TableViewCellSettingAccountDetail
//        if cell.textField_AccountDetail!.text != "選択してください" {
//            // String型の番号に変換してあげる
//            mid = cell.textField_AccountDetail.text!
//            cell.textField_AccountDetail.textColor = UIColor.black // 文字色をブラックとする
//            // String型の番号に変換してあげる tagに中区分の番号を保持しておいたものを取得
//            mid_num = String(cell.textField_AccountDetail.tag)
//        }
//        // 小区分
//        let cell_small = self.tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as! TableViewCellSettingAccountDetail
//        if cell_small.textField_AccountDetail!.text != "選択してください" {
//            // String型の番号に変換してあげる
//            small = cell_small.textField_AccountDetail.text!
//            cell_small.textField_AccountDetail.textColor = UIColor.black // 文字色をブラックとする
//            // String型の番号に変換してあげる tagに小区分の番号を保持しておいたものを取得
//            small_num = String(cell_small.textField_AccountDetail.tag)
//        }
        // 勘定科目名
        let cell_category = self.tableView.cellForRow(at: IndexPath(row: 2/*3*/, section: 0)) as! TableViewCellSettingAccountDetailAccount
        if cell_category.textField_AccountDetail_Account!.text != "入力してください" {
            accountname = cell_category.textField_AccountDetail_Account.text!
            // ダークモード対応
            if (UITraitCollection.current.userInterfaceStyle == .dark) {
                /* ダークモード時の処理 */
                cell_category.textField_AccountDetail_Account.textColor = .white
            } else {
                /* ライトモード時の処理 */
                // 文字色
                cell_category.textField_AccountDetail_Account.textColor = .black // 文字色をブラックとする
            }
        }
        // 表示科目名
        let cell_taxonomy = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as! TableViewCellSettingAccountDetailTaxonomy
        if cell_taxonomy.label!.text != "表示科目を選択してください" {
            taxonomyname = cell_taxonomy.label.text!
            // ダークモード対応
            if (UITraitCollection.current.userInterfaceStyle == .dark) {
                /* ダークモード時の処理 */
                cell_taxonomy.label.textColor = .white
            } else {
                /* ライトモード時の処理 */
                // 文字色
                cell_taxonomy.label.textColor = .black // 文字色をブラックとする
            }
        }
        print("PickerTextFieldAccountDetail", big ,
              mid ,
              small ,
              accountname ,
              taxonomyname )
        print("PickerTextFieldAccountDetail", big_num ,
              mid_num ,
              small_num )
    }
    // セルが選択された時に呼び出される　// すべての影響範囲に修正が必要
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let cell = tableView.cellForRow(at:indexPath) as! TableViewCellSettingAccountDetailTaxonomy
        // 勘定科目名　変更
//        var alertTextField: UITextField?
//        let alert = UIAlertController(
//            title: "Edit Name",
//            message: "Enter new name",
//            preferredStyle: UIAlertController.Style.alert)
//        alert.addTextField(
//            configurationHandler: {(textField: UITextField!) in
//                alertTextField = textField
//                textField.text = cell.label.text
//                // textField.placeholder = "Mike"
//                // textField.isSecureTextEntry = true
//        })
//        alert.addAction(
//            UIAlertAction(
//                title: "Cancel",
//                style: UIAlertAction.Style.cancel,
//                handler: nil))
//        alert.addAction(
//            UIAlertAction(
//                title: "OK",
//                style: UIAlertAction.Style.default) { _ in
//                if let text = alertTextField?.text {
//                    cell.label.text = text
//                    // 勘定科目の連番から、勘定科目名を更新する
//                    let databaseManagerSettingsTaxonomyAccount = DatabaseManagerSettingsTaxonomyAccount()
//                    databaseManagerSettingsTaxonomyAccount.updateAccountNameOfSettingsTaxonomyAccount(number: self.numberOfAccount, accountName: text) // 勘定科目
//                }
//            }
//        )
//        self.present(alert, animated: true, completion: nil)
    }
    // 追加・編集機能　画面遷移の準備の前に入力検証
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        //画面のことをScene（シーン）と呼ぶ。 セグエとは、シーンとシーンを接続し画面遷移を行うための部品である。
        if IndexPath(row: 0, section: 1) != self.tableView.indexPathForSelectedRow! { // 表示科目名以外は遷移しない
            return false //false:画面遷移させない
        }
        return true
    }
    var addAccount: Bool = false // 勘定科目　詳細　設定画面からの遷移で勘定科目追加の場合はtrue
    // 画面遷移の準備　表示科目一覧画面へ
    var tappedIndexPath: IndexPath?
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // 選択されたセルを取得
        let indexPath: IndexPath = self.tableView.indexPathForSelectedRow! // ※ didSelectRowAtの代わりにこれを使う方がいい　タップされたセルの位置を取得
        switch segue.identifier {
        // 設定勘定科目
        case "segue_TaxonomyList": //“セグウェイにつけた名称”:
            // segue.destinationの型はUIViewController
            let viewControllerGenearlLedgerAccount = segue.destination as! TableViewControllerSettingsTaxonomyList
            // 遷移先のコントローラに値を渡す
            viewControllerGenearlLedgerAccount.numberOfTaxonomyAccount = numberOfAccount // 設定勘定科目連番　を渡す
            switch big_num { //object?.Rank0 {
            case "0","1","2","3","4","5":
                viewControllerGenearlLedgerAccount.segmentedControl_switch.selectedSegmentIndex = 0 // セグメントスイッチにBSを設定
                // 遷移先のコントローラー.条件用の属性 = “条件”
                break
            case "6","7","8","9","10","11":
                viewControllerGenearlLedgerAccount.segmentedControl_switch.selectedSegmentIndex = 1 // セグメントスイッチにPLを設定
                break
            default:
                //
                break
            }
            viewControllerGenearlLedgerAccount.howToUse = true // 勘定科目　詳細　設定画面からの遷移の場合はtrue
            if addAccount { // 新規で設定勘定科目を追加する場合　addButtonを押下
                viewControllerGenearlLedgerAccount.addAccount = true // 新規で設定勘定科目を追加する場合　addButtonを押下
            }
            break
        default:
            //
            break
        }
        // セルの選択を解除
        tableView.deselectRow(at: indexPath, animated: true)
    }
    // 勘定科目に紐づけられた表示科目を変更する　設定勘定科目連番、表示科目連番
    func changeTaxonomyOfTaxonomyAccount(number: Int, numberOfTaxonomy: Int) -> Int {
        var newnumber = 0
        // 変更
        let databaseManagerSettingsTaxonomyAccount = DatabaseManagerSettingsTaxonomyAccount()
        databaseManagerSettingsTaxonomyAccount.updateTaxonomyOfSettingsTaxonomyAccount(number: number, numberOfTaxonomy: String(numberOfTaxonomy))
        newnumber = number
        return newnumber
    }
    
    func showNumberOfTaxonomy() {
        // 表示科目名
        if self.numberOfTaxonomy != 0 { // 表示科目が選択されて、表示科目番号が詳細画面に戻ってきた場合
            let cell_taxonomy = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as! TableViewCellSettingAccountDetailTaxonomy
            let dataBaseManagerSettingsTaxonomy = DataBaseManagerSettingsTaxonomy()
            let object = dataBaseManagerSettingsTaxonomy.getSettingsTaxonomy(numberOfTaxonomy: self.numberOfTaxonomy)
            cell_taxonomy.label.text! = "\(object!.number), \(object!.category)"
            // ダークモード対応
            if (UITraitCollection.current.userInterfaceStyle == .dark) {
                /* ダークモード時の処理 */
                cell_taxonomy.label.textColor = .white
            } else {
                /* ライトモード時の処理 */
                cell_taxonomy.label.textColor = .black // 文字色をブラックとする
            }
            taxonomyname = cell_taxonomy.label.text!
        }
    }
    // 入力ボタン
    @IBOutlet var Button_input: UIButton!// 入力ボタン
    @IBAction func Button_Input(_ sender: Any) {
        // 勘定科目　追加か編集か
        let databaseManagerSettingsTaxonomyAccount = DatabaseManagerSettingsTaxonomyAccount()
        var newnumber = 0
        // 入力チェック
        if big != "選択してください" && big != "" {
            if mid != "選択してください" && mid != "" {
//                if small != "選択してください" && small != ""{
                    if accountname != "入力してください" && accountname != "" {
                        if taxonomyname != "表示科目を選択してください" && taxonomyname != "" {
                        // TableViewControllerのviewWillAppearを呼び出す　更新のため
                        self.dismiss(animated: true, completion: {
                            [presentingViewController] () -> Void in
                            newnumber = databaseManagerSettingsTaxonomyAccount.addSettingsTaxonomyAccount(Rank0: self.big_num, Rank1: self.mid_num, Rank2: self.small_num, numberOfTaxonomy: String(self.numberOfTaxonomy), category: self.accountname, switching: true)
                            // 新規追加　を終了するためにフラグを倒す
                            if newnumber != 0 {
                                self.addAccount = false
//                                presentingViewController.numberOfAccount = num // 勘定科目　詳細画面 の勘定科目番号に代入
                                presentingViewController!.viewWillAppear(true) // TableViewをリロードする処理がある
                            }
                        })
                        }
                    }
//                }
            }
        }

    }
}
