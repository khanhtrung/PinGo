//
//  PingoFilter.swift
//  PinGo
//
//  Created by Hien Quang Tran on 9/4/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import Foundation

class PingoFilter {
    var distanceFilter: Double?
    var priceFrom: Double?
    var priceTo: Double?
    let distanceOptions = [5.0, 10.0, 15.0, 0.0]
    init() {
        distanceFilter = 0.0
        priceFrom = 0.0
        priceTo = 0.0
    }
    
    func resetFilter() {
        distanceFilter = 0.0
        priceFrom = 0.0
        priceTo = 0.0
    }
    
    
    func filterFromDistance(distanceArray: [Double]) -> [Double] {
        if distanceFilter != 0 {
            if let distanceFilter = distanceFilter {
                return distanceArray.filter({$0 < distanceFilter } )
            }
        }
        
        //if distance == 0, meaning filter from any distance
        return distanceArray
    }
    
    func comparePriceFrom(priceFrom: Double, to priceTo: Double) -> CompareOrder {
        if priceFrom < priceTo {
            return .OrderAscending
        } else if priceFrom == priceTo {
            return .OrderSame
        } else {
            return .OrderDescending
        }
    }
    func isDistance(distance: Double) -> Bool {
        if distance <= distanceFilter {
            return true
        }
        return false
    }
    func checkDistance(currentLocation: CLLocation, targetLocation: CLLocation) -> Bool{
        let distance = currentLocation.distanceFromLocation(targetLocation) / 1000
        if distance <= distanceFilter {
            return true
        }
        return false 
    }
    
    func setDistanceFromSegment(indexSegment: Int){
        distanceFilter = distanceOptions[indexSegment]
    }
    
    func checkConditionPrice(targerPrice: Double) -> Bool{
        if targerPrice < priceFrom! || targerPrice > priceTo! {
            return false
        }
        return true
    }
    func getIndexFromDistances(target: Double) -> Int{
        switch target {
        case 5.0:
            return 0
        case 10.0:
            return 1
        case 15.0:
            return 2
        default:
            return 3
        }
    }
    
}

enum CompareOrder {
    case OrderSame
    case OrderAscending
    case OrderDescending
}
