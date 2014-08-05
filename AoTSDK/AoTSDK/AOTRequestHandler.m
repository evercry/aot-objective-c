//
//  AOTRequestHandler.m
//  AoTLibrarySample
//
//  Created by Jason Lee on 8/4/14.
//  Copyright (c) 2014 ntels. All rights reserved.
//

#import "AOTRequestHandler.h"

@interface AOTRequestHandler () <NSURLConnectionDelegate, NSURLConnectionDataDelegate> {
    NSMutableData *_receivedData;
    AOTRequestHandlerCompletionBlock _completionBlock;
    AOTRequestHandlerFailureBlock _failureBlock;
    
}
@end

@implementation AOTRequestHandler

//현재 로컬시간을 UTC로 변환합니다.
+ (NSString *)UTCDateStringFromLocal:(NSString *)locDateString {
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
+ (NSString *)localDateFromUTC:(NSString *)utcDateString {
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    NSDate *utcDate = [df dateFromString:utcDateString];
    
    NSDateFormatter* df_local = [[NSDateFormatter alloc] init];
    [df_local setTimeZone:[NSTimeZone systemTimeZone]];
    [df_local setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    
    NSString* localString = [df_local stringFromDate:utcDate];
    return localString;
}

- (void)getAPIPath:(NSString *)path completion:(AOTRequestHandlerCompletionBlock)completion failure:(AOTRequestHandlerFailureBlock)failure {
    
    _completionBlock = completion;
    _failureBlock = failure;
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@", self.serverURL, path];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request setValue:self.authorization forHTTPHeaderField:@"Authorization"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    
    
    [self sendAsyncRequest:request];
}

- (void)postAPIPath:(NSString *)path parameter:(NSDictionary *)parameter completion:(AOTRequestHandlerCompletionBlock)completion failure:(AOTRequestHandlerFailureBlock)failure {
    
    _completionBlock = completion;
    _failureBlock = failure;
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@", self.serverURL, path];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameter
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    NSString *postLength = [NSString stringWithFormat:@"%d",[jsonData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:self.authorization forHTTPHeaderField:@"Authorization"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:jsonData];
    
    [self sendAsyncRequest:request];
}


- (void)sendAsyncRequest:(NSURLRequest *)request {

    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    if (connection) {
        _receivedData = [[NSMutableData alloc] init];
    } else {
        NSLog(@"Cant' connect url");
    }
}


#pragma mark - NSURLConnection Delegate & Data Delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    int responseStatusCode = [httpResponse statusCode];
    
    switch (responseStatusCode) {
        case 200://OK
            break;
        case 201: //Created
            break;
        case 202: //Accepted
            break;
        case 204: //No Content.
            break;
        case 404:
            NSLog(@"Not found.");
            break;
        case 405:
            NSLog(@"Method not allowed.");
            break;
    }
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"%@", error);
    
    if ([[connection currentRequest].HTTPMethod isEqualToString:@"GET"]) {
        if ([self.delegate respondsToSelector:@selector(didFailGetAPIPath:)]) {
            [self.delegate didFailGetAPIPath:error];
        }
    } else if ([[connection currentRequest].HTTPMethod isEqualToString:@"POST"]) {
        if ([self.delegate respondsToSelector:@selector(didFailPostAPIPath:)]) {
            [self.delegate didFailPostAPIPath:error];
        }
    }
    
    if (_failureBlock) {
        _failureBlock(error);
    }
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_receivedData appendData:data];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    if ([[connection currentRequest].HTTPMethod isEqualToString:@"GET"]) {
        if ([self.delegate respondsToSelector:@selector(didCompleteGetAPIPath:)]) {
            [self.delegate didCompleteGetAPIPath:_receivedData];
        }
    } else if ([[connection currentRequest].HTTPMethod isEqualToString:@"POST"]) {
        if ([self.delegate respondsToSelector:@selector(didCompletePostAPIPath:)]) {
            [self.delegate didCompletePostAPIPath:_receivedData];
        }
    }
    
    if (_completionBlock) {
        _completionBlock(_receivedData);
    }
}



#pragma mark - Singleton

+ (AOTRequestHandler *)sharedHandler {
    
    static AOTRequestHandler *sharedRequestHandler = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedRequestHandler = [[self alloc] init];
    });
    return sharedRequestHandler;
}

- (id)init {
    if (self = [super init]) {
        
    }
    return self;
}


@end
