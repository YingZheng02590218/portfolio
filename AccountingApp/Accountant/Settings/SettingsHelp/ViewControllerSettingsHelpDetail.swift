//
//  ViewControllerSettingsHelpDetail.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/12/25.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import UIKit

class ViewControllerSettingsHelpDetail: UIViewController {

    @IBOutlet var textView_aboutThisApp: UITextView!
    @IBOutlet var textView_thought: UITextView!
    @IBOutlet var textView_basicOfBookkeeping: UITextView!
    @IBOutlet var textView_setUp: UITextView!
    @IBOutlet var textView_setUp_basicInfo: UITextView!
    @IBOutlet var textView_setUp_account: UITextView!
    @IBOutlet var textView_setUp_accountEdit: UITextView!
    @IBOutlet var textView_configuration: UITextView!
    @IBOutlet var textView_journalEntry: UITextView!
    @IBOutlet var textView_journalEntry_edit: UITextView!
    @IBOutlet var textView_journalEntry_delete: UITextView!
    @IBOutlet var textView_journals: UITextView!
    
    
    var textView_switch: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        switch textView_switch {
        case 0:
            textView_aboutThisApp.isHidden = false
            let baseString = textView_aboutThisApp.text
            let attributedString = NSMutableAttributedString(string: baseString!)
            // 複数の属性を一気に指定します.
            // 全体の文字サイズを指定
            attributedString.addAttributes([
                .font: UIFont.systemFont(ofSize: 19)
            ], range: NSString(string: baseString!).range(of: baseString!))
            // カテゴリタイトルの文字サイズを指定
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 30)
            ], range: NSString(string: baseString!).range(of: "このアプリについて"))
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 20)
            ], range: NSString(string: baseString!).range(of: "アプリ名："))
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 20)
            ], range: NSString(string: baseString!).range(of: "概要："))
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 20)
            ], range: NSString(string: baseString!).range(of: "想定ユーザー："))
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 20)
            ], range: NSString(string: baseString!).range(of: "コンセプト："))
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 20)
            ], range: NSString(string: baseString!).range(of: "作成書類："))
            textView_aboutThisApp.attributedText = attributedString
            // ダークモード対応
            if (UITraitCollection.current.userInterfaceStyle == .dark) {
                /* ダークモード時の処理 */
                textView_aboutThisApp.textColor = .white
            } else {
                /* ライトモード時の処理 */
                textView_aboutThisApp.textColor = .black
            }
            break
        case 1:
            textView_thought.isHidden = false
