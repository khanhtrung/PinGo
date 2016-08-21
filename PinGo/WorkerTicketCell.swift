//
//  WorkerTicketCell.swift
//  PinGo
//
//  Created by Cao Thắng on 8/20/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//
import UIKit
import GooglePlaces
import GoogleMaps
import AFNetworking
import Alamofire
import CoreLocation

class WorkerTicketCell: UITableViewCell, GMSMapViewDelegate {
    
    //for map
    var locationManager = CLLocationManager()
    var didFindMyLocation = false
    var workerlocation = Location()
    var placesClient = GMSPlacesClient()
    var directionShow = false
    
    let mapDirectionAPI = "AIzaSyBA6WMj7LYhCNyj3ydOyfN0rogeB80UzCo"
    
    
    // View Status
    
    @IBOutlet weak var viewWordOfStatus: UIView!
    
    @IBOutlet weak var labelStatus: UILabel!
    // View User
    @IBOutlet weak var imageViewProfile: UIImageView!
    
    @IBOutlet weak var labelUsername: UILabel!
    
    @IBOutlet weak var ticketDetailView: UIView!
    
    @IBOutlet weak var connectionLineView: UIView!
    
    // View Info
    @IBOutlet weak var imageViewTicket: UIImageView!
    
    @IBOutlet weak var labelPhoneNumber: UILabel!
    
    
    @IBOutlet weak var imageViewLocation: UIImageView!
    
    @IBOutlet weak var buttonCall: UIButton!
    @IBOutlet weak var labelTitle: UILabel!
    
    @IBOutlet weak var labelDateCreated: UILabel!
    
    @IBOutlet weak var actionButton: UIButton!
    
    var homeTimeLineViewWorker: HomeTimeLineWorker?
    
    var themeColor: UIColor! {
        didSet {
            ticketDetailView.backgroundColor = themeColor
            viewWordOfStatus.backgroundColor = themeColor
            connectionLineView.backgroundColor = themeColor
        }
    }
    
    // Ticket
    var ticket: Ticket? {
        didSet {
            // View Status
            let oneWord = HandleUtil.getOneWordOfStatus((ticket?.status?.rawValue)!)
            labelStatus.text = oneWord
            viewWordOfStatus.layer.cornerRadius = viewWordOfStatus.frame.size.width / 2
            viewWordOfStatus.layer.masksToBounds = true
            // View User
            if ticket?.user?.profileImage?.imageUrl! != "" {
                let profileUser = ticket?.user?.profileImage?.imageUrl!
                HandleUtil.loadImageViewWithUrl(profileUser!, imageView: imageViewProfile)
                imageViewProfile.layer.cornerRadius = 5
                imageViewProfile.clipsToBounds = true
            }
            labelUsername.text = ticket?.user?.getFullName()
            // Check block or un block phoneNumber and Address
            if ticket?.worker?.id == Worker.currentUser?.id {
                // address
                labelPhoneNumber.text = ticket?.user?.phoneNumber
                // Location
                if ticket?.location?.address != "" {
                    //labelLocation.text = ticket?.location?.address!
                } else {
                    //labelLocation.text = "No Address"
                }
                
            } else {
                labelPhoneNumber.text = "Blocked"
                //labelLocation.text = "Blocked"
                
            }
            
            // View Information
            //            buttonCall.layer.cornerRadius = buttonCall.frame.size.width / 2
            //            buttonCall.layer.masksToBounds = true
            //            buttonCall.layer.borderColor = UIColor.whiteColor().CGColor
            //            buttonCall.layer.borderWidth = 2
            if ticket?.imageOne?.imageUrl! != "" {
                let imageTicket = ticket?.imageOne?.imageUrl!
                HandleUtil.loadImageViewWithUrl(imageTicket!, imageView: imageViewTicket)
            } else {
                imageViewTicket.image = UIImage(named: "no_image")
            }
            
            
            labelTitle.text = ticket?.title!
            labelDateCreated.text = HandleUtil.changeUnixDateToNSDate(ticket!.createdAt!)
            actionButton.layer.cornerRadius = 5
            actionButton.layer.borderColor = UIColor.whiteColor().CGColor
            actionButton.layer.borderWidth = 1
            
            if ticket?.status == Status.InService {
                actionButton.setTitle("Done", forState: .Normal)
            } else {
                if ticket?.status == Status.Pending{
                    actionButton.setTitle("Bid", forState: .Normal)
                } else {
                    if ticket?.status == Status.Done {
                        actionButton.setTitle("Waiting ...", forState: .Normal)
                    }
                }
            }
        }
    }
    
    
    
