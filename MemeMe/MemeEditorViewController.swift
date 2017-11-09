//
//   MemeEditorViewController.swift
//  MemeMe
//
//  Created by David Mulvihill on 4/12/15.
//  Copyright (c) 2015 David Mulvihill. All rights reserved.
//

import UIKit
import MobileCoreServices

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    weak var activeField: UITextField!
    weak var memedImage: UIImage!
    
    let memeTextAttributes = [
        NSStrokeColorAttributeName: UIColor.black,
        NSForegroundColorAttributeName: UIColor.white,
        NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName: -3.0
    ] as [String : Any]
    
    @IBOutlet weak var memeImageView: UIImageView!
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
        
        
    func generateMemedImage() -> UIImage {
        
        //TODO: hide toolbar and navbar
        topToolbar.isHidden = true
        bottomToolbar.isHidden = true
        
        //Render view to an image

        UIGraphicsBeginImageContext(self.view.frame.size)
        if ((self.view.snapshotView(afterScreenUpdates: true)) != nil) {
            self.memedImage = memeImageView.image
        }else{
            
        }
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
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        if (info[UIImagePickerControllerOriginalImage] as? UIImage) != nil {
            self.memeImageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        }
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true, completion: nil)
    }
    
    // Move the view up when the keyboard comes out and covers text field
    func keyboardWillShow(_ notification: Notification) {
    
        let keyboardHeight = getKeyboardHeight(notification)
        
        if activeField.frame.origin.y > self.view.frame.maxY - keyboardHeight {
            self.view.frame.origin.y -= keyboardHeight
        }
        
    }
    
    func keyboardWillHide(_ notification: Notification) {
        
        self.view.frame.origin.y = 0.0
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(MemeEditorViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(MemeEditorViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
    
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func shareMeme(_ sender: AnyObject) {

        self.memedImage = generateMemedImage()
        
        let activityVC = UIActivityViewController(activityItems: [self.memedImage], applicationActivities: nil)
        activityVC.completionWithItemsHandler = { activity, success, items, error in }
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
        self.present(imagePicker, animated: true, completion: nil)
    }

    @IBAction func pickAnImage(_ sender: Any) {
        
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.mediaTypes = [kUTTypeImage as String]
        self.present(imagePicker, animated: true, completion: nil)
    }
    
}


