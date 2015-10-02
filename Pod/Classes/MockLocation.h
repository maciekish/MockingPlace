//
//  MockLocation.h
//  MockingPlace
//
//  Created by Maciej Swic on 01/10/15.
//
//

@import Foundation;
@import CoreLocation;

NS_ASSUME_NONNULL_BEGIN

@interface MockLocation : NSObject

/**
 *  The title of the location or track.
 */
@property (nonatomic, strong) NSString *title;

/**
 *  The path to the file. It will be lazy loaded on demand.
 */
@property (nonatomic, strong) NSString *path;

/**
 *  Locations. One for a static place or more to simulate a track.
 */
@property (nonatomic, readonly) NSArray<CLLocation *> *locations;

- (instancetype)initWithTitle:(NSString *)title andPath:(NSString *)path;

/**
 *  Used to sort the list alphabetically.
 *
 *  @param otherObject The other object to compare.
 *
 *  @return The comparison result
 */
- (NSComparisonResult)compareTitle:(id)otherObject;

@end

NS_ASSUME_NONNULL_END