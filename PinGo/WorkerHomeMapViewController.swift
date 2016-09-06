//
//  WorkerHomeMapViewController.swift
//  PinGo
//
//  Created by Hien Quang Tran on 8/31/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import UIKit
import Alamofire
class WorkerHomeMapViewController: UIViewController {
    // View
    @IBOutlet weak var mapView: GMSMapView!
    
    @IBOutlet weak var labelCountTitle: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    // View Filter
    
    @IBOutlet weak var viewAll: UIView!
    
    @IBOutlet weak var viewInservice: UIView!
    
    @IBOutlet weak var viewPending: UIView!
    
    @IBOutlet weak var labelAll: UILabel!
    
    @IBOutlet weak var labelCountAll: UILabel!
    
    @IBOutlet weak var labelPending: UILabel!
    
    @IBOutlet weak var labelCountPending: UILabel!
    
    @IBOutlet weak var labelInservice: UILabel!
    
    @IBOutlet weak var labelCountInservice: UILabel!
    
    @IBOutlet weak var viewControlTable: UIView!
    
    
    // Declare global variables
    var locationManager = CLLocationManager()
    var marker: GMSMarker?
    
    var tickets: [Ticket] = []
    var ticketsFilter: [Ticket] = []
    
    var markers : [GMSMarker] = []
    var markersFilter: [GMSMarker] = []
    
    var isShowingTableView = false //check if user list in table view is shown or not
    
    var indexButton = 0
    
    var countAll = 0
    var countPending = 0
    var countInservice = 0
    
    var filter = PingoFilter()
    
    var currentLocation: CLLocation?
    
    var isFirstTimeLoadData = true
    @IBOutlet weak var tableSlideUpButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        initLocation()
        initTableView()
        setupSubAppearance()
        clearAllViewButtons()
        choosenViewButton(viewAll, labelTitle: labelAll, labelCount: labelCountAll)
        initActionForViewFilter()
        
        
        initSocket()
        
    }
    
    //MARK: - Actions
    
    @IBAction func onTableSlideUp(sender: UIButton) {
        //if tableview is hidden, slide it up, if it is shown then slide it down
        if !isShowingTableView {
            UIView.animateKeyframesWithDuration(0.6, delay: 0, options: .CalculationModeCubic, animations: {
                UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.33, animations: {
                    self.tableView.transform = CGAffineTransformIdentity
                    self.viewControlTable.transform = CGAffineTransformIdentity
                })
                
                //fliping effect for tableSlideUpButton
                UIView.addKeyframeWithRelativeStartTime(0.33, relativeDuration: 0.63, animations: {
                    self.tableSlideUpButton.transform = CGAffineTransformMakeScale(1, 0.1)
                    self.tableSlideUpButton.setImage(UIImage(named: "downFilled"), forState: .Normal)
                })
                
                UIView.addKeyframeWithRelativeStartTime(0.67, relativeDuration: 0.33, animations: {
                    self.tableSlideUpButton.transform = CGAffineTransformIdentity
                })
                }, completion: { finished in
                    self.isShowingTableView = !self.isShowingTableView
            })
        } else {
            UIView.animateKeyframesWithDuration(0.6, delay: 0, options: .CalculationModeCubic, animations: {
                UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.33, animations: {
                    self.tableView.transform = CGAffineTransformMakeTranslation(0, self.tableViewHeightConstraint.constant)
                    self.viewControlTable.transform = CGAffineTransformMakeTranslation(0, self.tableViewHeightConstraint.constant)
                })
                
                //fliping effect for tableSlideUpButton
                UIView.addKeyframeWithRelativeStartTime(0.33, relativeDuration: 0.63, animations: {
                    //self.tableSlideUpButton.transform = CGAffineTransformMakeScale(1, 0.1)
                    self.tableSlideUpButton.setImage(UIImage(named: "upFilled"), forState: .Normal)
                })
                
                UIView.addKeyframeWithRelativeStartTime(0.67, relativeDuration: 0.33, animations: {
                    //self.tableSlideUpButton.transform = CGAffineTransformMakeScale(1, 1)
                })
                }, completion: { finished in
                    self.isShowingTableView = !self.isShowingTableView
            })
        }
        
    }
    
    
    // MARK: - Helpers
    func setupSubAppearance() {
        
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "TicketDetailSegue" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let ticketDetailViewController = segue.destinationViewController as! DetailTicketViewController
                //let cell = tableView.cellForRowAtIndexPath(indexPath) as! WorkerTicketCell
                ticketDetailViewController.ticket = tickets[indexPath.row]
                
            }
        } else {
            if segue.identifier == "FilterSegue" {
                let filterViewController = segue.destinationViewController as! UserFilterViewController
                filterViewController.delegate = self
            }
        }
        
    }
    // MARK: initOpacityBarView
    func initOpacityBarView(){
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = true
    }
    
}
//MARK: - UITableViewDataSource, UITableViewDelegate
extension WorkerHomeMapViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ticketsFilter.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TicketWorkerCell", forIndexPath: indexPath) as! TicketWorkerCell
        let ticket = ticketsFilter[indexPath.row]
        let marker = markersFilter[indexPath.row]
        
        cell.location = currentLocation
        cell.marker = marker
        cell.ticket = ticket
        cell.workerHomeMapViewController = self
        cell.delegate = self
        
        
        return cell
    }
    
    func initTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 162
        tableView.rowHeight = UITableViewAutomaticDimension
        tableViewHeightConstraint.constant = (view.frame.height - 69 - 49) / 2
        tableView.transform = CGAffineTransformMakeTranslation(0, tableViewHeightConstraint.constant) //add the start stage for table View
        viewControlTable.transform = CGAffineTransformMakeTranslation(0, tableViewHeightConstraint.constant) ////add the start stage for tableViewSlideUpButton
        
    }
}


