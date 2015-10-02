//
//  MockingPlaceMenuTableViewController.m
//  MockingPlace
//
//  Created by Maciej Swic on 01/10/15.
//
//

#import "MockingPlaceMenuTableViewController.h"
@import CoreLocation;

#import "MockingPlace.h"
#import "MSWMockLocation.h"

#define kMockingPlaceCellIdentifier @"MockingPlaceCell"

@interface MockingPlaceMenuTableViewController ()

@property (nonatomic, strong) NSArray<MSWMockLocation *> *locations;

@end

@implementation MockingPlaceMenuTableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style andMockLocations:(NSArray<MSWMockLocation *> *)mockLocations
{
    self = [super initWithStyle:style];
    
    if (self) {
        self.locations = mockLocations;
        
        [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:kMockingPlaceCellIdentifier];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"MockingPlace";
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem.alloc initWithTitle:@"Disable" style:UIBarButtonItemStylePlain target:self action:@selector(disable)];
    self.navigationItem.leftBarButtonItem.enabled = MockingPlace.sharedInstance.mockLocation != nil;
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem.alloc initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
}

- (void)done
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)disable
{
    if ([self.delegate respondsToSelector:@selector(placeMenuViewController:didSelectMockLocation:)]) {
        [self.delegate placeMenuViewController:self didSelectMockLocation:nil];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.locations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMockingPlaceCellIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        cell = [UITableViewCell.alloc initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kMockingPlaceCellIdentifier];
    }
    
    [self configureCell:cell forIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
    cell.textLabel.text = self.locations[indexPath.row].title;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(placeMenuViewController:didSelectMockLocation:)]) {
        [self.delegate placeMenuViewController:self didSelectMockLocation:self.locations[indexPath.row]];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
