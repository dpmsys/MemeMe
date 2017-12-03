//
//   MemeEditorViewController.swift
//  MemeMe
//
//  Created by David Mulvihill on 4/12/15.
//  Copyright (c) 2015 David Mulvihill. All rights reserved.
//

import UIKit
import MobileCoreServices
import Photos
import PhotosUI

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    weak var activeField: UITextField!
    weak var memedImage: UIImage!
    
    let memeTextAttributes:[String:Any] = [
        NSAttributedStringKey.strokeColor.rawValue: UIColor.black,
        NSAttributedStringKey.foregroundColor.rawValue: UIColor.white,
        NSAttributedStringKey.font.rawValue: UIFont(name: "HelveticaNeue-CondensedBlack", size: 20)!,
        NSAttributedStringKey.strokeWidth.rawValue: -3.0
    ]
    
    @IBOutlet weak var memeImageView: UIImageView!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var botText: UITextField!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        
        self.topText.spellCheckingType = .no
        self.topText.autocorrectionType = .no
        self.topText.textAlignment = NSTextAlignment.center
        self.topText.defaultTextAttributes = memeTextAttributes
        self.topText.text = "TOP"
        self.topText.delegate = self

        self.botText.spellCheckingType = .no
        self.botText.autocorrectionType = .no
        self.botText.textAlignment = NSTextAlignment.center
        self.botText.defaultTextAttributes = memeTextAttributes
        self.botText.text = "BOTTOM"
        self.botText.delegate = self
        
        // if no camera on the device disable the camera button
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
        super.viewDidLoad()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        //Subscribe to the keyboard notifications, to allow the view to move when occluded by keyboard
        self.subscribeToKeyboardNotifications()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {

        self.unsubscribeFromKeyboardNotifications()
        super.viewWillDisappear(animated)
    
    }
    
    func checkPermission() {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .authorized:
            print("Access is granted by user")
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({
                (newStatus) in
                print("status is \(newStatus)")
                if newStatus ==  PHAuthorizationStatus.authorized {
                    /* do stuff here */
                    print("success")
                }
            })
            print("It is not determined until now")
        case .restricted:
            // same same
            print("User do not have access to photo album.")
        case .denied:
            // same same
            print("User has denied the permission.")
        }
    }
    
    func memeSharedHandler(_ activity: String!, completed: Bool, items: [AnyObject]!, error: NSError!) {
        
        if completed {
            //     self.save()
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    func save() {
        //create the meme
        
        // var meme = MeMe(toptext: topText.text, bottext: botText.text, image: memeImageView.image, memedImage: memedImage)
        
        //let object = UIApplication.sharedApplication().delegate
        // let appDelegate = object as! AppDelegate
        //appDelegate.sentMemes.append(meme)
        
        
    }
        
        
    func generateMemedImage() -> UIImage? {
        
        //TODO: hide toolbar and navbar
        topToolbar.isHidden = true
        bottomToolbar.isHidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        
        //TODO: show hidden toolbar and navbar
        topToolbar.isHidden = false
        bottomToolbar.isHidden = false
        
        return memedImage
    
    }
    
    
    // textField delegates
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        activeField = textField
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        activeField = nil
        
        return true
    }
    
    // imagePicker delegates
    
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.memeImageView.image = image
        }
        picker.dismiss(animated: true, completion: nil)
        dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        dismiss(animated: true, completion: nil)
    }
    
    // Move the view up when the keyboard comes out and covers text field
    @objc func keyboardWillShow(_ notification: Notification) {
    
        let keyboardHeight = getKeyboardHeight(notification)
        
        if activeField.frame.origin.y > self.view.frame.maxY - keyboardHeight {
            self.view.frame.origin.y -= keyboardHeight
        }
        
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        
        self.view.frame.origin.y = 0.0
    }
    
    @objc func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    @objc func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(MemeEditorViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(MemeEditorViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func unsubscribeFromKeyboardNotifications() {
    
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func shareMeme(_ sender: AnyObject) {

        memedImage = generateMemedImage()
        
        let activityVC = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        activityVC.completionWithItemsHandler = {(activityTypeChosen:UIActivityType?, completed:Bool, returnedItems:[Any]?, error:NSError?) -> Void in
            
            // ReturnedItems is an array of modified NSExtensionItem, or nil of nothing modified
            // if (activityType == nil) User dismissed the view controller without making a selection.
            
            // Dismiss the view controller we presented
            // (assume a reference to it was stored in self.activityVC)
            
            activityVC.dismiss(animated: true, completion: {
                if activityTypeChosen == nil {
                    NSLog("User canceled without choosing anything")
                }
                else if completed {
                    NSLog(")User chose an activity and iOS sent it to that other app/service/whatever OK")
                }
                else {
                    NSLog("There was an error: \(String(describing: error))")
                }
            })
            } as? UIActivityViewControllerCompletionWithItemsHandler

        self.present(activityVC, animated: true, completion: nil)
    }
    
    @IBAction func cancelEdit(_ sender: AnyObject) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func pickImageFromCamera(_ sender: Any) {
    
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.camera
        imagePicker.mediaTypes = [kUTTypeImage as String]
        present(imagePicker, animated: true, completion: nil)
    }

    @IBAction func pickAnImage(_ sender: Any) {
        
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.mediaTypes = [kUTTypeImage as String]
        present(imagePicker, animated: true, completion: nil)
    }
}