// MARK: Location Manager
extension WorkerHomeMapViewController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
            mapView.myLocationEnabled = true
            mapView.settings.myLocationButton = true
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("error location Manager")
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        locationManager.stopUpdatingLocation()
        
        //center camera around
        
        let camera = GMSCameraPosition.cameraWithTarget(locations[0].coordinate, zoom: 14)
        self.mapView.camera = camera
        currentLocation = locations[0]
        // Shoule load data if app have locatiion
        if isFirstTimeLoadData {
            loadDataFromAPI()
            isFirstTimeLoadData = false
        }
        
        //add marker
        marker = GMSMarker(position: locations[0].coordinate)
        //        marker?.icon = UIImage(named: "marker")
        marker?.map = self.mapView
    }
    func initLocation() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
}
// MARK - Socket
extension WorkerHomeMapViewController {
    func initSocket() {
        SocketManager.sharedInstance.getTicket { (ticket) in
            // Check category of ticket
            if ticket.category != Worker.currentUser?.category {
                return
            } else {
                var isNewTicket = true
                var index = 0
                if self.tickets.count > 0 {
                    for itemTicket in self.tickets {
                        
                        if itemTicket.id == ticket.id {
                            
                            if ticket.worker!.id != Worker.currentUser?.id && ticket.worker!.id != ""{
                                print("Not choose you")
                                //self.tickets.removeAtIndex(index)
                                //self.countPending -= 1
                                itemTicket.status = Status.ChoosenAnother
                                isNewTicket = false
                                break
                            } else {
                                if ticket.status == Status.Cancel{
                                    itemTicket.status = ticket.status
                                    isNewTicket = false
                                    
                                    break
                                }  else {
                                    if ticket.status == Status.Approved {
                                        itemTicket.status = ticket.status
                                        isNewTicket = false
                                        break
                                    } else {
                                        // Change Pending To Inservice
                                        itemTicket.status = ticket.status
                                        itemTicket.worker = ticket.worker
                                        isNewTicket = false
                                        self.countInservice += 1
                                        if self.countPending > 0 {
                                            self.countPending -= 1
                                        }
                                        
                                        //self.calculateCountWithStatus((ticket.status?.rawValue)!)
                                        self.updateUIOfMarker(index)
                                        //                                        self.addUserNewMarker(ticket.location!, status: (ticket.status?.rawValue)!)
                                        break
                                    }
                                    // Change status Pending to Inservice
                                }
                            }
                            // Remove ticket to history if ticket has been approved by user
                        }
                        index += 1
                    }
                    
                }
                if isNewTicket {
                    if self.filter.distanceFilter != 0 {
                        if self.filter.checkDistance(self.currentLocation!, targetLocation: (ticket.location?.convertToCllLocation())!){
                            self.calculateCountWithStatus((ticket.status?.rawValue)!)
                            self.tickets.insert(ticket, atIndex: 0)
                            self.addUserNewMarker(ticket.location!, status: (ticket.status?.rawValue)!)
                        }
                        
                    } else {
                        self.calculateCountWithStatus((ticket.status?.rawValue)!)
                        self.tickets.insert(ticket, atIndex: 0)
                        self.addUserNewMarker(ticket.location!, status: (ticket.status?.rawValue)!)
                    }
                    
                }
                self.indexAtViewTab(self.indexButton)
                self.tableView.reloadData()
                self.reloadLabelsCount()
                self.reloadLabelCountTitle(self.indexButton)
            }
            
        }
    }
}
// MARK: ViewFilter
extension WorkerHomeMapViewController {
    func viewAllAction(sender: AnyObject){
        clearAllViewButtons()
        choosenViewButton(viewAll, labelTitle: labelAll, labelCount: labelCountAll)
        indexButton = 0
        self.indexAtViewTab(self.indexButton)
        reloadLabelCountTitle(indexButton)
    }
    
