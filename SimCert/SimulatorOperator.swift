//
//  WindowsOperator.swift
//  SimCert
//
//  Created by Yannick Heinrich on 31.01.16.
//  Copyright © 2016 Yannick Heinrich. All rights reserved.
//

import Foundation

import ApplicationServices.HIServices
import CoreGraphics

class SimulatorOperator {
    
    let simulatorWindow: SimulatorWindow
    let uxElement: AXUIElement
    
    init(simulator: SimulatorWindow) {

        uxElement = AXUIElementCreateApplication(Int32(simulator.PID))
        simulatorWindow = simulator
        
    }

    
    func makeSimulatorVisible () {
        
        let visibleError: AXError = AXUIElementSetAttributeValue(uxElement, kAXFrontmostAttribute as CFString, kCFBooleanTrue)
        
        if visibleError != .success {
            print("Error:\(visibleError.rawValue)")
        }
    }
    
    func waitForHomeScreen() -> Bool {
        
        guard let _ = SimulatorOperator.waitForElement(uxElement, role: kAXSliderRole, title: "Page 1 of 2") else { return false }
        
        return true
    
    }
    func waitForInstallScreen() -> Bool {
        
        guard let _ = SimulatorOperator.waitForElement(uxElement, role: kAXButtonRole, title: "Install") else { return false }
        
        return true
        
    }
    func searchButtonAndClick (_ title: String) {
        
        guard let element = SimulatorOperator.findElement(uxElement, role: kAXButtonRole, title: title) else {
            return
        }
        
       let clickError =  AXUIElementPerformAction(element, kAXPressAction as CFString)
        
        if clickError != .success {
            print("Could not click:\(clickError.rawValue)")
        }
        
    }
    
    func searchButtonAndClickQuartzCore(_ title: String) {
        guard let element = SimulatorOperator.findElement(uxElement, role: kAXButtonRole, title: title) else {
            return
        }
        

        let positionPointer : UnsafeMutablePointer<AnyObject?> = UnsafeMutablePointer<AnyObject?>.allocate(capacity: 1)
        AXUIElementCopyAttributeValue(element, kAXPositionAttribute as CFString, positionPointer)
        
        let position = positionPointer.pointee as! AXValue

        var pt = CGPoint()
        AXValueGetValue(position, .cgPoint, &pt)
        
        
        let sizePointer : UnsafeMutablePointer<AnyObject?> = UnsafeMutablePointer<AnyObject?>.allocate(capacity: 1)
        AXUIElementCopyAttributeValue(element, kAXSizeAttribute as CFString, sizePointer)
        
        let size = sizePointer.pointee as! AXValue
        var siz = CGSize()
        AXValueGetValue(size, .cgSize, &siz)
        
        
        let elementFrame = CGRect(origin: pt, size: siz)
        let clickPosition = CGPoint(x: elementFrame.midX, y: elementFrame.midY)
        
        let clickDownEvent = CGEvent(mouseEventSource: nil, mouseType: .leftMouseDown, mouseCursorPosition: clickPosition, mouseButton: .left)
        let clickUpEvent = CGEvent(mouseEventSource: nil, mouseType: .leftMouseUp, mouseCursorPosition: clickPosition, mouseButton: .left)
        
        clickDownEvent?.post(tap: .cghidEventTap)
        
        Thread.sleep(forTimeInterval: 1.0)

        clickUpEvent?.post(tap: .cghidEventTap)
    }
    
    
    class func waitForElement(_ root:AXUIElement, role: String, title: String) -> AXUIElement? {
        
        let attempt = 20;
        
        for _ in 0 ..< attempt {
            if let element = SimulatorOperator.findElement(root, role: role, title: title){
                return element
            } else {
                Thread.sleep(forTimeInterval: 0.5)
                continue
            }
        }
        return nil
    }
    
    class func findElement(_ root:AXUIElement, role: String, title: String) -> AXUIElement? {
        let rolePointer : UnsafeMutablePointer<AnyObject?> = UnsafeMutablePointer<AnyObject?>.allocate(capacity: 1)
        let titlePointer : UnsafeMutablePointer<AnyObject?> = UnsafeMutablePointer<AnyObject?>.allocate(capacity: 1)

        AXUIElementCopyAttributeValue(root, kAXRoleAttribute as CFString, rolePointer)
        AXUIElementCopyAttributeValue(root, kAXTitleAttribute as CFString, titlePointer)
        
        guard let currentRole = rolePointer.pointee as? String,
              let currentTitle = titlePointer.pointee as? String else { return nil }
        
        print("<\(currentRole): \(currentTitle)>")
        
        if role == currentRole && currentTitle == title {
            return root
        } else {
            let childrenPointer : UnsafeMutablePointer<AnyObject?> = UnsafeMutablePointer<AnyObject?>.allocate(capacity: 1)
            AXUIElementCopyAttributeValue(root, kAXChildrenAttribute as CFString, childrenPointer)
            
            guard let children = childrenPointer.pointee as? [AXUIElement] else { return nil }
            
            var element: AXUIElement?
            
            for child in children {
                element = SimulatorOperator.findElement(child, role: role, title: title)
                
                if let element = element {
                    return element
                }
            }
            
            return nil
            
        }
    }
    
}
