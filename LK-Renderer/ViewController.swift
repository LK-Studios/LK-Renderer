//
//  ViewController.swift
//  LK-Renderer
//
//  Created by ArdiMaster on 31.12.15.
//
//  Copyright (C) 2016 LK-Studios
//
//  Distributed under the terms and conditions of the MIT license.
//  You can obtain a copy of the license at https://opensource.org/licenses/MIT
//

import Cocoa

class ViewController: NSViewController, NSURLSessionDownloadDelegate {

    @IBOutlet weak var versionSelector: NSPopUpButton!
    var blenderVersions: [String]!
    
    @IBOutlet weak var downloadButton: NSButton!
    
    @IBOutlet weak var progressBar: NSProgressIndicator!
    
    @IBOutlet weak var chooseBlendButton: NSButton!
    @IBOutlet weak var blendFileLabel: NSTextField!
    var blendFile = "none";
    var blendFileSimple = "none";
    
    @IBOutlet weak var radioSingleFrame: NSButton!
    @IBOutlet weak var singleFrameNumber: NSTextField!
    var animation = false;
    @IBOutlet weak var radioAnimation: NSButton!
    @IBOutlet weak var firstFrameNumber: NSTextField!
    @IBOutlet weak var lastFrameNumber: NSTextField!
    
    @IBOutlet weak var startRenderButton: NSButton!
    
    @IBOutlet weak var renderEngine: NSPopUpButton!
    
    @IBOutlet weak var chooseOutputFolderButton: NSButton!
    @IBOutlet weak var outputFolderLabel: NSTextField!
    var outFolder: String = "none";
    
    @IBOutlet weak var threadCountBox: NSTextField!
    
    @IBOutlet weak var imageViewer: NSImageView!
    
    var versionAvailability = 0;
    
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
        
        // Set list of versions
        blenderVersions = ["2.76b", "2.76a", "2.76", "2.75a", "2.75", "2.74", "2.73a", "2.73", "2.72b", "2.72a", "2.72", "2.71", "2.70a", "2.70", "2.69", "2.68a", "2.68", "2.67b", "2.67a", "2.67", "2.66a", "2.66", "2.65a", "2.65", "2.64a", "2.64", "2.63a", "2.63", "2.62", "2.61", "2.60a", "2.60", "2.59", "2.58a", "2.58", "2.57b", "2.57a", "2.57", "2.56a-Beta", "2.56-Beta", "2.55-Beta", "2.54-Beta", "2.53-Beta", "2.50-Alpha2", "2.50-Alpha1", "2.50-Alpha0", "2.49b", "2.49a", "2.49", "2.48"];
        // blenderVersions = ["2.76b", "2.76a", "2.76", "2.75a", "2.75", "2.49b"];
        versionSelector.removeAllItems();
        versionSelector.addItemsWithTitles(blenderVersions);
        versionSelector.selectItemWithTitle("2.76b");
        
        renderEngine.removeAllItems();
        renderEngine.addItemsWithTitles(["Blender Internal", "Cycles"]);
        renderEngine.selectItemWithTitle("Blender Internal");
        
        let empty: NSString = ("" as NSString);
        do {
            try empty.writeToFile("/Library/Caches/com.lk-studios.lk-renderer/BlenderVersions/available.txt", atomically: false, encoding: NSUTF8StringEncoding);
        } catch {
        
        }
        
        // Check for availability of selected Blender version
        let version = (versionSelector.selectedItem?.title)!;
        handleVersionAvailability(checkVersionAvailability(version));
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func selectedVersionChanged(sender: AnyObject) {
        // Check for availability of selected Blender version
        let version = (versionSelector.selectedItem?.title)!;
        handleVersionAvailability(checkVersionAvailability(version));
    }
    
    @IBAction func downloadButtonClicked(sender: AnyObject) {
        switch versionAvailability {
        case 2:
            break;
        case 1:
            versionSelector.enabled = false;
            downloadButton.enabled = false;
            downloadButton.title = "Unpacking...";
            progressBar.indeterminate = true;
            progressBar.startAnimation(self);
            unzipBlender((versionSelector.selectedItem?.title)!);
        case 0:
            print("Preparing to download Blender v" + (versionSelector.selectedItem?.title)!);
            versionSelector.enabled = false;
            downloadButton.title = "Downloading...";
            downloadButton.enabled = false;
            
            let listPath = NSBundle.mainBundle().pathForResource("BlenderVersions", ofType: "plist");
            let versionList = NSDictionary(contentsOfFile: listPath!);
            
            let downloadURL = "https://download.blender.org/release/" + (versionList!.valueForKey((versionSelector.selectedItem?.title)!) as! String);
            
            if self.task != nil { self.task.suspend(); self.task = nil; }
            
            let request = NSMutableURLRequest(URL: NSURL(string: downloadURL)!);
            self.task = self.session.downloadTaskWithRequest(request);
            print("Initiiating download...");
            task.resume();
        default:
            break;
        }
    }
    
