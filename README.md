
# iOS会計アプリ
アプリ名 : TheReckoning  
説明 : 複式簿記でつける会計帳簿アプリ
 
## App URL
### **https://apps.apple.com/us/app/id1535793378#?platform=iphone**  
 
## 主な機能
取引の情報を入力すると財務諸表を作成できる  
仕訳帳、総勘定元帳、試算表、精算表の作成と印刷  
貸借対照表、損益計算書の作成と印刷  
勘定科目の追加、削除、編集  
初回起動時にチュートリアルページを表示
  
## 使用方法
 ### 1.仕訳を登録
  ![画像1](https://is4-ssl.mzstatic.com/image/thumb/PurpleSource114/v4/06/59/22/06592244-79cf-1d19-1cb2-ec0f41c84e22/75fa3971-b900-4f55-9635-aa1eae0a8b26_Simulator_Screen_Shot_-_iPhone_Xs_Max_-_2020-10-15_at_01.32.22.png/230x0w.webp)
  取引を仕訳データとして登録します。  

 ### 2.会計帳簿を表示
  仕訳データを帳簿別に表示されます。

 #### 仕訳帳を表示
  ![画像2](https://is3-ssl.mzstatic.com/image/thumb/PurpleSource114/v4/41/9c/43/419c4329-92af-ae06-74da-58011cd0ed1c/5947984f-5926-48c0-95af-2f516f63ef1b_Simulator_Screen_Shot_-_iPhone_Xs_Max_-_2020-10-15_at_01.32.30.png/230x0w.webp)
  これまでに登録した仕訳をすべて表示されます。  

 #### 総勘定元帳を表示
  ![画像3](https://is1-ssl.mzstatic.com/image/thumb/PurpleSource124/v4/7e/7f/c6/7e7fc687-daa9-38ae-b4b4-696aa3857397/f5e8dc2e-a482-4f35-9e30-5a49d80ca73e_Simulator_Screen_Shot_-_iPhone_Xs_Max_-_2020-10-15_at_01.32.34.png/230x0w.webp)
  すべての勘定を一覧で表示されます。  

 #### 勘定を表示
  ![画像4](https://is4-ssl.mzstatic.com/image/thumb/PurpleSource124/v4/f3/dc/04/f3dc04d5-b092-8b05-6ef9-05f716209dee/92cd4ad8-feeb-4581-8d14-6ec45cfc5386_Simulator_Screen_Shot_-_iPhone_Xs_Max_-_2020-10-15_at_01.32.36.png/230x0w.webp)
  登録した仕訳の勘定科目別に仕訳が表示されます。  

 #### 決算書を表示
  ![画像5](https://is5-ssl.mzstatic.com/image/thumb/PurpleSource114/v4/52/62/11/526211b4-eae1-5e23-318d-c5b42afb490f/00244fba-2a5e-480f-b2d6-a26e868f1a3e_Simulator_Screen_Shot_-_iPhone_Xs_Max_-_2020-10-15_at_01.32.41.png/230x0w.webp)
  登録した仕訳を元に作成された決算書が表示されます。  
    ![画像6](https://is2-ssl.mzstatic.com/image/thumb/PurpleSource124/v4/a5/67/47/a567474e-bb3f-3e0e-c6fe-817b16c0cd38/90d1f8c4-37a0-42a8-90a0-64244b66d32d_Simulator_Screen_Shot_-_iPhone_Xs_Max_-_2020-10-15_at_01.32.43.png/230x0w.webp)
    ![画像7](https://is5-ssl.mzstatic.com/image/thumb/PurpleSource114/v4/41/83/25/41832564-36fb-ba04-f487-215af25fb87c/b4078cfa-c5cb-4f90-a5cf-9527f9c64859_Simulator_Screen_Shot_-_iPhone_Xs_Max_-_2020-10-15_at_01.32.48.png/230x0w.webp)

 ### 3.会計帳簿の印刷機能
  登録した仕訳を元に作成された決算書が印刷されます。
  
  
## 使用した技術
- 開発環境 : Xcode, Swift
- DataBase : Realm
- チュートリアル画面 : [Gecco](https://github.com/bannzai/Gecco)
- 画面デザイン : [EMTNeumorphicView](https://github.com/hirokimu/EMTNeumorphicView)
 