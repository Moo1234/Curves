//
//  SocketIOManager.swift
//  Curves
//
//  Created by Moritz Martin on 16.06.16.
//  Copyright © 2016 Moritz Martin. All rights reserved.
//

import UIKit

class SocketIOManager: NSObject {
    
    static let sharedInstance = SocketIOManager()
    
    override init() {
        super.init()
    }
    
    
    var socket: SocketIOClient = SocketIOClient(socketURL: NSURL(string: "http://134.60.165.97:3000")!)
    

    func establishConnection() {
        socket.connect()
    }
    
    
    func closeConnection() {
        socket.disconnect()
    }

    
    func connectToServerWithID(id: String, completionHandler: (userList: [[String: AnyObject]]!) -> Void) {
        socket.emit("connectUser", id)
        
        socket.on("userList") { ( dataArray, ack) -> Void in
            completionHandler(userList: dataArray[0] as! [[String: AnyObject]])
        }
        
        listenForOtherMessages()
    }
    
    
    func sendMessage(pID: String, xPos: CGFloat, yPos: CGFloat) {
        socket.emit("position", pID, xPos, yPos)
    }
    
    
    func getChatMessage(completionHandler: (messageInfo: [String: AnyObject]) -> Void) {
        socket.on("newPosition") { (dataArray, socketAck) -> Void in
            var messageDictionary = [String: AnyObject]()
            messageDictionary["pID"] = dataArray[0] as! String
            messageDictionary["xPos"] = dataArray[1] as! CGFloat
            messageDictionary["yPos"] = dataArray[2] as! CGFloat
            
            completionHandler(messageInfo: messageDictionary)
        }
    }
    

    
    
    private func listenForOtherMessages() {
        socket.on("userConnectUpdate") { (dataArray, socketAck) -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName("userWasConnectedNotification", object: dataArray[0] as! [String: AnyObject])
        }
        
        socket.on("userExitUpdate") { (dataArray, socketAck) -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName("userWasDisconnectedNotification", object: dataArray[0] as! String)
        }
        
        socket.on("userTypingUpdate") { (dataArray, socketAck) -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName("userTypingNotification", object: dataArray[0] as? [String: AnyObject])
        }
    }

    
}