    @IBAction func chooseBlendClicked(sender: AnyObject) {
        let openPanel = NSOpenPanel();
        openPanel.title = "Please select your .blend file";
        openPanel.canChooseDirectories = false;
        openPanel.resolvesAliases = true;
        openPanel.message = "Please select the .blend file you wish to render";
        openPanel.showsHiddenFiles = false;
        openPanel.allowsMultipleSelection = false;
        openPanel.allowedFileTypes = ["blend"]
        openPanel.runModal();
        
        let path = openPanel.URL?.path;
        if path != nil {
            blendFile = path!;
            let pathArray: [String] = blendFile.componentsSeparatedByString("/");
            blendFileLabel.stringValue = pathArray[pathArray.count - 1];
            blendFileSimple = pathArray[pathArray.count - 1];
            print("Chosen Blender file: " + blendFile);
        }
    }
    
    @IBAction func renderButtonClicked(sender: AnyObject) {
        let version = (versionSelector.selectedItem?.title)!
        let verFolder = getFolderName(version);
        let blenderPath = "/Library/Caches/com.lk-studios.lk-renderer/BlenderVersions/" + version + "/" + verFolder + "Blender.app/Contents/MacOS/blender";
        
        var engineString: String = "";
        if (renderEngine.selectedItem?.title)! == "Blender Internal" {
            engineString = "BLENDER_RENDER";
        } else if (renderEngine.selectedItem?.title)! == "Cycles" {
            engineString = "CYCLES";
        }
        
        if outFolder == "none" {
            outputFolderLabel.stringValue = "Please select an output folder!";
            return;
        }
        
        if blendFile == "none" {
            blendFileLabel.stringValue = "Please select a .blend file!";
            return;
        }
        
        let threadCount = threadCountBox.stringValue;
        if threadCount == "" {
            let alert = NSAlert();
            alert.alertStyle = NSAlertStyle.CriticalAlertStyle;
            alert.messageText = "Please specify the number of threads to be used!";
            alert.beginSheetModalForWindow(self.view.window!, completionHandler: nil);
            return;
        }
        
        var launchArguments: [String] = [];
        if animation {
            if firstFrameNumber.stringValue == "" || lastFrameNumber.stringValue == "" {
                let alert = NSAlert();
                alert.alertStyle = NSAlertStyle.CriticalAlertStyle;
                alert.messageText = "Please specify the first and last frame of the animation!";
                alert.beginSheetModalForWindow(self.view.window!, completionHandler: nil);
                return;
            }
            let firstFrame = firstFrameNumber.stringValue;
            let lastFrame = lastFrameNumber.stringValue;
            launchArguments = ["-b", blendFile, "-E", engineString, "-o", outFolder + "/" + blendFileSimple + "_out###.png", "-s", firstFrame, "-e", lastFrame, "-t", threadCount, "-a"];
        } else {
            if singleFrameNumber.stringValue == "" {
                let alert = NSAlert();
                alert.alertStyle = NSAlertStyle.CriticalAlertStyle;
                alert.messageText = "Please specify the frame you wish to render!";
                alert.beginSheetModalForWindow(self.view.window!, completionHandler: nil);
                return;
            }
            let frame = singleFrameNumber.stringValue;
            launchArguments = ["-b", blendFile, "-E", engineString, "-o", outFolder + "/" +  blendFileSimple + "_out###.png", "-f", frame, "-t", threadCount];
        }
        
        let renderTask = NSTask();
        renderTask.launchPath = blenderPath;
        renderTask.arguments = launchArguments;
        renderTask.launch();
        
        if !animation {
            renderTask.waitUntilExit();
        }
    }
    
    @IBAction func chooseOutputFolderClicked(sender: AnyObject) {
        let openPanel = NSOpenPanel();
        openPanel.title = "Please select output folder";
        openPanel.message = "Please select the folder in which the rendered image(s) should be stored";
        openPanel.resolvesAliases = true;
        openPanel.showsHiddenFiles = false;
        openPanel.allowsMultipleSelection = false;
        openPanel.canChooseDirectories = true;
        openPanel.canChooseFiles = false;
        openPanel.runModal();
        
        if let path = openPanel.URL?.path {
            outFolder = path;
            let pathArray: [String] = outFolder.componentsSeparatedByString("/");
            outputFolderLabel.stringValue = pathArray[pathArray.count - 1];
            print("Chosen output directory: " + outFolder);
        }
    }
    
