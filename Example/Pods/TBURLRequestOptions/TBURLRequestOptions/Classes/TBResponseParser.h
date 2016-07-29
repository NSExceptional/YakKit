//
//  TBResponseParser.h
//  Pods
//
//  Created by Tanner on 7/2/16.
//
//

#import <Foundation/Foundation.h>


#pragma mark Macros
#define TBDispatchToMain(block) dispatch_async(dispatch_get_main_queue(), ^{ block })
#define TBRunBlock(block) if ( block ) block()
#define TBRunBlockP(block, ...) if ( block ) block( __VA_ARGS__ )
#define TBRunBlockOnMain(block) TBDispatchToMain(TBRunBlock(block))
#define TBRunBlockOnMainP(block, ...) TBDispatchToMain(TBRunBlockP(block, __VA_ARGS__);)
#define NSNSString __unsafe_unretained NSString
#define NSNSURL __unsafe_unretained NSURL
#define TB_NAMESPACE(name, vals) extern const struct name vals name
#define TB_NAMESPACE_IMP(name) const struct name name =

@class TBResponseParser;
typedef void (^TBResponseBlock)(TBResponseParser *parser);

#pragma mark - TBResponseParser
@interface TBResponseParser : NSObject

+ (instancetype)error:(NSError *)error;
+ (void)parseResponseData:(NSData *)data
                 response:(NSHTTPURLResponse *)response
                    error:(NSError *)error
                 callback:(TBResponseBlock)callback;

+ (NSError *)error:(NSString *)message domain:(NSString *)domain code:(NSInteger)code;

#pragma mark Response information

@property (nonatomic, readonly) NSHTTPURLResponse *response;
@property (nonatomic, readonly) NSData            *data;
@property (nonatomic, readonly) NSError           *error;
@property (nonatomic, readonly) NSString          *contentType;

#pragma mark Response data helper accessors

@property (nonatomic, readonly) NSDictionary *JSON;
@property (nonatomic, readonly) NSString     *HTML;
@property (nonatomic, readonly) NSString     *XML;
@property (nonatomic, readonly) NSString     *javascript;
@property (nonatomic, readonly) NSString     *text;

@end


#pragma mark Status codes

typedef NS_ENUM(NSUInteger, TBHTTPStatusCode) {
    TBHTTPStatusCodeContinue = 100,
    TBHTTPStatusCodeSwitchProtocol,
    
    TBHTTPStatusCodeOK = 200,
    TBHTTPStatusCodeCreated,
    TBHTTPStatusCodeAccepted,
    TBHTTPStatusCodeNonAuthorativeInfo,
    TBHTTPStatusCodeNoContent,
    TBHTTPStatusCodeResetContent,
    TBHTTPStatusCodePartialContent,
    
    TBHTTPStatusCodeMultipleChoice = 300,
    TBHTTPStatusCodeMovedPermanently,
    TBHTTPStatusCodeFound,
    TBHTTPStatusCodeSeeOther,
    TBHTTPStatusCodeNotModified,
    TBHTTPStatusCodeUseProxy,
    TBHTTPStatusCodeUnused,
    TBHTTPStatusCodeTemporaryRedirect,
    TBHTTPStatusCodePermanentRedirect,
    
    TBHTTPStatusCodeBadRequest = 400,
    TBHTTPStatusCodeUnauthorized,
    TBHTTPStatusCodePaymentRequired,
    TBHTTPStatusCodeForbidden,
    TBHTTPStatusCodeNotFound,
    TBHTTPStatusCodeMethodNotAllowed,
    TBHTTPStatusCodeNotAcceptable,
    TBHTTPStatusCodeProxyAuthRequired,
    TBHTTPStatusCodeRequestTimeout,
    TBHTTPStatusCodeConflict,
    TBHTTPStatusCodeGone,
    TBHTTPStatusCodeLengthRequired,
    TBHTTPStatusCodePreconditionFailed,
    TBHTTPStatusCodePayloadTooLarge,
    TBHTTPStatusCodeURITooLong,
    TBHTTPStatusCodeUnsupportedMediaType,
    TBHTTPStatusCodeRequestedRangeUnsatisfiable,
    TBHTTPStatusCodeExpectationFailed,
    TBHTTPStatusCodeImATeapot,
    TBHTTPStatusCodeMisdirectedRequest = 421,
    TBHTTPStatusCodeUpgradeRequired = 426,
    TBHTTPStatusCodePreconditionRequired = 428,
    TBHTTPStatusCodeTooManyRequests,
    TBHTTPStatusCodeRequestHeaderFieldsTooLarge = 431,
    
    TBHTTPStatusCodeInternalServerError = 500,
    TBHTTPStatusCodeNotImplemented,
    TBHTTPStatusCodeBadGateway,
    TBHTTPStatusCodeServiceUnavailable,
    TBHTTPStatusCodeGatewayTimeout,
    TBHTTPStatusCodeHTTPVersionUnsupported,
    TBHTTPStatusCodeVariantAlsoNegotiates,
    TBHTTPStatusCodeAuthenticationRequired = 511,
};

extern NSString * TBHTTPStatusCodeDescriptionFromString(TBHTTPStatusCode code);

#pragma mark String constants

TB_NAMESPACE(TBContentType, {
    NSNSString *CSS;
    NSNSString *formURLEncoded;
    NSNSString *GIF;
    NSNSString *GZIP;
    NSNSString *HTML;
    NSNSString *javascript;
    NSNSString *JPEG;
    NSNSString *JSON;
    NSNSString *JWT;
    NSNSString *markdown;
    NSNSString *MPEG4VideoGeneric;
    NSNSString *multipartFormData;
    NSNSString *multipartEncrypted;
    NSNSString *plainText;
    NSNSString *PNG;
    NSNSString *rtf;
    NSNSString *textXML;
    NSNSString *XML;
    NSNSString *ZIP;
    NSNSString *ZLIB;
});

TB_NAMESPACE(TBHeader, {
    NSNSString *accept;
    NSNSString *acceptEncoding;
    NSNSString *acceptLanguage;
    NSNSString *acceptLocale;
    NSNSString *authorization;
    NSNSString *cacheControl;
    NSNSString *contentLength;
    NSNSString *contentType;
    NSNSString *date;
    NSNSString *expires;
    NSNSString *setCookie;
    NSNSString *status;
    NSNSString *userAgent;
});





















