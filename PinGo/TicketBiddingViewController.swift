//
//  TicketBiddingViewController.swift
//  PinGo
//
//  Created by Hien Quang Tran on 8/9/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import UIKit
import GoogleMaps

class TicketBiddingViewController: UIViewController {
    @IBOutlet weak var ticketTitleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateIssuedLabel: UILabel!

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var mapView: GMSMapView!
    
    @IBOutlet weak var bottomPanelView: UIView!
    
    @IBOutlet weak var topPanelView: UIView!
    
    var activityIndicatorView: NVActivityIndicatorView! = nil
    
    var newTicket: Ticket!
    
    var workerList: [Worker] = []
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .None
        
        //locationManager.delegate = self
        //locationManager.requestWhenInUseAuthorization()
        //mapView.delegate = self
        
        //addMarker()
        
        let cellNib = UINib(nibName: "NoResultFound", bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: "NoResultFound")
        
        setupAppearance()
        
        //set up appearance (need to refactor)
        ticketTitleLabel.text = newTicket.title?.uppercaseString
        
        //load worker list
        SocketManager.sharedInstance.getWorkers { (worker, idTicket) in
            if self.newTicket.id != idTicket {
                return
            }
            self.workerList.append(worker)
            self.tableView.reloadData()
        }
        
        print(newTicket.location?.latitude)
        print(newTicket.location?.longitute)
        print(newTicket.location?.address)
    }
    
    /*
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    }
    */
    
    @IBAction func filterTapped(sender: UIBarButtonItem) {
    }

    @IBAction func cancelTicketTapped(sender: UIButton) {
    }
    
    //MARK: - Helpers
    func setupAppearance() {
        setupIndicator()
        
        //top and bottom panel
        bottomPanelView.layer.cornerRadius = 5
        bottomPanelView.backgroundColor = AppThemes.bottomPanelColor
        
        topPanelView.layer.cornerRadius = 5
        topPanelView.backgroundColor = AppThemes.topPannelColor
        
        //color
        ticketTitleLabel.font = AppThemes.avenirBlack20
        ticketTitleLabel.textColor = UIColor.whiteColor()
        addressLabel.font = AppThemes.helveticaNeueRegular14
        addressLabel.textColor = UIColor.whiteColor()
        dateIssuedLabel.font = AppThemes.avenirBlack20
        dateIssuedLabel.textColor = UIColor.whiteColor()
        
        

        
        
    }
    
    func setupIndicator() {
        //set up positin & size for the indicator
        let width: CGFloat = 30
        let height: CGFloat = 30
        let x: CGFloat = bottomPanelView.frame.width - 50
        let y: CGFloat = (bottomPanelView.frame.height + topPanelView.frame.height) / 2 - height/2
        let frame = CGRect(x: x, y: y, width: width, height: height)
        
        activityIndicatorView = NVActivityIndicatorView(frame: frame, type: NVActivityIndicatorType.BallScaleMultiple, color: AppThemes.topPannelColor, padding: 60)
        
        let categoryIconContainerView = UIView(frame: frame)
        let categoryIconImageView = UIImageView(frame: CGRect(x: 5, y: 5, width: 20, height: 20)) //image is in the center of the container view
        categoryIconContainerView.layer.cornerRadius = categoryIconContainerView.frame.width / 2
        categoryIconImageView.image = UIImage(named: "greentech")
        categoryIconContainerView.addSubview(categoryIconImageView)
        categoryIconContainerView.backgroundColor = AppThemes.topPannelColor
        
        //        let resetButton = UIButton(frame: frame)
        //        resetButton.setImage(UIImage(named: "greentech"), forState: .Normal)
        //        resetButton.addTarget(self, action: #selector(buttonTapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        bottomPanelView.addSubview(activityIndicatorView)
        bottomPanelView.addSubview(categoryIconContainerView)
        activityIndicatorView.startAnimation()
    }
    
    func buttonTapped(sender: UIButton) {
        if activityIndicatorView.animating {
            activityIndicatorView.stopAnimation()
        } else {
            activityIndicatorView.startAnimation()
        }
    }
    
    //MARK: - Actions
    @IBAction func cancelTapped(sender: UIButton) {
        let alert = UIAlertController(title: "Cancel Request", message: "This process can not be undone. Are you sure? Tap OK to cancel this request", preferredStyle: .Alert)
        let okACtion = UIAlertAction(title: "OK", style: .Default) { _ in
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alert.addAction(okACtion)
        alert.addAction(cancelAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }
}



// MARK: - TableView data source and delegate
extension TicketBiddingViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workerList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("WorkerHistoryCell", forIndexPath: indexPath) as! WorkerDetailCell
        
        let colorIndex = indexPath.row < AppThemes.cellColors.count ? indexPath.row : getCorrespnsingColorForCell(indexPath.row)
        cell.backgroundColor = AppThemes.cellColors[colorIndex]
        cell.worker = workerList[indexPath.row]
        cell.ticket = newTicket!
        return cell
    }
    
}
/*
extension TicketBiddingViewController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        locationManager.startUpdatingLocation()
        
        mapView.myLocationEnabled = false
        mapView.settings.myLocationButton = false
        addMarker()
//        if status == .AuthorizedWhenInUse {
// 
//        }
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            locationManager.stopUpdatingLocation()
        }
        
    }
    
    //Helpers
    func addMarker() {
        if let latitude = newTicket.location?.latitude, let longitude = newTicket.location?.longitute {
            //Add Event Location Marker
            let camera = GMSCameraPosition.cameraWithLatitude(latitude as Double, longitude: longitude as Double, zoom: 14)
            let position = CLLocationCoordinate2DMake(latitude as Double, longitude as Double)
            let marker = GMSMarker(position: position)
            marker.icon = UIImage(named: "dog")
            
            marker.title = newTicket.title
            marker.map = self.mapView
            
            self.mapView.camera = camera
            marker.appearAnimation = kGMSMarkerAnimationPop
        }
    }
}*/
