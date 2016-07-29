//
//  NSData+Networking.m
//  TBURLRequestOptions
//
//  Created by Tanner Bennett on 1/7/16.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "NSData+Networking.h"
#import "NSString+Networking.h"
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>
#import "TBResponseParser.h"


#pragma mark Encryption
@implementation NSData (Encryption)

- (NSData *)AES128EncryptedDataWithKey:(NSString *)key {
    return [self AES128EncryptedDataWithKey:key iv:nil];
}

- (NSData *)AES128DecryptedDataWithKey:(NSString *)key {
    return [self AES128DecryptedDataWithKey:key iv:nil];
}

- (NSData *)AES128EncryptedDataWithKey:(NSString *)key iv:(NSString *)iv {
    return [self AES128Operation:kCCEncrypt key:key iv:iv options:kCCOptionPKCS7Padding | kCCOptionECBMode];
}

- (NSData *)AES128DecryptedDataWithKey:(NSString *)key iv:(NSString *)iv {
    return [self AES128Operation:kCCDecrypt key:key iv:iv options:kCCOptionPKCS7Padding];
}

- (NSData *)AES128DecryptedDataWithKeyData:(NSData *)key ivData:(NSData *)iv {
    return [self AES128Operation:kCCDecrypt keyData:key ivData:iv options:kCCOptionPKCS7Padding];
}

- (NSData *)AES128Operation:(CCOperation)operation key:(NSString *)key iv:(NSString *)iv options:(uint32_t)options {
    return [[self pad:0] AES128Operation:operation keyData:[key dataUsingEncoding:NSUTF8StringEncoding] ivData:[iv dataUsingEncoding:NSUTF8StringEncoding] options:options];
}

// kCCModeCBC
- (NSData *)AES128Operation:(CCOperation)operation keyData:(NSData *)key ivData:(NSData *)iv options:(uint32_t)options {
    NSParameterAssert(key);
    
    size_t bufferSize = self.length + kCCKeySizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t decryptedLength = 0;
    CCCryptorStatus cryptStatus = CCCrypt(operation,
                                          kCCAlgorithmAES128,
                                          options,
                                          key.bytes,
                                          kCCKeySizeAES256,
                                          iv.bytes,
                                          self.bytes,
                                          self.length,
                                          buffer,
                                          bufferSize,
                                          &decryptedLength);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:decryptedLength];
    }
    
    free(buffer);
    return nil;
}

- (NSData *)pad:(NSUInteger)blockSize {
    NSMutableData *data = self.mutableCopy;
    if (blockSize == 0)
        blockSize = 16;
    
    NSUInteger count = (blockSize - (data.length % blockSize)) % blockSize;
    data.length = data.length + count;
    
    return data;
}

@end


#pragma mark FileFormat
@implementation NSData (FileFormat)

- (BOOL)isJPEG {
    uint8_t a, b, c, d;
    [self getHeader:&a b:&b c:&c d:&d];
    
    return a == 0xFF && b == 0xD8 && c == 0xFF && (d == 0xE0 || d == 0xE1 || d == 0xE8);
}

- (BOOL)isPNG {
    uint8_t a, b, c, d;
    [self getHeader:&a b:&b c:&c d:&d];
    
    return a == 0x89 && b == 0x50 && c == 0x4E && d == 0x47;
}

- (BOOL)isGIF {
    uint8_t a, b, c, d;
    [self getHeader:&a b:&b c:&c d:&d];
    
    return a == 0x47 && b == 0x49 && c == 0x46 && d == 0x38;
}

- (BOOL)isImage {
    return self.isJPEG || self.isPNG || self.isGIF;
}

- (BOOL)isStillImage {
    return self.isJPEG || self.isPNG;
}

- (BOOL)isMPEG4 {
    uint8_t a, b, c, d;
    [self getBytes:&a range:NSMakeRange(4, 1)];
    [self getBytes:&b range:NSMakeRange(5, 1)];
    [self getBytes:&c range:NSMakeRange(6, 1)];
    [self getBytes:&d range:NSMakeRange(7, 1)];
    
    return a == 0x66 && b == 0x74 && c == 0x79 && d == 0x70;
}

