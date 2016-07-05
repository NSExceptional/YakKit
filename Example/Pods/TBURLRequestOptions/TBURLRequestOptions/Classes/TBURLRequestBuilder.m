//
//  TBURLRequestBuilder.m
//  Pods
//
//  Created by Ernestine Goates on 6/30/16.
//
//

#import "TBURLRequestBuilder.h"

#import "NSDictionary+Networking.h"
#import "NSArray+Networking.h"
#import "NSString+Networking.h"
#import "NSData+Networking.h"


#define BuilderOptionIMP(type, name, code)- (TBURLRequestBuilder *(^)(type))name {\
return ^(type name) { code return self; };\
}

#define BuilderOptionAutoIMP(type, name) BuilderOptionIMP(type, name, {\
_##name = name;\
})

static NSURLSessionConfiguration *defaultURLSessionConfig;
static NSMutableDictionary *progressToTasks;

@interface TBURLRequestBuilder () {
@public
    BOOL _background;
    NSString *_URL;
    NSString *_baseURL;
    NSString *_endpoint;
    NSDictionary *_headers;
    NSString *_contentTypeHeader;
    NSDictionary *_queries;
    NSData *_body;
    NSDictionary<NSString*, id> *_multipartStrings;
    NSDictionary<NSString*, NSData*> *_multipartData;
    NSString *_boundary;
    NSTimeInterval _timeout;
    NSURLRequestNetworkServiceType _serviceType;
    NSURLSessionConfiguration *_configuration;
    NSURLSession *_session;
}
@property (nonatomic, readonly) NSData *mutlipartBodyData;
@property (nonatomic, readonly) NSString *multipartContentTypeHeader;
@end

@interface TBURLRequestProxy () <NSURLSessionDelegate, NSURLSessionDataDelegate>
/// Returns the reciever
- (instancetype)build:(TBURLRequestBuilder *)builder;
@property (nonatomic) BOOL background;
@property (nonatomic) NSMutableURLRequest *internalRequest;
@end

@implementation TBURLRequestBuilder

+ (TBURLRequestProxy *)make:(void (^)(TBURLRequestBuilder *make))configurationHandler {
    TBURLRequestBuilder *builder = [self new];
    configurationHandler(builder);
    return [[TBURLRequestProxy new] build:builder];
}

- (id)copyWithZone:(NSZone *)zone {
    TBURLRequestBuilder *builder = [TBURLRequestBuilder new];
    builder->_background         = _background;
    builder->_URL                = _URL;
    builder->_baseURL            = _baseURL;
    builder->_endpoint           = _endpoint;
    builder->_headers            = _headers;
    builder->_contentTypeHeader  = _contentTypeHeader;
    builder->_queries            = _queries;
    builder->_body               = _body;
    builder->_multipartData      = _multipartData;
    builder->_boundary           = _boundary;
    return builder;
}

- (TBURLRequestBuilder *)background {
    _background = YES;
    return self;
}

BuilderOptionIMP(NSString *, URL, {
    NSAssert(!_baseURL && !_endpoint, @"Cannot use a full URL and a base URL");
    _URL = URL;
})
BuilderOptionIMP(NSString *, baseURL, {
    NSAssert(!_URL, @"Cannot use a base URL and a full URL");
    _baseURL = baseURL;
})
BuilderOptionIMP(NSString *, endpoint, {
    NSAssert(_baseURL, @"Must first use a baseURL");
    _endpoint = endpoint;
})

BuilderOptionAutoIMP(NSDictionary *, headers)
BuilderOptionAutoIMP(NSDictionary *, queries)
BuilderOptionAutoIMP(NSData *, body)
BuilderOptionAutoIMP(NSDictionary *, multipartStrings);
BuilderOptionAutoIMP(NSDictionary *, multipartData)
BuilderOptionAutoIMP(NSString *, boundary)
BuilderOptionAutoIMP(NSTimeInterval, timeout)
BuilderOptionAutoIMP(NSURLRequestNetworkServiceType, serviceType);
BuilderOptionAutoIMP(NSURLSessionConfiguration *, configuration);
BuilderOptionAutoIMP(NSURLSession *, session);


BuilderOptionIMP(NSString *, bodyString, {
    _body = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    _contentTypeHeader = TBContentType.plainText;
})
BuilderOptionIMP(NSDictionary *, bodyJSON, {
    _body = [NSJSONSerialization dataWithJSONObject:bodyJSON options:0 error:nil];
    _contentTypeHeader = TBContentType.JSON;
})
BuilderOptionIMP(NSString *, bodyFormString, {
    _body = [bodyFormString dataUsingEncoding:NSUTF8StringEncoding];
    _contentTypeHeader = TBContentType.formURLEncoded;
})
BuilderOptionIMP(NSDictionary *, bodyJSONFormString, {
    _body = [bodyJSONFormString.queryString dataUsingEncoding:NSUTF8StringEncoding];
    _contentTypeHeader = TBContentType.formURLEncoded;
})

- (NSData *)mutlipartBodyData {
    if (!_multipartData.count && !_multipartStrings.count) {
        return nil;
    }
    
    NSMutableData *body = [NSMutableData data];
    // Initial boundary
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", _boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    // Raw data
    [_multipartData enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSData *data, BOOL *stop) {
        [body appendData:[NSData boundary:_boundary withKey:key forDataValue:data]];
    }];
    // Form parameters
    if (_multipartStrings) {
        [_multipartStrings enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
            [body appendData:[NSData boundary:_boundary withKey:key forStringValue:obj]];
        }];
    }
    
    // Replace last \r\n with --
    [body replaceBytesInRange:NSMakeRange(body.length-2, 2) withBytes:[@"--" dataUsingEncoding:NSUTF8StringEncoding].bytes];
    
    return body.copy;
}

