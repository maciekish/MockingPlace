//
//  MockingPlaceMenuTableViewController.h
//  Pods
//
//  Created by Maciej Swic on 01/10/15.
//
//

@import UIKit;

@class MockingPlaceMenuTableViewController, MockLocation;

@protocol MockingPlaceMenuTableViewControllerDelegate <NSObject>

- (void)placeMenuViewController:(MockingPlaceMenuTableViewController *)viewController didSelectMockLocation:(MockLocation *)mockLocation;
- (void)placeMenuViewControllerDidDisappear:(MockingPlaceMenuTableViewController *)viewController;

@end

@interface MockingPlaceMenuTableViewController : UITableViewController

@property (nonatomic, weak) id<MockingPlaceMenuTableViewControllerDelegate> delegate;

- (instancetype)initWithStyle:(UITableViewStyle)style andMockLocations:(NSArray<MockLocation *> *)mockLocations;

@end
