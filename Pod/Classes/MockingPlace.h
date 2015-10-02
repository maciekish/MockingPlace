//
//  MockingPlace.h
//  MockingPlace
//
//  Created by Maciej Swic on 01/10/15.
//
//

@import Foundation;
@import CoreLocation;
#import "MSWMockingPlaceMenuTableViewController.h"

@interface MockingPlace : NSObject <MSWMockingPlaceMenuTableViewControllerDelegate, UIGestureRecognizerDelegate>

/**
 *  The selected MockLocation to simulate
 */
@property (nonatomic, strong) MSWMockLocation *mockLocation;

/**
 *  The currently simulated location
 */
@property (nonatomic, readonly) CLLocation *currentLocation;

+ (instancetype)sharedInstance;

/**
 *  Enables the gesture recognizer which brings up the locations menu.
 *  This does not start the simulation until you select a geojson file in the menu which
 *  is brought up by a two finger long press on the screen.
 */
+ (void)enable;

/**
 *  Disables the gesture recognizer and stops the current simulation.
 */
+ (void)disable;

@end
