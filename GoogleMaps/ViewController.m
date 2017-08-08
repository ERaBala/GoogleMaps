//
//  ViewController.m
//  GoogleMaps
//
//  Created by Bala on 07/08/17.
//  Copyright © 2017 Erabala. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{

    // Location Based
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
    
    // Location Object
    NSString * Latitude, *Longitude, * Address;

    double latnr, lonnr;
    // User Default
    NSUserDefaults *defaults;

}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //      Location start
    
    locationManager = [[CLLocationManager alloc] init];
    geocoder = [[CLGeocoder alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = kCLDistanceFilterNone; //whenever we move
    [locationManager startUpdatingLocation];
    [locationManager requestWhenInUseAuthorization]; // Add This Line
    
    //      Location end

    
    // get Location via name
    [self getLocationFromAddressString:@"chennai"];
    
}


- (void)locationManager:(CLLocationManager *)Manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    
    if (error) {
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Error"
                                      message:@"plz Check Your Internet Connection / without Your location app Dose not work properly"
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       //Do Some action here
                                                       
                                                   }];
        [alert addAction:ok];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
}




- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    
    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil) {
        Latitude = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
        Longitude = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
        
        latnr = currentLocation.coordinate.latitude;
        lonnr = currentLocation.coordinate.longitude;
        
        NSLog(@"lat %@ ans Long %@",Latitude,Longitude);
        [[NSUserDefaults standardUserDefaults] setObject:Latitude forKey:@"CurrentLatitude"];
        [[NSUserDefaults standardUserDefaults] setObject:Longitude forKey:@"CurrentLongitude"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
    // Stop Location Manager
    [locationManager stopUpdatingLocation];
    [self LoadMap];
    
    NSLog(@"Resolving the Address");
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
        if (error == nil && [placemarks count] > 0) {
            
            placemark = [placemarks lastObject];
            //            ViewController * viewController = (ViewController *)self.window.rootViewController;
            
            NSLog(@"%@",placemark.administrativeArea);
            NSLog(@"%@",placemark.subAdministrativeArea);
            
            NSLog(@"state === %@\n city == %@\n local == %@\n sublocation == %@",placemark.administrativeArea,placemark.subAdministrativeArea,placemark.locality,placemark.subLocality);
            
            [defaults setValue:placemark.administrativeArea forKey:@"State"];
            [defaults setValue:placemark.subAdministrativeArea forKey:@"City"];
            [defaults setValue:placemark.locality forKey:@"Local"];
            [defaults setValue:placemark.subLocality forKey:@"SubLocal"];
        }
        else {
            NSLog(@"%@", error.debugDescription);
        }
    }];
    
}


- (void)LoadMap {
    
    NSLog(@"%f looonnng %f",latnr,lonnr);
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:latnr
                                                            longitude:lonnr
                                                                 zoom:15];
    GMSMapView *mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    mapView.myLocationEnabled = YES;
    self.view = mapView;
    
    
    // Creates a marker in the center of the map.
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(latnr, lonnr);
    marker.title = @"Sydney";
    marker.snippet = @"Australia";
    marker.appearAnimation = kGMSMarkerAnimationPop;
    marker.icon = [GMSMarker markerImageWithColor:[UIColor blackColor]];
    marker.map = mapView;
}


-(CLLocationCoordinate2D) getLocationFromAddressString: (NSString*) addressStr {
    double latitude = 0, longitude = 0;
    
//    NSString *esc_addr =  [addressStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString * esc_addr = [addressStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    
    NSString *req = [NSString stringWithFormat:@"http://maps.google.com/maps/api/geocode/json?sensor=false&address=%@", esc_addr];
    NSString *result = [NSString stringWithContentsOfURL:[NSURL URLWithString:req] encoding:NSUTF8StringEncoding error:NULL];
    if (result) {
        NSScanner *scanner = [NSScanner scannerWithString:result];
        if ([scanner scanUpToString:@"\"lat\" :" intoString:nil] && [scanner scanString:@"\"lat\" :" intoString:nil]) {
            [scanner scanDouble:&latitude];
            if ([scanner scanUpToString:@"\"lng\" :" intoString:nil] && [scanner scanString:@"\"lng\" :" intoString:nil]) {
                [scanner scanDouble:&longitude];
            }
        }
    }
    CLLocationCoordinate2D center;
    center.latitude=latitude;
    center.longitude = longitude;
    NSLog(@"View Controller get Location Logitute : %f",center.latitude);
    NSLog(@"View Controller get Location Latitute : %f",center.longitude);
    return center;
    
}

@end
