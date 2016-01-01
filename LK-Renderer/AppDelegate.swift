//
//  AppDelegate.swift
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
            task.launchPath = "/bin/rm";
            task.arguments = ["-r", path];
            task.launch();
        }
        
        let task = NSTask();
        task.launchPath = "/bin/rm";
        task.arguments = ["/Library/Caches/com.lk-studios.lk-renderer/BlenderVersions/available.txt"];
        task.launch();
    }
    
}

