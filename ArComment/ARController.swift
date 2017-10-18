//
//  ViewController.swift
//  ArComment
//
//  Created by 和田　継嗣 on 2017/07/15.
//  Copyright © 2017年 和田　継嗣. All rights reserved.
//

import UIKit
import SpriteKit
import ARKit

class ARController: UIViewController, ARSKViewDelegate, UITextFieldDelegate {
    
   // @IBOutlet var sceneView: ARSKView!
    var sceneView:ARSKView!
    private var myTextField: UITextField!
    private var pointTextField:UITextField!
    
    //url関連
    var url:String!
    //コンテント一覧
    var contentList:[String] = []
    var ptsLit:[Int] = []
    var anchorCount = 0
    var commentFlg = true
    var yheight = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        sceneView = ARSKView(frame:CGRect(x:0,y:0,width:self.view.frame.size.width,height:self.view.frame.size.height*2/3))
         self.view.addSubview(sceneView)
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and node count
        sceneView.showsFPS = true
        sceneView.showsNodeCount = true
        
        // Load the SKScene from 'Scene.sks'
        if let scene = SKScene(fileNamed: "Scene") {
            sceneView.presentScene(scene)
        }
        setTextView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingSessionConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
      self.configureObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
}


extension ARController{
    
    func setTextView(){
        // UITextFieldを作成する.
        myTextField = UITextField(
            frame: CGRect(x:10,y:self.view.frame.size.height-50,width:self.view.frame.size.width-80,height:50))
        // 表示する文字を代入する.
        myTextField.text = ""
        myTextField.tag = 0
        myTextField.layer.borderColor = UIColorFromRGB(0xA5FCEB).cgColor
        // Delegateを設定する.
        myTextField.delegate = self
        // 枠を表示する.
        myTextField.borderStyle = UITextBorderStyle.roundedRect
        // Viewに追加する.
        self.view.addSubview(myTextField)
        
        //pt用のも
        pointTextField = UITextField(
            frame: CGRect(x:10,y:self.view.frame.size.height-100,width:50,height:50))
        // 表示する文字を代入する.
        pointTextField.text = ""
        pointTextField.tag = 1
        pointTextField.layer.borderColor = UIColorFromRGB(0xA5FCEB).cgColor
        // Delegateを設定する.
        pointTextField.delegate = self
        // 枠を表示する.
        pointTextField.borderStyle = UITextBorderStyle.roundedRect
        // Viewに追加する.
        self.view.addSubview(pointTextField)
        
        //投稿ボタン
        let okButton = UIButton(
            frame:CGRect(x:self.view.frame.size.width-70,y:self.view.frame.size.height-60,width:60,height:50))
        okButton.backgroundColor = UIColorFromRGB(0xA5FCEB)
        okButton.setTitle("投稿", for: .normal)
        okButton.layer.cornerRadius = 20.0
        okButton.addTarget(self, action:#selector(ARController.pushText), for: .touchUpInside)
        self.view.addSubview(okButton)
        let comButton = UIButton(
            frame:CGRect(x:self.view.frame.size.width-120,y:self.view.frame.size.height-200,width:120,height:50))
        comButton.backgroundColor = UIColorFromRGB(0x43C5B1)
        comButton.setTitle("PBL表示", for: .normal)
        comButton.layer.cornerRadius = 20.0
        comButton.addTarget(self, action:#selector(ARController.getCommentList), for: .touchUpInside)
        self.view.addSubview(comButton)
    }
    
    @objc func pushText(){
        let text = myTextField.text
        let pts = pointTextField.text
        myTextField.endEditing(true)
        let request: Request = Request()
        let requestUrl:String = self.url.appending("?comment=\(text!)&point=\(pts!)")
        let url: URL = URL(string: requestUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
        try request.get(url: url, completionHandler: { data, response, error in
            print("きた\(data)\(error)")
        })
        
        self.handleTap()
    }
    
}


//コメント一覧関連
extension ARController{
    
    @objc func getCommentList(){
        let request: Request = Request()
        
        let url: URL = URL(string: self.url)!
        try request.get(url: url, completionHandler: { data, response, error in
            // code
            print("これレスポンスね\(response):こっちデータ\(data)")
            var personalData: Data =  data!//da.data(using: String.Encoding.utf8)!
            do {
                let json = try JSONSerialization.jsonObject(with: personalData, options: JSONSerialization.ReadingOptions.allowFragments) // JSONパース。optionsは型推論可
                let top = json as! NSDictionary // トップレベルが配列
                let contentList = top["content"] as! NSArray
                let ptList = top["pt"] as! NSArray
                for roop in contentList {
                    self.contentList.append(roop as! String)
                }
                for roop in ptList{
                    self.ptsLit.append(Int((roop as! NSString).doubleValue))
                }
                for contentIndex in 0...self.contentList.count-1{
                   // print("インデックス=>\(commentIndex),\(self.commentList[commentIndex])")
                    self.contentEvent()
                }
            } catch {
                print(error) // パースに失敗したときにエラーを表示
            }
        })
        
    }
    //コメント一覧取得用イベント発火
    @objc
    func contentEvent() {
        // Create anchor using the camera's current position
        if let currentFrame = sceneView.session.currentFrame {
            var translation = matrix_identity_float4x4
            let randomz = Float(Int.random(min: -5, max: 5))/10.0
            translation.columns.3.z = -2.0
            translation.columns.3.x = -(Float(self.yheight))/3.0
            self.yheight += 1
            let transform = simd_mul(currentFrame.camera.transform, translation)
            
            // Add a new anchor to the session
            let anchor = ARAnchor(transform: transform)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                // 秒後に実行したい処理
                self.sceneView.session.add(anchor: anchor)
            }
           
        }else{
        }
    }
}

extension ARController{
    // Notificationを設定
    func configureObserver() {
        
        let notification = NotificationCenter.default
        notification.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        notification.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    // Notificationを削除
    func removeObserver() {
        
        let notification = NotificationCenter.default
        notification.removeObserver(self)
    }
    
    // キーボードが現れた時に、画面全体をずらす。
    @objc func keyboardWillShow(notification: Notification?) {
        
        let rect = (notification?.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
        let duration: TimeInterval? = notification?.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double
        UIView.animate(withDuration: duration!, animations: { () in
            let transform = CGAffineTransform(translationX: 0, y: -(rect?.size.height)!)
            self.view.transform = transform
            
        })
    }
    
    // キーボードが消えたときに、画面を戻す
    @objc func keyboardWillHide(notification: Notification?) {
        
        let duration: TimeInterval? = notification?.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? Double
        UIView.animate(withDuration: duration!, animations: { () in
            
            self.view.transform = CGAffineTransform.identity
        })
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder() // Returnキーを押したときにキーボードを下げる
        return true
    }
    
    
    
    // MARK: - ARSKViewDelegate
    
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    func view(_ view: ARSKView, nodeFor anchor: ARAnchor) -> SKNode? {
        //コメント一覧反映の場合
        if(anchorCount != self.contentList.count-1){
            let contentText = "\(self.contentList[self.anchorCount]) : \(self.ptsLit[self.anchorCount])"
            let labelNode = SKLabelNode(text: contentText)
            //let labelNode = SKSpriteNode(imageNamed:"sample.png")
            labelNode.horizontalAlignmentMode = .center
            labelNode.verticalAlignmentMode = .center
            if(anchorCount < contentList.count-1){
                anchorCount += 1
            }
            print("内容=>\(contentText)")
            return labelNode;
        }else{
        //コメント投稿の場合
            let labelNode = SKLabelNode(text: "\(self.myTextField.text!):\(self.pointTextField.text!)")
            labelNode.horizontalAlignmentMode = .center
            labelNode.verticalAlignmentMode = .center
            return labelNode;
        }
    }
    
    @objc
    func handleTap() {
        // Create anchor using the camera's current position
        if let currentFrame = sceneView.session.currentFrame {
            
            // Create a transform with a translation of 0.2 meters in front of the camera
            var translation = matrix_identity_float4x4
            translation.columns.3.z = -3.0
            let transform = simd_mul(currentFrame.camera.transform, translation)
            
            // Add a new anchor to the session
            let anchor = ARAnchor(transform: transform)
            print("アhンカーです\(anchor)")
            print("アhンカー内容\(anchor.transform)")
            sceneView.session.add(anchor: anchor)
        }
    }
}
