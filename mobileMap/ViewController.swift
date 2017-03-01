//
//  ViewController.swift
//  mobileMap
//
//  Created by teacher on 2/28/17.
//  Copyright © 2017 Mathien. All rights reserved.
//

import UIKit
import MapKit


class ViewController: UIViewController, UISearchBarDelegate
{
    @IBOutlet weak var myMapView: MKMapView!

    var searchController: UISearchController! // manage presentation of search bar
    var annotation: MKAnnotation! 
    var localSearchRequest: MKLocalSearchRequest! //request search for a POI
    var localSearch: MKLocalSearch! //initiate search
    var localSearchResponse: MKLocalSearchResponse!  // stores search result
    var pointAnnotation: MKPointAnnotation!  /// pin on map
    var pinAnnotationView: MKPinAnnotationView!


    override func viewDidLoad()
    {
        super.viewDidLoad()
    }

    @IBAction func showSearchBar(_ sender: Any)
    {
        searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.searchBar.delegate = self
        present(searchController, animated: true, completion: nil)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        //1: Once you click the keyboard search button, the app will dismiss the search controller over the nav bar. Then, the map view will look for any previously drawn annotations on the map and remove them.

        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)

        if myMapView.annotations.count != 0
        {
            annotation = myMapView.annotations[0]
            myMapView.removeAnnotation(annotation)
        }


        //2: The search process will be initiated asynchronously by transforming the search bar text into a natural language query, the ‘naturalLanguageQuery’ is very important in order to look up for -even an incomplete- addresses and POI (point of interests) like restaurants, Coffeehouse, etc.

        localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = searchBar.text
        localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.start { (localSearchResponse, error) -> Void in

            if localSearchResponse == nil
            {
                let alertController = UIAlertController(title: nil, message: "Place Not Found", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
                return
            }


        //3 If the search API returns a valid coordinates for the place, then the app will instantiate a 2D point and draw it on the map within a pin annotation view.

            self.pointAnnotation = MKPointAnnotation()
            self.pointAnnotation.title = searchBar.text
            self.pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude: localSearchResponse!.boundingRegion.center.longitude)


            self.pinAnnotationView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
            self.myMapView.centerCoordinate = self.pointAnnotation.coordinate
            self.myMapView.addAnnotation(self.pinAnnotationView.annotation!)

            self.centerMap(location: self.pointAnnotation.coordinate)
        }
    }

    // 4 centers the map based on the search result
    func centerMap(location: CLLocationCoordinate2D)
    {
        let span = MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)
        let region = MKCoordinateRegion(center: location, span: span)
        myMapView.setRegion(region, animated: true)
    }


}

