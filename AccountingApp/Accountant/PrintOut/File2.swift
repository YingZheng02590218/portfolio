//
// 参考
// https://qiita.com/papassan/items/c3e89b0cdf461ac29faa

//
//  PrintPDFViewController.swift
//  mamassan
//
//  Created by 福田敏一 on 2018/12/02.
//  Copyright © 2018 Toshikazu Fukuda. All rights reserved.
//
//「iOSにおける 描画と印刷のガイド」
//参考サイト https://developer.apple.com/jp/documentation/DrawingPrintingiOS.pdf

import UIKit

class PrintPDFViewController: UIViewController, UIPrintInteractionControllerDelegate {
    
    @IBOutlet weak var printButton: UIButton!
    //
    //
    //
    @IBOutlet weak var printUIButton: UIBarButtonItem!
    
    var pageSize = CGSize(width: 210 / 25.4 * 72, height: 297 / 25.4 * 72)
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
//p-63 リスト 5-1 ページ範囲の選択が可能な単一のPDFドキュメント
    //- (IBAction)printContent:(id)sender {
    @IBAction func printButton(_ sender: UIButton) {
        
        //A4, 210x297mm, 8.27x11.68インチ,595x841ピクセル
        pageSize = CGSize(width: 210 / 25.4 * 72, height: 297 / 25.4 * 72)//実際印刷用紙サイズ937x1452ピクセル
        //US Letter size, 215x279.4mm, 8.5x10.98インチ,612x792ピクセル
        pageSize = CGSize(width: 215 / 25.4 * 72, height: 279 / 25.4 * 72)//実際印刷用紙サイズ975x1350ピクセル
        //長3封筒, 235x120mm, 9.25x4.72インチ,340.2x666.1ピクセル
        pageSize = CGSize(width: 120 / 25.4 * 72, height: 235 / 25.4 * 72)//実際印刷用紙サイズ408x1087ピクセル
        //長型4号, 205x90mm, 8.07x3.54インチ,255.1x581.1ピクセル
        pageSize = CGSize(width: 90 / 25.4 * 72, height: 205 / 25.4 * 72)//実際印刷用紙サイズ231x910ピクセル//2.277930223441788//printable -> (3.0, 12.0, 84.0, 171.0)
        //ハガキ, 148x100mm, 5.83x3.94インチ,283.5x419.5ピクセル
        //pageSize = CGSize(width: 100 / 25.4 * 72, height: 148 / 25.4 * 72)//実際印刷用紙サイズ290x573ピクセル
        //L版, 127x89mm, 5x3.5インチ,252.3x360ピクセル
        //pageSize = CGSize(width: 89 / 25.4 * 72, height: 127 / 25.4 * 72)//実際印刷用紙サイズ225x450ピクセル
        //自前で幅: 1239pixelx高さ: 2808pixel 解像度: 150dpi(300dpiでもOKです)を用意します、表示内容やファイル名はお好みです
        let imageRect = UIImage(named: "用紙長4")!
        //Image
    //p-41 「ビットマップグラフィックスコンテキストを使って新しい画像を生成」
        //1. UIGraphicsBeginImageContextWithOptions関数でビットマップコンテキストを生成し、グラフィックススタックにプッシュします。
        //UIGraphicsBeginImageContextWithOptions(CGSizeMake(100.0,100.0), NO, 2.0);
        UIGraphicsBeginImageContextWithOptions(pageSize, false, 0.0)
        //2. UIKitまたはCore Graphicsのルーチンを使って、新たに生成したグラフィックスコンテキストに画 像を描画します。
        // [image drawInRect:imageRect];
        imageRect.draw(in: CGRect(origin: .zero, size: pageSize))
        //3. UIGraphicsGetImageFromCurrentImageContext関数を呼び出すと、描画した画像に基づく UIImageオブジェクトが生成され、返されます。必要ならば、さらに描画した上で再びこのメソッ ドを呼び出し、別の画像を生成することも可能です。
    //p-43 リスト 3-1 縮小画像をビットマップコンテキストに描画し、その結果の画像を取得する
        //self.appRecord.appIcon = UIGraphicsGetImageFromCurrentImageContext();
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        //4. UIGraphicsEndImageContextを呼び出してグラフィックススタックからコンテキストをポップします。
        UIGraphicsEndImageContext()
        
        let myImageView = UIImageView(image: newImage)
        myImageView.layer.position = CGPoint(x: self.view.frame.midX, y: self.view.frame.midY)
        
//PDF
    //p-49 リスト 4-2 ページ単位のコンテンツの描画
        //CGMutablePathRef framePath = CGPathCreateMutable();
        let framePath = NSMutableData()
    //p-45 「PDFコンテキストの作成と設定」
        // PDFグラフィックスコンテキストは、UIGraphicsBeginPDFContextToData関数、
        //  または UIGraphicsBeginPDFContextToFile関数のいずれかを使用して作成します。
        //  UIGraphicsBeginPDFContextToData関数の場合、
        //  保存先はこの関数に渡される NSMutableDataオブジェクトです。
        UIGraphicsBeginPDFContextToData(framePath, myImageView.bounds, nil)
    //p-46 「UIGraphicsBeginPDFPage関数は、デフォルトのサイズを使用してページを作成します。」
        UIGraphicsBeginPDFPage()
    //p-49 「リスト 4-2 ページ単位のコンテンツの描画」
        // グラフィックスコンテキストを取得する
        //CGContextRef currentContext = UIGraphicsGetCurrentContext();
        guard let currentContext = UIGraphicsGetCurrentContext() else { return }
        myImageView.layer.render(in: currentContext)
        //描画が終了したら、UIGraphicsEndPDFContextを呼び出して、PDFグラフィックスコンテキストを閉じます。
        UIGraphicsEndPDFContext()
        
        
//ここからプリントです
    //p-63 リスト 5-1 ページ範囲の選択が可能な単一のPDFドキュメント
        //UIPrintInteractionController *pic = [UIPrintInteractionController] sharedPrintController];
        let pic = UIPrintInteractionController.shared
        //if  (pic && UIPrintInteractionController canPrintData: self.myPDFData] ) { }
        if UIPrintInteractionController.canPrint(framePath as Data) {
            //pic.delegate = self;
            pic.delegate = self
            
            /*
             UIPrintInfo *printInfo = [UIPrintInfo printInfo];
             printInfo.outputType = UIPrintInfoOutputGeneral;
             printInfo.jobName = [self.path lastPathComponent];
             printInfo.duplex = UIPrintInfoDuplexLongEdge;
             pic.printInfo = printInfo;
             pic.showsPageRange = YES:
             pic.printingItem = self.myPDFData;
             */
            //参考サイト https://developer.apple.com/documentation/uikit/uiprintinfo/1623553-init
            //init(dictionary:)
            //let printInfo = UIPrintInfo(dictionary:nil)
            //参考サイト https://developer.apple.com/documentation/uikit/uiprintinfo/1623545-printinfo
            //printInfo()
            let printInfo = UIPrintInfo.printInfo()
            printInfo.outputType = .general
            printInfo.jobName = "lastPathComponent"
            printInfo.duplex = .none
            pic.printInfo = printInfo
            //'showsPageRange' was deprecated in iOS 10.0: Pages can be removed from the print preview, so page range is always shown.
            //pic.showsPageRange = YES;
            pic.printingItem = framePath
            
            //void (^completionHandler)(UIPrintInteractionController *, BOOL, NSError *)
            //^(UIPrintInteractionController *pic, BOOL completed, NSError *error) { self.content = nil;
            let completionHandler: (UIPrintInteractionController, Bool, NSError) -> Void = { (pic: UIPrintInteractionController, completed: Bool, error: Error?) in
                
                //if (!completed && error) NSLog(@"FAILED! due to error in domain %@ with error code %u", error.domain, error.code);
                if !completed && (error != nil) {
                    print("FAILED! due to error in domain %@ with error code %u \(String(describing: error))")
                }
            }
        //p-79 印刷インタラクションコントローラを使って印刷オプションを提示
            //UIPrintInteractionControllerには、ユーザに印刷オプションを表示するために次の3つのメソッ ドが宣言されており、それぞれアニメーションが付属しています。
            
            //if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            if UIDevice.current.userInterfaceIdiom == .pad {
                //これらのうちの2つは、iPadデバイス上で呼び出されることを想定しています。
                //・presentFromBarButtonItem:animated:completionHandler:は、ナビゲーションバーまたは ツールバーのボタン(通常は印刷ボタン)からアニメーションでPopover Viewを表示します。
                //[pic presentFromBarButtonItem:self.printButton animated:YES completionHandler:completionHandler];
                //参考サイト https://developer.apple.com/documentation/uikit/uiprintinteractioncontroller/1618176-present
                //pic.present(from: printButton.bounds, in: self.view, animated: true, completionHandler: completionHandler as? UIPrintInteractionController.CompletionHandler)
                print("通過・printButton.frame -> \(printButton.frame)")
                print("通過・printButton.bounds -> \(printButton.bounds)")
                //UIBarButtonItemの場合
                //参考サイト https://developer.apple.com/documentation/uikit/uiprintinteractioncontroller/1618169-present
                //pic.present(from: printUIButton, animated: true, completionHandler: nil)
                //・presentFromRect:inView:animated:completionHandler:は、アプリケーションのビューの任意の矩形からアニメーションでPopover Viewを表示します。
                //[controller presentFromRect:self.view inView:self.view animated:YES completionHandlercompletionHandler];
                pic.present(from: CGRect(x: 0, y: 0, width: 0, height: 0), in: self.view, animated: true, completionHandler: nil)
                print("iPadです")
            } else {
                //モーダル表示
                //・presentAnimated:completionHandler:は、画面の下端からスライドアップするページをアニメーション化します。これはiPhoneおよびiPod touchデバイス上で呼び出されることを想定しています。
                //[pic presentAnimated:YES completionHandler:completionHandler];
                pic.present(animated: true, completionHandler: completionHandler as? UIPrintInteractionController.CompletionHandler)
                print("iPhoneです")
            }
        }
    }
    
    func printInteractionController ( _ printInteractionController: UIPrintInteractionController, choosePaper paperList: [UIPrintPaper]) -> UIPrintPaper {
        
        for i in 0..<paperList.count {
            let paper: UIPrintPaper = paperList[i]
            print("paperListのビクセル is \(paper.paperSize.width) \(paper.paperSize.height)")
        }
        //ピクセル
        print("\npageSizeピクセル -> \(pageSize)")
        let bestPaper = UIPrintPaper.bestPaper(forPageSize: pageSize, withPapersFrom: paperList)
        //mmで用紙サイズと印刷可能範囲を表示
        print("paperSizeミリ -> \(bestPaper.paperSize.width / 72.0 * 25.4) \(bestPaper.paperSize.height / 72.0 * 25.4)")
        print("bestPaper -> \(bestPaper.printableRect.origin.x / 72.0 * 25.4) \(bestPaper.printableRect.origin.y / 72.0 * 25.4) \(bestPaper.printableRect.size.width / 72.0 * 25.4) \(bestPaper.printableRect.size.height / 72.0 * 25.4)\n")
        return bestPaper
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
}
    /*
     実行結果
     
     通過・printButton.frame -> (41.0, 167.0, 78.0, 30.0)
     通過・printButton.bounds -> (0.0, 0.0, 78.0, 30.0)
     iPadです
     
     3pageSizeピクセル -> (255.1181102362205, 581.1023622047244)
     paperSizeミリ -> (210.00000000000003, 297.0)
     bestPaper -> (6.35, 6.35, 197.3, 276.53999999999996)
     
     paperListのビクセル is (252.0, 360.0)
     paperListのビクセル is (255.11811023622047, 581.1023622047244)
     paperListのビクセル is (283.46456692913387, 419.5275590551181)
     paperListのビクセル is (288.0, 432.0)
     paperListのビクセル is (296.98582677165354, 684.0)
     paperListのビクセル is (297.6377952755906, 419.5275590551181)
     paperListのビクセル is (297.6377952755906, 666.1417322834645)
     paperListのビクセル is (311.81102362204723, 623.6220472440945)
     paperListのビクセル is (323.1496062992126, 459.21259842519686)
     paperListのビクセル is (340.15748031496065, 666.1417322834645)
     paperListのビクセル is (360.0, 504.0)
     paperListのビクセル is (360.0, 576.0)
     paperListのビクセル is (362.8346456692913, 515.9055118110236)
     paperListのビクセル is (419.5275590551181, 566.9291338582677)
     paperListのビクセル is (419.5275590551181, 595.2755905511812)
     paperListのビクセル is (515.9055118110236, 728.503937007874)
     paperListのビクセル is (595.2755905511812, 841.8897637795276)
     paperListのビクセル is (612.0, 792.0)
     
     pageSizeピクセル -> (255.1181102362205, 581.1023622047244)
     paperSizeミリ -> (90.0, 204.99999999999997)
     bestPaper -> (3.0, 12.0, 83.99999999999999, 180.99999999999997)
     
     */
