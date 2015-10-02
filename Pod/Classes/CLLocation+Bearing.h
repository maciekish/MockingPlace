//
//  CLLocation+Bearing.h
//  MockingPlace
//
//  Created by Maciej Swic on 02/10/15.
//
//

@import CoreLocation;

@interface CLLocation (Bearing)

/**
 *  Calculates the bearing between two locations.
 *
 *  @param toLocation The location to calculate a bearing to.
 *
 *  @return The bearing from this location to the other location.
 */
- (CLLocationDegrees)bearingToLocation:(CLLocation *)toLocation;

@end
