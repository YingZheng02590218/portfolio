//
//  ViewControllerTB.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/06/19.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import UIKit
import GoogleMobileAds // マネタイズ対応

// 合計残高試算表クラス　決算整理前
class ViewControllerTB: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPrintInteractionControllerDelegate {

    // マネタイズ対応
    // 広告ユニットID
    let AdMobID = "ca-app-pub-7616440336243237/8565070944"
    // テスト用広告ユニットID
    let TEST_ID = "ca-app-pub-3940256099942544/2934735716"
    // true:テスト
    let AdMobTest:Bool = true
    @IBOutlet var gADBannerView: GADBannerView!

    @IBOutlet weak var view_top: UIView!
    @IBOutlet weak var TableView_TB: UITableView!
    @IBOutlet weak var label_company_name: UILabel!
    @IBOutlet weak var label_title: UILabel!
    @IBOutlet weak var label_closingDate: UILabel!
    @IBOutlet weak var segmentedControl_switch: UISegmentedControl!
    @IBAction func segmentedControl(_ sender: Any) {
        if segmentedControl_switch.selectedSegmentIndex == 0 {
            label_title.text = "決算整理前合計試算表"
        }else {
            label_title.text = "決算整理前残高試算表"
        }
        TableView_TB.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        TableView_TB.delegate = self
        TableView_TB.dataSource = self
        // 合計額を計算
        let databaseManager = DataBaseManagerTB()
        databaseManager.calculateAmountOfAllAccount()
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: Selector(("refreshTable")), for: UIControl.Event.valueChanged)
        self.TableView_TB.refreshControl = refreshControl
    }
    // ビューが表示される直前に呼ばれる
    override func viewWillAppear(_ animated: Bool){
        // インセットを設定する　ステータスバーとナビゲーションバーより下からテーブルビューを配置するため
        TableView_TB.contentInset = UIEdgeInsets(top: +(UIApplication.shared.statusBarFrame.height+self.navigationController!.navigationBar.bounds.height), left: 0, bottom: (self.tabBarController?.tabBar.frame.size.height)!, right: 0)
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
        if segmentedControl_switch.selectedSegmentIndex == 0 {
            label_title.text = "決算整理前合計試算表"
        }else {
            label_title.text = "決算整理前残高試算表"
        }
        // 要素数が少ないUITableViewで残りの部分や余白を消す
        let tableFooterView = UIView(frame: CGRect.zero)
        TableView_TB.tableFooterView = tableFooterView

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
        print(TableView_TB.rowHeight)
        // GADBannerView を作成する
        addBannerViewToView(gADBannerView, constant: TableView_TB!.rowHeight * -1)
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
        let firstLunchKey = "firstLunch_TrialBalance"
        if ud.bool(forKey: firstLunchKey) {
            ud.set(false, forKey: firstLunchKey)
            ud.synchronize()
            // チュートリアル対応
            presentAnnotation()
        }
    }
    // チュートリアル対応
    func presentAnnotation() {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Annotation_TrialBalance") as! AnnotationViewController
        viewController.alpha = 0.5
        present(viewController, animated: true, completion: nil)
    }
    
    @objc func refreshTable() {
        // 全勘定の合計と残高を計算する
        let databaseManager = DataBaseManagerTB()
        databaseManager.setAllAccountTotal()
        databaseManager.calculateAmountOfAllAccount() // 合計額を計算
        //精算表　借方合計と貸方合計の計算 (修正記入、損益計算書、貸借対照表)
//        let databaseManagerWS = DataBaseManagerWS()
//        databaseManagerWS.calculateAmountOfAllAccount()
//        databaseManagerWS.calculateAmountOfAllAccountForBS()
//        databaseManagerWS.calculateAmountOfAllAccountForPL()
        // 更新処理
        self.TableView_TB.reloadData()
        // クルクルを止める
        TableView_TB.refreshControl?.endRefreshing()
    }
    //セルの数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let databaseManagerSettings = DatabaseManagerSettingsTaxonomyAccount()
        let objects = databaseManagerSettings.getSettingsTaxonomyAccountAdjustingSwitch(AdjustingAndClosingEntries: false, switching: true)
        return objects.count + 1 //合計額の行の分
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let databaseManagerSettings = DatabaseManagerSettingsTaxonomyAccount()
        let objects = databaseManagerSettings.getSettingsTaxonomyAccountAdjustingSwitch(AdjustingAndClosingEntries: false, switching: true)
        let databaseManager = DataBaseManagerTB()
        if indexPath.row < objects.count {
            //① UI部品を指定
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell_TB", for: indexPath) as! TableViewCellTB
            // 勘定科目をセルに表示する
            //        cell.textLabel?.text = "\(objects[indexPath.row].category as String)"
            cell.label_account.text = "\(objects[indexPath.row].category as String)"
            cell.label_account.textAlignment = NSTextAlignment.center
            switch segmentedControl_switch.selectedSegmentIndex {
            case 0: // 合計　借方
                cell.label_debit.text = setComma(amount: databaseManager.getTotalAmount(account: "\(objects[indexPath.row].category as String)", leftOrRight: 0))
                    // 合計　貸方
                cell.label_credit.text = setComma(amount:databaseManager.getTotalAmount(account: "\(objects[indexPath.row].category as String)", leftOrRight: 1))
                break
            case 1: // 残高　借方
                cell.label_debit.text = setComma(amount:databaseManager.getTotalAmount(account: "\(objects[indexPath.row].category as String)", leftOrRight: 2))
                    // 残高　貸方
                cell.label_credit.text = setComma(amount:databaseManager.getTotalAmount(account: "\(objects[indexPath.row].category as String)", leftOrRight: 3))
                break
            default:
                print("cell_TB")
                break
            }
            return cell
        }else {
            let dataBaseManagerFinancialStatements = DataBaseManagerFinancialStatements()
            let object = dataBaseManagerFinancialStatements.getFinancialStatements()
            //① UI部品を指定
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell_last_TB", for: indexPath) as! TableViewCellTB
//            let r = 0
//            switch r {
            switch segmentedControl_switch.selectedSegmentIndex {
            case 0: // 合計　借方
                cell.label_debit.text = setComma(amount: object.compoundTrialBalance!.debit_total_total)
                    // 合計　貸方
                cell.label_credit.text = setComma(amount: object.compoundTrialBalance!.credit_total_total)
                break
            case 1: // 残高　借方
                cell.label_debit.text = setComma(amount:object.compoundTrialBalance!.debit_balance_total)
                    // 残高　貸方
                cell.label_credit.text = setComma(amount:object.compoundTrialBalance!.credit_balance_total)
                break
            default:
                print("cell_last_TB")
                break
            }
            // 借方貸方の金額が不一致の場合、文字色を赤
            if cell.label_debit.text != cell.label_credit.text {
                cell.label_debit.textColor = .red
                cell.label_credit.textColor = .red
            }
            return cell
        }
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
    
    var printing: Bool = false // プリント機能を使用中のみたてるフラグ　true:セクションをテーブルの先頭行に固定させない。描画時にセクションが重複してしまうため。
    // disable sticky section header
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if printing {
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) // ここがポイント。画面表示用にインセットを設定した、ステータスバーとナビゲーションバーの高さの分をリセットするために0を設定する。
            if scrollView.contentOffset.y >= UIApplication.shared.statusBarFrame.height && scrollView.contentOffset.y >= 0 {
                scrollView.contentInset = UIEdgeInsets(top: -(UIApplication.shared.statusBarFrame.height+TableView_TB.sectionHeaderHeight), left: 0, bottom: 0, right: 0)
            }
        }else{
//            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            // インセットを設定する　ステータスバーとナビゲーションバーより下からテーブルビューを配置するため
            scrollView.contentInset = UIEdgeInsets(top: +(UIApplication.shared.statusBarFrame.height+self.navigationController!.navigationBar.bounds.height), left: 0, bottom: (self.tabBarController?.tabBar.frame.size.height)!, right: 0)
        }
    }
    var pageSize = CGSize(width: 210 / 25.4 * 72, height: 297 / 25.4 * 72)
    @IBOutlet weak var button_print: UIButton!
    /**
     * 印刷ボタン押下時メソッド
     */
    @IBAction func button_print(_ sender: UIButton) {
        let indexPath = TableView_TB.indexPathsForVisibleRows // テーブル上で見えているセルを取得する
        self.TableView_TB.scrollToRow(at: IndexPath(row: indexPath!.count-1, section: 0), at: UITableView.ScrollPosition.bottom, animated: false)// 一度最下行までレイアウトを描画させる
        printing = true
        self.TableView_TB.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableView.ScrollPosition.bottom, animated: false) //ビットマップコンテキストに描画後、画面上のTableViewを先頭にスクロールする

        // 第三の方法
        //余計なUIをキャプチャしないように隠す
        TableView_TB.showsVerticalScrollIndicator = false
        if let tappedIndexPath: IndexPath = self.TableView_TB.indexPathForSelectedRow { // タップされたセルの位置を取得
            TableView_TB.deselectRow(at: tappedIndexPath, animated: true)// セルの選択を解除
        }
