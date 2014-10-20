//
//  BGMapViewDelegate.h
//  TiClusteredMapKit
//
//  Created by Bruno Guidolim on 10/14/14.
//
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "KPClusteringController.h"
#import "TiProxy.h"

@interface BGMapViewDelegate : NSObject <MKMapViewDelegate>

@property (strong, nonatomic) KPClusteringController *clusteringController;
@property (strong, nonatomic) TiProxy *mapViewProxy;

@end
