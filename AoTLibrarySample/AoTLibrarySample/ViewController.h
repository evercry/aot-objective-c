//
//  ViewController.h
//  AoTLibrarySample
//
//  Created by Jason Lee on 8/4/14.
//  Copyright (c) 2014 ntels. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (strong, nonatomic) NSString *deviceId;
@property (strong, nonatomic) NSString *nodeId;

- (IBAction)btnReadSensorDataTouched:(id)sender;
- (IBAction)btnReadExectuedResultTouched:(id)sender;
- (IBAction)btnExecuteActuatorTouched:(id)sender;

@end
