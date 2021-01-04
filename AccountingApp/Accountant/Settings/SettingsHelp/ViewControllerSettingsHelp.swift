//
//  ViewControllerSettingsHelp.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/12/25.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import UIKit

class ViewControllerSettingsHelp: UIViewController {

    @IBOutlet var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let baseString = textView.text
        let attributedString = NSMutableAttributedString(string: baseString!)
        // 複数の属性を一気に指定します.
        // 全体の文字サイズを指定
        attributedString.addAttributes([
            .font: UIFont.systemFont(ofSize: 19)
        ], range: NSString(string: baseString!).range(of: baseString!))
        // カテゴリタイトルの文字サイズを指定
        attributedString.addAttributes([
            .font: UIFont.boldSystemFont(ofSize: 30)
        ], range: NSString(string: baseString!).range(of: "1. 概要"))
        attributedString.addAttributes([
            .font: UIFont.boldSystemFont(ofSize: 30)
        ], range: NSString(string: baseString!).range(of: "2. 基礎知識"))
        attributedString.addAttributes([
            .font: UIFont.boldSystemFont(ofSize: 30)
        ], range: NSString(string: baseString!).range(of: "3. 初期設定"))
        attributedString.addAttributes([
            .font: UIFont.boldSystemFont(ofSize: 30)
        ], range: NSString(string: baseString!).range(of: "4. 帳簿に記帳する"))
        attributedString.addAttributes([
            .font: UIFont.boldSystemFont(ofSize: 30)
        ], range: NSString(string: baseString!).range(of: "5. 決算準備"))
        attributedString.addAttributes([
            .font: UIFont.boldSystemFont(ofSize: 30)
        ], range: NSString(string: baseString!).range(of: "6. 決算作業"))
        // リンクを設置
        attributedString.addAttribute(.link,
                                      value: "Link0",
                                      range: NSString(string: baseString!).range(of: "このアプリについて"))
        attributedString.addAttribute(.link,
                                      value: "Link1",
                                      range: NSString(string: baseString!).range(of: "当アプリで採用した会計概念"))
        attributedString.addAttribute(.link,
                                      value: "Link2",
                                      range: NSString(string: baseString!).range(of: "簿記の基礎"))
//        attributedString.addAttribute(.link,
//                                      value: "Link3",
//                                      range: NSString(string: baseString!).range(of: "初期設定の手順"))
        attributedString.addAttribute(.link,
                                      value: "Link4",
                                      range: NSString(string: baseString!).range(of: "基本情報の登録をしよう"))
        attributedString.addAttribute(.link,
                                      value: "Link5",
                                      range: NSString(string: baseString!).range(of: "勘定科目を設定しよう"))
        attributedString.addAttribute(.link,
                                      value: "Link6",
                                      range: NSString(string: baseString!).range(of: "勘定科目の編集しよう"))
        attributedString.addAttribute(.link,
                                      value: "Link7",
                                      range: NSString(string: baseString!).range(of: "環境設定を確認・変更しよう"))
        attributedString.addAttribute(.link,
                                      value: "Link8",
                                      range: NSString(string: baseString!).range(of: "仕訳を入力する"))
        attributedString.addAttribute(.link,
                                      value: "Link9",
                                      range: NSString(string: baseString!).range(of: "仕訳を修正する"))
        attributedString.addAttribute(.link,
                                      value: "Link10",
                                      range: NSString(string: baseString!).range(of: "仕訳を削除する"))
        attributedString.addAttribute(.link,
                                      value: "Link11",
                                      range: NSString(string: baseString!).range(of: "入力した取引を確認しよう"))
        textView.attributedText = attributedString
        // ダークモード対応
        if (UITraitCollection.current.userInterfaceStyle == .dark) {
            /* ダークモード時の処理 */
            textView.textColor = .white
        } else {
            /* ライトモード時の処理 */
            textView.textColor = .black
        }
        textView.frame = CGRect(x: 0, y: 0, width: (UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.bounds.width)!, height: (UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.bounds.height)!)
        textView.center = view.center
        textView.isSelectable = true
        textView.isEditable = false
        textView.delegate = self
        view.addSubview(textView)
    }
}