    func viewPendingAction(sender: AnyObject){
        clearAllViewButtons()
        choosenViewButton(viewPending, labelTitle: labelPending, labelCount: labelCountPending)
        indexButton = 1
        self.indexAtViewTab(self.indexButton)
        reloadLabelCountTitle(indexButton)
    }
    
    func viewInserviceAction(sender: AnyObject){
        clearAllViewButtons()
        choosenViewButton(viewInservice, labelTitle: labelInservice, labelCount: labelCountInservice)
        indexButton = 2
        self.indexAtViewTab(self.indexButton)
        reloadLabelCountTitle(indexButton)
    }
    
    func initActionForViewFilter() {
        
        let gestureAll = UITapGestureRecognizer(target: self, action: #selector(HomeTimeLineWorker.viewAllAction(_:)))
        viewAll.addGestureRecognizer(gestureAll)
        
        // View Pending
        viewPending.layer.borderColor = UIColor.whiteColor().CGColor
        viewPending.layer.borderWidth = 1
        
        let gesturePending = UITapGestureRecognizer(target: self, action: #selector(HomeTimeLineWorker.viewPendingAction(_:)))
        viewPending.addGestureRecognizer(gesturePending)
        
        // View Inservice
        viewInservice.layer.borderColor = UIColor.whiteColor().CGColor
        viewInservice.layer.borderWidth = 1
        
        let getstureInservice = UITapGestureRecognizer(target: self, action: #selector(HomeTimeLineWorker.viewInserviceAction(_:)))
        viewInservice.addGestureRecognizer(getstureInservice)
    }
    
    func clearAllViewButtons(){
        clearViewButton(viewAll, labelTitle: labelAll, labelCount: labelCountAll)
        clearViewButton(viewInservice, labelTitle: labelInservice, labelCount: labelCountPending)
        clearViewButton(viewPending, labelTitle: labelPending, labelCount: labelCountInservice)
    }
    
    func clearViewButton(view: UIView, labelTitle: UILabel, labelCount: UILabel) {
        view.backgroundColor = UIColor.clearColor()
        labelTitle.textColor = UIColor.whiteColor()
        labelCount.textColor = UIColor.whiteColor()
    }
    
    func choosenViewButton(view: UIView, labelTitle: UILabel, labelCount: UILabel){
        view.backgroundColor = UIColor.whiteColor()
        labelTitle.textColor = AppThemes.appColorTheme
        labelCount.textColor = AppThemes.appColorTheme
    }
    
}
// MARK: Count label status
extension WorkerHomeMapViewController {
    // MARK: calculate count with status ticket
    func calculateCountWithStatus(status: String) {
        switch status {
        case Status.Pending.rawValue:
            countAll += 1
            countPending += 1
            break
        case Status.InService.rawValue:
            countAll += 1
            countInservice += 1
            if countPending > 0 {
                countPending -= 1
            }
            break
        default:
            print("do nothing")
            break
        }
        
    }
    func reloadLabelsCount() {
        labelCountAll.text = "(\(countAll))"
        labelCountPending.text = "(\(countPending))"
        labelCountInservice.text = "(\(countInservice))"
    }
    func reloadLabelCountTitle(indexView: Int) {
        switch indexView {
        case 0:
            UIView.animateWithDuration(0.7) {
                self.labelCountTitle.text = "\(self.countAll) tickets"
            }
            break
        case 1:
            UIView.animateWithDuration(0.7) {
                self.labelCountTitle.text = "\(self.countPending) tickets"
            }
            
            break
        case 2:
            UIView.animateWithDuration(0.7) {
                self.labelCountTitle.text = "\(self.countInservice) tickets"
            }
            break
        default:
            break
        }
    }
    //MARK: filter tickets based on their status
    func filterTicketList(status: String) {
        if ticketsFilter.count > 0 && markersFilter.count > 0{
            ticketsFilter.removeAll()
            for marker in markersFilter {
                marker.map = nil
            }
        }
        for ticket in tickets {
            if ticket.status?.rawValue == status {
                ticketsFilter.append(ticket)
                self.addUserMarkerFilter(ticket.location!, status: (ticket.status?.rawValue)!)
            }
        }
    }
    
    //MARK: filter ticket inservice and done
    func filterTicketListForInserviceAndDone(){
        if ticketsFilter.count > 0 && markersFilter.count > 0{
            ticketsFilter.removeAll()
            for marker in markersFilter {
                marker.map = nil
            }
        }
        for ticket in tickets {
            if ticket.status == Status.InService || ticket.status == Status.Done || ticket.status == Status.Approved{
                ticketsFilter.append(ticket)
                self.addUserMarkerFilter(ticket.location!, status: (ticket.status?.rawValue)!)
            }
        }
    }
    
    // MARK : index list ticket with filter
    func indexAtViewTab(index: Int){
        switch index {
        case 0:
            //all tickets
            ticketsFilter = tickets
            if markersFilter.count > 0 {
                for marker in markersFilter {
                    marker.map = nil
                }
                markersFilter = markers
                for marker in markersFilter {
                    marker.map = self.mapView
                }
            }
            markersFilter = markers
            break
        case 1:
            //ticket pending
            filterTicketList(Status.Pending.rawValue)
            break
        case 2:
            //ticket inservice and done
            filterTicketListForInserviceAndDone()
            break
        default:
            break
        }
        UIView.animateWithDuration(0.7) {
            self.tableView.reloadData()
        }
    }
}
// MARK: Load data from API
extension WorkerHomeMapViewController {
    func loadDataFromAPI(){
        var parameters = [String : AnyObject]()
        parameters["status"] = "Pending"
        parameters["category"] = Worker.currentUser?.category
        parameters["idWorker"] = Worker.currentUser?.id
        var isChanged = false
        Alamofire.request(.POST, "\(API_URL)\(PORT_API)/v1/ticketOnCategory", parameters: parameters).responseJSON { response  in
            print("ListTicketController ---")
            print("\(response.result.value)")
            let JSONArrays  = response.result.value!["data"] as! [[String: AnyObject]]
            for JSONItem in JSONArrays {
                let ticket = Ticket(data: JSONItem)
                
                if ticket.status == Status.Pending {
                    // Check distance
                    if self.filter.distanceFilter != 0 {
                        // Range distance
                        if self.filter.checkDistance(self.currentLocation!, targetLocation: (ticket.location?.convertToCllLocation())!){
                            self.tickets.append(ticket)
                            self.addUserMarker(ticket.location!, status: (ticket.status?.rawValue)!)
                            self.calculateCountWithStatus((ticket.status?.rawValue)!)
                            isChanged = true
                        }
                        
                    } else {
                        // If distance is Any
                        self.tickets.append(ticket)
                        self.addUserMarker(ticket.location!, status: (ticket.status?.rawValue)!)
                        self.calculateCountWithStatus((ticket.status?.rawValue)!)
                        isChanged = true
                    }
                    
                } else {
                    if ticket.status == Status.InService {
                        self.tickets.append(ticket)
                        self.addUserMarker(ticket.location!, status: (ticket.status?.rawValue)!)
                        self.calculateCountWithStatus((ticket.status?.rawValue)!)
                        isChanged = true
                    }
                }
            }
            
            if isChanged {
                self.indexAtViewTab(self.indexButton)
                self.tableView.reloadData()
                self.reloadLabelsCount()
                self.reloadLabelCountTitle(self.indexButton)
            }
            
        }
    }
}

// MARK: Add user marker
extension WorkerHomeMapViewController {
    func addUserMarker(location: Location, status: String) {
        let lat = location.latitude as! Double
        let long = location.longitute as! Double
        let newLocation = CLLocation(latitude: lat, longitude: long)
        var marker: GMSMarker?
        marker = GMSMarker(position: newLocation.coordinate)
        marker?.icon = getMarkerImageWithStatus(status)
        marker!.title = "\((location.address)!)"
        marker?.map = self.mapView
        markers.append(marker!)
    }
    func addUserNewMarker(location: Location, status: String) {
        let lat = location.latitude as! Double
        let long = location.longitute as! Double
        let newLocation = CLLocation(latitude: lat, longitude: long)
        var marker: GMSMarker?
        marker = GMSMarker(position: newLocation.coordinate)
        marker?.icon = getMarkerImageWithStatus(status)
        marker!.title = "\((location.address)!)"
        marker?.map = self.mapView
        markers.insert(marker!, atIndex: 0)
    }
    func addUserMarkerFilter(location: Location, status: String) {
        let lat = location.latitude as! Double
        let long = location.longitute as! Double
        let newLocation = CLLocation(latitude: lat, longitude: long)
        var marker: GMSMarker?
        marker = GMSMarker(position: newLocation.coordinate)
        marker?.icon = getMarkerImageWithStatus(status)
        marker!.title = "\((location.address)!)"
        marker?.map = self.mapView
        markersFilter.append(marker!)
    }
    func updateUIOfMarker(index: Int){
        //markers[index].map = nil
        markers[index].icon = UIImage(named: "marker_small_orange")!
    }
    
    func getMarkerImageWithStatus(status: String) -> UIImage {
        switch status {
        case Status.Pending.rawValue:
            return UIImage(named: "marker_small")!
        case Status.InService.rawValue:
            return UIImage(named: "marker_small_orange")!
        default:
            return UIImage()
        }
    }
}
// MARK: TicketWorkerCellDelegate
extension WorkerHomeMapViewController : TicketWorkerCellDelegate {
    func ticketWorkerDelegate(marker: GMSMarker) {
        self.mapView.selectedMarker = marker
        let target = CLLocationCoordinate2D(latitude: marker.layer.latitude, longitude: marker.layer.longitude)
        mapView.animateToLocation(target)
    }
}
// MARK: UserFilterDelegate
extension WorkerHomeMapViewController: UserFilterDelegate {
    func userFilterDelegate(filter: PingoFilter) {
        self.filter = filter
        countAll = 0
        countPending = 0
        countInservice = 0
        reloadLabelsCount()
        reloadLabelCountTitle(indexButton)
        tickets.removeAll()
        ticketsFilter.removeAll()
        markers.removeAll()
        markersFilter.removeAll()
        for marker in markersFilter {
            marker.map = nil
        }
        for marker in markers {
            marker.map = nil
        }
        mapView.clear()
        loadDataFromAPI()
        print("Filter: \(self.filter.distanceFilter)")
        
    }
}
