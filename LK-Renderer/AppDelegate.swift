//
//  AppDelegate.swift
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

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var cleanupVersions = Set<String>();
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        var listContents: NSString = ("" as NSString);
        do {
            let listPath = "/Library/Caches/com.lk-studios.lk-renderer/BlenderVersions/available.txt"
            listContents = try NSString(contentsOfFile: listPath, encoding: NSUTF8StringEncoding);
        } catch {
            return;
        }
        let versionList = listContents.componentsSeparatedByString("\n") as [String];
        if versionList.isEmpty {
            return;
        }
        
        for ver in versionList {
            cleanupVersions.insert(ver);
        }
        
        for version in cleanupVersions {
            if version == "" {
                continue;
            }
            
            let path = "/Library/Caches/com.lk-studios.lk-renderer/BlenderVersions/" + version;
            let task = NSTask();
            task.launchPath = "/bin/chmod";
            task.arguments = ["-v", "-R", "u+w", path];
            task.launch();
            task.waitUntilExit();
        }
        
        for version in cleanupVersions {
            if version == "" {
                continue;
            }
            
            let path = "/Library/Caches/com.lk-studios.lk-renderer/BlenderVersions/" + version;
            let task = NSTask();
            task.launchPath = "/bin/rm";
            task.arguments = ["-rv", path];
            task.launch();
        }
        
        let task = NSTask();
        task.launchPath = "/bin/rm";
        task.arguments = ["-v", "/Library/Caches/com.lk-studios.lk-renderer/BlenderVersions/available.txt"];
        task.launch();
    }
    
}

