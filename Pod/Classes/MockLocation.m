//
//  MockLocation.m
//  Pods
//
//  Created by Maciej Swic on 01/10/15.
//
//

#import "MockLocation.h"

@implementation MockLocation

@synthesize locations = _locations;

- (instancetype)initWithTitle:(NSString *)title andPath:(NSString *)path
{
    self = super.init;
    
    if (self) {
        self.title = title;
        self.path = path;
    }
    
    return self;
}

- (NSArray<CLLocation *> *)locations
{
    if (!_locations) {
        NSError *error;
        
        id jsonObject = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:self.path] options:kNilOptions error:&error];
        
        if (error) {
            [[UIAlertView.alloc initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        } else {
            if ([jsonObject[@"features"] count] > 0) {
                NSArray *coordinates = jsonObject[@"features"][0][@"geometry"][@"coordinates"];
                NSMutableArray *locations = NSMutableArray.new;
                
                // If this is a single place and not a track, wrap it so that the parser below will understand it.
                if (![coordinates.firstObject isKindOfClass:NSArray.class]) {
                    coordinates = [@[coordinates] mutableCopy];
                }
                
                for (NSArray *coordinateParts in coordinates) {
                    CLLocation *newLocation = [CLLocation.alloc initWithLatitude:[coordinateParts[1] doubleValue] longitude:[coordinateParts[0] doubleValue]];
                    [locations addObject:newLocation];
                }
                
                _locations = locations.copy;
            }
        }
    }
    
    return _locations;
}

- (NSComparisonResult)compareTitle:(id)otherObject
{
    if ([otherObject isKindOfClass:MockLocation.class]) {
        MockLocation *otherLocation = (MockLocation *)otherObject;
        
        return [self.title compare:otherLocation.title options:NSCaseInsensitiveSearch];
    } else {
        return NSOrderedSame;
    }
}

@end
