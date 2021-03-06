//
//  jobObject.h
//  ZER0trace External
//
//  Created by Robert Crosby on 10/11/17.
//  Copyright © 2017 fully toasted. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface jobObject : NSObject

@property (nonatomic, strong) NSURL* videoURL;
@property (nonatomic, strong) NSString *dateOfDestruction;
@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, strong) NSDate *dateObject;
@property (nonatomic, strong) NSArray* driveTimes;
@property (nonatomic, strong) NSArray* driveSerials;
@property (nonatomic, strong) NSString *jobCode;
@property (nonatomic, strong) NSString *signature;

-(instancetype)initWithType:(NSURL*)videoURL andTimes:(NSArray*)driveTimes andSerials:(NSArray*)driveSerials andDate:(NSString*)date andCode:(NSString*)jobCode andLocation:(CLLocation*)location andDateObject:(NSDate*)dateObject andSignature:(NSString*)signature;


@end
