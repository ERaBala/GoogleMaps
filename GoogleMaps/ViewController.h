//
//  ViewController.h
//  GoogleMaps
//
//  Created by Bala on 07/08/17.
//  Copyright © 2017 Erabala. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import <CoreLocation/CoreLocation.h>


@interface ViewController : UIViewController <CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet UIView *MapView;
@property (strong, nonatomic) IBOutlet GMSMapView *GMSMap;


@end

