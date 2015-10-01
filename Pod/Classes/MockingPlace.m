//
//  MockingPlace.m
//  Pods
//
//  Created by Maciej Swic on 01/10/15.
//
//

#import "MockingPlace.h"
@import CoreLocation;
@import JRSwizzle;

#import "CLLocationManager+MockingPlaces.h"
#import "MockLocation.h"

@interface MockingPlace ()

@property (nonatomic, strong) UILongPressGestureRecognizer *gestureRecognizer;
@property (nonatomic, strong) MockingPlaceMenuTableViewController *menuViewController;
@property (nonatomic, strong) NSTimer *simulationTimer;
@property (nonatomic) NSUInteger simulationStep;

@end

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
    
    NSLog(@"%@", mockLocation.locations);
    
    [self startSimulation];
}

- (void)startSimulation
{
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
    [self.simulationTimer invalidate];
    
    if (self.mockLocation.locations.count > 1) {
        self.simulationTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(simulate) userInfo:nil repeats:NO];
    }
    
    [NSNotificationCenter.defaultCenter postNotificationName:kMockingPlacesLocationChangedNotification object:self.mockLocation.locations[self.simulationStep]];
    
    self.simulationStep++;
    
    if (self.simulationStep >= self.mockLocation.locations.count) {
        self.simulationStep = 0;
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

@end
