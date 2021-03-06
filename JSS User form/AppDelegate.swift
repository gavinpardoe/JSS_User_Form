//
//  AppDelegate.swift
//  JSS User form
//
//  Created by Gavin on 14/06/2016.
//  Copyright © 2016 Trams Ltd. All rights reserved.
//
//  Designed for Use with JAMF Casper Suite.
//
//  The MIT License (MIT)
//
//  Copyright (c) 2016 Gavin Pardoe
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software
//  without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
//  PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
//  CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    // Refrence to Window Controller Class
    var windowController: WindowController?
    
    // Path to JAMF Binary
    let binPath = "/usr/local/jamf/bin/jamf"
    var fileMgr = NSFileManager.defaultManager()

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        
        // References WindowController.swift
        let windowController = WindowController()
        windowController.showWindow(self)
        self.windowController = windowController
        
        // Checks JAMF Binary at launch, Displays Message if Missing
        if fileMgr.fileExistsAtPath(binPath) {
            //debugPrint("JAMF Binary Found")
            
        } else {
            
            //debugPrint("JAMF Binary Missing")
            // Displays Sheet with info and quit button, Disables Submit Button
            windowController.submitButton.enabled = false
            windowController.binaryMissingAlert()
        }
        
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

