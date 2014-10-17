/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2014 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "ComGuidolimTiclusteredmapkitView.h"
#import "BGAnnotation.h"

@implementation ComGuidolimTiclusteredmapkitView

-(void)initializeState
{
    // This method is called right after allocating the view and
    // is useful for initializing anything specific to the view
    
    [self createMapView];
    
    [super initializeState];
    
    NSLog(@"[VIEW LIFECYCLE EVENT] initializeState");
}

- (void)createMapView {
    if (mapView == nil) {
        mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
        mapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        mapViewDelegate = [[BGMapViewDelegate alloc] init];
        mapViewDelegate.clusteringController = [[KPClusteringController alloc] initWithMapView:mapView];
        [mapView setDelegate:mapViewDelegate];
        
        [self addSubview:mapView];
    }
}

- (void)frameSizeChanged:(CGRect)frame bounds:(CGRect)bounds {
    NSLog(@"[VIEW LIFECYCLE EVENT] frameSizeChanged");
    if (mapView == nil) {
        [self createMapView];
    }
    [TiUtils setView:mapView positionRect:bounds];
}

#pragma mark Annotations
- (void)setAnnotations:(id)args {
    ENSURE_TYPE(args,NSArray);
    ENSURE_UI_THREAD(setAnnotations,args);
    
    NSArray *array = (NSArray *)args;
    NSMutableArray *annotations = [NSMutableArray new];
    
    [array enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
        BGAnnotation *annotation = [[BGAnnotation alloc] init];
        annotation._coordinate = CLLocationCoordinate2DMake([TiUtils doubleValue:[dict objectForKey:@"latitude"]],[TiUtils doubleValue:[dict objectForKey:@"longitude"]]);
        annotation._title = [TiUtils stringValue:[dict objectForKey:@"title"]];
        annotation._subtitle = [TiUtils stringValue:[dict objectForKey:@"subtitle"]];
        
        NSMutableDictionary *mutableDict = [NSMutableDictionary dictionaryWithDictionary:dict];
        [mutableDict setObject:self.proxy forKey:@"proxy"];
        
        annotation.userInfo = mutableDict;
        
        [annotations addObject:annotation];
    }];

    [mapViewDelegate.clusteringController setAnnotations:annotations];
}

#pragma mark - Properties
-(void)setUserLocation_:(id)value {
    mapView.showsUserLocation = [TiUtils boolValue:value];
}

- (void)setMapType_:(id)value {
    mapView.mapType = [TiUtils intValue:value];
}

- (void)setZoomEnabled_:(id)value {
    mapView.zoomEnabled = [TiUtils boolValue:value];
}

- (void)setScrollEnabled_:(id)value {
    mapView.scrollEnabled = [TiUtils boolValue:value];
}

- (void)setPitchEnabled_:(id)value {
    mapView.pitchEnabled = [TiUtils boolValue:value];
}

- (void)setRotateEnabled_:(id)value {
    mapView.rotateEnabled = [TiUtils boolValue:value];
}


@end