    // Map Haena
    func forMapDirection(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 200
        locationManager.requestWhenInUseAuthorization()
        
        currentLocation()
        
        placesClient = GMSPlacesClient.sharedClient()
    }
    
    func currentLocation(){
        
        placesClient.currentPlaceWithCallback({ (placeLikelihoods, error) -> Void in
            guard error == nil else {
                print("Current Place error: \(error!.localizedDescription)")
                print("errorrrr")
                return
            }
            
            self.workerlocation.longitute = (self.locationManager.location?.coordinate.longitude)!
            self.workerlocation.latitude = (self.locationManager.location?.coordinate.latitude)!
            
            self.workerlocation.address = placeLikelihoods!.likelihoods[0].place.formattedAddress!
            
        })
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        forMapDirection()
        //let ticketDetailGestureRecognizer = UITapGestureRecognizer(target: self, action: <#T##Selector#>)
    }
    
    @IBAction func mapDirectionAction(sender: AnyObject) {
        print("abc")
        
        if let locationLog = ticket!.location!.longitute, let locationLat = ticket!.location!.latitude, let workerloclog = workerlocation.longitute, let workerloclat = workerlocation.latitude{
            
            var urlString = "http://maps.google.com/maps?"
            urlString += "saddr=\(workerloclog),\(workerloclat)"
            urlString += "&daddr=\(locationLat)),\(locationLog)"
            print(urlString)
            if let url = NSURL(string: urlString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
                
            {
                UIApplication.sharedApplication().openURL(url)
            }
            
            
            print("bahhh")
            
        }
    }
    
    @IBAction func onDoAction(sender: UIButton) {
        if ticket?.status?.rawValue == "Pending" {
            
            if actionButton.titleLabel!.text != "Waiting" {
                
                let storyBoard: UIStoryboard = UIStoryboard(name: "Worker", bundle: nil)
                
                let resultViewController =
                    storyBoard.instantiateViewControllerWithIdentifier("SetPricePopUpViewController") as! SetPricePopUpViewController
                resultViewController.ticket = self.ticket!
                homeTimeLineViewWorker!.presentViewController(resultViewController, animated: true, completion:nil)
                actionButton.setTitle("Waiting", forState: .Normal)
                
            }
        } else {
            let parameters: [String: AnyObject] = [
                "statusTicket": Status.Done.rawValue,
                "idTicket": (ticket?.id!)!
            ]
            let url = "\(API_URL)\(PORT_API)/v1/updateStatusOfTicket"
            Alamofire.request(.POST, url, parameters: parameters).responseJSON { response  in
                print(response.result.value!)
                let JSON = response.result.value!["data"] as! [String: AnyObject]
                print(JSON)
                self.ticket = Ticket(data: JSON)
                SocketManager.sharedInstance.updateTicket(self.ticket!.id!, statusTicket: (self.ticket?.status?.rawValue)!, idUser: (self.ticket?.user?.id)!)
            }
        }
    }
    
    
}

extension WorkerTicketCell: CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedWhenInUse {
            //            mapView.myLocationEnabled = true
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("error")
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation = locations[0]
        
        let location_default = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        //        currentlocation_latitude = location.latitude
        //        currentlocation_long = location.longitude
        workerlocation.latitude = location_default.latitude
        workerlocation.longitute = location_default.longitude
        
        print(location_default)
        print(workerlocation)
        
        locationManager.stopUpdatingLocation()
    }
}