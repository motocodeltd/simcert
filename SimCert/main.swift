//
//  main.swift
//  simcert
//
//  Created by Yannick Heinrich on 05.02.16.
//  Copyright © 2016 Yannick Heinrich. All rights reserved.
//

import Foundation


let UUIDArgument = "-uuid";
let CertificateArgument = "-certificate";

var args  = ProcessInfo().arguments

//!MARK: - Helpers

func printUsage() {
    print("Usage: SimCert.app -uuid <UUID> -certificate <path> ")
}


func getArgumentWithOption(_ opt: String) -> String? {
    
    if let index = args.index(of: opt) , args.count >= (index + 1) {
        return args[index + 1];
    }
    return nil;
}

func getArgumentListWithOption(_ opt: String) -> [String] {
    
    if let index = args.index(of: opt) , args.count >= (index + 1) {
        return Array(args[index+1..<args.count])
    }
    return [];
}


//!MARK: - Installation
func install(_ uuidString: String, paths: [String]){
    
    guard let UUID = UUID(uuidString: uuidString) else {
        
        print("Invalid UUID parameters")
        return
    }
    
    
    let URLs = paths.map( { (filePath) -> String? in
        let path: String
        if filePath.contains("~"){
            path = (filePath as NSString).expandingTildeInPath
        } else {
            path = filePath
        }
        
        if !FileManager.default.fileExists(atPath: path) {
            print("Invalid path");
            return nil
        } else {
            return path
        }
        
    }).flatMap { $0 }.map { URL(fileURLWithPath: $0) }
    
    let installer = SimulatorInstaller(uuid: UUID, certificates: URLs)
    
    installer.install()
    installer.closeSimulator()
    exit(1)
}

//!MARK: - Main

let value = kAXTrustedCheckOptionPrompt.takeUnretainedValue()
let options: [String:AnyObject] = [value as String: (true as CFBoolean)]

if(!AXIsProcessTrustedWithOptions(options as CFDictionary?)){
    
    print("You need to give access to accessibility API")
    exit(1)
}


guard let uuid = getArgumentWithOption(UUIDArgument) else {
    print("Missing UUID parameters")
    printUsage()
    exit(1)
}

let certificates = getArgumentListWithOption(CertificateArgument)

if certificates.count > 0 {
    install(uuid, paths: certificates)
} else {
    print("Missing certificates parameters")
    printUsage()
    exit(1)
}





