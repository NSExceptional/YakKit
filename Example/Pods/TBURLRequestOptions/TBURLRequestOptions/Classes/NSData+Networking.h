//
//  NSData+Networking.h
//  TBURLRequestOptions
//
//  Created by Tanner Bennett on 1/7/16.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSData (AES)

- (NSData *)AES128EncryptedDataWithKey:(NSString *)key;
- (NSData *)AES128DecryptedDataWithKey:(NSString *)key;
- (NSData *)AES128EncryptedDataWithKey:(NSString *)key iv:(NSString *)iv;
- (NSData *)AES128DecryptedDataWithKey:(NSString *)key iv:(NSString *)iv;

/** Pads data using PKCS5. blockSize defaults to 16 if given 0. */
- (NSData *)pad:(NSUInteger)blockSize;

@end


@interface NSData (FileFormat)

@property (nonatomic, readonly) BOOL isJPEG;
@property (nonatomic, readonly) BOOL isPNG;
@property (nonatomic, readonly) BOOL isImage;
@property (nonatomic, readonly) BOOL isMPEG4;
@property (nonatomic, readonly) BOOL isMedia;
@property (nonatomic, readonly) BOOL isCompressed;

@end


@interface NSData (Encoding)

@property (nonatomic, readonly) NSString *base64URLEncodedString;
@property (nonatomic, readonly) NSString *MD5Hash;
@property (nonatomic, readonly) NSString *hexadecimalString;
@property (nonatomic, readonly) NSString *sha256Hash;

@end


@interface NSData (REST)
+ (NSData *)boundary:(NSString *)boundary withKey:(NSString *)key forStringValue:(NSString *)string;
+ (NSData *)boundary:(NSString *)boundary withKey:(NSString *)key forDataValue:(NSData *)data;
@end