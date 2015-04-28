//
//   MemeEditorViewController.swift
//  MemeMe
//
//  Created by David Mulvihill on 4/12/15.
//  Copyright (c) 2015 David Mulvihill. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    weak var activeField: UITextField!
    weak var memedImage: UIImage!
    weak var activityController: UIActivityViewController!
    
    let memeTextAttributes = [
        NSStrokeColorAttributeName: UIColor.blackColor(),
        NSForegroundColorAttributeName: UIColor.whiteColor(),
        NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName: -3.0
    ]
    
    @IBOutlet weak var memeImageView: UIImageView!
    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var botText: UITextField!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        
        self.topText.textAlignment = NSTextAlignment.Center
        self.topText.defaultTextAttributes = memeTextAttributes
        self.topText.text = "TOP"
        self.topText.delegate = self

        self.botText.textAlignment = NSTextAlignment.Center
        self.botText.defaultTextAttributes = memeTextAttributes
        self.botText.text = "BOTTOM"
        self.botText.delegate = self
        
        // if no camera on the device disable the camera button
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        super.viewDidLoad()
        
    }
    
    
    override func viewWillAppear(animated: Bool) {
        
        //Subscribe to the keyboard notifications, to allow the view to move when occluded by keyboard
        self.subscribeToKeyboardNotifications()
        
    }
    
    override func viewWillDisappear(animated: Bool) {

        self.unsubscribeFromKeyboardNotifications()
        super.viewWillDisappear(animated)
    
    }
    

    
    func memeSharedHandler (activityType: String!, completed: Bool, returnedItems: [AnyObject]!, activityError: NSError!) -> Void {
        
        self.save()
        self.activityController.dismissViewControllerAnimated(true, completion: nil)

    }
    
    func save() {
        //create the meme
        
        var meme = MeMe(toptext: topText.text, bottext: botText.text, image: memeImageView.image, memedImage: memedImage)
        
    }
        
        
    func generateMemedImage() -> UIImage {
        
        //TODO: hide toolbar and navbar
        topToolbar.hidden = true
        bottomToolbar.hidden = true
        
        //Render view to an image
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        
        //TODO: show hidden toolbar and navbar
        topToolbar.hidden = false
        bottomToolbar.hidden = false
        
        return memedImage
    
    }
    
    
    // textField delegates
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        activeField = textField
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        activeField = nil
        
        return true
    }
    
    // imagePicker delegates
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
    
        picker.dismissViewControllerAnimated(true, completion: nil)
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.memeImageView.image = image
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Move the view up when the keyboard comes out and covers text field
    func keyboardWillShow(notification: NSNotification) {
    
        let keyboardHeight = getKeyboardHeight(notification)
        
        if activeField.frame.origin.y > self.view.frame.maxY - keyboardHeight {
            self.view.frame.origin.y -= keyboardHeight
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        self.view.frame.origin.y = 0.0
    }
    
    func getKeyboardHeight(notification:NSNotification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    func subscribeToKeyboardNotifications() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
    
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func shareMeme(sender: AnyObject) {

        self.memedImage = generateMemedImage()
        
        let activityController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        self.activityController.completionWithItemsHandler = self.memeSharedHandler as UIActivityViewControllerCompletionWithItemsHandler
        
        self.presentViewController(activityController, animated: true, completion: nil)
    
    }
    
    @IBAction func cancelEdit(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    
    }
    
    @IBAction func pickImageFromCamera(sender: AnyObject) {
    
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }

    @IBAction func pickAnImage(sender: AnyObject) {
        
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
}


