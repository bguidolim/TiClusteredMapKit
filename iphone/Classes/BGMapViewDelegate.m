//
//  BGMapViewDelegate.m
//  TiClusteredMapKit
//
//  Created by Bruno Guidolim on 10/14/14.
//
//

#import "BGMapViewDelegate.h"
#import "BGAnnotation.h"
#import "KPAnnotation.h"
#import "TiBase.h"
#import "TiButtonUtil.h"
#import "TiViewProxy.h"
#import "TiUILabelProxy.h"

#define LEFT_BUTTON  1
#define RIGHT_BUTTON 2

@implementation BGMapViewDelegate

#pragma mark - Custom methods
- (void)setAnnotationProperties:(MKAnnotationView *)annotationView dictionaty:(NSDictionary *)dictionary {
    annotationView.canShowCallout = [TiUtils boolValue:[dictionary objectForKey:@"canShowCallout"] def:YES];
    annotationView.draggable = [TiUtils boolValue:[dictionary objectForKey:@"draggable"]];
    
    if ([dictionary objectForKey:@"centerOffset"]) {
        CGPoint centerOffset = [TiUtils pointValue:[dictionary objectForKey:@"centerOffset"]];
        annotationView.centerOffset = centerOffset;
    }
    
    UIView *left = [self leftViewAccessoryForAnnotation:dictionary];
    UIView *right = [self rightViewAccessoryForAnnotation:dictionary];
    if (left != nil) {
        annotationView.leftCalloutAccessoryView = left;
    }
    
    if (right!=nil) {
        annotationView.rightCalloutAccessoryView = right;
    }
}

- (UIView*)leftViewAccessoryForAnnotation:(NSDictionary *)dict {
    TiViewProxy* viewProxy = [dict objectForKey:@"leftView"];
    if (viewProxy!=nil && [viewProxy isKindOfClass:[TiViewProxy class]]) {
        return [viewProxy view];
    } else {
        id button = [dict objectForKey:@"leftButton"];
        if (button!=nil) {
            return [self makeButton:button tag:LEFT_BUTTON annotation:dict];
        }
    }
    return nil;
}

- (UIView*)rightViewAccessoryForAnnotation:(NSDictionary *)dict  {
    TiViewProxy* viewProxy = [dict objectForKey:@"rightView"];
    if (viewProxy!=nil && [viewProxy isKindOfClass:[TiViewProxy class]]) {
        return [viewProxy view];
    } else {
        id button = [dict objectForKey:@"rightButton"];
        if (button!=nil) {
            return [self makeButton:button tag:RIGHT_BUTTON annotation:dict];
        }
    }
    return nil;
}

- (UIView*)makeButton:(id)button tag:(int)buttonTag annotation:(NSDictionary *)dict {
    UIView *button_view = nil;
    if ([button isKindOfClass:[NSNumber class]]) {
        // this is button type constant
        int type = [TiUtils intValue:button];
        button_view = [TiButtonUtil buttonWithType:type];
    } else {
        UIImage *image = [TiUtils image:[dict objectForKey:(buttonTag == LEFT_BUTTON?@"leftButton":@"rightButton")] proxy:self.mapViewProxy];
        if (image!=nil) {
            CGSize size = [image size];
            UIButton *bview = [UIButton buttonWithType:UIButtonTypeCustom];
            [TiUtils setView:bview positionRect:CGRectMake(0,0,size.width,size.height)];
            bview.backgroundColor = [UIColor clearColor];
            [bview setImage:image forState:UIControlStateNormal];
            button_view = bview;
        }
    }
    if (button_view!=nil) {
        button_view.tag = buttonTag;
    }
    return button_view;
}

- (void)configureCounter:(MKAnnotationView *)annotationView count:(NSInteger)count {
    if ([self.clusterPin objectForKey:@"counterLabel"]) {
        UILabel *label = (UILabel *)[annotationView viewWithTag:999];
        
        TiUILabelProxy *viewProxy = (TiUILabelProxy *)[self.clusterPin objectForKey:@"counterLabel"];
        id labelView = viewProxy.view;
        
        UILabel *newLabel = [labelView label];
        label.text = [NSString stringWithFormat:@"%ld",(long)count];
        label.font = newLabel.font;
        label.textColor = newLabel.textColor;
        label.textAlignment = newLabel.textAlignment;
        label.frame = [labelView frame];
        [annotationView bringSubviewToFront:label];
    }
}