extension UIViewController: UITextViewDelegate {
    public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        // Storyboardを呼び出し
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        // Storyboard内のViewControllerをIDから呼び出し
        let viewController = storyboard.instantiateViewController(withIdentifier: "TermOfUse") as! ViewControllerSettingsHelpDetail

        let urlString = URL.absoluteString
        
        if urlString == "Link0" {
            print("このアプリについてのリンクがタップされました")
            // ログ送信処理
            // 詳細画面を開く処理
            viewController.navigationItem.title = "このアプリについて"
            viewController.textView_switch = 0
        }

        if urlString == "Link1" {
            print("当アプリで採用した会計概念のリンクがタップされました")
            // ログ送信処理
            // 詳細画面を開く処理
            viewController.navigationItem.title = "当アプリで採用した会計概念"
            viewController.textView_switch = 1
        }

        if urlString == "Link2" {
            print("簿記の基礎のリンクがタップされました")
            // ログ送信処理
            // 詳細画面を開く処理
            viewController.navigationItem.title = "簿記の基礎"
            viewController.textView_switch = 2
        }
        
        if urlString == "Link3" {
            print("初期設定の手順のリンクがタップされました")
            // ログ送信処理
            // 詳細画面を開く処理
            viewController.navigationItem.title = "初期設定の手順"
            viewController.textView_switch = 3
        }
        if urlString == "Link4" {
            print("基本情報の登録をしようのリンクがタップされました")
            // ログ送信処理
            // 詳細画面を開く処理
            viewController.navigationItem.title = "基本情報の登録をしよう"
            viewController.textView_switch = 4
        }
        if urlString == "Link5" {
            print("勘定科目を設定しようのリンクがタップされました")
            // ログ送信処理
            // 詳細画面を開く処理
            viewController.navigationItem.title = "勘定科目を設定しよう"
            viewController.textView_switch = 5
        }
        if urlString == "Link6" {
            print("勘定科目の編集しようのリンクがタップされました")
            // ログ送信処理
            // 詳細画面を開く処理
            viewController.navigationItem.title = "勘定科目の編集しよう"
            viewController.textView_switch = 6
        }
        if urlString == "Link7" {
            print("環境設定を確認・変更しようのリンクがタップされました")
            // ログ送信処理
            // 詳細画面を開く処理
            viewController.navigationItem.title = "環境設定を確認・変更しよう"
            viewController.textView_switch = 7
        }
        if urlString == "Link8" {
            print("仕訳を入力するのリンクがタップされました")
            // ログ送信処理
            // 詳細画面を開く処理
            viewController.navigationItem.title = "仕訳を入力する"
            viewController.textView_switch = 8
        }
        if urlString == "Link9" {
            print("仕訳を修正するのリンクがタップされました")
            // ログ送信処理
            // 詳細画面を開く処理
            viewController.navigationItem.title = "仕訳を修正する"
            viewController.textView_switch = 9
        }
        if urlString == "Link10" {
            print("仕訳を削除するのリンクがタップされました")
            // ログ送信処理
            // 詳細画面を開く処理
            viewController.navigationItem.title = "仕訳を削除する"
            viewController.textView_switch = 10
        }
        if urlString == "Link11" {
            print("入力した取引を確認しようのリンクがタップされました")
            // ログ送信処理
            // 詳細画面を開く処理
            viewController.navigationItem.title = "入力した取引を確認しよう"
            viewController.textView_switch = 11
        }
        // 画面遷移
        present(viewController, animated: true, completion: nil)
        
        return false // 通常のURL遷移を行わない
    }
}

//extension ViewControllerSettingsHelp: UITextViewDelegate {
//    public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
//        let urlString = URL.absoluteString
//        if urlString == "TermOfUseLink" {
//            // Storyboardを呼び出し
//            let storyboard = UIStoryboard(name: "ViewControllerSettingsHelpDetail", bundle: nil)
//            // Storyboard内のViewControllerをIDから呼び出し
//            let viewController = storyboard.instantiateViewController(withIdentifier: "TermOfUse")
//            // 画面遷移
//            navigationController?.pushViewController(viewController, animated: true)
//            return false // 通常のURL遷移を行わない
//        }
//        return true // 通常のURL遷移を行う
//    }
//}
