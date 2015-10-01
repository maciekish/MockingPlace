//
//  MockingPlace.h
//  Pods
//
//  Created by Maciej Swic on 01/10/15.
//
//

@import Foundation;
@import CoreLocation;
#import "MockingPlaceMenuTableViewController.h"

@interface MockingPlace : NSObject <MockingPlaceMenuTableViewControllerDelegate, UIGestureRecognizerDelegate>

/**
 *  The selected MockLocation to simulate
 */
@property (nonatomic, strong) MockLocation *mockLocation;

/**
 *  The current simulated location
 */
@property (nonatomic, readonly) CLLocation *currentLocation;

+ (instancetype)sharedInstance;
+ (void)enable;

@end
