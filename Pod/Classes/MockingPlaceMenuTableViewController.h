//
//  MockingPlaceMenuTableViewController.h
//  MockingPlace
//
//  Created by Maciej Swic on 01/10/15.
//
//

@import UIKit;

@class MockingPlaceMenuTableViewController, MSWMockLocation;

@protocol MockingPlaceMenuTableViewControllerDelegate <NSObject>

- (void)placeMenuViewController:(MockingPlaceMenuTableViewController *)viewController didSelectMockLocation:(MSWMockLocation *)mockLocation;

@end

@interface MockingPlaceMenuTableViewController : UITableViewController

@property (nonatomic, weak) id<MockingPlaceMenuTableViewControllerDelegate> delegate;

- (instancetype)initWithStyle:(UITableViewStyle)style andMockLocations:(NSArray<MSWMockLocation *> *)mockLocations;

@end
