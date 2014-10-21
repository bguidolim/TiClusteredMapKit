/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2014 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "ComGuidolimTiclusteredmapkitView.h"
#import "BGAnnotation.h"

@implementation ComGuidolimTiclusteredmapkitView

-(void)initializeState {
    // This method is called right after allocating the view and
    // is useful for initializing anything specific to the view
    
    [self createMapView];
    
    [super initializeState];
}

- (void)createMapView {
    if (mapView == nil) {
        mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
        mapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        mapViewDelegate = [[BGMapViewDelegate alloc] init];
        mapViewDelegate.clusteringController = [[KPClusteringController alloc] initWithMapView:mapView];
        mapViewDelegate.mapViewProxy = self.proxy;
        [mapView setDelegate:mapViewDelegate];
        
        [self addSubview:mapView];
    }
}

- (void)frameSizeChanged:(CGRect)frame bounds:(CGRect)bounds {
    if (mapView == nil) {
        [self createMapView];
    }
    [TiUtils setView:mapView positionRect:bounds];
}

-(void)render {
    if (![NSThread isMainThread]) {
        TiThreadPerformOnMainThread(^{[self render];}, NO);
        return;
    }

    if (mapView == nil || mapView.bounds.size.width == 0 || mapView.bounds.size.height == 0) {
        return;
    }
    
    if (region.center.latitude!=0 && region.center.longitude!=0 && !isnan(region.center.latitude) && !isnan(region.center.longitude)) {
        if (regionFits) {
            [mapView setRegion:[mapView regionThatFits:region] animated:animate];
        } else {
            [mapView setRegion:region animated:animate];
        }
    }
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
        
        annotation.properties = dict;
        
        if ([dict objectForKey:@"userInfo"]) {
            NSDictionary *userInfo = [dict objectForKey:@"userInfo"];
            ENSURE_TYPE(userInfo, NSDictionary);
            
            annotation.userInfo = userInfo;
        }
        
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

-(void)setRegionFit_:(id)value {
    regionFits = [TiUtils boolValue:value];
    [self render];
}

-(void)setAnimate_:(id)value {
    animate = [TiUtils boolValue:value];
}

-(void)setRegion_:(id)location {
    ENSURE_SINGLE_ARG(location,NSDictionary);
    
    [self setLocation_:location];
}

-(void)setLocation_:(id)location {
    ENSURE_SINGLE_ARG(location,NSDictionary);
    
    id lat = [location objectForKey:@"latitude"];
    id lon = [location objectForKey:@"longitude"];
    id latdelta = [location objectForKey:@"latitudeDelta"];
    id londelta = [location objectForKey:@"longitudeDelta"];
    
    if (lat) {
        region.center.latitude = [lat doubleValue];
    }
    
    if (lon) {
        region.center.longitude = [lon doubleValue];
    }
    
    if (latdelta) {
        region.span.latitudeDelta = [latdelta doubleValue];
    }
    
    if (londelta) {
        region.span.longitudeDelta = [londelta doubleValue];
    }
    
    id an = [location objectForKey:@"animate"];
    if (an) {
        animate = [an boolValue];
    }
    
    id rf = [location objectForKey:@"regionFit"];
    if (rf) {
        regionFits = [rf boolValue];
    }
    [self render];
}

-(void)setClusterPin_:(id)value {
    ENSURE_SINGLE_ARG(value,NSDictionary);
    
    mapViewDelegate.clusterPin = value;
}

-(void)willFirePropertyChanges {
    regionFits = [TiUtils boolValue:[self.proxy valueForKey:@"regionFit"]];
    animate = [TiUtils boolValue:[self.proxy valueForKey:@"animate"]];
}

-(void)didFirePropertyChanges {
    [self render];
}

@end