#pragma mark - MapView Delegate
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[KPAnnotation class]]) {
        KPAnnotation *clusterAnnotation = (KPAnnotation *)annotation;
        
        id<MKAnnotation> ann;
        NSDictionary *userInfo;
        NSString *identifier = nil;
        
        if (clusterAnnotation.isCluster) {
            ann = (KPAnnotation *)clusterAnnotation;
            userInfo = self.clusterPin;
            identifier = @"cluster-pin";
            
            if ([userInfo objectForKey:@"clusterName"]) {
                clusterAnnotation.title = [NSString stringWithFormat:@"%lu %@",(unsigned long)clusterAnnotation.annotations.count, [userInfo objectForKey:@"clusterName"]];
            }
        } else {
            ann = (BGAnnotation *)[[clusterAnnotation.annotations allObjects] objectAtIndex:0];
            clusterAnnotation.title = ann.title;
            clusterAnnotation.subtitle = ann.subtitle;
            userInfo = [(BGAnnotation *)ann properties];
        }
        
        if ([userInfo objectForKey:@"customView"]) {
            if (identifier == nil) {
                identifier = @"customview-pin";
            }
            
            MKAnnotationView *annotationView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
            if (annotationView == nil) {
                annotationView = [[MKAnnotationView alloc] initWithAnnotation:ann reuseIdentifier:identifier];
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
                label.tag = 999;
                
                [annotationView addSubview:label];
            }
            
            TiViewProxy *viewProxy = (TiViewProxy*)[userInfo objectForKey:@"customView"];
            UIView *customView = (UIView*)[viewProxy view];
            [customView setFrame:CGRectMake(0, 0, customView.frame.size.width, customView.frame.size.height)];
            
            annotationView.frame = customView.frame;
            [annotationView addSubview:customView];
            
            [self setAnnotationProperties:annotationView dictionaty:userInfo];
            
            if (clusterAnnotation.isCluster) {
                [self configureCounter:annotationView count:clusterAnnotation.annotations.count];
            }
            
            return annotationView;
            
        } else if ([userInfo objectForKey:@"image"]) {
            if (identifier == nil) {
                identifier = @"image-pin";
            }
            
            MKAnnotationView *annotationView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
            if (annotationView == nil) {
                annotationView = [[MKAnnotationView alloc] initWithAnnotation:ann reuseIdentifier:identifier];
                
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
                label.tag = 999;
                
                [annotationView addSubview:label];
            }
            
            UIImage *image = [TiUtils image:[userInfo objectForKey:@"image"] proxy:self.mapViewProxy];
            annotationView.image = image;
            
            [self setAnnotationProperties:annotationView dictionaty:userInfo];
            
            if (clusterAnnotation.isCluster) {
                [self configureCounter:annotationView count:clusterAnnotation.annotations.count];
            }
            
            return annotationView;
            
        } else {
            if (identifier == nil) {
                identifier = @"pin";
            }
            
            MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
            if (pinView == nil) {
                pinView = [[MKPinAnnotationView alloc] initWithAnnotation:ann reuseIdentifier:identifier];
            }
            
            if ([userInfo objectForKey:@"pincolor"]) {
                switch ([[userInfo objectForKey:@"pincolor"] integerValue]) {
                    case 0:
                        pinView.pinColor = MKPinAnnotationColorRed;
                        break;
                        
                    case 1:
                        pinView.pinColor = MKPinAnnotationColorGreen;
                        break;
                        
                    case 2:
                        pinView.pinColor = MKPinAnnotationColorPurple;
                        break;
                        
                    default:
                        break;
                }
            } else {
                pinView.pinColor = MKPinAnnotationColorRed;
            }
            
            [self setAnnotationProperties:pinView dictionaty:userInfo];
            
            return pinView;
        }
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)aview calloutAccessoryControlTapped:(UIControl *)control {
    if ([aview.annotation isKindOfClass:[KPAnnotation class]]) {
        KPAnnotation *annotation = (KPAnnotation *)aview.annotation;
        
        if (!annotation.isCluster) {
            MKPinAnnotationView *pinview = (MKPinAnnotationView*)aview;
            NSString * clickSource = @"unknown";
            
            if (aview.leftCalloutAccessoryView == control) {
                clickSource = @"leftButton";
            } else if (aview.rightCalloutAccessoryView == control) {
                clickSource = @"rightButton";
            }
            [self fireClickEvent:pinview source:clickSource];
        }
    }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    [self.clusteringController refresh:YES];
}

#pragma mark Click handler
- (void)fireClickEvent:(MKAnnotationView *)pinview source:(NSString *)source{
    KPAnnotation *cAnnotation = (KPAnnotation *)pinview.annotation;
    BGAnnotation *annotation = [[cAnnotation.annotations allObjects] objectAtIndex:0];
    
    BOOL parentWants = [self.mapViewProxy _hasListeners:@"click"];
    if(!parentWants) {
        return;
    }
    
    NSNumber *indexNumber = [NSNumber numberWithInteger:pinview.tag];
    id clicksource = source ? source : (id)[NSNull null];
    
    NSDictionary * event = [NSDictionary dictionaryWithObjectsAndKeys:
                            clicksource,@"clicksource",
                            self.mapViewProxy,@"map",
                            indexNumber,@"index",
                            annotation.userInfo,@"userInfo",
                            nil];
    
    if (parentWants){
        [self.mapViewProxy fireEvent:@"click" withObject:event];
    }

}

@end
