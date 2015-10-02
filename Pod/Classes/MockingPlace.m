//
//  MockingPlace.m
//  MockingPlace
//
//  Created by Maciej Swic on 01/10/15.
//
//

#import "MockingPlace.h"
#import <JRSwizzle/JRSwizzle.h>
@import CoreLocation;

#import "CLLocationManager+MockingPlaces.h"
#import "CLLocation+Bearing.h"
#import "MSwMockLocation.h"

@interface MockingPlace ()

@property (nonatomic, strong) UILongPressGestureRecognizer *gestureRecognizer;
@property (nonatomic, weak) MSWMockingPlaceMenuTableViewController *menuViewController;
@property (nonatomic, strong) NSTimer *simulationTimer;
@property (nonatomic) NSUInteger simulationStep;

@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) CLLocation *previousLocation;

@end

@implementation MockingPlace

+ (void)load
{
    // Replace the necessary methods.
    [CLLocationManager jr_swizzleClassMethod:@selector(locationServicesEnabled) withClassMethod:@selector(mock_locationServicesEnabled) error:nil];
    [CLLocationManager jr_swizzleClassMethod:@selector(headingAvailable) withClassMethod:@selector(mock_headingAvailable) error:nil];
    [CLLocationManager jr_swizzleMethod:@selector(locationServicesEnabled) withMethod:@selector(mock_locationServicesEnabled) error:nil];
    [CLLocationManager jr_swizzleMethod:@selector(startUpdatingLocation) withMethod:@selector(mock_startUpdatingLocation) error:nil];
    [CLLocationManager jr_swizzleMethod:@selector(stopUpdatingLocation) withMethod:@selector(mock_stopUpdatingLocation) error:nil];
    [CLLocationManager jr_swizzleMethod:@selector(location) withMethod:@selector(mock_location) error:nil];
}

+ (instancetype)sharedInstance
{
    static id instance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = MockingPlace.new;
    });
    
    return instance;
}

+ (void)enable
{
    MockingPlace.sharedInstance.gestureRecognizer = [UILongPressGestureRecognizer.alloc initWithTarget:MockingPlace.sharedInstance action:@selector(showMenu:)];
    MockingPlace.sharedInstance.gestureRecognizer.delegate = MockingPlace.sharedInstance;
    MockingPlace.sharedInstance.gestureRecognizer.numberOfTouchesRequired = 2;
    
    // Wait for the UI to load
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIApplication.sharedApplication.keyWindow addGestureRecognizer:MockingPlace.sharedInstance.gestureRecognizer];
    });
}

+ (void)disable
{
    if (MockingPlace.sharedInstance.gestureRecognizer) {
        [UIApplication.sharedApplication.keyWindow removeGestureRecognizer:MockingPlace.sharedInstance.gestureRecognizer];
    }
    
    [MockingPlace.sharedInstance stopSimulation];
}

- (void)showMenu:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if (!self.menuViewController) {
            MSWMockingPlaceMenuTableViewController *menuViewController = [MSWMockingPlaceMenuTableViewController.alloc initWithStyle:UITableViewStylePlain andMockLocations:self.availableLocations];
            menuViewController.delegate = self;
            
            UINavigationController *navigationController = [UINavigationController.alloc initWithRootViewController:menuViewController];
            navigationController.navigationBar.barTintColor = UIColor.darkGrayColor;
            navigationController.navigationBar.tintColor = UIColor.whiteColor;
            navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: UIColor.whiteColor};
            navigationController.modalPresentationStyle = UIModalPresentationOverFullScreen;
            [UIApplication.sharedApplication.keyWindow.rootViewController presentViewController:navigationController animated:YES completion:nil];
            self.menuViewController = menuViewController;
        }
    }
}

#pragma mark - MockPlaceMenu Delegate

- (void)placeMenuViewController:(MSWMockingPlaceMenuTableViewController *)viewController didSelectMockLocation:(MSWMockLocation *)mockLocation
{
    self.mockLocation = mockLocation;
}

#pragma mark - Private

- (NSArray<MSWMockLocation *> *)availableLocations
{
    NSArray<NSString *> *filePaths = [NSBundle.mainBundle pathsForResourcesOfType:@"geojson" inDirectory:nil];
    NSMutableArray<MSWMockLocation *> *locations = NSMutableArray.new;
    
    for (NSString *filePath in filePaths) {
        NSString *fileName = filePath.lastPathComponent.stringByDeletingPathExtension.capitalizedString;
        
        // Ignore coverage.geojson
        if (![fileName.lowercaseString isEqualToString:@"coverage"]) {
            MSWMockLocation *mockLocation = [MSWMockLocation.alloc initWithTitle:fileName andPath:filePath];
            [locations addObject:mockLocation];
        }
    }
    
    [locations sortUsingSelector:@selector(compareTitle:)];
    
    return locations.copy;
}

- (void)setMockLocation:(MSWMockLocation *)mockLocation
{
    _mockLocation = mockLocation;
    _simulationStep = 0;
    
    if (_mockLocation) {
        [self startSimulation];
    } else {
        [self stopSimulation];
    }
}

- (void)simulate
{
    self.previousLocation = self.currentLocation;
    
    if (self.mockLocation.locations.count == 0) {
        [[UIAlertView.alloc initWithTitle:@"Error" message:@"Couldn't parse your geojson. Check the example files at https://www.github.com/maciekish/MockingPlace" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    } else if (self.mockLocation.locations.count > 1) {
        self.simulationTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(simulate) userInfo:nil repeats:NO];
    }
    
    // Calculate heading and speed
    CLLocationSpeed speed = [self.previousLocation distanceFromLocation:self.mockLocation.locations[self.simulationStep]] / [NSDate.date timeIntervalSinceDate:self.previousLocation.timestamp];
    CLLocationDirection course = [self.previousLocation bearingToLocation:self.mockLocation.locations[self.simulationStep]];
    
    // Make a new location with the correct speed, course and date.
    CLLocation *location = [CLLocation.alloc initWithCoordinate:self.mockLocation.locations[self.simulationStep].coordinate altitude:self.mockLocation.locations[self.simulationStep].altitude horizontalAccuracy:0 verticalAccuracy:0 course:course speed:speed timestamp:NSDate.date];
    
    // Assign and propagate
    self.currentLocation = location;
    [NSNotificationCenter.defaultCenter postNotificationName:kMockingPlacesLocationChangedNotification object:location];
    
    // Go to next coordinate if track
    self.simulationStep++;
    if (self.simulationStep >= self.mockLocation.locations.count) {
        self.simulationStep = 0;
    }
}

- (void)startSimulation
{
    [self stopSimulation];
    [self simulate];
}

- (void)stopSimulation
{
    self.currentLocation = nil;
    [self.simulationTimer invalidate];
    [NSNotificationCenter.defaultCenter postNotificationName:kMockingPlacesStatusChangedNotification object:nil];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

@end
