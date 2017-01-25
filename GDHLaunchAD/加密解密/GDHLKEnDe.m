//
//  GDHLKEnDe.m
//  GDHChatTest
//
//  Created by 高得华 on 16/12/24.
//  Copyright © 2016年 GaoFei. All rights reserved.
//

#import "GDHLKEnDe.h"
#import <CommonCrypto/CommonDigest.h>
#import "NSData+Base64.h"
#import "NSString+Base64.h"
#import "NSData+CommonCrypto.h"
#import <Security/Security.h>

@interface GDHLKEnDe ()

@property (assign, nonatomic) SecKeyRef publicKey;
@property (assign, nonatomic) SecKeyRef privateKey;

@end

@implementation GDHLKEnDe

/**
 单例
 
 @return GDHLKEnDe对象
 */
+ (GDHLKEnDe *)ShareGDHLKEnDe {
    static GDHLKEnDe * share = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        share = [[GDHLKEnDe alloc] init];
    });
    return share;
}

#pragma - ========= MD5加密 ==============
/**
 MD5加密
 
 @param type 机密类型
 @param srcString 需要加密的字符串
 @param capital 是否大写
 @return MD5加密之后的字符串
 */
+ (NSString *)MD5_GDHTYPE:(GDHMD5TYPE)type
               encryption:(NSString *)srcString
                  capital:(BOOL)capital {
    if (type == GDHMD5TYPE_16Bit || type == GDHMD5TYPE_32Bit) {//常规加密
        const char *cStr = [srcString UTF8String];
        unsigned char digest[CC_MD5_DIGEST_LENGTH];
        CC_MD5(cStr, (uint32_t)strlen(cStr), digest);
        NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
        for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
            [result appendFormat:@"%02x", digest[i]];
        if (type == GDHMD5TYPE_32Bit) {//32位加密
            return capital ? [result uppercaseString]:result;
        }else{//16位加密
            //提取32位MD5散列的中间16位 //即9～25位
            NSString * result16 = [[result substringToIndex:24] substringFromIndex:8];
            return capital ? [result16 uppercaseString]:result16;
        }
    }else{
        const char *cstr = [srcString cStringUsingEncoding:NSUTF8StringEncoding];
        NSData *data = [NSData dataWithBytes:cstr length:srcString.length];

        NSMutableString* result;
        if (type == GDHMD5TYPE_Sha1) {
            uint8_t digest[CC_SHA1_DIGEST_LENGTH];
            CC_SHA1(data.bytes, (uint32_t)data.length, digest);
            result = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
            for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
                [result appendFormat:@"%02x", digest[i]];
            }
        }else if (type == GDHMD5TYPE_Sha256) {
            uint8_t digest[CC_SHA256_DIGEST_LENGTH];
            CC_SHA256(data.bytes, (uint32_t)data.length, digest);
            result = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
            for(int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
                [result appendFormat:@"%02x", digest[i]];
            }
        }else if (type == GDHMD5TYPE_Sha384) {
            uint8_t digest[CC_SHA384_DIGEST_LENGTH];
            CC_SHA384(data.bytes, (uint32_t)data.length, digest);
            result = [NSMutableString stringWithCapacity:CC_SHA384_DIGEST_LENGTH * 2];
            for(int i = 0; i < CC_SHA384_DIGEST_LENGTH; i++) {
                [result appendFormat:@"%02x", digest[i]];
            }
        }else if (type == GDHMD5TYPE_Sha512) {
            uint8_t digest[CC_SHA512_DIGEST_LENGTH];
            CC_SHA512(data.bytes, (uint32_t)data.length, digest);
            result = [NSMutableString stringWithCapacity:CC_SHA512_DIGEST_LENGTH * 2];
            for(int i = 0; i < CC_SHA512_DIGEST_LENGTH; i++) {
                [result appendFormat:@"%02x", digest[i]];
            }
        }
        return capital ? [result uppercaseString]:result;
    }
}

#pragma mark - ========= AES ================

/**
 AES加密解密
 
 @param type GDHAESTYPE_EN:加密 GDHAESTYPE_DE:解密
 @param message 需要加密/解密字符串
 @param password 密码
 @return 加密字符串/解密字符串
 */
