//
//  TBURLRequestBuilder.h
//  Pods
//
//  Created by Ernestine Goates on 6/30/16.
//
//

#import <Foundation/Foundation.h>
#import "TBResponseParser.h"

@class TBURLRequestProxy;
typedef void (^BuilderBlock)(NSDictionary *json, NSData *data, NSError *error, NSInteger code);
#define BuilderOption(type, name) @property (nonatomic, readonly) TBURLRequestBuilder *(^name)(type)

@interface TBURLRequestBuilder : NSObject <NSCopying>

/// This method takes a block that will configure a given \c TBURLRequestBuilder object.
/// The resulting builder is used to make a \c TBURLRequestProxy object.
+ (TBURLRequestProxy *)make:(void(^)(TBURLRequestBuilder *make))configurationHandler;

/// The full URL for the request, excluding any query parameters.
BuilderOption(NSString *, URL);
/// Must use with endpoint.
BuilderOption(NSString *, baseURL);
/// Relative to \c baseURL, must use if using it and must use after \c baseURL.
BuilderOption(NSString *, endpoint);

BuilderOption(NSDictionary *, headers);

/// Queries to be appended to the final request URL. Automatically URL encoded.
BuilderOption(NSDictionary *, queries);
/// The HTTP request body. You must explicitly set the MIME content type when using this.
BuilderOption(NSData       *, body);
/// Convenience getter/setter for the \c body as a string.
BuilderOption(NSString     *, bodyString);
/// Convenience getter/setter for the \c body as JSON.
BuilderOption(NSDictionary *, bodyJSON);
/// Convenience getter/setter for the \c body as a URL form encoded string.
BuilderOption(NSString     *, bodyFormString);
/// Convenience getter/setter for the \c body as a URL form encoded string given JSON.
BuilderOption(NSDictionary *, bodyJSONFormString);
/// Appended to the body as string parameters in a multipart-form request.
/// Overrides the Content-Type header when set. Used in conjunction with \c mutlipartData.
/// Dictionary must be of generic type <NSString *, NSData *> where the key is the name.
/// \c body is ignored if this field is set.
BuilderOption(NSDictionary *, multipartStrings);

/// Overrides the Content-Type header when set. Used in conjunction with \c multipartStrings.
/// Dictionary must be of generic type <NSString *, NSData *> where the key is the name.
BuilderOption(NSDictionary *, multipartData);
/// Used when the content type is \c multipart/form-data.
/// Overrides the Content-Type header when used. One will
/// be chosen for you if needed and omitted from the builder.
BuilderOption(NSString *, boundary);

BuilderOption(NSTimeInterval, timeout);
BuilderOption(NSURLRequestNetworkServiceType, serviceType);
/// Default configuration used if not set, ignored if \c session is set.
BuilderOption(NSURLSessionConfiguration *, configuration);
BuilderOption(NSURLSession *, session);

/// For your own use
BuilderOption(id, metadata);

@end


/// This class is used to actually make HTTP requests
/// and can only be correctly created by \c TBURLRequestBuilder.
///
/// If you did not specify your own \c NSURLSession object, each
/// method call sends the desired request and returns an
/// \c NSProgress object denoting the progress of the request,
/// relative to the bytes of the body data to be sent.
/// Otherwise each method returns \c nil.
@interface TBURLRequestProxy : NSObject

/// May not have it's \c HTTPMethod set
@property (nonatomic, readonly) NSMutableURLRequest       *request;
@property (nonatomic, readonly) NSURLSessionConfiguration *configuration;
/// The reciever serves as the session's \c NSURLSessionDataDelegate to update returned \c NSProgress objects.
@property (nonatomic) NSURLSession                        *session;
@property (nonatomic) id metadata;

- (NSProgress *)GET:(TBResponseBlock)completion;
- (NSProgress *)POST:(TBResponseBlock)completion;
- (NSProgress *)PUT:(TBResponseBlock)completion;
- (NSProgress *)HEAD:(TBResponseBlock)completion;
- (NSProgress *)DELETE:(TBResponseBlock)completion;
- (NSProgress *)OPTIONS:(TBResponseBlock)completion;
- (NSProgress *)CONNECT:(TBResponseBlock)completion;

@end
