//
//  Ticket.swift
//  PinGo
//
//  Created by Hien Quang Tran on 8/6/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import UIKit

public enum Status: String {
    case Pending = "Pending" //when user just create a new ticket and is looking for worker
    case InService = "InService"// when user has picked a worker but the task hasn't been finished
    case Done = "Done" //when the task has been done by worker
    case Cancel = "Cancel" //when user cancel the ticket
    case Approved = "Approved"
    case ChoosenAnother = "ChoosenAnother"
}

class Ticket: NSObject {
    var category: String?
    var title: String?
    var ticketDescription: String?
    var workerName: String?
    var userName: String?
    var urgent: Bool?
    var user: UserProfile?
    var worker: Worker?
    var status: Status?
    var imageOne: ImageResource?
    var imageTwo: ImageResource?
    var imageThree: ImageResource?
    var location: Location?
    var id: String?
    var descriptions: String = ""
    var createdAt: String?
    var dataJson: [String: AnyObject]?
    var comment: String = ""
    // Hien Code 
    var issueImageVideoPath: String?
    var dateCreated: NSDate?
    override init() {
        category = ""
        title = ""
        descriptions = ""
        urgent = true
        user = UserProfile()
        worker = Worker()
        status = Status.Pending
        imageOne = ImageResource()
        imageTwo =  ImageResource()
        imageThree = ImageResource()
        location = Location()
    }
    
//    init(data: [String: AnyObject]){
//        id = data["_id"] as? String
//        category = data["category"] as? String
//        title = data["title"] as? String
//        urgent  = data["urgent"] as? Bool
//        let createBy = data["createBy"] as? [String: AnyObject]
//        user = UserProfile(data: createBy!)
//    }
    
    init(user: User, worker: Worker, id: String, category: String, title: String, status: Status, issueImageVideoPath: String?, dateCreated: NSDate) {
        self.user = user
        self.worker = worker
        self.id = id
        self.category = category
        self.title = title
        self.status = status
        self.issueImageVideoPath = issueImageVideoPath
        self.dateCreated = dateCreated
    }
    
    init(data: [String: AnyObject]){
        dataJson = data
        self.id = data["_id"] as? String
        if let category = data["category"] as? String {
            self.category = category
        }
        
        if let title = data["title"] as? String {
            self.title = title
        }
        
        if let user = data["createBy"] as? [String:AnyObject] {
            self.user = UserProfile()
            self.user?.setTempData(user)
        }
        
        if let worker = data["responsible"] as? [String:AnyObject]{
            self.worker = Worker()
            self.worker?.setTempData(worker)
        }
        
        if let status = data["status"] as? String{
            
            //transferToEnum(from: status)

            switch status {
            case Status.Cancel.rawValue:
                self.status = Status.Cancel
            case Status.InService.rawValue:
                self.status = Status.InService
            case Status.Done.rawValue:
                self.status = Status.Done
            case Status.Approved.rawValue:
                self.status = Status.Approved
            default:
                self.status = Status.Pending
            }
        }
        
        if let ticketImage = data["ticketImages"] as? [[String:AnyObject]]{
            self.imageOne = ImageResource(data: ticketImage[0])
            self.imageTwo = ImageResource(data: ticketImage[1])
            self.imageThree = ImageResource(data: ticketImage[2])
        }
        
        if let descriptions  = data["description"] as? String {
            self.descriptions = descriptions
        }
        if let createdAt = data["createdAt"] as? String{
            self.createdAt = createdAt
        }
        if let location = data["location"] as? [String: AnyObject]{
            self.location = Location(data: location)
        }
        if let descriptions = data["descriptions"] as? String {
            self.descriptions = descriptions
        }
        
        if let comment = data["comment"] as? String {
            self.comment = comment
        }
    }
    
    //tranfer from string back to enum when receive JSOn from server
    func transferToEnum(from statusString: String) {
        
        switch statusString {
        case Status.Cancel.rawValue:
            self.status = Status.Cancel
        case Status.InService.rawValue:
            self.status = Status.InService
        case Status.Done.rawValue:
            self.status = Status.Done
        case Status.Approved.rawValue:
            self.status = Status.Approved
        default:
            self.status = Status.Pending
        }
    }
    
    func getImagesArray() -> [String]{
        var imagesArray: [String] = []
        if imageOne?.imageUrl != "" {
            imagesArray.append((imageOne?.imageUrl)!)
        }
        
        if imageTwo?.imageUrl != "" {
            imagesArray.append((imageTwo?.imageUrl)!)
        }
        
        if imageThree?.imageUrl != "" {
            imagesArray.append((imageThree?.imageUrl)!)
        }
        
        return imagesArray
    }
}




