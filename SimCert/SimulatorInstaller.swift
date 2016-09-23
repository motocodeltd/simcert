//
//  SimulatorInstaller.swift
//  SimCert
//
//  Created by Yannick Heinrich on 04.02.16.
//  Copyright © 2016 Yannick Heinrich. All rights reserved.
//

import Foundation

class SimulatorInstaller {
    
    static let WAIT_STEP_SEC = 10.0
    static let deltaTime = DispatchTime.now() + Double(Int64(SimulatorInstaller.WAIT_STEP_SEC * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)

    let UUID: Foundation.UUID
    let certificatesURLs: [URL]
    
    var simulatorWindow: SimulatorWindow?
    
    let analyzer = ElementsAnalyzer()
    
    init(uuid:Foundation.UUID, certificates: [URL]){
        self.UUID = uuid
        self.certificatesURLs = certificates
    }
 
    
    func install(){
            print("=== Start installing \(self.UUID.uuidString) with \(self.certificatesURLs)")
        
            startSimulator()
            for certURL in self.certificatesURLs {
                openURL(certURL)
                installCertificateSequence()
            }
        
    }

    func startSimulator(){
        
        let task = Process()
        task.launchPath = "/usr/bin/open"
        task.arguments = ["-a",  "Simulator",  "--args",  "-CurrentDeviceUDID", self.UUID.uuidString]
        task.launch()
        task.waitUntilExit()
        
        print("Start Simulator Termination: \(task.terminationStatus)")
        
        Thread.sleep(forTimeInterval: 15.0)
        simulatorWindow = self.analyzer.simulatorWindows()[0]
        print("Windows:\(simulatorWindow)")

    }
    
    func openURL(_ certificateURL: URL){
        
        Thread.sleep(forTimeInterval: 5.0)
        
        let task = Process()
        task.launchPath = "/usr/bin/xcrun"
        task.arguments = ["simctl", "openurl", "booted", certificateURL.absoluteString]
        task.launch()
        task.waitUntilExit()
        
        print("Open URL Termination: \(task.terminationStatus)")
    }
    
    func installCertificateSequence(){
        guard let simulatorWindow = self.simulatorWindow else { print("Simulator does not seems to be launched"); return }
        
        let op = SimulatorOperator(simulator: simulatorWindow)
        
        // First Install
        Thread.sleep(forTimeInterval: 5.0)
        print("=== First Page ")
        op.searchButtonAndClick("Install")
        Thread.sleep(forTimeInterval: 1.0) //Don't know why but needs to be done two times OR start the simulator first
        op.searchButtonAndClick("Install")
        
        Thread.sleep(forTimeInterval: 5.0)
        print("=== Second Page ")
        op.searchButtonAndClick("Install")
        
        // Need to be done two time
        Thread.sleep(forTimeInterval: 5.0)
        //actor.searchButtonAndClick("Install")
        print("=== Popup Page ")
        op.searchButtonAndClickQuartzCore("Install")
        
        Thread.sleep(forTimeInterval: 5.0)
        print("=== Done Page ")
        op.searchButtonAndClick("Done")

        Thread.sleep(forTimeInterval: 3.0)
    }
    
    func closeSimulator() {
        
        let task = Process()
        task.launchPath = "/usr/bin/osascript"
        task.arguments = ["-e", "quit app \"Simulator\""]
        task.launch()
        task.waitUntilExit()
        
        print("Close Simulator Termination: \(task.terminationStatus)")

    }
}
