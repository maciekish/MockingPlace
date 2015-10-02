//
//  MockingPlaceMenuTableViewController.h
//  MockingPlace
//
//  Created by Maciej Swic on 01/10/15.
//
//

@import UIKit;

@class MockingPlaceMenuTableViewController, MockLocation;

@protocol MockingPlaceMenuTableViewControllerDelegate <NSObject>

- (void)placeMenuViewController:(MockingPlaceMenuTableViewController *)viewController didSelectMockLocation:(MockLocation *)mockLocation;

@end

@interface MockingPlaceMenuTableViewController : UITableViewController

@property (nonatomic, weak) id<MockingPlaceMenuTableViewControllerDelegate> delegate;

- (instancetype)initWithStyle:(UITableViewStyle)style andMockLocations:(NSArray<MockLocation *> *)mockLocations;

@end
