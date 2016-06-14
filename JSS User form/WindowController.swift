//
//  WindowController.swift
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

class WindowController: NSWindowController, NSTextFieldDelegate {

    // Interface Connections
    @IBOutlet weak var statusLabel: NSTextField!
    @IBOutlet weak var assetTag: NSTextField!
    @IBOutlet weak var username: NSTextField!
    @IBOutlet weak var email: NSTextField!
    @IBOutlet weak var departmentPopUP: NSPopUpButton!
    var department: [String]!
    
    @IBOutlet weak var submitButton: NSButton!
    @IBOutlet weak var quitButton: NSButton!
    
    // Key Refrences for userDetails.plist
    let assetTagKey = "AssetTag"
    let usernameKey = "Username"
    let emailKey = "Email"
    let departmentKey = "Department"
    let jssUpdatedKey = "JSSUpdated"
    
    // Tells WindowController.xib to Display
    override var windowNibName: String? {
        return "WindowController"
    }

    override func windowDidLoad() {
        super.windowDidLoad()

        // Set Window Level
        self.window!.level = Int(CGWindowLevelForKey(.FloatingWindowLevelKey))
        self.window!.makeKeyAndOrderFront(nil)
        
        // Define Window Appearance
        window?.titlebarAppearsTransparent = true
        window?.titleVisibility = .Hidden
        window?.backgroundColor = NSColor.whiteColor()
        self.quitButton.enabled = false
        self.quitButton.hidden = true
        
        // Popup Button Settings
        department = ["Accounts", "Design", "Marketing", "Operations", "Sales", "Service"] // Modify as required
        departmentPopUP.removeAllItems()
        departmentPopUP.addItemsWithTitles(department)
        departmentPopUP.selectItemAtIndex(0)
        
    }
    