+ (NSString *)AES_GDHTYPE:(GDHAESTYPE)type
                  message:(NSString *)message
                 password:(NSString *)password {
    if (type == GDHAESTYPE_EN) {//加密
        NSData *encryptedData = [[message dataUsingEncoding:NSUTF8StringEncoding] AES256EncryptedDataUsingKey:[[password dataUsingEncoding:NSUTF8StringEncoding] SHA256Hash] error:nil];
        NSString *base64EncodedString = [NSString base64StringFromData:encryptedData length:[encryptedData length]];
        return base64EncodedString;
    }else if (type == GDHAESTYPE_DE){//解密
        NSData *encryptedData = [NSData base64DataFromString:message];
        NSData *decryptedData = [encryptedData decryptedAES256DataUsingKey:[[password dataUsingEncoding:NSUTF8StringEncoding] SHA256Hash] error:nil];
        return [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
    }else{
        return @"暂无法解密或加密";
    }
}

#pragma mark - ========= RSA ================

//设置公钥
- (void)setPublic_key:(NSString *)public_key
{
    NSData *data = [public_key base64DecodedData];
    SecCertificateRef myCertificate = SecCertificateCreateWithData(kCFAllocatorDefault, (__bridge CFDataRef)data);
    SecPolicyRef myPolicy = SecPolicyCreateBasicX509();
    SecTrustRef myTrust;
    OSStatus status = SecTrustCreateWithCertificates(myCertificate,myPolicy,&myTrust);
    SecTrustResultType trustResult;
    if (status == noErr) {
        status = SecTrustEvaluate(myTrust, &trustResult);
    }
    SecKeyRef securityKey = SecTrustCopyPublicKey(myTrust);
    CFRelease(myCertificate);
    CFRelease(myPolicy);
    CFRelease(myTrust);
    self.publicKey = securityKey;
}

//设置私钥
+ (void)loadPrivate_key:(NSString *)private_key password:(NSString *)password
{
    NSData *p12Data = [private_key base64DecodedData];
    SecKeyRef privateKeyRef = NULL;
    NSMutableDictionary * options = [[NSMutableDictionary alloc] init];
    [options setObject: password forKey:(__bridge id)kSecImportExportPassphrase];
    CFArrayRef items = CFArrayCreate(NULL, 0, 0, NULL);
    OSStatus securityError = SecPKCS12Import((__bridge CFDataRef) p12Data, (__bridge CFDictionaryRef)options, &items);
    if (securityError == noErr && CFArrayGetCount(items) > 0) {
        CFDictionaryRef identityDict = CFArrayGetValueAtIndex(items, 0);
        SecIdentityRef identityApp = (SecIdentityRef)CFDictionaryGetValue(identityDict, kSecImportItemIdentity);
        securityError = SecIdentityCopyPrivateKey(identityApp, &privateKeyRef);
        if (securityError != noErr) {
            privateKeyRef = NULL;
        }
    }
    CFRelease(items);
    [GDHLKEnDe ShareGDHLKEnDe].privateKey = privateKeyRef;
}


/**
 RSA加密解密
 
 @param type GDHRSATYPE_EN:加密 GDHRSATYPE_DE:解密
 @param message 需要加密/解密字符串
 @return 加密字符串/解密字符串
 */
+ (NSString *)RSA_GDHTYPE:(GDHRSATYPE)type
                  message:(NSString *)message {
    if (type == GDHRSATYPE_EN) {//加密
        NSData* data = [message dataUsingEncoding:NSUTF8StringEncoding];
        NSData* encryptedData = [[GDHLKEnDe ShareGDHLKEnDe] rsaEncryptData: data];
        NSString* base64EncryptedString = [encryptedData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
        return base64EncryptedString;
    }else if (type == GDHRSATYPE_DE) {//解密
        NSData* data = [[NSData alloc] initWithBase64EncodedString:message options:0];
        NSData* decryptData = [[GDHLKEnDe ShareGDHLKEnDe] rsaDecryptData: data];
        NSString* result = [[NSString alloc] initWithData: decryptData encoding:NSUTF8StringEncoding];
        return result;
    }else{
        return @"暂无法解密或加密";
    }
}


#pragma mark - ================ 辅助函数 ================
// 加密的大小受限于SecKeyEncrypt函数，SecKeyEncrypt要求明文和密钥的长度一致，如果要加密更长的内容，需要把内容按密钥长度分成多份，然后多次调用SecKeyEncrypt来实现
- (NSData*) rsaEncryptData:(NSData*)data {
    SecKeyRef key = self.publicKey;
    size_t cipherBufferSize = SecKeyGetBlockSize(key);
    uint8_t *cipherBuffer = malloc(cipherBufferSize * sizeof(uint8_t));
    size_t blockSize = cipherBufferSize - 11;       // 分段加密
    size_t blockCount = (size_t)ceil([data length] / (double)blockSize);
    NSMutableData *encryptedData = [[NSMutableData alloc] init] ;
    for (int i=0; i<blockCount; i++) {
        NSInteger bufferSize = MIN(blockSize,[data length] - i * blockSize);
        NSData *buffer = [data subdataWithRange:NSMakeRange(i * blockSize, bufferSize)];
        OSStatus status = SecKeyEncrypt(key, kSecPaddingPKCS1, (const uint8_t *)[buffer bytes], [buffer length], cipherBuffer, &cipherBufferSize);
        if (status == noErr){
            NSData *encryptedBytes = [[NSData alloc] initWithBytes:(const void *)cipherBuffer length:cipherBufferSize];
            [encryptedData appendData:encryptedBytes];
        }else{
            if (cipherBuffer) {
                free(cipherBuffer);
            }
            return nil;
        }
    }
    if (cipherBuffer){
        free(cipherBuffer);
    }
    return encryptedData;
}

- (NSData*) rsaDecryptData:(NSData*)data {
    SecKeyRef key = self.privateKey;
    size_t cipherLen = [data length];
    void *cipher = malloc(cipherLen);
    [data getBytes:cipher length:cipherLen];
    size_t plainLen = SecKeyGetBlockSize(key) - 12;
    void *plain = malloc(plainLen);
    OSStatus status = SecKeyDecrypt(key, kSecPaddingPKCS1, cipher, cipherLen, plain, &plainLen);
    
    if (status != noErr) {
        return nil;
    }
    
    NSData *decryptedData = [[NSData alloc] initWithBytes:(const void *)plain length:plainLen];
    
    return decryptedData;
}


@end
