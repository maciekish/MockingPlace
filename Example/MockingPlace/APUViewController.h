//
//  APUViewController.h
//  MockingPlace
//
//  Created by Maciej Swic on 10/01/2015.
//  Copyright (c) 2015 Maciej Swic. All rights reserved.
//

@import UIKit;
@import MapKit;

@interface APUViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate>

@property (nonatomic, weak) IBOutlet MKMapView *mapView;

@end