- (BOOL)isMedia {
    return self.isImage || self.isMPEG4;
}

- (BOOL)isCompressed {
    uint8_t a, b, c, d;
    [self getHeader:&a b:&b c:&c d:&d];
    
    return (a == 0x50 && b == 0x4B && c == 0x03 && d == 0x04) || // PK zip
    (a == 0x1F && b == 0x8B && c == 0x08) || // GZIP, GZ, TGZ
    (a == 0x1F && b == 0x9D) || (a == 0x1F && b == 0xA0) || // TAR.Z
    (a == 0x37 && b == 0x7A && c == 0xBC && d == 0xAF) || // 7z
    (a == 0x42 && b == 0x5A && c == 0x68); // bzip2
    
}

- (void)getHeader:(void *)a b:(void *)b c:(void *)c d:(void *)d {
    [self getBytes:a length:1];
    [self getBytes:b range:NSMakeRange(1, 1)];
    [self getBytes:c range:NSMakeRange(2, 1)];
    [self getBytes:d range:NSMakeRange(3, 1)];
}

- (NSString *)appropriateFileExtension {
    if (self.isJPEG) return @".jpg";
    if (self.isPNG) return @".png";
    if (self.isMPEG4) return @".mp4";
    if (self.isCompressed) return @".zip";
    return @".dat";
}

- (NSString *)contentType {
    if (self.isPNG) return TBContentType.PNG;
    if (self.isJPEG) return TBContentType.JPEG;
    if (self.isGIF) return TBContentType.GIF;
    if (self.isMPEG4) return TBContentType.MPEG4VideoGeneric;
    
    uint8_t a, b, c, d;
    [self getHeader:&a b:&b c:&c d:&d];
    
    if (a == 0x50 && b == 0x4B && c == 0x03 && d == 0x04) return TBContentType.ZIP;
    if (a == 0x1F && b == 0x8B && c == 0x08) return TBContentType.GZIP;
    
    return nil;
}

@end


#pragma mark Encoding
@implementation NSData (Encoding)

- (NSString *)base64URLEncodedString {
    NSString *str = [self base64EncodedStringWithOptions:0];
    
    str = [str stringByReplacingOccurrencesOfString:@"=" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"+" withString:@"-"];
    str = [str stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    
    return str;
}

- (NSString *)MD5Hash {
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5( self.bytes, (CC_LONG)self.length, result ); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];  
}

- (NSString *)hexadecimalString {
    const unsigned char *dataBuffer = (const unsigned char *)self.bytes;
    
    if (!dataBuffer)
        return [NSString string];
    
    NSUInteger      dataLength  = self.length;
    NSMutableString *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];
    
    for (int i = 0; i < dataLength; ++i)
        [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];
    
    return hexString;
}

- (NSString *)sha256Hash {
    unsigned char result[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(self.bytes, (unsigned int)self.length, result);
    
    NSMutableString *hash = [NSMutableString string];
    for(int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++)
        [hash appendFormat:@"%02x", result[i]];
    
    return hash;
}

@end


#pragma mark REST
@implementation NSData (REST)

+ (NSData *)boundary:(NSString *)boundary withKey:(NSString *)key forStringValue:(NSString *)string {
    NSMutableData *boundaryData = [NSMutableData data];
    [boundaryData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n%@", key, string] dataUsingEncoding:NSUTF8StringEncoding]];
    [boundaryData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    return boundaryData;
}

+ (NSData *)boundary:(NSString *)boundary withKey:(NSString *)key forDataValue:(NSData *)data {
    NSMutableData *boundaryData = [NSMutableData data];
    [boundaryData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", key, key] dataUsingEncoding:NSUTF8StringEncoding]];
    [boundaryData appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [boundaryData appendData:data];
    [boundaryData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    return boundaryData;
}

@end
