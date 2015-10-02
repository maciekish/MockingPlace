//
//  CLLocation+Bearing.m
//  MockingPlace
//
//  Created by Maciej Swic on 02/10/15.
//
//

#import "CLLocation+Bearing.h"

#define degreesToRadians(x) (M_PI * x / 180.0)
#define radiandsToDegrees(x) (x * 180.0 / M_PI)

@implementation CLLocation (Bearing)

- (CLLocationDegrees)bearingToLocation:(CLLocation *)toLocation
{
    double fromLat = degreesToRadians(self.coordinate.latitude);
    double fromLng = degreesToRadians(self.coordinate.longitude);
    double toLat = degreesToRadians(toLocation.coordinate.latitude);
    double toLng = degreesToRadians(toLocation.coordinate.longitude);
    
    double degrees = radiandsToDegrees(atan2(sin(toLng-fromLng)*cos(toLat), cos(fromLat)*sin(toLat)-sin(fromLat)*cos(toLat)*cos(toLng-fromLng)));
    
    if (degrees >= 0) {
        return degrees;
    } else {
        return 360 + degrees;
    }
}

@end