//            pageSize = CGSize(width: 210 / 25.4 * 72, height: 297 / 25.4 * 72)//実際印刷用紙サイズ937x1452ピクセル
//        pageSize = CGSize(width: TableView_TB.contentSize.width / 25.4 * 72, height: TableView_TB.contentSize.height / 25.4 * 72)
        pageSize = CGSize(width: 210 / 25.4 * 72, height: 297 / 25.4 * 72)//実際印刷用紙サイズ937x1452ピクセル
        print("TableView_TB.contentSize:\(TableView_TB.contentSize)")
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
        gADBannerView.isHidden = true
        let newImage = self.TableView_TB.captureImagee()
        //4. UIGraphicsEndImageContextを呼び出してグラフィックススタックからコンテキストをポップします。
        UIGraphicsEndImageContext()
        printing = false
        gADBannerView.isHidden = false
        self.TableView_TB.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableView.ScrollPosition.bottom, animated: false)// 元の位置に戻す //ビットマップコンテキストに描画後、画面上のTableViewを先頭にスクロールする
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
            printInfo.jobName = "Trial Balance Sheet"
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
        TableView_TB.showsVerticalScrollIndicator = true
        self.TableView_TB.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableView.ScrollPosition.bottom, animated: false) // 元の位置に戻す
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

extension UIScrollView {

    func getContentImage(captureSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(captureSize, false, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }

        // 元の frame.size を記憶
        let originalSize = self.frame.size
        // frame.size を一時的に変更
        self.frame.size = self.contentSize
        self.layer.render(in: context)
        // 元に戻す
        self.frame.size = originalSize

        let capturedImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();

        return capturedImage
    }
}
