//
//  ViewController.m
//  AoTLibrarySample
//
//  Created by Jason Lee on 8/4/14.
//  Copyright (c) 2014 ntels. All rights reserved.
//
#import "AOTRequestHandler.h"

#import "ViewController.h"

@interface ViewController () {

}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Server URL 설정
    [AOTRequestHandler sharedHandler].serverURL = @"http://110.10.80.32:14000";
    
    //Authorization 설정
    [AOTRequestHandler sharedHandler].authorization = @"Basic QTU1NjQwMTg0NDkzOjA4MzFhYWE1NjgxNjQwZWE=";
    
    //디바이스 아이디 설정
    self.deviceId = @"D70127176610";
    
    //노드 아이디 설정
    self.nodeId = @"1";
}

//현재 로컬시간을 UTC로 변환합니다.
- (NSString *)UTCDateStringFromLocal:(NSString *)locDateString {
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyyMMddHHmmss"];
    NSDate *locDate = [df dateFromString:locDateString];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyyMMddHHmmssSSS";
    
    NSTimeZone *utc = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    [dateFormatter setTimeZone:utc];
    NSString *timeStamp = [dateFormatter stringFromDate:locDate];
    timeStamp = [NSString stringWithFormat:@"%@Z",timeStamp];
    return timeStamp;
}

//UTC 시간을 현재 로컬 시간을 변환합니다.
- (NSString *)localDateFromUTC:(NSString *)utcDateString {
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    NSDate *utcDate = [df dateFromString:utcDateString];
    
    NSDateFormatter* df_local = [[NSDateFormatter alloc] init];
    [df_local setTimeZone:[NSTimeZone systemTimeZone]];
    [df_local setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    
    NSString* localString = [df_local stringFromDate:utcDate];
    return localString;
}


//API서버에 센서데이터 조회를 요청합니다.
- (IBAction)btnReadSensorDataTouched:(id)sender {
    
    //특정 기간동안의 데이터를 요청하는 경우
    
    //현재 지역 날짜시간을 UTC로 변환합니다.
    NSString *startDate = [self UTCDateStringFromLocal:@"20140801170630"];
    NSString *endDate = [self UTCDateStringFromLocal:@"20140804180630"];
    
    NSString *parameter = [NSString stringWithFormat:@"?start=%@&end=%@" , startDate, endDate];
    
    
    //최근 데이터를 기준으로 특정 갯수만큼 조회하는 경우
//    NSString *parameter = @"?count=10";
    
    NSString *apiFormat = @"/v1/contents/%@/%@%@";
    NSString *apiPath = [NSString stringWithFormat:apiFormat, self.deviceId, self.nodeId, parameter];
    
    [[AOTRequestHandler sharedHandler] getAPIPath:apiPath completion:^(id responseObject) {//데이터 조회를 요청합니다.
        NSError *error = nil;
        id result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&error];
        
        if (error) {
            NSLog(@"%@", error);
            return;
        }
        
        
        if ([result isKindOfClass:[NSArray class]]) {
            
            //GMT 날짜를 로컬 날짜로 변환하는 예제
            for (NSDictionary *dict in result) {
                if ([dict objectForKey:@"collect_time"]) {
                    NSString *collectTime = [dict objectForKey:@"collect_time"];
                    NSString *localDateString = [self localDateFromUTC:collectTime];
                    
                    NSLog(@"%@", localDateString);
                }
            }
            
        } else if ([result isKindOfClass:[NSDictionary class]]) {
            NSLog(@"%@", result);
        }
        
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}

//API서버에 명령 실행 결과를 요청합니다.
- (IBAction)btnReadExectuedResultTouched:(id)sender {
    
    //제어하고자 하는 디바이스 아이디
    NSString *commandId = @"53DEF2DF050a2230EF000000";
    
    NSString *apiFormat = @"/v1/commands/%@/%@/%@";
    NSString *apiPath = [NSString stringWithFormat:apiFormat, self.deviceId, self.nodeId, commandId];
    
    
    [[AOTRequestHandler sharedHandler] getAPIPath:apiPath completion:^(id responseObject) {
        NSError *error = nil;
        NSDictionary *jsonDictonary = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&error];
        
        if (error) {
            NSLog(@"%@", error);
            return;
        }
        
        NSLog(@"%@", jsonDictonary);
        
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}

//API서버에 특정 디바이스에 대한 제어를 요청합니다.
- (IBAction)btnExecuteActuatorTouched:(id)sender {
    
    
    NSString *apiFormat = @"/v1/commands/%@/%@";
    NSString *apiPath = [NSString stringWithFormat:apiFormat, self.deviceId, self.nodeId];
    
    //제어 요청값
    NSDictionary *parameter = @{@"request_value": @"true"};
    
    [[AOTRequestHandler sharedHandler] postAPIPath:apiPath parameter:parameter completion:^(id responseObject) {
        NSError *error = nil;
        NSDictionary *jsonDictonary = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&error];
        
        if (error) {
            NSLog(@"%@", error);
            return;
        }
        
        NSLog(@"%@", jsonDictonary);
        
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
