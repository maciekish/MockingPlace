//
//  APUViewController.m
//  MockingPlace
//
//  Created by Maciej Swic on 10/01/2015.
//  Copyright (c) 2015 Maciej Swic. All rights reserved.
//

#import "APUViewController.h"
@import MockingPlace;

@interface APUViewController ()

@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation APUViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
#ifdef DEBUG
    [MockingPlace enable];
#endif
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!self.locationManager) {
        self.locationManager = CLLocationManager.new;
        self.locationManager.delegate = self;
        self.locationManager.distanceFilter = kCLDistanceFilterNone;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        [self.locationManager requestAlwaysAuthorization];
    }
    
    [self.locationManager startUpdatingLocation];
    [self.locationManager startUpdatingHeading];
    
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:animated];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    NSLog(@"MKMapView updated location to %@", userLocation);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    NSLog(@"CLLocationManager updated locations to %@", locations);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    NSLog(@"CLLocationManager updated heading to %.0f", newHeading.magneticHeading);
}

@end
