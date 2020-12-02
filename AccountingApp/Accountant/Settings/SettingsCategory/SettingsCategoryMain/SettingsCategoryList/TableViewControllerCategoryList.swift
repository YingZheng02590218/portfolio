//
//  TableViewControllerCategory.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/05/21.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import UIKit
import GoogleMobileAds // マネタイズ対応
import AudioToolbox // 効果音

// 勘定科目一覧　画面
class TableViewControllerCategoryList: UITableViewController {
    
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
        // 複数選択を可能にする
        // falseの場合は単一選択になる
        tableView.allowsMultipleSelectionDuringEditing = false
        // 編集ボタンの設定
        navigationItem.rightBarButtonItem = editButtonItem
        // 追加ボタンの初期値は、押下不可
        Button_add.isEnabled = false
    }
    // 編集モード切り替え
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.isEditing = editing
        print(editing)
        // 追加ボタンは、編集モード中は押下可能とする
        if editing {
            Button_add.isEnabled = true
        }else {
            Button_add.isEnabled = false
        }
    }

    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        // データベース
        let databaseManagerSettingsTaxonomyAccount = DatabaseManagerSettingsTaxonomyAccount()
        let objects = databaseManagerSettingsTaxonomyAccount.getSettingsTaxonomyAccount(section: indexPath.section)
        // デフォルトの勘定科目数（230）以上ある場合は、削除可能とし、それ以下の場合は削除不可とする。
        if 230 > objects[indexPath.row].number {
            return .none // 削除不可
        }
