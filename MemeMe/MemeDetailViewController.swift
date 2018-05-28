//
//  MemeDetailViewController.swift
//  MemeMe
//
//  Created by David Mulvihill on 5/27/18.
//  Copyright © 2018 David Mulvihill. All rights reserved.
//

import Foundation
import UIKit

class MemeDetailViewController: UIViewController {

    @IBOutlet weak var detailImageView: UIImageView!
    
    override func viewDidLoad() {
        self.detailImageView.image = memeLocker[selected].memedImage
        
    }
}
