//
//  FPBeaconHelper.h
//  WhosFancy
//
//  Created by Andrea Mazzini on 30/06/14.
//  Copyright (c) 2014 Fancy Pixel. All rights reserved.
//

@interface FPBeaconHelper : NSObject

@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, assign) BOOL track;

+ (FPBeaconHelper *)sharedHelper;

- (void)loadUser;
- (void)saveUser;

- (void)startMonitoring;
- (void)stopMonitoring;

@end
