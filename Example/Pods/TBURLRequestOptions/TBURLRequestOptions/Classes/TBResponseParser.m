//
//  TBResponseParser.m
//  Pods
//
//  Created by Tanner on 7/2/16.
//
//

#import "TBResponseParser.h"


@interface TBResponseParser ()
@property (nonatomic, readonly) BOOL hasJSON;
@property (nonatomic, readonly) BOOL hasHTML;
@property (nonatomic, readonly) BOOL hasXML;
@property (nonatomic, readonly) BOOL hasJavascript;
@property (nonatomic, readonly) BOOL hasText;
@end

@implementation TBResponseParser
@synthesize JSON = _JSON;
@synthesize text = _text;

- (id)initWithDataData:(NSData *)data response:(NSHTTPURLResponse *)response error:(NSError *)error {
    self = [super init];
    if (self) {
        _data     = data ?: [NSData data];
        _response = response;
        _error    = error;
        
        NSString *contentType = self.contentType;
        _hasJSON       = [contentType hasPrefix:TBContentType.JSON];
        _hasHTML       = [contentType isEqualToString:TBContentType.HTML];
        _hasXML        = [contentType isEqualToString:TBContentType.XML];
        _hasJavascript = [contentType isEqualToString:TBContentType.javascript];
        _hasText       = [contentType hasPrefix:@"text"] || _hasXML || _hasJSON;
        
        if (!error) {
            NSUInteger code = self.response.statusCode;
            if (code <= 400) {
                _error = [[self class] error:TBHTTPStatusCodeDescription(code) domain:@"TBResponseParser" code:code];
            }
        }
    }
    
    return self;
}

- (NSString *)contentType { return self.response.allHeaderFields[TBHeader.contentType]; }
- (NSString *)HTML { return _hasHTML ? self.text : nil; }
- (NSString *)XML { return _hasXML ? self.text : nil; }
- (NSString *)javascript { return _hasJavascript ? self.text : nil; }

- (NSDictionary *)JSON {
    if (!_JSON && _hasJSON) {
        _JSON = [NSJSONSerialization JSONObjectWithData:self.data options:0 error:nil];
    }
    
    return _JSON;
}

- (NSString *)text {
    if (!_text && _hasText) {
        _text = [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding];
    }
    
    return _text;
}

+ (void)parseResponseData:(NSData *)data response:(NSHTTPURLResponse *)response error:(NSError *)error callback:(TBResponseBlock)callback {
    TBRunBlockOnMainP(callback, [[TBResponseParser alloc] initWithDataData:data response:response error:error]);
}

+ (NSError *)error:(NSString *)message domain:(NSString *)domain code:(NSInteger)code {
    return [NSError errorWithDomain:domain code:code userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(message, @""),
                                                                NSLocalizedFailureReasonErrorKey: NSLocalizedString(message, @"")}];
}

@end


#pragma mark Content Types

TB_NAMESPACE_IMP(TBContentType) {
    .CSS                = @"texg/css",
    .formURLEncoded     = @"application/x-www-form-urlencoded",
    .GZIP               = @"application/gzip",
    .HTML               = @"text/html",
    .javascript         = @"application/javascript",
    .JSON               = @"application/json",
    .JWT                = @"application/jwt",
    .markdown           = @"text/markdown",
    .multipartFormData  = @"multipart/form-data",
    .multipartEncrypted = @"mutlipart/encrypted",
    .plainText          = @"text/plain",
    .rtf                = @"text/rtf",
    .textXML            = @"text/xml",
    .XML                = @"application/xml",
    .ZIP                = @"application/zip",
    .ZLIB               = @"application/zlib"
};

TB_NAMESPACE_IMP(TBHeader) {
    .accept          = @"Accept",
    .acceptEncoding  = @"Accept-Encoding",
    .acceptLanguage  = @"Accept-Language",
    .acceptLocale    = @"Accept-Locale",
    .authorization   = @"Authorization",
    .cacheControl    = @"Cache-Control",
    .contentLength   = @"Content-Length",
    .contentType     = @"Content-Type",
    .date            = @"Date",
    .expires         = @"Expires",
    .setCookie       = @"Set-Cookie",
    .status          = @"Status",
    .userAgent       = @"User-Agent"
};

#pragma mark Status codes

NSString * TBHTTPStatusCodeDescriptionFromString(NSString *code) {
    code = [code stringByReplacingOccurrencesOfString:@"TBHTTPStatusCode" withString:@""];
    code = [code stringByReplacingOccurrencesOfString:@"([a-z])([A-Z])" withString:@"$1 $2"
                                              options:NSRegularExpressionSearch range:NSMakeRange(0, code.length)];
    return code;
}
