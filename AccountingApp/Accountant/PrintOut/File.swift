//
// 参考
// https://qiita.com/papassan/items/c3e89b0cdf461ac29faa

//
//  FB1006ViewController.swift
//  mamassan
//
//  Created by 福田敏一 on 2018/11/30.
//  Copyright © 2018 Toshikazu Fukuda. All rights reserved.
//
//国税庁サイト http://www.nta.go.jp/law/tsutatsu/kobetsu/hojin/010705/pdf/180401_02.pdf
//

import UIKit

class FB1006ViewController: UIViewController, UIPrintInteractionControllerDelegate {
    
    @IBOutlet weak var UIView: UIView!//CGRect(x: 0, y: 0, width: 480, height: 680)
    //画像は国税庁サイトの法人事業概況説明書FB1006の1枚目、つまり表面、ちなみに裏面が2枚目です
    //この法人事業概況説明書の毎年税務署から郵送される現物は1枚で両面印刷になっています
    //ダウンロードしてPDFからPNGへ変更すると幅2480pixelx3507pixel解像度300dpiです
    @IBOutlet weak var 画像: UIImageView!//CGRect(x: 6, y: 7, width: 469, height: 666)
    
    var pageSize = CGSize(width: 210 / 25.4 * 72, height: 297 / 25.4 * 72)
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //リスト 5-1 ページ範囲の選択が可能な単一のPDFドキュメント
    //- (IBAction)printContent:(id)sender {
    @IBAction func printContent(_ sender: UIButton) {
        // キャプチャする元UIViewに新たに追加したUIView範囲を取得する
        let rect = UIView.bounds//実行結果 : rect = (0.0, 0.0, 480.0, 680.0)
        print("通過・rect -> \(rect)")
        //参考サイト https://developer.apple.com/documentation/uikit/1623912-uigraphicsbeginimagecontextwitho
    //p-41・ビットマップグラフィックスコンテキストを使って新しい画像を生成
        //UIKitの場合、その手順は次のようになります。
        // 1. UIGraphicsBeginImageContextWithOptions関数でビットマップコンテキストを生成し、グラフィックススタックにプッシュします。
        //UIGraphicsBeginImageContextWithOptions(CGSizeMake(100.0,100.0), NO, 2.0);
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        // 2. UIKitまたはCore Graphicsのルーチンを使って、新たに生成したグラフィックスコンテキストに画像を描画します。
        //CGContextRef context = UIGraphicsGetCurrentContext();
        let CGContextRef : CGContext = UIGraphicsGetCurrentContext()!
        // view内の描画をcontextに複写するbitMap
        UIView.layer.render(in: CGContextRef)
        // 3. UIGraphicsGetImageFromCurrentImageContext関数を呼び出すと、描画した画像に基づく UIImageオブジェクトが生成され、返されます。必要ならば、さらに描画した上で再びこのメソッ ドを呼び出し、別の画像を生成することも可能です。
        //UIImage *backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
        let backgroundImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        // 4. UIGraphicsEndImageContextを呼び出してグラフィックススタックからコンテキストをポップします。
        UIGraphicsEndImageContext()
        
//印刷はここからです
    //p-58
        //印刷サポートの概要
        /*         大まかに言うと、印刷機能をアプリケーションに組み込む方法は2通りあます、UIActivityViewControllerを使っていて、ページ範囲を選んだり、用紙選択の処理をオーバーライドしたりする必要がなければ、印刷アクティビティを追加する、という方法があります。
         今回は私はこの方法で印刷します
         */
    //p-80 最後に、標準ビューコントローラのpresent*メソッドを使って、アクティビティビューを表示しま す。ここでユーザが印刷を選択すると、iOS側が印刷ジョブを生成するようになっています。詳しく は、『UIActivityViewController Class Reference 』および『UIActivity Class Reference 』を参照してください。
        
        let shareText = "Apple - Apple iPhone X"
        let shareWebsite = NSURL(string: "https://www.apple.com/jp/iphone-x/")!
        let shareImage = backgroundImage
        
        var activityItems = [] as [Any]
        activityItems = [shareText, shareWebsite] as [Any]
        activityItems.append(shareImage)
        //参考サイト https://developer.apple.com/documentation/uikit/uiactivityviewcontroller/1622019-init
        //Declaration
        //init(activityItems: [Any], applicationActivities: [UIActivity]?)
        let activityController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            // so that iPads won't crash・以下がないとiPadだとクラッシュします
            activityController.popoverPresentationController?.sourceView = self.view
            present(activityController, animated: true, completion: nil)
            print("iPadです・印刷物はフチなしで印刷されます")
        } else {
            present(activityController, animated: true, completion: nil)
            print("iPhoneです・印刷物はフチなしで印刷されます")
        }
        /*
    //p-58
         //それ以外の場合は、UIPrintInteractionControllerクラスを使って実装しなければなりません。
         //以下の実装は未使用で省略されています
         UIPrintInteractionController *pic = [UIPrintInteractionController] sharedPrintController];
         */
        //訂正します、今回は2つのコードは印刷には使用していませんが関数func printInteractionControllerを利用してbestPaper -> (0.0, 0.0, 210.00000000000003, 297.0)などを利用する為には必要でした、これで利用できます
        let pic = UIPrintInteractionController.shared
        /*
         if  (pic && UIPrintInteractionController canPrintData: self.myPDFData] ) { }
         if UIPrintInteractionController.canPrint(myPDFData as Data) {
         pic.delegate = self;
         */
        pic.delegate = self
        /*
         }
         //以下省略
         */
    }
    //p-78の「リスト 5-8 printInteractionController:choosePaper:メソッドの実装」
    /*
     - (UIPrintPaper *)printInteractionController:(UIPrintInteractionController *)pic choosePaper:(NSArray *)paperList {
     // カスタムメソッドとプロパティ...
     CGSize pageSize = [self pageSizeForDocumentType:self.document.type];
     return [UIPrintPaper bestPaperForPageSize:pageSize
     withPapersFromArray:paperList];
     }
     */
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
    
    /*
     実行結果
     通過・rect -> (0.0, 0.0, 480.0, 680.0)
     iPadです・印刷物はフチなしで印刷されます
     
     pageSizeピクセル -> (595.2755905511812, 841.8897637795276)
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
     
     pageSizeピクセル -> (595.2755905511812, 841.8897637795276)
     paperSizeミリ -> (210.00000000000003, 297.0)
     bestPaper -> (0.0, 0.0, 210.00000000000003, 297.0)
     
     */
    
    /*
     次にコードの解説を知りたい方に解説します

     法的書類に印刷する
     法的書類と書きましたが私は販売アプリと経理アプリと決算アプリと確定申告アプリを1つのアプリとして開発しています

     今回は国税庁の「法人事業概況説明書FB1006」を取り上げますが校正するコードは解説しません、印刷だけです、まずは正式に税務署から郵送される現物と同じに法人事業概況説明書の印刷が出来てからでないと、校正コードを埋め込んでも現物とのズレが出るでしょう ? だから楽しい校正作業は無駄なんですよ

     用意する書類は ? 別に個人で好きな書類を選択してください、今回は私は法人事業概況説明書ですが書類と置き換えます、書類はA4版とします

     ご存知でしょうが書類画像をstoryboardにセット方法

     私の場合、書類画像をPNGで幅2480pixelx3507pixel解像度300dpiで用意してプロジェクトに取り込みます
     元Viewに書類画像用のUIViewをCGRect(x: 0, y: 0, width: 480, height: 680)のサイズで追加します
     追加したUIViewに書類画像用にUIImageViewでCGRect(x: 6, y: 7, width: 469, height: 666)のサイズで追加します、この部分で現物書類と同じものが印刷されます、何度も納得がいくまでサイズ調整しました
     追加したUIImageViewに書類画像PNGを設定します
     運が良ければ、これでRunするとノーコードで書類画像が表示するでしょうね ? しかし、印刷のテストならこれでOKですが ? 実際に現物書類に印刷するのであればコツがあるのですよね ?

     コツの解説をするとすれば ? 私は「iOSにおける 描画と印刷のガイド」の理解不足が原因でした ? ご存知でしょうが ? これから印刷の部分を解説しますが ? ポイントは ? その前に、Appleのガイドの内容を説明します

     印刷と印刷されるものは別のものです
     印刷は2種類あります、理由はp52から解説がありますが、p58からの「印刷サポートの概要」が重要です
     印刷されるものは解説ではPDFとHTMLとTEXTとWebViewが解説されています
     しかし、この解説で私が求めていることを実現できませんでしたが、もしかして私の理解不足かと思いもう一度Appleの解説を読み直しました

     私はAppleの解説を理解する事に時間がかかりました、基本は書類と同じものを印刷することが目的だからですね ? 私は画像にラベルとかを設置して印刷すると校正なしに思うように印刷したい場所に文字が印刷されると期待していましたが、できませんでした、私は1年位、印刷には離れて他のコードを開発して完成したので最後に印刷が残りました、結局、印刷したい追加Viewを印刷対象にする事が必要でありました

     また、校正の話ですが ? 私は2016年のMacbook Pro 256GBを使用していますが書類の法人事業概況説明書の記入欄のすべての項目にラベルを設置すると正確ではありませんが最低でも金額の部分の9桁の左右の36項目の部分のラベルの総数は324個のラベルが必要ですよね ? 私はすべての記入箇所にラベルを設置しました、1日で終わると思いますが大変な作業でした、気付いたことは、これだけの数のラベルを1つのstoryboardに設置すると校正作業はPCの性能の限界でサイズの変更とかの処理に数十秒の遅延が発生します、私のMacの限界を感じてしまいますね ? もしかしたら私のプロジェクトは私のMacでは限界のようですね ? しかし、1日で1枚の書類は校正できますよ
     ここまで

     追加

     もしも、正確に校正して現物書類と同じに印刷ができたら、そして現物書類を使って印刷することも可能ですよね ? 専用紙でないいと受け付けてくれない書類は現物書類に印刷するためにラベルのみの印刷の工夫が必要ですね ? 各自で工夫しましょうね ?

     私の場合は

     storyboardにラベルのみの印刷をするボタンを設置しました
     ラベルのみが表示するように「画像.alpha = 0」にして消しました

     */
}

