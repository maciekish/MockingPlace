//
//  MSWMockingPlaceMenuTableViewController.m
//  MockingPlace
//
//  Created by Maciej Swic on 01/10/15.
//
//

#import "MSWMockingPlaceMenuTableViewController.h"
@import CoreLocation;

#import "MSWMockingPlace.h"
#import "MSWMockLocation.h"

#define kMockingPlaceCellIdentifier @"MockingPlaceCell"

@interface MSWMockingPlaceMenuTableViewController ()

@property (nonatomic, strong) NSArray<MSWMockLocation *> *locations;
@property (nonatomic, strong) UIBlurEffect *blurEffect;

@end

@implementation MSWMockingPlaceMenuTableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style andMockLocations:(NSArray<MSWMockLocation *> *)mockLocations
{
    self = [super initWithStyle:style];
    
    if (self) {
        self.locations = mockLocations;
        
        if (NSClassFromString(@"UIVisualEffectView") &&
            !UIAccessibilityIsReduceTransparencyEnabled()) {
            self.blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
            UIVisualEffectView *blurEffectView = [UIVisualEffectView.alloc initWithEffect:self.blurEffect];
            blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight; // Less code than using autolayout.
            [blurEffectView setFrame:self.tableView.frame];
            
            self.tableView.backgroundColor = UIColor.clearColor;
            self.tableView.separatorEffect = [UIVibrancyEffect effectForBlurEffect:self.blurEffect];
            self.tableView.backgroundView = (UIView *)blurEffectView;
        }
        
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
    
    [self configureCell:cell forIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Tag 1 is used to tell whether the cell has the effect view added to it. MockingPlace is about location simulation and i don't think this warrants its own UITableView subclass.
    if (cell.contentView.tag != 1) {
        cell.backgroundColor = UIColor.clearColor;
        
        UILabel *textLabel = cell.textLabel;
        [textLabel removeFromSuperview];
        
        UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:self.blurEffect];
        UIVisualEffectView *effectView = [UIVisualEffectView.alloc initWithEffect:vibrancyEffect];
        effectView.frame = cell.contentView.bounds;
        effectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [effectView.contentView addSubview:textLabel];
        textLabel.frame = cell.contentView.bounds;
        [cell.contentView addSubview:effectView];
        
        cell.contentView.tag = 1;
    }
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
