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

class ViewController: NSViewController, NSURLSessionDownloadDelegate {

    @IBOutlet weak var versionSelector: NSPopUpButton!
    var blenderVersions: [String]!
    
    @IBOutlet weak var downloadButton: NSButton!
    
    @IBOutlet weak var progressBar: NSProgressIndicator!
    
    var task: NSURLSessionTask!
    lazy var session : NSURLSession = {
        let config = NSURLSessionConfiguration.ephemeralSessionConfiguration();
        config.allowsCellularAccess = false;
        return NSURLSession(configuration: config, delegate: self, delegateQueue: NSOperationQueue.mainQueue());
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        progressBar.minValue = 0.0;
        progressBar.maxValue = 1.0;
        progressBar.doubleValue = 0.0;
        
        self.task = nil;
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
        versionSelector.enabled = false;
        downloadButton.title = "Downloading...";
        downloadButton.enabled = false;
        
        let listPath = NSBundle.mainBundle().pathForResource("BlenderVersions", ofType: "plist");
        let versionList = NSDictionary(contentsOfFile: listPath!);
        
        let downloadURL = "https://download.blender.org/release/" + (versionList!.valueForKey((versionSelector.selectedItem?.title)!) as! String);
        
        if self.task != nil { return; }
        
        let request = NSMutableURLRequest(URL: NSURL(string: downloadURL)!);
        self.task = self.session.downloadTaskWithRequest(request);
        task.resume();
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        print("Downloaded \(totalBytesWritten) of \(totalBytesExpectedToWrite) bytes");
        progressBar.doubleValue = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite);
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        downloadButton.title = "Saving...";
        progressBar.indeterminate = true
        progressBar.startAnimation(self);
        
        let version = (versionSelector.selectedItem?.title)!;
        let targetURL = NSURL(string: "file:///Library/Caches/com.lk-studios.lk-renderer/BlenderVersions/" + version + ".zip");
        let fileManager = NSFileManager.defaultManager();
        do {
            try fileManager.createDirectoryAtPath("/Library/Caches/com.lk-studios.lk-renderer/BlenderVersions", withIntermediateDirectories: true, attributes: nil);
            try fileManager.moveItemAtURL(location, toURL: targetURL!);
        } catch {
            print("An error occured while attempting to save the downloaded Blender instance.");
            progressBar.stopAnimation(self);
            progressBar.indeterminate = false;
            progressBar.doubleValue = 0.0;
            downloadButton.title = "Download Blender";
            downloadButton.enabled = true;
            return;
        }
        
        downloadButton.title = "Unpacking...";
        let task = NSTask();
        task.launchPath = "/usr/bin/unzip";
        task.arguments = ["/Library/Caches/com.lk-studios.lk-renderer/BlenderVersions/" + version + ".zip", "-d /Library/Caches/com.lk-studios.lk-renderer/BlenderVersions/" + version];
        task.launch();
        
        progressBar.stopAnimation(self);
        progressBar.indeterminate = false;
        progressBar.doubleValue = 1.0;
        downloadButton.title = "Available";
    }
}