- (NSString *)multipartContentTypeHeader {
    NSString *header = _contentTypeHeader.lowercaseString;
    if ([header hasPrefix:@"multipart"]) {
        if (![header containsString:@"boundary"]) {
            _boundary = _boundary ?: [NSUUID UUID].UUIDString;
            return [NSString stringWithFormat:@"%@; boundary=%@", _contentTypeHeader, _boundary];
        }
    } else if (_multipartData || _multipartStrings) {
        _contentTypeHeader = @"mutlipart/form-data";
        return self.multipartContentTypeHeader;
    }
    
    return nil;
}

@end


@implementation TBURLRequestProxy
@synthesize configuration = _configuration;

+ (void)initialize {
    if (self == [TBURLRequestProxy class]) {
        defaultURLSessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        progressToTasks = [NSMutableDictionary dictionary];
    }
}

- (instancetype)build:(TBURLRequestBuilder *)builder {
    // Explicit Content-Type
    NSString *contentType = builder.multipartContentTypeHeader ?: builder->_contentTypeHeader;
    if (contentType) {
        builder->_headers = MergeDictionaries(builder->_headers, @{@"Content-Type": builder->_contentTypeHeader});
    }
    
    NSURL *url = [NSURL URLWithString:builder->_URL ?: [builder->_baseURL stringByAppendingPathComponent:builder->_endpoint]];
    if (_internalRequest) {
        self.internalRequest.URL = url;
    } else {
        self.internalRequest = [NSMutableURLRequest requestWithURL:url];
    }
    
    self.internalRequest.HTTPBody            = builder.mutlipartBodyData ?: builder->_body;
    self.internalRequest.allHTTPHeaderFields = builder->_headers;
    self.internalRequest.timeoutInterval     = builder->_timeout;
    self.internalRequest.networkServiceType  = builder->_serviceType;
    
    self.background = builder->_background;
    _configuration  = builder->_configuration;
    self.session    = builder->_session;
    
    return self;
}

- (NSMutableURLRequest *)request { return self.internalRequest.copy; }
- (NSURLSessionConfiguration *)configuration { return self.session.configuration ?: _configuration ?: defaultURLSessionConfig; }
- (NSURLSession *)session {
    if (!_session) {
        _session = [NSURLSession sessionWithConfiguration:self.configuration delegate:self delegateQueue:nil];
    }
    
    return _session;
}

- (NSProgress *)GET:(TBResponseBlock)completion { return [self start:@"GET" callback:completion]; }
- (NSProgress *)POST:(TBResponseBlock)completion { return [self start:@"POST" callback:completion]; }
- (NSProgress *)PUT:(TBResponseBlock)completion { return [self start:@"PUT" callback:completion]; }
- (NSProgress *)HEAD:(TBResponseBlock)completion { return [self start:@"HEAD" callback:completion]; }
- (NSProgress *)DELETE:(TBResponseBlock)completion { return [self start:@"DELETE" callback:completion]; }
- (NSProgress *)OPTIONS:(TBResponseBlock)completion { return [self start:@"OPTIONS" callback:completion]; }
- (NSProgress *)CONNECT:(TBResponseBlock)completion { return [self start:@"CONNECT" callback:completion]; }

- (NSProgress *)start:(NSString *)method callback:(TBResponseBlock)completion {
    NSParameterAssert(method);
    self.internalRequest.HTTPMethod = method;
    
    NSURLSessionTask *task = [self.session dataTaskWithRequest:self.internalRequest completionHandler:^(NSData *d, NSURLResponse *r, NSError *e) {
        [TBResponseParser parseResponseData:d response:(id)r error:e callback:completion];
    }];
    
    // NSProgress for task 
    if (self.session.delegate == self) {
        NSProgress *progress = [NSProgress progressWithTotalUnitCount:100];
        progressToTasks[@(task.taskIdentifier)] = progress;
        return progress;
    }
    
    return nil;
}

#pragma mark Delegate stuff

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didBecomeDownloadTask:(NSURLSessionDownloadTask *)downloadTask {
    /// Download task takes on 50% of the original progress
    NSProgress *parent = progressToTasks[@(dataTask.taskIdentifier)];
    NSProgress *child  = [NSProgress progressWithTotalUnitCount:downloadTask.countOfBytesExpectedToReceive parent:parent pendingUnitCount:50];
    progressToTasks[@(dataTask.taskIdentifier)] = nil;
    progressToTasks[@(downloadTask.taskIdentifier)] = child;
    parent.completedUnitCount = 50;
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didBecomeStreamTask:(NSURLSessionStreamTask *)streamTask {
    NSProgress *progress = progressToTasks[@(dataTask.taskIdentifier)];
    progress.completedUnitCount = progress.totalUnitCount;
    progressToTasks[@(dataTask.taskIdentifier)] = nil;
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [self updateProgressForTask:dataTask];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)sent totalBytesSent:(int64_t)totalSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    [self updateProgressForTask:task];
}

/// Progress is complete when all bytes have been sent and recieved. Sent and recieved are 50% respectively.
- (void)updateProgressForTask:(NSURLSessionTask *)task {
    NSProgress *progress    = progressToTasks[@(task.taskIdentifier)];
    CGFloat percentRecieved = task.countOfBytesReceived/task.countOfBytesExpectedToReceive;
    CGFloat percentSent     = task.countOfBytesSent/task.countOfBytesExpectedToSend;
    progress.completedUnitCount = 50 * (percentSent + percentRecieved);
}

@end