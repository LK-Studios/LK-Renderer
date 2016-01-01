//
//  ViewController.swift
//  LK-Renderer
//
//  Created by ArdiMaster on 31.12.15.
// 
//  LK-Renderer
//  Copyright (C) 2016 LK-Studios
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation; either version 2 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License along
//  with this program; if not, write to the Free Software Foundation, Inc.,
//  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var versionSelector: NSPopUpButton!
    var blenderVersions: [String]!
    
    @IBOutlet weak var downloadButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    override func awakeFromNib() {
        // blenderVersions = ["2.76b", "2.76a", "2.76", "2.75", "2.74", "2,73", "2.72", "2.71", "2.70", "2.69", "2.68", "2.67", "2.66", "2.65", "2.64", "2.63", "2.62", "2.61", "2.60"];
        blenderVersions = ["2.76b"];
        versionSelector.removeAllItems();
        versionSelector.addItemsWithTitles(blenderVersions);
        versionSelector.selectItemWithTitle("2.76b");
    }
    
    
    @IBAction func downloadButtonClicked(sender: AnyObject) {
        let listPath = NSBundle.mainBundle().pathForResource("BlenderVersions", ofType: "plist");
        let versionList = NSDictionary(contentsOfFile: listPath!);
        
        let downloadURL = "https://download.blender.org/release/" + (versionList!.valueForKey((versionSelector.selectedItem?.title)!) as! String);
        let targetPath = "/Library/Caches/com.lk-studios.lk-renderer/BlenderVersions/" + (versionSelector.selectedItem?.title)! + ".zip";
        let fileManager = NSFileManager.defaultManager();
        
        do {
            try fileManager.createDirectoryAtPath("/Library/Caches/com.lk-studios.lk-renderer/BlenderVersions", withIntermediateDirectories: true, attributes: nil);
            fileManager.createFileAtPath(targetPath, contents: NSData(contentsOfURL: NSURL(string: downloadURL)!), attributes: nil);
        } catch {
            print("An error occured while trying to download Blender. Please check your internet connection.");
        }
    }
    
    
}

