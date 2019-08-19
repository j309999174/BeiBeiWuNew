//
//  ResetViewController.swift
//  BeiBeiWu
//
//  Created by 江东 on 2019/8/14.
//  Copyright © 2019 江东. All rights reserved.
//

import UIKit
import Alamofire
class ResetViewController: UIViewController {

    var titleType:String?
    var value:String?
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var portraitImage: UIImageView!
    @IBOutlet weak var valueText: UITextField!
    
    @IBOutlet weak var ageOutlet: UISegmentedControl!
    @IBAction func ageSegment(_ sender: UISegmentedControl) {
        value = sender.titleForSegment(at: sender.selectedSegmentIndex)
    }
    
   
    @IBOutlet weak var propertyOutlet: UISegmentedControl!
    @IBAction func propertySegment(_ sender: UISegmentedControl) {
        value = sender.titleForSegment(at: sender.selectedSegmentIndex)
    }
    
    @IBAction func submitBtn(_ sender: Any) {
        switch titleType {
        case "头像设置":
            setUserPortrait()
            break
        case "性别设置":
            submitValue(type: "性别", url: "reset")
            break
        case "属性设置":
            submitValue(type: "属性", url: "reset")
            break
        case "意见反馈":
            submitValue(type: "意见", url: "feedback")
            break
        default:
            submitValue(type: "其他", url: "reset")
            break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch titleType {
        case "头像设置":
            typeLabel.text = titleType
            portraitImage.isHidden = false
            break
        case "性别设置":
            ageOutlet.isHidden = false
            value = "男"
            typeLabel.text = titleType
            break
        case "属性设置":
            propertyOutlet.isHidden = false
            value = "Z"
            typeLabel.text = titleType
            break
        case "意见反馈":
            valueText.isHidden = false
            valueText.placeholder = titleType
            typeLabel.text = titleType
            break
        default:
            valueText.isHidden = false
            valueText.placeholder = titleType
            typeLabel.text = titleType
            break
        }
        
        
        let imgClick = UITapGestureRecognizer(target: self, action: #selector(imAction))
        portraitImage.addGestureRecognizer(imgClick)
        //开启 isUserInteractionEnabled 手势否则点击事件会没有反应
        portraitImage.isUserInteractionEnabled = true

        // Do any additional setup after loading the view.
    }
    //点击事件方法
    @objc func imAction() -> Void {
        print("图片点击事件")
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        let actionSheet = UIAlertController(title: "图片选择器", message: "选择图片", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "相机", style: .default, handler: {(action: UIAlertAction) in
            imagePickerController.sourceType = .camera
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "相册", style: .default, handler: {(action: UIAlertAction) in
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        actionSheet.popoverPresentationController!.sourceView = self.view
        actionSheet.popoverPresentationController!.sourceRect = CGRect(x: 0,y: 0,width: 1.0,height: 1.0);
        self.present(actionSheet, animated: true, completion: nil)
    }

    func setUserPortrait(){
        let rootPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                           .userDomainMask, true)[0] as String
        let filePath = "\(rootPath)/pickedimage.jpg"
        
        let imageURL = URL(fileURLWithPath: filePath)
        
        let userInfo = UserDefaults()
        let userID = userInfo.string(forKey: "userID")
        let userNickName = userInfo.string(forKey: "userNickName")
        Alamofire.upload( multipartFormData: { multipartFormData in
            multipartFormData.append(self.titleType!.data(using: String.Encoding.utf8)!, withName: "type")
            multipartFormData.append(userID!.data(using: String.Encoding.utf8)!, withName: "userID")
            multipartFormData.append(imageURL, withName: "userPortrait", fileName: "portrait.jpg", mimeType: "image/*")
        }, to: "https://applet.banghua.xin/app/index.php?i=99999&c=entry&a=webapp&do=reset&m=socialchat",
           encodingCompletion: { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    if let data = response.data, let utf8Text = String(data: data, encoding: .utf8){
                        print("Data: \(utf8Text)")
                        userInfo.setValue(utf8Text, forKey: "userPortrait")
                        //刷新融云缓存
                        let userinfo = RCUserInfo.init(userId: userID, name: userNickName, portrait: utf8Text)
                        RCIM.shared()?.refreshUserInfoCache(userinfo, withUserId: userID)
                        
                        self.view.makeToast("设置成功")
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "Main5") as! Main5ViewController
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            case .failure(let encodingError):
                print(encodingError)
            }
        }
        )
    }
    
    func submitValue(type:String,url:String){
        let userInfo = UserDefaults()
        let userID = userInfo.string(forKey: "userID")
        let userNickName = userInfo.string(forKey: "userNickName")
        let userPortrait = userInfo.string(forKey: "userPortrait")
        var parameters: Parameters?
        
        switch type {
        case "性别":
            parameters = ["type": titleType!,"userID":userID!,"value":value!]
            break
        case "属性":
            parameters = ["type": titleType!,"userID":userID!,"value":value!]
            break
        case "意见":
            value = valueText.text
            if(value == ""){
                self.view.makeToast("请输入内容")
            }else{
                parameters = ["type": titleType!,"userID":userID!,"nickname":userNickName!,"portrait":userPortrait!,"content":value!]
            }
            break
        default:
            value = valueText.text
            if(value == ""){
                self.view.makeToast("请输入内容")
            }else{
                parameters = ["type": titleType!,"userID":userID!,"value":value!]
            }
            break
        }
        
        Alamofire.request("https://applet.banghua.xin/app/index.php?i=99999&c=entry&a=webapp&do=\(url)&m=socialchat", method: .post, parameters: parameters).response { response in
            print("Request: \(String(describing: response.request))")
            print("Response: \(String(describing: response.response))")
            print("Error: \(String(describing: response.error))")
            
            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                print("Data: \(utf8Text)")
                if self.titleType == "昵称设置"{
                    userInfo.setValue(self.value!, forKey: "userNickName")
                    //刷新融云缓存
                    let userinfo = RCUserInfo.init(userId: userID, name:self.value!, portrait: userPortrait)
                    RCIM.shared()?.refreshUserInfoCache(userinfo, withUserId: userID)
                }
                self.view.makeToast("设置成功")
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "Main5") as! Main5ViewController
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
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

extension ResetViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        portraitImage.image = image
        //将选择的图片保存到Document目录下
        let fileManager = FileManager.default
        let rootPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                           .userDomainMask, true)[0] as String
        let filePath = "\(rootPath)/pickedimage.jpg"
        let imageData = image.jpegData(compressionQuality: 0.1)
        fileManager.createFile(atPath: filePath, contents: imageData, attributes: nil)
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}