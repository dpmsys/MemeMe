//
//  SentMemeCollectionViewController.swift
//  MemeMe
//
//  Created by David Mulvihill on 4/17/18.
//  Copyright © 2018 David Mulvihill. All rights reserved.
//

import UIKit
import Foundation
import MobileCoreServices
import AVFoundation

class SentMemeCollectionViewController:  UICollectionViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionView?.contentMode = .scaleAspectFit
        
        if collectionModified {
            collectionModified = false
            self.collectionView?.reloadData()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memeLocker.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> MemeCollectionViewCell {
        
        let CellID = "SentMemeCollectionCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellID, for: indexPath) as! MemeCollectionViewCell
        
        let meme = memeLocker[(indexPath as NSIndexPath).row]
        cell.nameLabel?.text = meme.topText
        cell.memeImageView?.image = meme.memedImage
        
        return cell
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "CollectionDetail") {
            let indexPath = self.collectionView?.indexPathsForSelectedItems?.first
            selected = indexPath!.row
        }
    }
}
