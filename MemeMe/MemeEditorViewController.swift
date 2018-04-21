//
//   MemeEditorViewController.swift
//  MemeMe
//
//  Created by David Mulvihill on 12/1/17.
//  Copyright (c) 2017 David Mulvihill. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVFoundation

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    weak var activeField: UITextField!
    weak var memedImage: UIImage!
    
    let memeTextAttributes:[String:Any] = [
        NSAttributedStringKey.strokeColor.rawValue: UIColor.black,
        NSAttributedStringKey.foregroundColor.rawValue: UIColor.white,
        NSAttributedStringKey.font.rawValue: UIFont(name: "HelveticaNeue-CondensedBlack", size: 35)!,
        NSAttributedStringKey.strokeWidth.rawValue: -3.0
    ]
    
    @IBOutlet weak var memeImageView: UIImageView!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var botText: UITextField!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    func initFields(textField: UITextField, withText text: String) {
        textField.defaultTextAttributes = memeTextAttributes
        textField.spellCheckingType = .no
        textField.autocorrectionType = .no
        textField.textAlignment = NSTextAlignment.center
        textField.autocapitalizationType = .allCharacters
        textField.text = text
        textField.delegate = self
    }
    
    func initScreen() {
        initFields(textField: topText, withText: "TOP")
        initFields(textField: botText, withText: "BOTTOM")
        memeImageView.image = #imageLiteral(resourceName: "LaunchImage")
    }

    override func viewDidLoad() {
     
        super.viewDidLoad()
        initScreen()

        // if no camera on the device disable the camera button
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        //Subscribe to the keyboard notifications, to allow the view to move when occluded by keyboard
        self.subscribeToKeyboardNotifications()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {

        super.viewWillDisappear(animated)
        self.unsubscribeFromKeyboardNotifications()

    }
    
    func save() {
        
        //create the meme object
        let meme = MeMe(topText: topText.text!, botText: botText.text!, image: memeImageView.image, memedImage: memedImage)
        NSLog("Meme text %s %s",meme.topText, meme.botText)
    }
        
    func hideToolBars(_ hide: Bool) {
        topToolbar.isHidden = hide
        bottomToolbar.isHidden = hide
    }
    
    func generateMemedImage() -> UIImage? {

        // hide the toolbars
        hideToolBars(true)
        
        // Render view to an image
        //UIGraphicsBeginImageContext(self.view.frame.size)
        UIGraphicsBeginImageContextWithOptions(self.view.frame.size, false, 0);
        
        self.view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // redisplay the toolbars
        hideToolBars(false)
        
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
    
    @objc func imagePickerController(_ picker: UIImagePickerController,
                                     didFinishPickingMediaWithInfo info: [String : Any]) {
        
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.memeImageView.image = image
        }
        
        picker.dismiss(animated: true, completion: nil)
        dismiss(animated: true, completion: nil)
    }

    @objc func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        //dismiss(animated: true, completion: nil)
    }
    
    // Move the view up when the keyboard comes out and covers text field
    
    @objc func keyboardWillShow(_ notification: Notification) {
    
        let keyboardHeight = getKeyboardHeight(notification)
    
        if activeField.frame.origin.y + activeField.frame.height > self.view.frame.maxY - keyboardHeight {
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
    
    
    @objc override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // handle social sharing of memed image
    
    @IBAction func shareMeme(_ sender: AnyObject) {

        let memedImage = generateMemedImage()
        
        if (memedImage != nil) {

            let activityVC = UIActivityViewController(activityItems: [memedImage as Any], applicationActivities: nil)
            activityVC.completionWithItemsHandler = {(activityTypeChosen:UIActivityType?, completed:Bool, returnedItems:[Any]?, error:NSError?) -> Void in
            
                if activityTypeChosen == nil {
                    NSLog("%s\n","user cancelled")
                } else {
                    if completed {
                        NSLog("User chose an activity and iOS sent it to that other app/service/whatever OK")
                        self.save();
                    } else {
                        NSLog("There was an error: \(String(describing: error))")
                    }
                }
                activityVC.dismiss(animated: true, completion: nil)

            } as? UIActivityViewControllerCompletionWithItemsHandler

            self.present(activityVC, animated: true, completion: nil)
        } else {
            NSLog("%s","memeImage is nil")
        }
    }
    
    @IBAction func cancelEdit(_ sender: AnyObject) {
        
        self.dismiss(animated: true, completion: nil)
        //self.viewDidLoad()
        //self.viewWillAppear(false)
        
    }
    
    }
    
    func presentImagePickerWith(sourceType: UIImagePickerControllerSourceType) {
        
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        imagePicker.mediaTypes = [kUTTypeImage as String]
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func pickImageFromCamera(_ sender: Any) {
    
        presentImagePickerWith(sourceType: UIImagePickerControllerSourceType.camera)

    }

    @IBAction func pickAnImage(_ sender: Any) {
        
        presentImagePickerWith(sourceType: UIImagePickerControllerSourceType.photoLibrary)

    }
}


