//
//  FPBeaconHelper.m
//  WhosFancy
//
//  Created by Andrea Mazzini on 30/06/14.
//  Copyright (c) 2014 Fancy Pixel. All rights reserved.
//

#import "FPBeaconHelper.h"
@import CoreLocation;


typedef NS_ENUM(NSInteger, FPCheckDirection) {
    FPCheckDirectionIn,
    FPCheckDirectionOut
};

@interface FPBeaconHelper () <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *manager;
@property (nonatomic, strong) CLBeaconRegion *region;
@property (nonatomic, strong) NSDictionary *settings;

@end

@implementation FPBeaconHelper

+ (FPBeaconHelper *)sharedHelper
{
    static FPBeaconHelper *sharedHelper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedHelper = [[self alloc] init];
    });
    return sharedHelper;
}

- (NSDictionary *)settings
{
    if (_settings == nil) {
        _settings = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"settings" ofType:@"json"] options:NSUTF8StringEncoding error:nil] options:NSJSONReadingAllowFragments error:nil];
    }
    return _settings;
}

- (void)loadUser
{
    NSUserDefaults*	defaults = [NSUserDefaults standardUserDefaults];
	self.email = [defaults stringForKey:@"user_email"];
	self.password = [defaults stringForKey:@"user_password"];
	self.track = [defaults boolForKey:@"user_track"];
}

- (void)saveUser
{
    NSUserDefaults*	defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:self.email forKey:@"user_email"];
	[defaults setObject:self.password forKey:@"user_password"];
    [defaults setBool:self.track forKey:@"user_track"];
    [defaults synchronize];
}

- (CLLocationManager *)manager
{
    if (_manager == nil) {
        _manager = [[CLLocationManager alloc] init];
        _manager.delegate = self;
    }
    return _manager;
}

- (CLBeaconRegion *)region
{
    if (_region == nil) {
        NSUUID *proximityUUID = [[NSUUID alloc] initWithUUIDString:self.settings[@"udid"]];
        _region = [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID
                                                          major:[self.settings[@"major"] intValue]
                                                          minor:[self.settings[@"minor"] intValue]
                                                     identifier:self.settings[@"identifier"]];
        
        [_region setNotifyOnExit:YES];
        [_region setNotifyOnEntry:YES];
        [_region setNotifyEntryStateOnDisplay:YES];
    }
    return _region;
}

- (void)startMonitoring
{
    if (self.track) {
        [self.manager startMonitoringForRegion:self.region];
        [self.manager stopRangingBeaconsInRegion:self.region];        
    }
}

- (void)stopMonitoring
{
    [self.manager stopMonitoringForRegion:self.region];
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    if ([region isKindOfClass:[CLBeaconRegion class]]) {
        CLBeaconRegion *beaconRegion = (CLBeaconRegion *)region;
        if ([beaconRegion.identifier isEqualToString:self.settings[@"identifier"]] && [beaconRegion.major intValue] == [self.settings[@"major"] intValue] && [beaconRegion.minor intValue]== [self.settings[@"minor"] intValue]) {
            UILocalNotification *notification = [[UILocalNotification alloc] init];
            notification.userInfo = @{@"identifier": region.identifier};
            notification.alertBody = [NSString stringWithFormat:@"Entering %@", region.identifier];
            notification.soundName = @"Default";
            [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
            [self remoteCheckin:FPCheckDirectionIn];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    if ([region isKindOfClass:[CLBeaconRegion class]]) {
        CLBeaconRegion *beaconRegion = (CLBeaconRegion *)region;
        if ([beaconRegion.identifier isEqualToString:self.settings[@"identifier"]] && [beaconRegion.major intValue] == [self.settings[@"major"] intValue] && [beaconRegion.minor intValue]== [self.settings[@"minor"] intValue]) {
            UILocalNotification *notification = [[UILocalNotification alloc] init];
            notification.userInfo = @{@"identifier": region.identifier};
            notification.alertBody = [NSString stringWithFormat:@"Exiting %@", region.identifier];
            notification.soundName = @"Default";
            [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
            [self remoteCheckin:FPCheckDirectionOut];
        }
    }
}

- (void)remoteCheckin:(FPCheckDirection)direction
{
    NSString *url = @"";
    if (direction == FPCheckDirectionIn) {
        url = self.settings[@"checkin"];
    } else {
        url = self.settings[@"checkout"];
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"POST";
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", self.email, self.password];
    NSData *authData = [authStr dataUsingEncoding:NSASCIIStringEncoding];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodedStringWithOptions:NSDataBase64Encoding76CharacterLineLength]];
    [request setValue:authValue forHTTPHeaderField:@"Authorization"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [NSURLConnection sendSynchronousRequest:request
                              returningResponse:nil
                                          error:nil];
    });
}

@end