//            textView_thought.font = .systemFont(ofSize: 19)
            let baseString = textView_thought.text
            let attributedString = NSMutableAttributedString(string: baseString!)
            // 複数の属性を一気に指定します.
            // 全体の文字サイズを指定
            attributedString.addAttributes([
                .font: UIFont.systemFont(ofSize: 19)
            ], range: NSString(string: baseString!).range(of: baseString!))
            // カテゴリタイトルの文字サイズを指定
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 30)
            ], range: NSString(string: baseString!).range(of: "当アプリで採用した会計概念"))
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 20)
            ], range: NSString(string: baseString!).range(of: "□　簿記の分類"))
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 20)
            ], range: NSString(string: baseString!).range(of: "□　帳簿会計の分類"))
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 20)
            ], range: NSString(string: baseString!).range(of: "□　会計帳簿の分類"))
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 20)
            ], range: NSString(string: baseString!).range(of: "□　仕訳の分類"))
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 20)
            ], range: NSString(string: baseString!).range(of: "□　帳簿決算（帳簿の締め切り）方法"))
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 20)
            ], range: NSString(string: baseString!).range(of: "□　経済活動の種類による分類"))
            textView_thought.attributedText = attributedString
            // ダークモード対応
            if (UITraitCollection.current.userInterfaceStyle == .dark) {
                /* ダークモード時の処理 */
                textView_thought.textColor = .white
            } else {
                /* ライトモード時の処理 */
                textView_thought.textColor = .black
            }
            break
        case 2:
            textView_basicOfBookkeeping.isHidden = false
            let baseString = textView_basicOfBookkeeping.text
            let attributedString = NSMutableAttributedString(string: textView_basicOfBookkeeping.text)
            let textAttachment = NSTextAttachment()
            textAttachment.image = UIImage(named: "簿記一巡.png")!
            let oldWidth = textAttachment.image!.size.width;
            print(textAttachment.image!.size.width)
            print(textView_basicOfBookkeeping.frame.size.width)
            print((UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.bounds.width)!)
            let scaleFactor = oldWidth / (textView_basicOfBookkeeping.frame.size.width - 20)*1; //for the padding inside the textView
            print(scaleFactor)
            textAttachment.image = UIImage.init(cgImage: textAttachment.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            let attrStringWithImage = NSAttributedString(attachment: textAttachment)
            print(textView_basicOfBookkeeping.text.unicodeScalars.count)
            // 複数の属性を一気に指定します.
            // 全体の文字サイズを指定
            attributedString.addAttributes([
                .font: UIFont.systemFont(ofSize: 19)
            ], range: NSString(string: baseString!).range(of: baseString!))
            // カテゴリタイトルの文字サイズを指定
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 30)
            ], range: NSString(string: baseString!).range(of: "1. 簿記の基礎"))
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 20)
            ], range: NSString(string: baseString!).range(of: "1. 取引の発生から財務諸表までの流れ"))
            attributedString.replaceCharacters(in: NSMakeRange(150, 1), with: attrStringWithImage)
            textView_basicOfBookkeeping.attributedText = attributedString
            // ダークモード対応
            if (UITraitCollection.current.userInterfaceStyle == .dark) {
                /* ダークモード時の処理 */
                textView_basicOfBookkeeping.textColor = .white
            } else {
                /* ライトモード時の処理 */
                textView_basicOfBookkeeping.textColor = .black
            }
            break
        case 3: // 初期設定の手順
            textView_setUp.isHidden = false
            let baseString = textView_setUp.text
            let attributedString = NSMutableAttributedString(string: textView_setUp.text)
            // 複数の属性を一気に指定します.
            // 全体の文字サイズを指定
            attributedString.addAttributes([
                .font: UIFont.systemFont(ofSize: 19)
            ], range: NSString(string: baseString!).range(of: baseString!))
            // カテゴリタイトルの文字サイズを指定
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 30)
            ], range: NSString(string: baseString!).range(of: "1. 初期設定の手順"))
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 20)
            ], range: NSString(string: baseString!).range(of: "    1. 基本情報の登録 "))
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 20)
            ], range: NSString(string: baseString!).range(of: "    2. 勘定科目体系の登録 "))
            textView_setUp.attributedText = attributedString
            // ダークモード対応
            if (UITraitCollection.current.userInterfaceStyle == .dark) {
                /* ダークモード時の処理 */
                textView_setUp.textColor = .white
            } else {
                /* ライトモード時の処理 */
                textView_setUp.textColor = .black
            }
            break
        case 4: // 基本情報の登録をしよう
            textView_setUp_basicInfo.isHidden = false
            let baseString = textView_setUp_basicInfo.text
            let attributedString = NSMutableAttributedString(string: textView_setUp_basicInfo.text)
            // 基本情報の登録　事業者名を設定しよう 設定画面
            let textAttachment = NSTextAttachment()
            textAttachment.image = UIImage(named: "TableViewControllerSettings_cell_user.png")!
            var oldWidth = textAttachment.image!.size.width
            print(textAttachment.image!.size.width)
            print(textView_setUp_basicInfo.frame.size.width)
            var scaleFactor = oldWidth / (textView_setUp_basicInfo.frame.size.width - 20)*3; // -20 for the padding inside the textView, *3 textViewの幅の三分の1のサイズにするため
            textAttachment.image = UIImage.init(cgImage: textAttachment.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            var attrStringWithImage = NSAttributedString(attachment: textAttachment)
            print(textView_setUp_basicInfo.text.unicodeScalars.count)
            print(NSString(string: baseString!).range(of: "こちらで設定した事業者名は"))
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "こちらで設定した事業者名は").location-3, 1), with: attrStringWithImage)
            // 基本情報の登録 事業者名を設定しよう 帳簿情報画面
            let textAttachmentt = NSTextAttachment()
            textAttachmentt.image = UIImage(named: "TableViewControllerSettingsInformation.png")!
            oldWidth = textAttachmentt.image!.size.width
            scaleFactor = oldWidth / (textView_setUp_basicInfo.frame.size.width - 20)*3; //for the padding inside the textView
            textAttachmentt.image = UIImage.init(cgImage: textAttachmentt.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            attrStringWithImage = NSAttributedString(attachment: textAttachmentt)
            print(textView_setUp_basicInfo.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "こちらで設定した事業者名は").location-2, 1), with: attrStringWithImage)
            // 基本情報の登録 決算日を設定しよう ①
            let textAttachment1 = NSTextAttachment()
            textAttachment1.image = UIImage(named: "TableViewControllerSettings_cell_list_settings_term.png")!
            oldWidth = textAttachment1.image!.size.width
            scaleFactor = oldWidth / (textView_setUp_basicInfo.frame.size.width - 20)*3; //for the padding inside the textView
            textAttachment1.image = UIImage.init(cgImage: textAttachment1.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            attrStringWithImage = NSAttributedString(attachment: textAttachment1)
            print(textView_setUp_basicInfo.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "こちらで設定した決算日は").location-3, 1), with: attrStringWithImage)
            // 基本情報の登録 決算日を設定しよう ②
            let textAttachment2 = NSTextAttachment()
            textAttachment2.image = UIImage(named: "Text View set Up basic Info2.png")!
            oldWidth = textAttachment2.image!.size.width
            scaleFactor = oldWidth / (textView_setUp_basicInfo.frame.size.width - 20)*3; //for the padding inside the textView
            textAttachment2.image = UIImage.init(cgImage: textAttachment2.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            attrStringWithImage = NSAttributedString(attachment: textAttachment2)
            print(textView_setUp_basicInfo.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "こちらで設定した決算日は").location-2, 1), with: attrStringWithImage)
            // 基本情報の登録 会計帳簿を作成しよう
            let textAttachment0 = NSTextAttachment()
            textAttachment0.image = UIImage(named: "TableViewControllerSettings_cell_list_settings_term.png")!
            oldWidth = textAttachment0.image!.size.width
            scaleFactor = oldWidth / (textView_setUp_basicInfo.frame.size.width - 20)*3; //for the padding inside the textView
            textAttachment0.image = UIImage.init(cgImage: textAttachment0.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            attrStringWithImage = NSAttributedString(attachment: textAttachment0)
            print(textView_setUp_basicInfo.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "会計帳簿を作成後に").location-4, 1), with: attrStringWithImage)
            // 基本情報の登録 会計帳簿を作成しよう ③
            let textAttachment3 = NSTextAttachment()
            textAttachment3.image = UIImage(named: "Text View set Up basic Info3.png")!
            oldWidth = textAttachment3.image!.size.width
            scaleFactor = oldWidth / (textView_setUp_basicInfo.frame.size.width - 20)*3; //for the padding inside the textView
            textAttachment3.image = UIImage.init(cgImage: textAttachment3.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            attrStringWithImage = NSAttributedString(attachment: textAttachment3)
            print(textView_setUp_basicInfo.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "会計帳簿を作成後に").location-3, 1), with: attrStringWithImage)
            // 基本情報の登録 会計帳簿を作成しよう ④
            let textAttachment4 = NSTextAttachment()
            textAttachment4.image = UIImage(named: "Text View set Up basic Info4.png")!
            oldWidth = textAttachment4.image!.size.width
            scaleFactor = oldWidth / (textView_setUp_basicInfo.frame.size.width - 20)*3; //for the padding inside the textView
            textAttachment4.image = UIImage.init(cgImage: textAttachment4.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            attrStringWithImage = NSAttributedString(attachment: textAttachment4)
            print(textView_setUp_basicInfo.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "会計帳簿を作成後に").location-2, 1), with: attrStringWithImage)
            // 複数の属性を一気に指定します.
            // 全体の文字サイズを指定
            attributedString.addAttributes([
                .font: UIFont.systemFont(ofSize: 19)
            ], range: NSString(string: baseString!).range(of: baseString!))
            // カテゴリタイトルの文字サイズを指定
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 30)
            ], range: NSString(string: baseString!).range(of: "2. 基本情報の登録をしよう"))
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 20)
            ], range: NSString(string: baseString!).range(of: "* 事業者名を設定しよう"))
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 20)
            ], range: NSString(string: baseString!).range(of: "* 決算日を設定しよう"))
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 20)
            ], range: NSString(string: baseString!).range(of: "* 会計帳簿を作成しよう"))
            textView_setUp_basicInfo.attributedText = attributedString
            // ダークモード対応
            if (UITraitCollection.current.userInterfaceStyle == .dark) {
                /* ダークモード時の処理 */
                textView_setUp_basicInfo.textColor = .white
            } else {
                /* ライトモード時の処理 */
                textView_setUp_basicInfo.textColor = .black
            }
            break
        case 5: // 勘定科目を設定しよう
            textView_setUp_account.isHidden = false
            let baseString = textView_setUp_account.text
            let attributedString = NSMutableAttributedString(string: textView_setUp_account.text)
            // 勘定科目体系の登録 勘定科目を一覧で表示 ①
            let textAttachment00 = NSTextAttachment()
            textAttachment00.image = UIImage(named: "Text View set Up1.png")!
            var oldWidth = textAttachment00.image!.size.width
            var scaleFactor = oldWidth / (textView_setUp_account.frame.size.width - 20)*3; //for the padding inside the textView
            textAttachment00.image = UIImage.init(cgImage: textAttachment00.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            var attrStringWithImage = NSAttributedString(attachment: textAttachment00)
            print(textView_setUp_account.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "表示順：").location-4, 1), with: attrStringWithImage)
            // 勘定科目体系の登録 勘定科目を一覧で表示 ②
            let textAttachment000 = NSTextAttachment()
            textAttachment000.image = UIImage(named: "Text View set Up2.png")!
            oldWidth = textAttachment000.image!.size.width
            scaleFactor = oldWidth / (textView_setUp_account.frame.size.width - 20)*3; //for the padding inside the textView
            textAttachment000.image = UIImage.init(cgImage: textAttachment000.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            attrStringWithImage = NSAttributedString(attachment: textAttachment000)
            print(textView_setUp_account.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "表示順：").location-3, 1), with: attrStringWithImage)
            // 勘定科目体系の登録 勘定科目を一覧で表示 ③
            let textAttachment0000 = NSTextAttachment()
            textAttachment0000.image = UIImage(named: "TableViewControllerCategoryList.png")!
            oldWidth = textAttachment0000.image!.size.width
            scaleFactor = oldWidth / (textView_setUp_account.frame.size.width - 20)*3; //for the padding inside the textView
            textAttachment0000.image = UIImage.init(cgImage: textAttachment0000.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            attrStringWithImage = NSAttributedString(attachment: textAttachment0000)
            print(textView_setUp_account.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "表示順：").location-2, 1), with: attrStringWithImage)
            // 勘定科目体系の登録 表示科目別に勘定科目を表示 ①
            let textAttachment0 = NSTextAttachment()
            textAttachment0.image = UIImage(named: "Text View set Up1.png")!
            oldWidth = textAttachment0.image!.size.width
            scaleFactor = oldWidth / (textView_setUp_account.frame.size.width - 20)*3; //for the padding inside the textView
            textAttachment0.image = UIImage.init(cgImage: textAttachment0.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            attrStringWithImage = NSAttributedString(attachment: textAttachment0)
            print(textView_setUp_account.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "BS (貸借対照表)科目と").location-4, 1), with: attrStringWithImage)
            // 勘定科目体系の登録　表示科目別に勘定科目を表示 ②
            let textAttachment1 = NSTextAttachment()
            textAttachment1.image = UIImage(named: "TableViewControllerSettingsCategory_categoriesBSandPL.png")!
            oldWidth = textAttachment1.image!.size.width
            scaleFactor = oldWidth / (textView_setUp_account.frame.size.width - 20)*3; //for the padding inside the textView
            textAttachment1.image = UIImage.init(cgImage: textAttachment1.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            attrStringWithImage = NSAttributedString(attachment: textAttachment1)
            print(textView_setUp_account.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "BS (貸借対照表)科目と").location-3, 1), with: attrStringWithImage)
            // 勘定科目体系の登録　表示科目別に勘定科目を表示 ③
            let textAttachment11 = NSTextAttachment()
            textAttachment11.image = UIImage(named: "TableViewControllerSettingsTaxonomyAccountByTaxonomyList.png")!
            oldWidth = textAttachment11.image!.size.width
            scaleFactor = oldWidth / (textView_setUp_account.frame.size.width - 20)*3; //for the padding inside the textView
            textAttachment11.image = UIImage.init(cgImage: textAttachment11.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            attrStringWithImage = NSAttributedString(attachment: textAttachment11)
            print(textView_setUp_account.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "BS (貸借対照表)科目と").location-2, 1), with: attrStringWithImage)
            // 勘定科目体系の登録　新規に追加登録する ①設定画面
            let textAttachmentttt = NSTextAttachment()
            textAttachmentttt.image = UIImage(named: "Text View set Up1.png")!
            oldWidth = textAttachmentttt.image!.size.width
            scaleFactor = oldWidth / (textView_setUp_account.frame.size.width - 20)*3; //for the padding inside the textView
            textAttachmentttt.image = UIImage.init(cgImage: textAttachmentttt.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            attrStringWithImage = NSAttributedString(attachment: textAttachmentttt)
            print(textView_setUp_account.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "勘定科目を追加登録後は").location-7, 1), with: attrStringWithImage)
            // 勘定科目体系の登録　新規に追加登録する ②
            let textAttachment2 = NSTextAttachment()
            textAttachment2.image = UIImage(named: "Text View set Up2.png")!
            oldWidth = textAttachment2.image!.size.width
            scaleFactor = oldWidth / (textView_setUp_account.frame.size.width - 20)*3; //for the padding inside the textView
            textAttachment2.image = UIImage.init(cgImage: textAttachment2.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            attrStringWithImage = NSAttributedString(attachment: textAttachment2)
            print(textView_setUp_account.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "勘定科目を追加登録後は").location-6, 1), with: attrStringWithImage)
            // 勘定科目体系の登録　新規に追加登録する ③
            let textAttachment3 = NSTextAttachment()
            textAttachment3.image = UIImage(named: "Text View set Up3.png")!
            oldWidth = textAttachment3.image!.size.width
            scaleFactor = oldWidth / (textView_setUp_account.frame.size.width - 20)*3; //for the padding inside the textView
            textAttachment3.image = UIImage.init(cgImage: textAttachment3.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            attrStringWithImage = NSAttributedString(attachment: textAttachment3)
            print(textView_setUp_account.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "勘定科目を追加登録後は").location-5, 1), with: attrStringWithImage)
            // 勘定科目体系の登録　新規に追加登録する ④
            let textAttachment4 = NSTextAttachment()
            textAttachment4.image = UIImage(named: "Text View set Up4.png")!
            oldWidth = textAttachment4.image!.size.width
            scaleFactor = oldWidth / (textView_setUp_account.frame.size.width - 20)*3; //for the padding inside the textView
            textAttachment4.image = UIImage.init(cgImage: textAttachment4.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            attrStringWithImage = NSAttributedString(attachment: textAttachment4)
            print(textView_setUp_account.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "勘定科目を追加登録後は").location-4, 1), with: attrStringWithImage)
            // 勘定科目体系の登録　新規に追加登録する ⑤
            let textAttachment5 = NSTextAttachment()
            textAttachment5.image = UIImage(named: "Text View set Up5.png")!
            oldWidth = textAttachment5.image!.size.width
            scaleFactor = oldWidth / (textView_setUp_account.frame.size.width - 20)*3; //for the padding inside the textView
            textAttachment5.image = UIImage.init(cgImage: textAttachment5.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            attrStringWithImage = NSAttributedString(attachment: textAttachment5)
            print(textView_setUp_account.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "勘定科目を追加登録後は").location-3, 1), with: attrStringWithImage)
            // 勘定科目体系の登録　新規に追加登録する ⑥
            let textAttachment6 = NSTextAttachment()
            textAttachment6.image = UIImage(named: "Text View set Up6.png")!
            oldWidth = textAttachment6.image!.size.width
            scaleFactor = oldWidth / (textView_setUp_account.frame.size.width - 20)*3; //for the padding inside the textView
            textAttachment6.image = UIImage.init(cgImage: textAttachment6.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            attrStringWithImage = NSAttributedString(attachment: textAttachment6)
            print(textView_setUp_account.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "勘定科目を追加登録後は").location-2, 1), with: attrStringWithImage)
            // 複数の属性を一気に指定します.
            // 全体の文字サイズを指定
            attributedString.addAttributes([
                .font: UIFont.systemFont(ofSize: 19)
            ], range: NSString(string: baseString!).range(of: baseString!))
            // カテゴリタイトルの文字サイズを指定
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 30)
            ], range: NSString(string: baseString!).range(of: "3. 勘定科目を設定しよう"))
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 20)
            ], range: NSString(string: baseString!).range(of: "* 準備資料"))
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 20)
            ], range: NSString(string: baseString!).range(of: "* 勘定科目の確認"))
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 20)
            ], range: NSString(string: baseString!).range(of: "* 勘定科目体系の図"))
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 20)
            ], range: NSString(string: baseString!).range(of: "* 新規に追加登録する"))
            textView_setUp_account.attributedText = attributedString
            // ダークモード対応
            if (UITraitCollection.current.userInterfaceStyle == .dark) {
                /* ダークモード時の処理 */
                textView_setUp_account.textColor = .white
            } else {
                /* ライトモード時の処理 */
                textView_setUp_account.textColor = .black
            }
            break
        case 6: // 勘定科目の編集しよう
            textView_setUp_accountEdit.isHidden = false
            let baseString = textView_setUp_accountEdit.text
            let attributedString = NSMutableAttributedString(string: textView_setUp_accountEdit.text)
            // 勘定科目体系の登録 修正をする ①
            let textAttachment00 = NSTextAttachment()
            textAttachment00.image = UIImage(named: "Text View set Up1.png")!
            var oldWidth = textAttachment00.image!.size.width
            var scaleFactor = oldWidth / (textView_setUp_accountEdit.frame.size.width - 20)*3; //for the padding inside the textView
            textAttachment00.image = UIImage.init(cgImage: textAttachment00.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            var attrStringWithImage = NSAttributedString(attachment: textAttachment00)
            print(textView_setUp_accountEdit.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "表示科目名のみ変更").location-7, 1), with: attrStringWithImage)
            // 勘定科目体系の登録 修正をする ②
            let textAttachment000 = NSTextAttachment()
            textAttachment000.image = UIImage(named: "Text View set Up2.png")!
            oldWidth = textAttachment000.image!.size.width
            scaleFactor = oldWidth / (textView_setUp_accountEdit.frame.size.width - 20)*3; //for the padding inside the textView
            textAttachment000.image = UIImage.init(cgImage: textAttachment000.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            attrStringWithImage = NSAttributedString(attachment: textAttachment000)
            print(textView_setUp_accountEdit.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "表示科目名のみ変更").location-6, 1), with: attrStringWithImage)
            // 勘定科目体系の登録 修正をする ③
            let textAttachment0000 = NSTextAttachment()
            textAttachment0000.image = UIImage(named: "TableViewControllerCategoryList1.png")!
            oldWidth = textAttachment0000.image!.size.width
            scaleFactor = oldWidth / (textView_setUp_accountEdit.frame.size.width - 20)*3; //for the padding inside the textView
            textAttachment0000.image = UIImage.init(cgImage: textAttachment0000.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            attrStringWithImage = NSAttributedString(attachment: textAttachment0000)
            print(textView_setUp_accountEdit.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "表示科目名のみ変更").location-5, 1), with: attrStringWithImage)
            // 勘定科目体系の登録 修正をする ④
            let textAttachment00000 = NSTextAttachment()
            textAttachment00000.image = UIImage(named: "TableViewControllerCategoryList2.png")!
            oldWidth = textAttachment00000.image!.size.width
            scaleFactor = oldWidth / (textView_setUp_accountEdit.frame.size.width - 20)*3; //for the padding inside the textView
            textAttachment00000.image = UIImage.init(cgImage: textAttachment00000.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            attrStringWithImage = NSAttributedString(attachment: textAttachment00000)
            print(textView_setUp_accountEdit.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "表示科目名のみ変更").location-4, 1), with: attrStringWithImage)
            // 勘定科目体系の登録 修正をする ⑤
            let textAttachment000000 = NSTextAttachment()
            textAttachment000000.image = UIImage(named: "TableViewControllerCategoryList3.png")!
            oldWidth = textAttachment000000.image!.size.width
            scaleFactor = oldWidth / (textView_setUp_accountEdit.frame.size.width - 20)*3; //for the padding inside the textView
            textAttachment000000.image = UIImage.init(cgImage: textAttachment000000.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            attrStringWithImage = NSAttributedString(attachment: textAttachment000000)
            print(textView_setUp_accountEdit.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "表示科目名のみ変更").location-3, 1), with: attrStringWithImage)
            // 勘定科目体系の登録 修正をする ⑥
            let textAttachment0000000 = NSTextAttachment()
            textAttachment0000000.image = UIImage(named: "TableViewControllerCategoryList4.png")!
            oldWidth = textAttachment0000000.image!.size.width
            scaleFactor = oldWidth / (textView_setUp_accountEdit.frame.size.width - 20)*3; //for the padding inside the textView
            textAttachment0000000.image = UIImage.init(cgImage: textAttachment0000000.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            attrStringWithImage = NSAttributedString(attachment: textAttachment0000000)
            print(textView_setUp_accountEdit.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "表示科目名のみ変更").location-2, 1), with: attrStringWithImage)
            
            // 勘定科目体系の登録 削除をする ①
            let textAttachment00000000 = NSTextAttachment()
            textAttachment00000000.image = UIImage(named: "Text View set Up1.png")!
            oldWidth = textAttachment00000000.image!.size.width
            scaleFactor = oldWidth / (textView_setUp_accountEdit.frame.size.width - 20)*3; //for the padding inside the textView
            textAttachment00000000.image = UIImage.init(cgImage: textAttachment00000000.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            attrStringWithImage = NSAttributedString(attachment: textAttachment00000000)
            print(textView_setUp_accountEdit.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "新規で追加した勘定科目").location-8, 1), with: attrStringWithImage)
            // 勘定科目体系の登録 削除をする ②
            let textAttachment000000000 = NSTextAttachment()
            textAttachment000000000.image = UIImage(named: "Text View set Up2.png")!
            oldWidth = textAttachment000000000.image!.size.width
            scaleFactor = oldWidth / (textView_setUp_accountEdit.frame.size.width - 20)*3; //for the padding inside the textView
            textAttachment000000000.image = UIImage.init(cgImage: textAttachment000000000.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            attrStringWithImage = NSAttributedString(attachment: textAttachment000000000)
            print(textView_setUp_accountEdit.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "新規で追加した勘定科目").location-7, 1), with: attrStringWithImage)
            // 勘定科目体系の登録 削除をする ③
            let textAttachment0000000000 = NSTextAttachment()
            textAttachment0000000000.image = UIImage(named: "Text View set Up3.png")!
            oldWidth = textAttachment0000000000.image!.size.width
            scaleFactor = oldWidth / (textView_setUp_accountEdit.frame.size.width - 20)*3; //for the padding inside the textView
            textAttachment0000000000.image = UIImage.init(cgImage: textAttachment0000000000.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            attrStringWithImage = NSAttributedString(attachment: textAttachment0000000000)
            print(textView_setUp_accountEdit.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "新規で追加した勘定科目").location-6, 1), with: attrStringWithImage)
            // 勘定科目体系の登録 削除をする ④
            let textAttachment444 = NSTextAttachment()
            textAttachment444.image = UIImage(named: "TableViewControllerCategoryList_delete1.png")!
            oldWidth = textAttachment444.image!.size.width
            scaleFactor = oldWidth / (textView_setUp_accountEdit.frame.size.width - 20)*3; //for the padding inside the textView
            textAttachment444.image = UIImage.init(cgImage: textAttachment444.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            attrStringWithImage = NSAttributedString(attachment: textAttachment444)
            print(textView_setUp_accountEdit.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "新規で追加した勘定科目").location-5, 1), with: attrStringWithImage)
            // 勘定科目体系の登録 削除をする ⑤
            let textAttachment555 = NSTextAttachment()
            textAttachment555.image = UIImage(named: "TableViewControllerCategoryList_delete2.png")!
            oldWidth = textAttachment555.image!.size.width
            scaleFactor = oldWidth / (textView_setUp_accountEdit.frame.size.width - 20)*3; //for the padding inside the textView
            textAttachment555.image = UIImage.init(cgImage: textAttachment555.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            attrStringWithImage = NSAttributedString(attachment: textAttachment555)
            print(textView_setUp_accountEdit.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "新規で追加した勘定科目").location-4, 1), with: attrStringWithImage)
            // 勘定科目体系の登録 削除をする ⑥
            let textAttachment666 = NSTextAttachment()
            textAttachment666.image = UIImage(named: "TableViewControllerCategoryList_delete3.png")!
            oldWidth = textAttachment666.image!.size.width
            scaleFactor = oldWidth / (textView_setUp_accountEdit.frame.size.width - 20)*3; //for the padding inside the textView
            textAttachment666.image = UIImage.init(cgImage: textAttachment666.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            attrStringWithImage = NSAttributedString(attachment: textAttachment666)
            print(textView_setUp_accountEdit.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "新規で追加した勘定科目").location-3, 1), with: attrStringWithImage)
            // 勘定科目体系の登録 削除をする ⑦
            let textAttachment777 = NSTextAttachment()
            textAttachment777.image = UIImage(named: "TableViewControllerCategoryList_delete4.png")!
            oldWidth = textAttachment777.image!.size.width
            scaleFactor = oldWidth / (textView_setUp_accountEdit.frame.size.width - 20)*3; //for the padding inside the textView
            textAttachment777.image = UIImage.init(cgImage: textAttachment777.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            attrStringWithImage = NSAttributedString(attachment: textAttachment777)
            print(textView_setUp_accountEdit.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "新規で追加した勘定科目").location-2, 1), with: attrStringWithImage)
            // 複数の属性を一気に指定します.
            // 全体の文字サイズを指定
            attributedString.addAttributes([
                .font: UIFont.systemFont(ofSize: 19)
            ], range: NSString(string: baseString!).range(of: baseString!))
            // カテゴリタイトルの文字サイズを指定
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 30)
            ], range: NSString(string: baseString!).range(of: "4. 勘定科目の編集しよう"))
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 20)
            ], range: NSString(string: baseString!).range(of: "* 修正をする"))
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 20)
            ], range: NSString(string: baseString!).range(of: "* 削除をする"))
            textView_setUp_accountEdit.attributedText = attributedString
            // ダークモード対応
            if (UITraitCollection.current.userInterfaceStyle == .dark) {
                /* ダークモード時の処理 */
                textView_setUp_accountEdit.textColor = .white
            } else {
                /* ライトモード時の処理 */
                textView_setUp_accountEdit.textColor = .black
            }
            break
        case 7: // 環境設定を確認・変更しよう
            textView_configuration.isHidden = false
            let baseString = textView_configuration.text
            let attributedString = NSMutableAttributedString(string: textView_configuration.text)
            // 勘定科目体系の登録 削除をする ⑥
            let textAttachment666 = NSTextAttachment()
            textAttachment666.image = UIImage(named: "TableViewControllerSettings_cell_list_settings_Journals.png")!
            var oldWidth = textAttachment666.image!.size.width
            var scaleFactor = oldWidth / (textView_configuration.frame.size.width - 20)*3; //for the padding inside the textView
            textAttachment666.image = UIImage.init(cgImage: textAttachment666.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            var attrStringWithImage = NSAttributedString(attachment: textAttachment666)
            print(textView_configuration.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "損益振替仕訳と資本振替仕訳の表示").location-3, 1), with: attrStringWithImage)
            // 勘定科目体系の登録 削除をする ⑦
            let textAttachment777 = NSTextAttachment()
            textAttachment777.image = UIImage(named: "TableViewControllerSettings_cell_list_settings_Journals1.png")!
            oldWidth = textAttachment777.image!.size.width
            scaleFactor = oldWidth / (textView_configuration.frame.size.width - 20)*3; //for the padding inside the textView
            textAttachment777.image = UIImage.init(cgImage: textAttachment777.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            attrStringWithImage = NSAttributedString(attachment: textAttachment777)
            print(textView_configuration.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "損益振替仕訳と資本振替仕訳の表示").location-2, 1), with: attrStringWithImage)
            // 複数の属性を一気に指定します.
            // 全体の文字サイズを指定
            attributedString.addAttributes([
                .font: UIFont.systemFont(ofSize: 19)
            ], range: NSString(string: baseString!).range(of: baseString!))
            // カテゴリタイトルの文字サイズを指定
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 30)
            ], range: NSString(string: baseString!).range(of: "5. 環境設定を確認・変更しよう"))
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 20)
            ], range: NSString(string: baseString!).range(of: "* 仕訳帳画面"))
            textView_configuration.attributedText = attributedString
            // ダークモード対応
            if (UITraitCollection.current.userInterfaceStyle == .dark) {
                /* ダークモード時の処理 */
                textView_configuration.textColor = .white
            } else {
                /* ライトモード時の処理 */
                textView_configuration.textColor = .black
            }
            break
        case 8: // 仕訳を入力する
            textView_journalEntry.isHidden = false
            let baseString = textView_journalEntry.text
            let attributedString = NSMutableAttributedString(string: textView_journalEntry.text)
            // 勘定科目体系の登録 削除をする ⑥
            let textAttachment666 = NSTextAttachment()
            textAttachment666.image = UIImage(named: "ViewControllerJournalEntry.png")!
            let oldWidth = textAttachment666.image!.size.width
            let scaleFactor = oldWidth / (textView_journalEntry.frame.size.width - 20)*3; //for the padding inside the textView
            textAttachment666.image = UIImage.init(cgImage: textAttachment666.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            let attrStringWithImage = NSAttributedString(attachment: textAttachment666)
            print(textView_journalEntry.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "① 日付の入力").location-2, 1), with: attrStringWithImage)
            // 複数の属性を一気に指定します.
            // 全体の文字サイズを指定
            attributedString.addAttributes([
                .font: UIFont.systemFont(ofSize: 19)
            ], range: NSString(string: baseString!).range(of: baseString!))
            // カテゴリタイトルの文字サイズを指定
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 30)
            ], range: NSString(string: baseString!).range(of: "4. 帳簿に記帳する"))
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 20)
            ], range: NSString(string: baseString!).range(of: "1. 仕訳を入力する"))
            textView_journalEntry.attributedText = attributedString
            // ダークモード対応
            if (UITraitCollection.current.userInterfaceStyle == .dark) {
                /* ダークモード時の処理 */
                textView_journalEntry.textColor = .white
            } else {
                /* ライトモード時の処理 */
                textView_journalEntry.textColor = .black
            }
            break
        case 9: // 仕訳を修正する
            textView_journalEntry_edit.isHidden = false
            let baseString = textView_journalEntry_edit.text
            let attributedString = NSMutableAttributedString(string: textView_journalEntry_edit.text)
            // 4. 帳簿に記帳する 2. 仕訳を修正する ①
            let textAttachment666 = NSTextAttachment()
            textAttachment666.image = UIImage(named: "TableViewControllerJournals.png")!
            var oldWidth = textAttachment666.image!.size.width
            var scaleFactor = oldWidth / (textView_journalEntry_edit.frame.size.width - 20)*3; //for the padding inside the textView
            textAttachment666.image = UIImage.init(cgImage: textAttachment666.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            var attrStringWithImage = NSAttributedString(attachment: textAttachment666)
            print(textView_journalEntry_edit.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "① 任意の仕訳を長押し").location-3, 1), with: attrStringWithImage)
            // 4. 帳簿に記帳する 2. 仕訳を修正する　②
            let textAttachment777 = NSTextAttachment()
            textAttachment777.image = UIImage(named: "TableViewControllerJournals1.png")!
            oldWidth = textAttachment777.image!.size.width
            scaleFactor = oldWidth / (textView_setUp_accountEdit.frame.size.width - 20)*3; //for the padding inside the textView
            textAttachment777.image = UIImage.init(cgImage: textAttachment777.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            attrStringWithImage = NSAttributedString(attachment: textAttachment777)
            print(textView_setUp_accountEdit.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "① 任意の仕訳を長押し").location-2, 1), with: attrStringWithImage)
            // 複数の属性を一気に指定します.
            // 全体の文字サイズを指定
            attributedString.addAttributes([
                .font: UIFont.systemFont(ofSize: 19)
            ], range: NSString(string: baseString!).range(of: baseString!))
            // カテゴリタイトルの文字サイズを指定
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 30)
            ], range: NSString(string: baseString!).range(of: "4. 帳簿に記帳する"))
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 20)
            ], range: NSString(string: baseString!).range(of: "2. 仕訳を修正する"))
            textView_journalEntry_edit.attributedText = attributedString
            // ダークモード対応
            if (UITraitCollection.current.userInterfaceStyle == .dark) {
                /* ダークモード時の処理 */
                textView_journalEntry_edit.textColor = .white
            } else {
                /* ライトモード時の処理 */
                textView_journalEntry_edit.textColor = .black
            }
            break
        case 10: // 仕訳を削除する
            textView_journalEntry_delete.isHidden = false
            let baseString = textView_journalEntry_delete.text
            let attributedString = NSMutableAttributedString(string: textView_journalEntry_delete.text)
            // 4. 帳簿に記帳する 2. 仕訳を修正する ①
            let textAttachment666 = NSTextAttachment()
            textAttachment666.image = UIImage(named: "TableViewControllerJournals.png")!
            var oldWidth = textAttachment666.image!.size.width
            var scaleFactor = oldWidth / (textView_journalEntry_delete.frame.size.width - 20)*3; //for the padding inside the textView
            textAttachment666.image = UIImage.init(cgImage: textAttachment666.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            var attrStringWithImage = NSAttributedString(attachment: textAttachment666)
            print(textView_journalEntry_delete.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "① 任意の仕訳を右から左へスワイプ").location-4, 1), with: attrStringWithImage)
            // 4. 帳簿に記帳する 2. 仕訳を修正する　②
            let textAttachment777 = NSTextAttachment()
            textAttachment777.image = UIImage(named: "TableViewControllerJournals2.png")!
            oldWidth = textAttachment777.image!.size.width
            scaleFactor = oldWidth / (textView_journalEntry_delete.frame.size.width - 20)*3; //for the padding inside the textView
            textAttachment777.image = UIImage.init(cgImage: textAttachment777.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            attrStringWithImage = NSAttributedString(attachment: textAttachment777)
            print(textView_journalEntry_delete.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "① 任意の仕訳を右から左へスワイプ").location-3, 1), with: attrStringWithImage)
            // 4. 帳簿に記帳する 2. 仕訳を修正する　③
            let textAttachment888 = NSTextAttachment()
            textAttachment888.image = UIImage(named: "TableViewControllerJournals3.png")!
            oldWidth = textAttachment888.image!.size.width
            scaleFactor = oldWidth / (textView_journalEntry_delete.frame.size.width - 20)*3; //for the padding inside the textView
            textAttachment888.image = UIImage.init(cgImage: textAttachment888.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            attrStringWithImage = NSAttributedString(attachment: textAttachment888)
            print(textView_journalEntry_delete.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "① 任意の仕訳を右から左へスワイプ").location-2, 1), with: attrStringWithImage)
            // 複数の属性を一気に指定します.
            // 全体の文字サイズを指定
            attributedString.addAttributes([
                .font: UIFont.systemFont(ofSize: 19)
            ], range: NSString(string: baseString!).range(of: baseString!))
            // カテゴリタイトルの文字サイズを指定
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 30)
            ], range: NSString(string: baseString!).range(of: "4. 帳簿に記帳する"))
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 20)
            ], range: NSString(string: baseString!).range(of: "3. 仕訳を削除する"))
            textView_journalEntry_delete.attributedText = attributedString
            // ダークモード対応
            if (UITraitCollection.current.userInterfaceStyle == .dark) {
                /* ダークモード時の処理 */
                textView_journalEntry_delete.textColor = .white
            } else {
                /* ライトモード時の処理 */
                textView_journalEntry_delete.textColor = .black
            }
            break
        case 11: // 入力した取引を確認しよう
            textView_journals.isHidden = false
            let baseString = textView_journals.text
            let attributedString = NSMutableAttributedString(string: textView_journals.text)
            // 仕訳帳 ①
            let textAttachment666 = NSTextAttachment()
            textAttachment666.image = UIImage(named: "TableViewControllerJournals4.png")!
            var oldWidth = textAttachment666.image!.size.width
            var scaleFactor = oldWidth / (textView_journals.frame.size.width - 20)*3; //for the padding inside the textView
            textAttachment666.image = UIImage.init(cgImage: textAttachment666.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            var attrStringWithImage = NSAttributedString(attachment: textAttachment666)
            print(textView_journals.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "* 総勘定元帳").location-3, 1), with: attrStringWithImage)
            // 総勘定元帳　①
            let textAttachment777 = NSTextAttachment()
            textAttachment777.image = UIImage(named: "TableViewControllerGeneralLedger.png")!
            oldWidth = textAttachment777.image!.size.width
            scaleFactor = oldWidth / (textView_journals.frame.size.width - 20)*3; //for the padding inside the textView
            textAttachment777.image = UIImage.init(cgImage: textAttachment777.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            attrStringWithImage = NSAttributedString(attachment: textAttachment777)
            print(textView_journals.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "② 任意の勘定").location-3, 1), with: attrStringWithImage)
            // 総勘定元帳　②
            let textAttachment888 = NSTextAttachment()
            textAttachment888.image = UIImage(named: "TableViewControllerGeneralLedger1.png")!
            oldWidth = textAttachment888.image!.size.width
            scaleFactor = oldWidth / (textView_journals.frame.size.width - 20)*3; //for the padding inside the textView
            textAttachment888.image = UIImage.init(cgImage: textAttachment888.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
            attrStringWithImage = NSAttributedString(attachment: textAttachment888)
            print(textView_journals.text.unicodeScalars.count)
            attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString!).range(of: "② 任意の勘定").location-2, 1), with: attrStringWithImage)
            // 複数の属性を一気に指定します.
            // 全体の文字サイズを指定
            attributedString.addAttributes([
                .font: UIFont.systemFont(ofSize: 19)
            ], range: NSString(string: baseString!).range(of: baseString!))
            // カテゴリタイトルの文字サイズを指定
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 30)
            ], range: NSString(string: baseString!).range(of: "4. 帳簿に記帳する"))
            attributedString.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 20)
            ], range: NSString(string: baseString!).range(of: "4. 入力した取引を確認しよう"))
            textView_journals.attributedText = attributedString
            // ダークモード対応
            if (UITraitCollection.current.userInterfaceStyle == .dark) {
                /* ダークモード時の処理 */
                textView_journals.textColor = .white
            } else {
                /* ライトモード時の処理 */
                textView_journals.textColor = .black
            }
            break
        default:
            break
        }
    }
}