    @IBAction func singleFrameChosen(sender: AnyObject) {
        radioAnimation.state = NSOffState;
        firstFrameNumber.enabled = false;
        lastFrameNumber.enabled = false;
        animation = false;
        singleFrameNumber.enabled = true;
    }
    @IBAction func animationChosen(sender: AnyObject) {
        radioSingleFrame.state = NSOffState;
        singleFrameNumber.enabled = false;
        animation = true;
        firstFrameNumber.enabled = true;
        lastFrameNumber.enabled = true;
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
        unzipBlender(version);

        progressBar.stopAnimation(self);
        progressBar.indeterminate = false;
        progressBar.doubleValue = 1.0;
        downloadButton.title = "Available";
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        if error == nil { return; }
        let alert = NSAlert();
        alert.alertStyle = NSAlertStyle.WarningAlertStyle;
        alert.messageText = "An error occured while attempting to download Blender.";
        alert.informativeText = error!.localizedDescription;
        alert.beginSheetModalForWindow(self.view.window!, completionHandler: nil);
        handleVersionAvailability(0);
    }
    
    func unzipBlender(version: String) {
        let task = NSTask();
        task.launchPath = "/usr/bin/unzip";
        task.arguments = ["-o", "/Library/Caches/com.lk-studios.lk-renderer/BlenderVersions/" + version + ".zip", "-d", "/Library/Caches/com.lk-studios.lk-renderer/BlenderVersions/" + version];
        task.launch();
        addAvailableVersion(version);
        task.waitUntilExit();
        handleVersionAvailability(2);
    }
    
    func addAvailableVersion(version: String) {
        var currentListContents = ("" as NSString);
        let path = "/Library/Caches/com.lk-studios.lk-renderer/BlenderVersions/available.txt"
        do {
            currentListContents = try NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding);
        } catch {
            currentListContents = ("" as NSString);
        }
        let listContents: String = (currentListContents as String) + "\n" + version;
        
        do {
            // let fileManager = NSFileManager.defaultManager();
            // try fileManager.removeItemAtPath(path);
            try listContents.writeToFile(path, atomically: false, encoding: NSUTF8StringEncoding);
        } catch {
            
        }
    }
    
    func isVersionAvailable(version: String) -> Bool {
        do {
            let path = "/Library/Caches/com.lk-studios.lk-renderer/BlenderVersions/available.txt"
            let listContents = try NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding);
            let versionList = listContents.componentsSeparatedByString("\n") as [String];
            return versionList.contains(version);
        } catch {
            return false;
        }
    }
    
    func isVersionZipAvaiable(version: String) -> Bool {
        let path = "/Library/Caches/com.lk-studios.lk-renderer/BlenderVersions/" + version + ".zip";
        let fileManager = NSFileManager.defaultManager();
        
        return fileManager.fileExistsAtPath(path)
    }
    
    func checkVersionAvailability(version: String) -> Int {
        print("Checking availability of Blender version " + version);
        var available: Int = -1;
        if isVersionAvailable(version) {
            print("Unpacked available");
            available = 2;
        } else if isVersionZipAvaiable(version) {
            print("Zip available");
            available = 1;
        } else {
            available = 0;
        }
        versionAvailability = available;
        return available;
    }
    
    func handleVersionAvailability(availabilty: Int) {
        switch availabilty {
        case 2:
            downloadButton.enabled = false;
            downloadButton.title = "Available";
            progressBar.stopAnimation(self);
            progressBar.indeterminate = false;
            progressBar.doubleValue = 1.0;
            versionSelector.enabled = true;
            startRenderButton.enabled = true;
            break;
        case 1:
            downloadButton.enabled = true;
            downloadButton.title = "Unpack";
            progressBar.stopAnimation(self);
            progressBar.indeterminate = false;
            progressBar.doubleValue = 1.0;
            versionSelector.enabled = true;
            startRenderButton.enabled = false;
            break;
        case 0:
            downloadButton.enabled = true;
            downloadButton.title = "Download";
            progressBar.stopAnimation(self);
            progressBar.indeterminate = false;
            progressBar.doubleValue = 0.0;
            versionSelector.enabled = true;
            startRenderButton.enabled = false;
            break;
        default:
            break;
        }
        
        versionAvailability = availabilty;
    }
    
    func getFolderName (version: String) -> String {
        switch version {
        case "2.76a", "2.76":
            return "";
        case "2.75a", "2.75", "2.74", "2.73a", "2.73", "2.72b", "2.72", "2.71a", "2.71", "2.70a", "2.70", "2.69", "2.68a", "2.68", "2.67b", "2.67a", "2.67", "2.66a", "2.66", "2.65a", "2.65", "2.64a", "2.64":
            return "Blender/";
        case "2.60a", "2.60":
            return "Blender/";
        case "2.56a-Beta", "2.56-Beta", "2.55-Beta", "2.54-Beta", "2.53-Beta", "2.50-Alpha2", "2.50-Alpha1":
            return "";
        case "2.50-Alpha0":
            return "Blender/";
        case "2.49":
            return "blender/";
        case "2.48":
            return "Blender/";
        default:
            let versionList = NSDictionary(contentsOfFile: NSBundle.mainBundle().pathForResource("BlenderVersions", ofType: "plist")!);
            let verString = versionList!.valueForKey(version) as! String;
            return (verString.componentsSeparatedByString("/")[1]).componentsSeparatedByString(".z")[0] + "/";
        }
    }
}