//        return .insert // これを設定しないと削除モードになる
        return .delete
    }
    // セルの右側から出てくるdeleteボタンを押下した時
    override func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath) {
        // ユーザーが新規追加した勘定科目のみを削除可能とする。
        if editingStyle == .delete {
//            PersonStore.shared.remove(indexPath.row)
            // 確認のポップアップを表示したい
            self.showPopover(indexPath: indexPath)
//            tableView.reloadData()
        }
        if editingStyle == .insert {
        // 対象セルの下に追加（先にリストに追加する）
//        tableDataList.insert(0, at: indexPath.row + 1)
            tableView.beginUpdates()
            tableView.insertRows(at: [IndexPath(row: indexPath.row + 1, section: 0)], with: .automatic)
            tableView.endUpdates()
        }
    }
    // 削除機能 アラートのポップアップを表示
    private func showPopover(indexPath: IndexPath) {
        // データベース
        let databaseManagerSettingsTaxonomyAccount = DatabaseManagerSettingsTaxonomyAccount()
        let objects = databaseManagerSettingsTaxonomyAccount.getSettingsTaxonomyAccount(section: indexPath.section)
        print(objects)
        // 勘定クラス
        let dataBaseManagerAccount = DataBaseManagerAccount()
        let objectss = dataBaseManagerAccount.getAllJournalEntryInAccountAll(account: objects[indexPath.row].category) // 全年度の仕訳データを確認する
        let objectsss = dataBaseManagerAccount.getAllAdjustingEntryInAccountAll(account: objects[indexPath.row].category) // 全年度の仕訳データを確認する
        let alert = UIAlertController(title: "削除", message: "「\(objects[indexPath.row].category)」を削除しますか？\n仕訳データが \(objectss.count) 件\n決算整理仕訳データが \(objectsss.count) 件あります", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            (action: UIAlertAction!) in
            print("OK アクションをタップした時の処理")
            // 設定勘定科目、勘定、仕訳、決算整理仕訳、損益勘定、損益振替仕訳　データを削除
            let result = databaseManagerSettingsTaxonomyAccount.deleteSettingsTaxonomyAccount(number: objects[indexPath.row].number)
            if result == true {
                self.tableView.reloadData() // データベースの削除処理が成功した場合、テーブルをリロードする
            }else {
                print("削除失敗　設定勘定科目")
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        // 勘定科目画面から、仕訳帳画面へ遷移して仕訳を追加した後に、戻ってきた場合はリロードする
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
        case 10: return   "特別損益"
        case 11: return   "税金"
        default: return   ""
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let databaseManagerSettings = DatabaseManagerSettingsTaxonomyAccount()
        let objects = databaseManagerSettings.getSettingsTaxonomyAccount(section: section)
        return objects.count
    }
    //セルを生成して返却するメソッド
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> TableViewCellCategoryList {
        // データベース
        let databaseManagerSettingsTaxonomyAccount = DatabaseManagerSettingsTaxonomyAccount()
        let objects = databaseManagerSettingsTaxonomyAccount.getSettingsTaxonomyAccount(section: indexPath.section)
        //① UI部品を指定　TableViewCellCategory
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell_list_category", for: indexPath) as! TableViewCellCategoryList
        // 勘定科目の名称をセルに表示する 丁数(元丁) 勘定名
        cell.textLabel?.text = " \(objects[indexPath.row].number). \(objects[indexPath.row].category as String)"
//        cell.label_category.text = " \(objects[indexPath.row].category as String)"
        // 勘定科目の連番
        cell.tag = objects[indexPath.row].number
        // 勘定科目の有効無効
        cell.ToggleButton.isOn = objects[indexPath.row].switching
        // 勘定科目の有効無効　変更時のアクションを指定
        cell.ToggleButton.addTarget(self, action: #selector(hundleSwitch), for: UIControl.Event.valueChanged)
        // モデルオブフェクトの取得 勘定別に取得
        let dataBaseManagerAccount = DataBaseManagerAccount()
        let objectss = dataBaseManagerAccount.getAllJournalEntryInAccountAll(account: objects[indexPath.row].category as String) // 通常仕訳　勘定別 全年度にしてはいけない
        let objectsss = dataBaseManagerAccount.getAllAdjustingEntryInAccountAll(account: objects[indexPath.row].category as String) // 決算整理仕訳　勘定別　損益勘定以外 全年度にしてはいけない
        // タクソノミに紐付けされていない勘定科目はスイッチをONにできないように無効化する
        if "" == objects[indexPath.row].numberOfTaxonomy {
            //UIButtonを無効化
            cell.ToggleButton.isEnabled = false
        }else {
            // 仕訳データが存在する場合、トグルスイッチはOFFにできないように、無効化する
            if objectss.count <= 0 && objectsss.count <= 0 {
                //UIButtonを有効化
                cell.ToggleButton.isEnabled = true
            }else {
                //UIButtonを無効化
                cell.ToggleButton.isEnabled = false
            }
        }
        return cell
    }
    // 勘定科目の有効無効　変更時のアクション TableViewの中のどのTableViewCellに配置されたトグルスイッチかを探す
    @objc func hundleSwitch(sender: UISwitch) {
        // UISwitchが配置されたセルを探す
        var hoge = sender.superview // 親ビュー
        while(hoge!.isKind(of: TableViewCellCategoryList.self) == false) {
            hoge = hoge!.superview
        }
        let cell = hoge as! TableViewCellCategoryList
        // touchIndexは選択したセルが何番目かを記録しておくプロパティ
        let touchIndex: IndexPath = self.tableView.indexPath(for: cell)!
        // データベース
        let databaseManagerSettingsTaxonomyAccount = DatabaseManagerSettingsTaxonomyAccount() //データベースマネジャー
        let objects = databaseManagerSettingsTaxonomyAccount.getSettingsTaxonomyAccount(section: touchIndex.section)
//        let objects = databaseManagerSettingsTaxonomyAccount.getSettingsSwitchingOn(section: touchIndex.section)
        // セクション内でonとなっているスイッチが残りひとつの場合は、offにさせない
        if objects.count <= 1 {
            if !sender.isOn { // ON から　OFF に切り替えようとした時は効果音を鳴らす
                print(objects.count)
                // 効果音
                let soundIdRing: SystemSoundID = 1000 //
                AudioServicesPlaySystemSound(soundIdRing)
            }
            // ONに強制的に戻す
            sender.isOn = true
            changeSwitch(tag: cell.tag, isOn: sender.isOn) // 引数：連番、トグルスイッチ.有効無効
            //UIButtonを無効化　はしないで、強制的にONに戻す
//            sender.isEnabled = false
            sender.isEnabled = true
        }else {
            // ここからデータベースを更新する
            changeSwitch(tag: cell.tag, isOn: sender.isOn) // 引数：連番、トグルスイッチ.有効無効
            //UIButtonを有効化
            sender.isEnabled = true
        }
//        tableView.reloadData() // 不要　注意：ここでリロードすると、トグルスイッチが深緑色となり元の緑色に戻らなくなる
    }
    // トグルスイッチの切り替え　データベースを更新
    func changeSwitch(tag: Int, isOn: Bool) { // 引数：連番、トグルスイッチ.有効無効
        // 勘定科目のスイッチを設定する
        let databaseManagerSettingsTaxonomyAccount = DatabaseManagerSettingsTaxonomyAccount()
        databaseManagerSettingsTaxonomyAccount.updateSettingsCategorySwitching(tag: tag, isOn: isOn)
        // 表示科目のスイッチを設定する　勘定科目がひとつもなければOFFにする
        let dataBaseSettingsCategoryBSAndPL = DataBaseManagerSettingsTaxonomy()
        dataBaseSettingsCategoryBSAndPL.updateSettingsCategoryBSAndPLSwitching(number: tag)
    }
    // 画面遷移の準備　勘定科目画面
    @IBOutlet var Button_add: UIBarButtonItem!
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // セグエで場合分け
        if segue.identifier == "segue_add_account"{ // 新規で設定勘定科目を追加する場合　addButtonを押下
            // segue.destinationの型はUIViewController
            let tableViewControllerSettingsCategoryDetail = segue.destination as! TableViewControllerSettingsCategoryDetail
            // 遷移先のコントローラに値を渡す
            tableViewControllerSettingsCategoryDetail.addAccount = true // セルに表示した勘定科目の連番を取得
        }else{ // 既存の設定勘定科目を選択された場合
            // 選択されたセルを取得
            let indexPath: IndexPath = self.tableView.indexPathForSelectedRow! // ※ didSelectRowAtの代わりにこれを使う方がいい　タップされたセルの位置を取得
            let databaseManagerSettings = DatabaseManagerSettingsTaxonomyAccount()
            let objects = databaseManagerSettings.getSettingsTaxonomyAccount(section: indexPath.section)
            // segue.destinationの型はUIViewController
            let tableViewControllerSettingsCategoryDetail = segue.destination as! TableViewControllerSettingsCategoryDetail
            // 遷移先のコントローラに値を渡す
            tableViewControllerSettingsCategoryDetail.numberOfAccount = objects[indexPath.row].number // セルに表示した勘定科目の連番を取得
            // セルの選択を解除
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}
