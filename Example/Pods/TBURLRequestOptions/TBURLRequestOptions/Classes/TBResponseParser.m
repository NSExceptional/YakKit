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

+ (instancetype)error:(NSError *)error {
    return [[self alloc] initWithDataData:nil response:nil error:error];
}

- (id)initWithDataData:(NSData *)data response:(NSHTTPURLResponse *)response error:(NSError *)error {
    self = [super init];
    if (self) {
        _data     = data ?: [NSData data];
        _response = response;
        _error    = error;
        
        NSString *contentType = self.contentType;
        
        if (data.length) {
            _hasJSON       = [contentType hasPrefix:TBContentType.JSON];
            _hasHTML       = [contentType hasPrefix:TBContentType.HTML];
            _hasXML        = [contentType hasPrefix:TBContentType.XML] || [contentType hasPrefix:TBContentType.textXML];
            _hasJavascript = [contentType hasPrefix:TBContentType.javascript];
            _hasText       = [contentType hasPrefix:@"text"] || _hasXML || _hasJSON || _hasJavascript;
        }
        
        if (!error) {
            NSUInteger code = self.response.statusCode;
            if (code >= 400) {
                _error = [[self class] error:TBHTTPStatusCodeDescriptionFromString(code) domain:@"TBResponseParser" code:code];
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
    if ((!_JSON && _hasJSON) || _ignoreContentTypeForJSON) {
        _JSON = [NSJSONSerialization JSONObjectWithData:self.data options:0 error:nil];
        _ignoreContentTypeForJSON = NO;
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
    .GIF                = @"image/gif",
    .GZIP               = @"application/gzip",
    .HTML               = @"text/html",
    .javascript         = @"application/javascript",
    .JPEG               = @"image/jpeg",
    .JSON               = @"application/json",
    .JWT                = @"application/jwt",
    .markdown           = @"text/markdown",
    .MPEG4VideoGeneric  = @"video/mpeg4-generic",
    .multipartFormData  = @"multipart/form-data",
    .multipartEncrypted = @"multipart/encrypted",
    .plainText          = @"text/plain",
    .PNG                = @"image/png",
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

NSString * _TBHTTPStatusCodeDescriptionFromString(NSString *code) {
    code = [code stringByReplacingOccurrencesOfString:@"TBHTTPStatusCode" withString:@""];
    code = [code stringByReplacingOccurrencesOfString:@"([a-z])([A-Z])" withString:@"$1 $2"
                                              options:NSRegularExpressionSearch range:NSMakeRange(0, code.length)];
    return code;
}

#define TBStringifyEnum(enum) @(#enum)

NSString * TBHTTPStatusCodeDescriptionFromString(TBHTTPStatusCode code) {
    switch (code) {
        case TBHTTPStatusCodeContinue: {
            return _TBHTTPStatusCodeDescriptionFromString(TBStringifyEnum(TBHTTPStatusCodeContinue));
        }
        case TBHTTPStatusCodeSwitchProtocol: {
            return _TBHTTPStatusCodeDescriptionFromString(TBStringifyEnum(TBHTTPStatusCodeSwitchProtocol));
        }
        case TBHTTPStatusCodeOK: {
            return _TBHTTPStatusCodeDescriptionFromString(TBStringifyEnum(TBHTTPStatusCodeOK));
        }
        case TBHTTPStatusCodeCreated: {
            return _TBHTTPStatusCodeDescriptionFromString(TBStringifyEnum(TBHTTPStatusCodeCreated));
        }
        case TBHTTPStatusCodeAccepted: {
            return _TBHTTPStatusCodeDescriptionFromString(TBStringifyEnum(TBHTTPStatusCodeAccepted));
        }
        case TBHTTPStatusCodeNonAuthorativeInfo: {
            return _TBHTTPStatusCodeDescriptionFromString(TBStringifyEnum(TBHTTPStatusCodeNonAuthorativeInfo));
        }
        case TBHTTPStatusCodeNoContent: {
            return _TBHTTPStatusCodeDescriptionFromString(TBStringifyEnum(TBHTTPStatusCodeNoContent));
        }
        case TBHTTPStatusCodeResetContent: {
            return _TBHTTPStatusCodeDescriptionFromString(TBStringifyEnum(TBHTTPStatusCodeResetContent));
        }
        case TBHTTPStatusCodePartialContent: {
            return _TBHTTPStatusCodeDescriptionFromString(TBStringifyEnum(TBHTTPStatusCodePartialContent));
        }
        case TBHTTPStatusCodeMultipleChoice: {
            return _TBHTTPStatusCodeDescriptionFromString(TBStringifyEnum(TBHTTPStatusCodeMultipleChoice));
        }
        case TBHTTPStatusCodeMovedPermanently: {
            return _TBHTTPStatusCodeDescriptionFromString(TBStringifyEnum(TBHTTPStatusCodeMovedPermanently));
        }
        case TBHTTPStatusCodeFound: {
            return _TBHTTPStatusCodeDescriptionFromString(TBStringifyEnum(TBHTTPStatusCodeFound));
        }
        case TBHTTPStatusCodeSeeOther: {
            return _TBHTTPStatusCodeDescriptionFromString(TBStringifyEnum(TBHTTPStatusCodeSeeOther));
        }
        case TBHTTPStatusCodeNotModified: {
            return _TBHTTPStatusCodeDescriptionFromString(TBStringifyEnum(TBHTTPStatusCodeNotModified));
        }
        case TBHTTPStatusCodeUseProxy: {
            return _TBHTTPStatusCodeDescriptionFromString(TBStringifyEnum(TBHTTPStatusCodeUseProxy));
        }
        case TBHTTPStatusCodeUnused: {
            return _TBHTTPStatusCodeDescriptionFromString(TBStringifyEnum(TBHTTPStatusCodeUnused));
        }
        case TBHTTPStatusCodeTemporaryRedirect: {
            return _TBHTTPStatusCodeDescriptionFromString(TBStringifyEnum(TBHTTPStatusCodeTemporaryRedirect));
        }
        case TBHTTPStatusCodePermanentRedirect: {
            return _TBHTTPStatusCodeDescriptionFromString(TBStringifyEnum(TBHTTPStatusCodePermanentRedirect));
        }
        case TBHTTPStatusCodeBadRequest: {
            return _TBHTTPStatusCodeDescriptionFromString(TBStringifyEnum(TBHTTPStatusCodeBadRequest));
        }
        case TBHTTPStatusCodeUnauthorized: {
            return _TBHTTPStatusCodeDescriptionFromString(TBStringifyEnum(TBHTTPStatusCodeUnauthorized));
        }
        case TBHTTPStatusCodePaymentRequired: {
            return _TBHTTPStatusCodeDescriptionFromString(TBStringifyEnum(TBHTTPStatusCodePaymentRequired));
        }
        case TBHTTPStatusCodeForbidden: {
            return _TBHTTPStatusCodeDescriptionFromString(TBStringifyEnum(TBHTTPStatusCodeForbidden));
        }
        case TBHTTPStatusCodeNotFound: {
            return _TBHTTPStatusCodeDescriptionFromString(TBStringifyEnum(TBHTTPStatusCodeNotFound));
        }
        case TBHTTPStatusCodeMethodNotAllowed: {
            return _TBHTTPStatusCodeDescriptionFromString(TBStringifyEnum(TBHTTPStatusCodeMethodNotAllowed));
        }
        case TBHTTPStatusCodeNotAcceptable: {
            return _TBHTTPStatusCodeDescriptionFromString(TBStringifyEnum(TBHTTPStatusCodeNotAcceptable));
        }
        case TBHTTPStatusCodeProxyAuthRequired: {
            return _TBHTTPStatusCodeDescriptionFromString(TBStringifyEnum(TBHTTPStatusCodeProxyAuthRequired));
        }
        case TBHTTPStatusCodeRequestTimeout: {
            return _TBHTTPStatusCodeDescriptionFromString(TBStringifyEnum(TBHTTPStatusCodeRequestTimeout));
        }
        case TBHTTPStatusCodeConflict: {
            return _TBHTTPStatusCodeDescriptionFromString(TBStringifyEnum(TBHTTPStatusCodeConflict));
        }
        case TBHTTPStatusCodeGone: {
            return _TBHTTPStatusCodeDescriptionFromString(TBStringifyEnum(TBHTTPStatusCodeGone));
        }
        case TBHTTPStatusCodeLengthRequired: {
            return _TBHTTPStatusCodeDescriptionFromString(TBStringifyEnum(TBHTTPStatusCodeLengthRequired));
        }
        case TBHTTPStatusCodePreconditionFailed: {
            return _TBHTTPStatusCodeDescriptionFromString(TBStringifyEnum(TBHTTPStatusCodePreconditionFailed));
        }
        case TBHTTPStatusCodePayloadTooLarge: {
            return _TBHTTPStatusCodeDescriptionFromString(TBStringifyEnum(TBHTTPStatusCodePayloadTooLarge));
        }
        case TBHTTPStatusCodeURITooLong: {
            return _TBHTTPStatusCodeDescriptionFromString(TBStringifyEnum(TBHTTPStatusCodeURITooLong));
        }
        case TBHTTPStatusCodeUnsupportedMediaType: {
            return _TBHTTPStatusCodeDescriptionFromString(TBStringifyEnum(TBHTTPStatusCodeUnsupportedMediaType));
        }
        case TBHTTPStatusCodeRequestedRangeUnsatisfiable: {
            return _TBHTTPStatusCodeDescriptionFromString(TBStringifyEnum(TBHTTPStatusCodeRequestedRangeUnsatisfiable));
        }
        case TBHTTPStatusCodeExpectationFailed: {
            return _TBHTTPStatusCodeDescriptionFromString(TBStringifyEnum(TBHTTPStatusCodeExpectationFailed));
        }
        case TBHTTPStatusCodeImATeapot: {
            return _TBHTTPStatusCodeDescriptionFromString(TBStringifyEnum(TBHTTPStatusCodeImATeapot));
        }
        case TBHTTPStatusCodeMisdirectedRequest: {
            return _TBHTTPStatusCodeDescriptionFromString(TBStringifyEnum(TBHTTPStatusCodeMisdirectedRequest));
        }
        case TBHTTPStatusCodeUpgradeRequired: {
            return _TBHTTPStatusCodeDescriptionFromString(TBStringifyEnum(TBHTTPStatusCodeUpgradeRequired));
        }
        case TBHTTPStatusCodePreconditionRequired: {
            return _TBHTTPStatusCodeDescriptionFromString(TBStringifyEnum(TBHTTPStatusCodePreconditionRequired));
        }
        case TBHTTPStatusCodeTooManyRequests: {
            return _TBHTTPStatusCodeDescriptionFromString(TBStringifyEnum(TBHTTPStatusCodeTooManyRequests));
        }
        case TBHTTPStatusCodeRequestHeaderFieldsTooLarge: {
            return _TBHTTPStatusCodeDescriptionFromString(TBStringifyEnum(TBHTTPStatusCodeRequestHeaderFieldsTooLarge));
        }
        case TBHTTPStatusCodeInternalServerError: {
            return _TBHTTPStatusCodeDescriptionFromString(TBStringifyEnum(TBHTTPStatusCodeInternalServerError));
        }
        case TBHTTPStatusCodeNotImplemented: {
            return _TBHTTPStatusCodeDescriptionFromString(TBStringifyEnum(TBHTTPStatusCodeNotImplemented));
        }
        case TBHTTPStatusCodeBadGateway: {
            return _TBHTTPStatusCodeDescriptionFromString(TBStringifyEnum(TBHTTPStatusCodeBadGateway));
        }
        case TBHTTPStatusCodeServiceUnavailable: {
            return _TBHTTPStatusCodeDescriptionFromString(TBStringifyEnum(TBHTTPStatusCodeServiceUnavailable));
        }
        case TBHTTPStatusCodeGatewayTimeout: {
            return _TBHTTPStatusCodeDescriptionFromString(TBStringifyEnum(TBHTTPStatusCodeGatewayTimeout));
        }
        case TBHTTPStatusCodeHTTPVersionUnsupported: {
            return _TBHTTPStatusCodeDescriptionFromString(TBStringifyEnum(TBHTTPStatusCodeHTTPVersionUnsupported));
        }
        case TBHTTPStatusCodeVariantAlsoNegotiates: {
            return _TBHTTPStatusCodeDescriptionFromString(TBStringifyEnum(TBHTTPStatusCodeVariantAlsoNegotiates));
        }
        case TBHTTPStatusCodeAuthenticationRequired: {
            return _TBHTTPStatusCodeDescriptionFromString(TBStringifyEnum(TBHTTPStatusCodeAuthenticationRequired));
        }
    }
}