    // Receives Changes to Text Fields from Delegate & Constrains Characters
    override func controlTextDidChange(obj: NSNotification) {
        
        let characterSet: NSCharacterSet = NSCharacterSet(charactersInString: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789-_").invertedSet
        let alphaCharSet: NSCharacterSet = NSCharacterSet(charactersInString: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ.").invertedSet
        let mailCharSet: NSCharacterSet = NSCharacterSet(charactersInString: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ@._").invertedSet
        
        self.assetTag.stringValue = (self.assetTag.stringValue.componentsSeparatedByCharactersInSet(characterSet) as NSArray).componentsJoinedByString("")
        self.username.stringValue = (self.username.stringValue.componentsSeparatedByCharactersInSet(alphaCharSet) as NSArray).componentsJoinedByString("")
        self.email.stringValue = (self.email.stringValue.componentsSeparatedByCharactersInSet(mailCharSet) as NSArray).componentsJoinedByString("")
        
    }

    // Runs JAMF Recon, Submits Assinged Values to JSS & Creates userDetails.plist
    func reconSubmitData() {
        
        // Get NSTextField Values as Strings
        let assetTagValue = assetTag.stringValue
        let usernameValue = username.stringValue
        let emailValue = email.stringValue
        let departmentValue = departmentPopUP.title
        _ = departmentValue
        
        // Recon Command with Assinged Values
        let appleScriptRecon = NSAppleScript(source: "do shell script \"/usr/local/jamf/bin/jamf recon -assetTag \(assetTagValue) -realname \(usernameValue) -email \(emailValue) -department \(departmentValue)\" with administrator " + "privileges")!.executeAndReturnError(nil)
        let result = appleScriptRecon.stringValue
        //debugPrint(result)
        
        if ((result?.containsString("<computer_id")) != nil) {
            //debugPrint("process completed")
            
            // Update Status Label
            self.statusLabel.stringValue = "Process Completed Successfully"
            
            // Update Controls - Hide Submit Button/ Show Quit Button
            self.submitButton.hidden = true
            self.quitButton.enabled = true
            self.quitButton.hidden = false
            
            // Specify Values for .plist
            if let plist = Plist(name: "userDetails") {
                
                let dict = plist.getMutablePlistFile()!
                dict[assetTagKey] = (assetTagValue)
                dict[usernameKey] = (usernameValue)
                dict[emailKey] = (emailValue)
                dict[departmentKey] = (departmentValue)
                dict[jssUpdatedKey] = "YES"
                
                do {
                    try plist.addValuesToPlistFile(dict)
                } catch {
                    print(error)
                }
                
                print(plist.getValuesInPlistFile())
            } else {
                print("Unable to get Plist")
            }
            
        } else {
            print("process failed")
            
            // Update Status Label
            self.statusLabel.stringValue = "Process Completed but Not Uploaded to Server!"
            
            // Specify values for .plist
            if let plist = Plist(name: "userDetails") {
                
                let dict = plist.getMutablePlistFile()!
                dict[assetTagKey] = (assetTagValue)
                dict[usernameKey] = (usernameValue)
                dict[emailKey] = (emailValue)
                dict[departmentKey] = (departmentValue)
                dict[jssUpdatedKey] = "NO"
                
                do {
                    try plist.addValuesToPlistFile(dict)
                } catch {
                    print(error)
                }
                
                print(plist.getValuesInPlistFile())
            } else {
                print("Unable to get Plist")
            }
            
            // Displays Error Message if JAMF Recon could not be Run
            reconFailedAlert()
            
        }
    }
    
    // Checks for Empty Text Fields, Calls reconSubmitData if all Fields are Populated
    func reconCheckValues() {
        
        // Get NSTextField Values as Strings
        let assetTagValue = assetTag.stringValue
        let usernameValue = username.stringValue
        let emailValue = email.stringValue
        let departmentValue = departmentPopUP.title
        _ = departmentValue
        
        // Make Sure Text Fields are not Empty
        if assetTagValue.isEmpty {
            
            //debugPrint("No Asset Tag Entered")
            missingValuesAlert()
            
        } else if usernameValue.isEmpty {
            
            //debugPrint("No Username Entered")
            missingValuesAlert()
            
        } else if emailValue.isEmpty {
            
            //debugPrint("No Email Entered")
            missingValuesAlert()
            
        } else {
            
            //debugPrint("Running Command")
            // Update Status Label
            self.statusLabel.stringValue = "Submitting Information. Will Take Around 30 seconds..."
            
            // Disable Submit Button
            self.submitButton.enabled = false
            
            // Delay Calling reconSubmitData Function, this Allows the Main Queue to Update Before Running the NSAppleScript Method
            let delaySec = 0.3 * Double(NSEC_PER_SEC)
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delaySec))
            dispatch_after(time, dispatch_get_main_queue()) {
                
                // Calls reconSubmitData Funcation
                self.reconSubmitData()
            }
            
        }
    }
    
    // Display Message if Any Text Fields are Empty
    func missingValuesAlert(){
        
        let alert = NSAlert()
        alert.messageText = "Missing Text Field Values" // Edit as Required
        alert.informativeText = "All Text Fields Must be Populated" // Edit as Required
        alert.addButtonWithTitle("Ok")
        
        alert.beginSheetModalForWindow(self.window!, completionHandler: { (returnCode) -> Void in
            if returnCode == NSAlertFirstButtonReturn {
                
            }
        })
    }
    
    // Display Message if JAMF Binary is Missing, at App Launch
    func binaryMissingAlert(){
        
        let binaryAlert = NSAlert()
        binaryAlert.messageText = "Missing Managment Component" // Edit as Required
        binaryAlert.informativeText = "Casper Suite framework is missing or incomplete. Machine may need to be re-inrolled into Casper, please contact IT support" // Edit as Required
        binaryAlert.addButtonWithTitle("Quit")
        
        binaryAlert.beginSheetModalForWindow(self.window!, completionHandler: { (returnCode) -> Void in
            if returnCode == NSAlertFirstButtonReturn {
                NSApplication.sharedApplication().terminate(self)
                
            }
        })
    }
    
    // Display Message if reconSubmitData Fails
    func reconFailedAlert() {
        
        let reconAlert = NSAlert()
        reconAlert.messageText = "Unable to Connect to Server" // Edit as Required
        reconAlert.informativeText = "Unable to connect to the server, please check your WiFi or Ethernet connection and try again. If you continue to see this message please contact IT Support" // Edit as Required
        reconAlert.addButtonWithTitle("Try Again")
        reconAlert.addButtonWithTitle("Quit")
        
        reconAlert.beginSheetModalForWindow(self.window!, completionHandler: { (returnCode) -> Void in
            if returnCode == NSAlertFirstButtonReturn {
                
                // Update Status Label
                self.statusLabel.stringValue = "Submitting Information. Will Take Around 30 seconds..."
                
                // Delay Calling reconSubmitData Function, this Allows the Main Queue to Update Before Running the NSAppleScript Method
                let delaySec = 0.2 * Double(NSEC_PER_SEC)
                let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delaySec))
                dispatch_after(time, dispatch_get_main_queue()) {
                    
                    // Calls reconSubmitData Funcation
                    self.reconSubmitData()
                }
                
                
            } else if returnCode == NSAlertSecondButtonReturn {
                
                NSApplication.sharedApplication().terminate(self)
            }
        })
    }
    
    @IBAction func submit(sender: AnyObject) {
        
        // Calls reconCheckValues Funcation
        reconCheckValues()
        
    }
    
    @IBAction func quit(sender: AnyObject) {
        
        NSApplication.sharedApplication().terminate(self)
        
    }
    
}
