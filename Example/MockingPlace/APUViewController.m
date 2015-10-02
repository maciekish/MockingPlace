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

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    NSLog(@"CLLocationManager updated location to %@", locations.firstObject);
}

@end
