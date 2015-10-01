//
//  MockingPlace.m
//  Pods
//
//  Created by Maciej Swic on 01/10/15.
//
//

#import "MockingPlace.h"
#import <JRSwizzle/JRSwizzle.h>
@import CoreLocation;

#import "CLLocationManager+MockingPlaces.h"
#import "MockLocation.h"

@interface MockingPlace ()

@property (nonatomic, strong) UILongPressGestureRecognizer *gestureRecognizer;
@property (nonatomic, strong) MockingPlaceMenuTableViewController *menuViewController;
@property (nonatomic, strong) NSTimer *simulationTimer;
@property (nonatomic) NSUInteger simulationStep;

@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) CLLocation *previousLocation;

@end

#define degreesToRadians(x) (M_PI * x / 180.0)
#define radiandsToDegrees(x) (x * 180.0 / M_PI)

@implementation MockingPlace

+ (void)load
{
    [CLLocationManager jr_swizzleClassMethod:@selector(locationServicesEnabled) withClassMethod:@selector(mock_locationServicesEnabled) error:nil];
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
        instance = [[[self class] alloc] init];
    });
    
    return instance;
}

+ (void)enable
{
    MockingPlace.sharedInstance.gestureRecognizer = [UILongPressGestureRecognizer.alloc initWithTarget:MockingPlace.sharedInstance action:@selector(showMenu:)];
    MockingPlace.sharedInstance.gestureRecognizer.numberOfTapsRequired = 1;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIApplication.sharedApplication.keyWindow addGestureRecognizer:MockingPlace.sharedInstance.gestureRecognizer];
    });
}

+ (void)disable
{
    if (MockingPlace.sharedInstance.gestureRecognizer) {
        [UIApplication.sharedApplication.keyWindow removeGestureRecognizer:MockingPlace.sharedInstance.gestureRecognizer];
    }
}

- (void)showMenu:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if (!self.menuViewController) {
            self.menuViewController = [MockingPlaceMenuTableViewController.alloc initWithStyle:UITableViewStylePlain andMockLocations:self.availableLocations];
            self.menuViewController.delegate = self;
            
            UINavigationController *navigationController = [UINavigationController.alloc initWithRootViewController:self.menuViewController];
            [UIApplication.sharedApplication.keyWindow.rootViewController presentViewController:navigationController animated:YES completion:nil];
        }
    }
}

#pragma mark - MockPlaceMenu Delegate

- (void)placeMenuViewController:(MockingPlaceMenuTableViewController *)viewController didSelectMockLocation:(MockLocation *)mockLocation
{
    self.mockLocation = mockLocation;
}

- (void)placeMenuViewControllerDidDisappear:(MockingPlaceMenuTableViewController *)viewController
{
    self.menuViewController = nil;
}

#pragma mark - Private

- (NSArray<MockLocation *> *)availableLocations
{
    NSArray<NSString *> *filePaths = [NSBundle.mainBundle pathsForResourcesOfType:@"geojson" inDirectory:nil];
    NSMutableArray<MockLocation *> *locations = NSMutableArray.new;
    
    for (NSString *filePath in filePaths) {
        NSString *fileName = filePath.lastPathComponent.stringByDeletingPathExtension.capitalizedString;
        
        MockLocation *mockLocation = [MockLocation.alloc initWithTitle:fileName andPath:filePath];
        [locations addObject:mockLocation];
    }
    
    [locations sortUsingSelector:@selector(compareTitle:)];
    
    return locations.copy;
}

- (void)setMockLocation:(MockLocation *)mockLocation
{
    _mockLocation = mockLocation;
    _simulationStep = 0;
    
    if (!_mockLocation) {
        _currentLocation = nil;
    }
    
    [self startSimulation];
}

- (void)startSimulation
{
    [self stopSimulation];
    
    if (self.mockLocation) {
        [self simulate];
    }
}

- (void)stopSimulation
{
    [self.simulationTimer invalidate];
}

- (void)simulate
{
    self.previousLocation = self.currentLocation;
    
    if (self.mockLocation.locations.count == 0) {
        [[UIAlertView.alloc initWithTitle:@"Error" message:@"Couldn't parse your geojson. Check the example files at https://www.github.com/maciekish/MockingPlace" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
    
    if (self.mockLocation.locations.count > 1) {
        self.simulationTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(simulate) userInfo:nil repeats:NO];
    }
    
    // Calculate heading and speed
    CLLocationSpeed speed = [self.previousLocation distanceFromLocation:self.mockLocation.locations[self.simulationStep]] / [NSDate.date timeIntervalSinceDate:self.previousLocation.timestamp];
    CLLocationDirection course = [self headingFromLocation:self.previousLocation toLocation:self.mockLocation.locations[self.simulationStep]];
    
    // Make a new location with the correct speed, course and date.
    CLLocation *location = [CLLocation.alloc initWithCoordinate:self.mockLocation.locations[self.simulationStep].coordinate altitude:self.mockLocation.locations[self.simulationStep].altitude horizontalAccuracy:0 verticalAccuracy:0 course:course speed:speed timestamp:NSDate.date];
    
    // Assign and propagate
    self.currentLocation = location;
    [NSNotificationCenter.defaultCenter postNotificationName:kMockingPlacesLocationChangedNotification object:location];
    
    self.simulationStep++;
    
    if (self.simulationStep >= self.mockLocation.locations.count) {
        self.simulationStep = 0;
    }
}

- (CFLocaleLanguageDirection)headingFromLocation:(CLLocation *)fromLocation toLocation:(CLLocation *)toLocation
{
    double fLat = degreesToRadians(fromLocation.coordinate.latitude);
    double fLng = degreesToRadians(fromLocation.coordinate.longitude);
    double tLat = degreesToRadians(toLocation.coordinate.latitude);
    double tLng = degreesToRadians(toLocation.coordinate.longitude);
    
    double degree = radiandsToDegrees(atan2(sin(tLng-fLng)*cos(tLat), cos(fLat)*sin(tLat)-sin(fLat)*cos(tLat)*cos(tLng-fLng)));
    
    if (degree >= 0) {
        return degree;
    } else {
        return 360 + degree;
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

@end
