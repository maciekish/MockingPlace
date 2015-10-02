//
//  MSWMockingPlaceMenuTableViewController.h
//  MockingPlace
//
//  Created by Maciej Swic on 01/10/15.
//
//

@import UIKit;

@class MSWMockingPlaceMenuTableViewController, MSWMockLocation;

@protocol MSWMockingPlaceMenuTableViewControllerDelegate <NSObject>

- (void)placeMenuViewController:(MSWMockingPlaceMenuTableViewController *)viewController didSelectMockLocation:(MSWMockLocation *)mockLocation;

@end

@interface MSWMockingPlaceMenuTableViewController : UITableViewController

@property (nonatomic, weak) id<MSWMockingPlaceMenuTableViewControllerDelegate> delegate;

- (instancetype)initWithStyle:(UITableViewStyle)style andMockLocations:(NSArray<MSWMockLocation *> *)mockLocations;

@end
