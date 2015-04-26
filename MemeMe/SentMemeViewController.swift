//
//  SentMemeViewController.swift
//  MemeMe
//
//  Created by David Mulvihill on 3/31/15.
//  Copyright (c) 2015 David Mulvihill. All rights reserved.
//

import UIKit


class SentMemeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var sentMemes: [MeMe]!
    
    override func viewWillAppear(animated: Bool) {
       
        super.viewWillAppear(true)
        
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        sentMemes = appDelegate.sentMemes
    
    }
    
    override func viewDidLoad() {
        
        //    var newMeme: MeMe!
        var image: UIImage!
        var memedImage: UIImage!
        var cnt: Int?
        
        super.viewDidLoad()
        

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "+", style: UIBarButtonItemStyle.Plain, target: self, action: "newMeme")
        // Do any additional setup after loading the view, typically from a nib.
        
        if let cnt = sentMemes?.count {
            
            //TODO: show my sent memes
        
        }else{
            newMeme()
        }
    }

    
    //  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    //    if (segue.identifier == "memeEditorSegue") {
    //        let memeEditorVC:MemeEditorViewController = segue.destinationViewController as!
    //        MemeEditorViewController
    //    }
    //}
    func newMeme () {
        
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("MemeEditorViewController") as! MemeEditorViewController
        
        if let navController = self.navigationController {
            navController.pushViewController(controller, animated: true)
        }
 
    }
    
    // Model
    
    
    // Mark: Table View Data Source Methods
    
    /**
    * Number of Rows
    */
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.sentMemes.count
    
    }
    
    
    /**
    * Cell For Row At Index Path
    */
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // TODO: Implement method
        // 1. Dequeue a reusable cell from the table, using the correct “reuse identifier”
        // 2. Find the model object that corresponds to that row
        // 3. Set the images and labels in the cell with the data from the model object
        // 4. return the cell.
        
        let cell = tableView.dequeueReusableCellWithIdentifier("memeReuseID")
            as! UITableViewCell
        cell.textLabel?.text = self.sentMemes[indexPath.row].toptext
        
        return cell
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

