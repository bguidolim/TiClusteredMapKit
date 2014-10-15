//
//  BGAnnoation.m
//  TiClusteredMapKit
//
//  Created by Bruno Guidolim on 10/14/14.
//
//

#import "BGAnnotation.h"

@implementation BGAnnotation

- (NSString *)title {
    return __title;
}

- (NSString *)subtitle {
    return __subtitle;
}

- (CLLocationCoordinate2D)coordinate {
    return __coordinate;
}

@end
