//
//  CLLocationManager+MockingPlaces.h
//  MockingPlace
//
//  Created by Maciej Swic on 01/10/15.
//
//

@import Foundation;
@import CoreLocation;

UIKIT_EXTERN NSString *const kMockingPlacesLocationChangedNotification;

@interface CLLocationManager (MockingPlaces)

+ (BOOL)mock_locationServicesEnabled;
+ (BOOL)mock_headingAvailable;
+ (CLAuthorizationStatus)mock_authorizationStatus;

- (void)mock_startUpdatingLocation;
- (void)mock_stopUpdatingLocation;
- (CLLocation *)mock_location;

@end
