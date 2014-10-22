//
//  BGAnnoation.h
//  TiClusteredMapKit
//
//  Created by Bruno Guidolim on 10/14/14.
//
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface BGAnnotation : NSObject <MKAnnotation>

@property (copy, nonatomic) NSString *_title;
@property (copy, nonatomic) NSString *_subtitle;
@property (assign, nonatomic) CLLocationCoordinate2D _coordinate;
@property (strong, nonatomic) NSDictionary *properties;
@property (strong, nonatomic) NSDictionary *userInfo;

@end
