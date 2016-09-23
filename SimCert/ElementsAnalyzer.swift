//
//  ElementsAnalyzer.swift
//  SimCert
//
//  Created by Yannick Heinrich on 30.01.16.
//  Copyright © 2016 Yannick Heinrich. All rights reserved.
//


import Cocoa


struct SimulatorWindow {
    let ownerName: String
    let windowName: String
    let PID: Int
    var bounds: CGRect
    var windowID: Int
}

class ElementsAnalyzer {
    

    class func rawSimulatorWindows() -> [[String:AnyObject]]{
        
        if let windowsList = CGWindowListCopyWindowInfo(.optionOnScreenOnly, 0){
            
            let count = CFArrayGetCount(windowsList)
            
            var infos: [[String:AnyObject]] = []
            
            for index in 0..<count{
                if let info = unsafeBitCast(CFArrayGetValueAtIndex(windowsList, index), to: NSDictionary.self) as? [String:AnyObject] {
                    
                    infos.append(info)
                }
            }
            return infos
        }
        
        
        fatalError("Unpredictable behaviour")
    }
    
    
    func waitUntilSimulatorLaunched() -> SimulatorWindow? {
        
        let attempt = 5
        
        for _ in 0..<attempt {
            
            let windows = simulatorWindows()

            if windows.count == 0 {
                Thread.sleep(forTimeInterval: 0.5)
                continue
            } else {
                return windows[0]
            }
        }
        return nil;
    }
    
    func simulatorWindows() -> [SimulatorWindow] {
        
        
        let allWindows = ElementsAnalyzer.rawSimulatorWindows()
        let simulatorWindows = allWindows.filter { (info) -> Bool in
            if let ownerName = info[kCGWindowOwnerName as String] as? String {
               return ownerName.contains("Simulator")
            }
            return false
        }
        
        var uniqWindowsID:[Int] = []
        return simulatorWindows.map({ (info) -> SimulatorWindow in
            
            if let ownerName = info[kCGWindowOwnerName as String] as? String,
                   let windowsName = info[kCGWindowName as String] as? String,
                   let pid  = info[kCGWindowOwnerPID as String] as? Int,
                   let boundsDict = info[kCGWindowBounds as String] as? NSDictionary,
                   let windowID = info[kCGWindowNumber as String] as? Int

            {
                let rect = CGRect(dictionaryRepresentation: boundsDict)!
                return SimulatorWindow(ownerName: ownerName, windowName: windowsName, PID: pid, bounds: rect, windowID: windowID)
            }
    
            fatalError("Could not retrieve value")
            
        }).filter({ (sim) -> Bool in
            
            let pid = sim.windowID
            let windowsName = sim.windowName
            
            if !uniqWindowsID.contains(pid) && windowsName != "" {
                uniqWindowsID.append(pid)
                return true
            }
            
            return false
            
        })
    }
}
