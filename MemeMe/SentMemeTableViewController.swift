//
//  SentMemeTableViewController.swift
//  MemeMe
//
//  Created by David Mulvihill on 4/17/18.
//  Copyright © 2018 David Mulvihill. All rights reserved.
//

import UIKit
import Foundation
import MobileCoreServices
import AVFoundation

class SentMemeTableViewController:  UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = 150
        self.tableView.separatorStyle = .none
        if memeLocker.count == 0 {
            performSegue(withIdentifier: "EditorSegue", sender: nil)
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if tableModified {
            tableModified = false
            self.tableView.reloadData()
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memeLocker.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let CellID = "SentMemeCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CellID, for: indexPath) as! MemeTableViewCell
        let meme = memeLocker[(indexPath as NSIndexPath).row]
        
        cell.nameLabel.text = meme.topText + "..." + meme.botText
        cell.memeImageView.image = meme.memedImage
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "TableDetail") {
            selected = ((tableView.indexPathForSelectedRow! as NSIndexPath).row) as Int
        }
    }
}

