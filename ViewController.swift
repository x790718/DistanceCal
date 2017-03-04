//
//  ViewController.swift
//  hwCaculator
//
//  Created by Eddey on 2016/10/28.
//  Copyright © 2016年 EDP. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    
    @IBOutlet weak var startLocationField: UITextField!
    @IBOutlet weak var destinationField: UITextField!
    

    @IBOutlet weak var finalPriceView: UIView!
    @IBOutlet weak var startPriceLabel: UILabel!
    @IBOutlet weak var distancePriceLabel: UILabel!
    @IBOutlet weak var timePriceLabel: UILabel!
    @IBOutlet weak var longDistancePriceLabel: UILabel!
    
    @IBOutlet weak var totalPriceLabel: UILabel!
    
    
    @IBOutlet weak var spinnerView: UIActivityIndicatorView!
    
    
    @IBOutlet weak var bouncePriceView: UIView!
    @IBOutlet weak var bounceRateLabel: UILabel!
    
    var locationManagement: CLLocationManager!
    
    
    
    let startPrice = 30.0
    let pricePerMinute = 2.0
    let priceperKM = 11.5
    let longDistance = 15.0
    let longDistancePerPriceKM = 11.5
    let minmumPrice = 50.0
    
    var mapItems = [MKMapItem]()
    var completedCount = 0
    var distanceFinal: Double = 0.0
    var timeFinal: Double = 0.0
    
    var cc = (CLLocationDegrees)()
    
   
    
    @IBAction func resetTapped(_ sender: Any) {
        
        startLocationField.text = nil
        destinationField.text = nil
        
        
        let startPrice = 0
        let disPrice = 0
        let timePrice = 0
        let longDistancePrice = 0
        let totalPrice = 0
        
        startPriceLabel.text = "\(startPrice)"
        distancePriceLabel.text = "\(disPrice)"
        timePriceLabel.text = "\(timePrice)"
        longDistancePriceLabel.text = "\(longDistancePrice)"
        totalPriceLabel.text = "\(totalPrice)"
        
        
        self.completedCount = 0
        
        finalPriceView.isHidden = true
        bouncePriceView.isHidden = true
        spinnerView.isHidden = true
        
    }
    
    
    
    @IBAction func caculateTapped(_ sender: Any) {
        
        print("start")
        spinnerView.isHidden = false
        
        if let startLocationtext = startLocationField.text, let destinationtext = destinationField.text{
        
            if startLocationtext.isEmpty || destinationtext.isEmpty{
            
                let alertController = UIAlertController(
                    title: "提示",
                    message: "請輸入正確地點資訊",
                    preferredStyle: .alert)
                
                let okAction = UIAlertAction(
                    title: "確認",
                    style: .default,
                    handler: {
                        (action: UIAlertAction!) -> Void in
                        print("按下確認後，閉包裡的動作")
                })
                alertController.addAction(okAction)
                
                // 顯示提示框
                self.present(alertController,
                             animated: true, completion: nil)
                
                self.spinnerView.isHidden = true
            
            }
        
        }
        
        if self.completedCount == 2 {
            
            self.completedCount = 0
            
        }
        
        let startSearchRequest = MKLocalSearchRequest()
        startSearchRequest.naturalLanguageQuery = startLocationField.text
        
        let startRequest = MKLocalSearch(request: startSearchRequest)
        startRequest.start { (startResponse, error) in
            
            print("搜尋結束：起點")
            print("\(startResponse?.mapItems.first)")
            
            if let mapItem = startResponse?.mapItems.first {
                self.mapItems.append(mapItem)
                self.completedCount += 1
            }
            if self.completedCount == 2 {
                self.calculateRoute()
            }
            
        }
        
        let destinationSearchRequest = MKLocalSearchRequest()
        destinationSearchRequest.naturalLanguageQuery = destinationField.text
        
        let destinationRequest = MKLocalSearch(request: destinationSearchRequest)
        destinationRequest.start { (destionationResponse, error) in
            
            print("搜尋結束：目的地")
            print("\(destionationResponse?.mapItems.first)")
            
            if let mapItem = destionationResponse?.mapItems.first {
                self.mapItems.append(mapItem)
                self.completedCount += 1
            }
            if self.completedCount == 2 {
                self.calculateRoute()
            }
            
        }

    }
    
    
    func calculateRoute(){
        
        
        print("準備開始路徑規劃")
        
        let routeRequest = MKDirectionsRequest()
        routeRequest.source = self.mapItems.first
        routeRequest.destination = self.mapItems.last
        routeRequest.transportType = MKDirectionsTransportType.automobile
        
        let finalRoute = MKDirections(request: routeRequest)
        finalRoute.calculate { (routeResponse, error) in
            
            print("完成")
            print("\(routeResponse?.routes.first?.distance)")
            print("\(routeResponse?.routes.first?.expectedTravelTime)")
            
            if let distanceRoute = routeResponse?.routes.first?.distance, let timeRoute = routeResponse?.routes.first?.expectedTravelTime{
            
            self.distanceFinal = distanceRoute/1000
            self.timeFinal = timeRoute/60
                
            print(self.distanceFinal, "distance")
            print((self.timeFinal),"time")
                
            
            self.calculatPrice()
                
            }
            
        }
        
    }
    
    
    func calculatPrice(){
        
        print("OK!!!!!!")
        

        if self.distanceFinal > 0 && self.timeFinal > 0{
        
            
            let distancePrice = self.distanceFinal * priceperKM
            let timePrice = self.timeFinal * pricePerMinute
            var longdistancePrice = (self.distanceFinal - longDistance) * longDistancePerPriceKM
            
            if longdistancePrice < 0{
            
                longdistancePrice = 0
                
            }
            
            var totalPrice = startPrice + distancePrice + timePrice
            
            if totalPrice <= minmumPrice{
            
                totalPrice = minmumPrice
            
            }
        
            startPriceLabel.text = "\(lround(startPrice))"
            distancePriceLabel.text = "\(lround(distancePrice))"
            timePriceLabel.text = "\(lround(timePrice))"
            longDistancePriceLabel.text = "\(lround(longdistancePrice))"
            
            totalPriceLabel.text = "\(lround(totalPrice))"
            
            print("over")
            spinnerView.isHidden = true
            
        }
        
        
        if self.completedCount == 2{
            
            finalPriceView.isHidden = false
            bouncePriceView.isHidden = false
            
        }
            
        else {
            
            finalPriceView.isHidden = true
            bouncePriceView.isHidden = true
            
        }
    
    }
    
    
    @IBAction func bouncePaySlider(_ sender: UISlider) {
        
        let bounceRate = String(format : "%.1f", Float(sender.value))
        bounceRateLabel.text = bounceRate+"x"
        
        self.calculatPrice()
        
        let finalBounceRate = Double(sender.value)
        if let totalPriceText = totalPriceLabel.text, let totalPrice = Double(totalPriceText){
        
            let bouncePay = totalPrice * finalBounceRate
            
            totalPriceLabel.text = "\(lround(bouncePay))"
        
        }
        
    }
    

    
    @IBAction func currentLocationTapped(_ sender: Any) {
    
    
        //print(self.locationManagement.location?.coordinate.latitude)
        //print(self.locationManagement.location?.coordinate.longitude)
        
        //print(self.locationManagement.location)
        
        let cLatitude = (self.locationManagement.location?.coordinate.latitude)!
        let cLongtitude = (self.locationManagement.location?.coordinate.longitude)!
        
        startLocationField.text = "\(cLatitude, cLongtitude)"
        
                
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    
        
        self.locationManagement = CLLocationManager()
        self.locationManagement.delegate = self
        
        self.locationManagement.requestAlwaysAuthorization()
        
        self.locationManagement.startUpdatingLocation()
        
        print("startUpdatingLocation")
        
        
        
        
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // 停止定位自身位置
        locationManagement.stopUpdatingLocation()
    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        finalPriceView.isHidden = true
        bouncePriceView.isHidden = true
        spinnerView.isHidden = true
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        startLocationField.endEditing(true)
        destinationField.endEditing(true)
    }


}

