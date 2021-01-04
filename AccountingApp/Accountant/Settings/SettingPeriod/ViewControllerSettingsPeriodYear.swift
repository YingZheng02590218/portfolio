//
//  ViewControllerSettingsPeriodYear.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/06/05.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import UIKit

class ViewControllerSettingsPeriodYear: UIViewController,UIPickerViewDataSource,UIPickerViewDelegate {
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //UIPickerView
        // Delegate設定
        pickerView.delegate = self
        pickerView.dataSource = self
    }
    // ビューが表示された後に呼ばれる
    override func viewDidAppear(_ animated: Bool){
        // ドラムロールの初期位置 データベースに保存された年度の翌年
        let dataBaseManagerPeriod = DataBaseManagerSettingsPeriod()
        pickerView.selectRow(dataBaseManagerPeriod.getMainBooksAllCount(), inComponent: 0, animated: true) //翌年の分
    }

//UIPickerView
    //UIPickerViewの列の数 コンポーネントの数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2 // ドラムロールは二列
    }
    //UIPickerViewの行数、リストの数 コンポーネントの内のデータ
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            let dataBaseManagerPeriod = DataBaseManagerSettingsPeriod()
            return dataBaseManagerPeriod.getMainBooksAllCount() + 1 //翌年の分
        default:
            return 1
        }
    }
    //UIPickerViewの最初の表示 ホイールに表示する選択肢のタイトル
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return getPeriodFromDB(row: row)
        default:
            return "年度"
        }
     }
    // 年度の選択肢
    func getPeriodFromDB(row: Int) -> String {
        let dataBaseManagerPeriod = DataBaseManagerSettingsPeriod()
        
        let objects = dataBaseManagerPeriod.getMainBooksAll()
        if dataBaseManagerPeriod.getMainBooksAllCount() <= row {
            var lastRow = row
            lastRow -= 1
            var lastfisvalYear = objects[lastRow].fiscalYear
            lastfisvalYear += 1
            return lastfisvalYear.description // 翌年の分
        }else {
            return objects[row].fiscalYear.description
        }
    }
    
    @IBAction func save(_ sender: Any) {
        // 選択した年度の会計帳簿を作成する
        let row = pickerView.selectedRow(inComponent: 0)
        let fiscalYear = getPeriodFromDB(row: row)
        createNewPeriod(fiscalYear: Int(fiscalYear)!)
        let tabBarController = self.presentingViewController as! UITabBarController // 基底となっているコントローラ
        let splitViewController = tabBarController.selectedViewController as! UISplitViewController // 基底のコントローラから、選択されているを取得する
        let navigationController = splitViewController.viewControllers[0]  as! UINavigationController // スプリットコントローラから、現在選択されているコントローラを取得する
        let navigationController2: UINavigationController
        // iPadとiPhoneで動きが変わるので分岐する
        if UIDevice.current.userInterfaceIdiom == .pad { // iPad
//        if UIDevice.current.orientation == .portrait { // ポートレート 上下逆さまだとポートレートとはならない
             navigationController2 = splitViewController.viewControllers[1]  as! UINavigationController // ナビゲーションバーコントローラの配下にあるビューコントローラーを取得
            print("iPad ビューコントローラーの階層")
            print("splitViewController[0]      :", splitViewController.viewControllers[0])     // UINavigationController
            print("splitViewController[1]      :", splitViewController.viewControllers[1] )    // UINavigationController
            print("  navigationController[0]   :", navigationController.viewControllers[0])    // TableViewControllerSettings
            print("    navigationController2[0]:", navigationController2.viewControllers[0])   // TableViewControllerSettingsPeriod
        }else { // iPhone
            navigationController2 = navigationController.viewControllers[1] as! UINavigationController
//             navigationController2 = navigationController.viewControllers[0] as! UINavigationController // ナビゲーションバーコントローラの配下にあるビューコントローラーを取得
            print("iPhone ビューコントローラーの階層")
            print("splitViewController[0]      :", splitViewController.viewControllers[0])     // UINavigationController
            print("  navigationController[0]   :", navigationController.viewControllers[0])    // TableViewControllerSettings
            print("  navigationController[1]   :", navigationController.viewControllers[1])    // UINavigationController
            print("    navigationController2[0]:", navigationController2.viewControllers[0])   // TableViewControllerSettingsPeriod
        }

        let presentingViewController = navigationController2.viewControllers[0] as! TableViewControllerSettingsPeriod // 呼び出し元のビューコントローラーを取得

        // viewWillAppearを呼び出す　更新のため
        self.dismiss(animated: true, completion: {
            [presentingViewController] () -> Void in
            // ViewController(年度選択画面)を閉じた時に、遷移元であるViewController(会計期間画面)で行いたい処理
            presentingViewController.showAd()// TableViewをリロードする処理がある
        })
    }
    
    func createNewPeriod(fiscalYear: Int){
        // オブジェクト作成
        let dataBaseManager = DataBaseManagerAccountingBooks()
        // データベースに会計帳簿があるかをチェック
        if !dataBaseManager.checkInitialising(DataBase: DataBaseAccountingBooks(), fiscalYear: fiscalYear) { // データベースに同じ年度のモデルオブフェクトが存在しない場合
            let number = dataBaseManager.addAccountingBooks(fiscalYear: fiscalYear)
        // 仕訳帳画面　　初期化
            let dataBaseManagerJournals = DataBaseManagerJournals()
            // データベースに仕訳帳画面の仕訳帳があるかをチェック
            if !dataBaseManagerJournals.checkInitialising(DataBase: DataBaseJournals(), fiscalYear: fiscalYear) { // データベースにモデルオブフェクトが存在しない場合
                dataBaseManagerJournals.addJournals(number: number)
            }
        // 総勘定元帳画面　初期化
            let dataBaseManagerGeneralLedger = DataBaseManagerGeneralLedger()
            // データベースに勘定画面の勘定があるかをチェック
            if !dataBaseManagerGeneralLedger.checkInitialising(DataBase: DataBaseGeneralLedger(), fiscalYear: fiscalYear) { // データベースにモデルオブフェクトが存在しない場合
                dataBaseManagerGeneralLedger.addGeneralLedger(number: number)
            }
        // 決算書画面　初期化
            let dataBaseManagerFinancialStatements = DataBaseManagerFinancialStatements()
            // データベースに勘定画面の勘定があるかをチェック
            if !dataBaseManagerFinancialStatements.checkInitialising(DataBase: DataBaseFinancialStatements(), fiscalYear: fiscalYear) { // データベースにモデルオブフェクトが存在しない場合
                dataBaseManagerFinancialStatements.addFinancialStatements(number: number)
            }
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
