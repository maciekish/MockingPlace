//
//  CLLocationManager+MockingPlaces.m
//  MockingPlace
//
//  Created by Maciej Swic on 01/10/15.
//
//

#import "CLHeading+Init.h"
#import "CLLocationManager+MockingPlaces.h"
#import "MockingPlace.h"

NSString *const kMockingPlacesLocationChangedNotification = @"kMockingPlacesLocationChanged";

@implementation CLLocationManager (MockingPlaces)

+ (BOOL)mock_locationServicesEnabled;
{
    return YES;
}

+ (BOOL)mock_headingAvailable
{
    return YES;
}

+ (CLAuthorizationStatus)mock_authorizationStatus
{
    return kCLAuthorizationStatusAuthorizedAlways;
}

-(void)mock_startUpdatingLocation;
{
    [NSNotificationCenter.defaultCenter removeObserver:self];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(locationUpdated:) name:kMockingPlacesLocationChangedNotification object:nil];

    if ([self.delegate respondsToSelector:@selector(locationManager:didUpdateLocations:)] &&
        self.location) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self.delegate locationManager:self didUpdateLocations:@[self.location]];
        });
    }
}

- (void)mock_stopUpdatingLocation
{
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

-(CLLocation *)mock_location;
{
    return MockingPlace.sharedInstance.currentLocation;
}

// MockingPlace sends a notification with the new location each time the simulated location changes. All CLLocationmanagers pick it up here and propagate it to their delegates.
- (void)locationUpdated:(NSNotification *)notification
{
    if ([notification.object isKindOfClass:CLLocation.class]) {
        CLLocation *location = (CLLocation *)notification.object;
        
        if ([self.delegate respondsToSelector:@selector(locationManager:didUpdateLocations:)]) {
            [self.delegate locationManager:self didUpdateLocations:@[location]];
        }
        
        CLHeading *heading = [CLHeading.alloc initWithHeading:location.course accuracy:0];
        
        if ([self.delegate respondsToSelector:@selector(locationManager:didUpdateHeading:)]) {
            [self.delegate locationManager:self didUpdateHeading:heading];
        }
    }
}

@end
