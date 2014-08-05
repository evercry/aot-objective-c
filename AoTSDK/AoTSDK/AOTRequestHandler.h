//
//  AOTRequestHandler.h
//  AoTLibrarySample
//
//  Created by Jason Lee on 8/4/14.
//  Copyright (c) 2014 ntels. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AOTRequestHandlerDelegate <NSObject>

@optional

- (void)didCompleteGetAPIPath:(id)responseData;
- (void)didFailGetAPIPath:(NSError *)error;

- (void)didCompletePostAPIPath:(id)responseData;
- (void)didFailPostAPIPath:(NSError *)error;

@end
@interface AOTRequestHandler : NSObject

typedef void(^AOTRequestHandlerCompletionBlock)(id responseObject);
typedef void(^AOTRequestHandlerFailureBlock)(NSError *error);

@property (strong, nonatomic) NSString *serverURL;
@property (strong, nonatomic) NSString *authorization;
@property (weak, nonatomic) id <AOTRequestHandlerDelegate> delegate;

/**
 API서버에 데이터 조회를 요청함 - RESTFul GET
 
 @param path api경로
 @param completion 메소드 실행 성공 시 호출되는 블럭
 @param failure 메소드 실행 실패 시 호출되는 블럭
 */
- (void)getAPIPath:(NSString *)path completion:(AOTRequestHandlerCompletionBlock)completion failure:(AOTRequestHandlerFailureBlock)failure;

/**
 API서버에 커맨드/제어를 요청합니다. - RESTFul POST
 
 @param path api경로
 @param completion 메소드 실행 성공 시 호출되는 블럭
 @param failure 메소드 실행 실패 시 호출되는 블럭
 */
- (void)postAPIPath:(NSString *)path parameter:(NSDictionary *)parameter completion:(AOTRequestHandlerCompletionBlock)completion failure:(AOTRequestHandlerFailureBlock)failure;;


/**
 현재 로컬시간을 UTC로 변환합니다.
 
 @param locDateString 현재 날짜시간 문자열 yyyyMMddHHmmss
 @return UTC 날짜시간 문자열
 */
+ (NSString *)UTCDateStringFromLocal:(NSString *)locDateString;


/**
 UTC 시간을 현재 로컬 시간을 변환합니다.
 
 @param utcDateString UTC 날짜시간 문자열 
 @return 로컬 날짜시간 문자열
 */
+ (NSString *)localDateFromUTC:(NSString *)utcDateString;

/** 
 AOTRequestHandler 싱글톤 인스턴스를 반환합니다.
 @return AOTRequestHandler 인스턴스
 */
+ (AOTRequestHandler *)sharedHandler;

@end
