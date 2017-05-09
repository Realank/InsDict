//
//  WordModel.m
//  InsDict
//
//  Created by Realank on 2017/5/9.
//  Copyright © 2017年 Realank. All rights reserved.
//

#import "WordModel.h"
#import <AFNetworking.h>
@implementation WordModel

+(NSString *)URLSymbolConvert:(NSString *)srcStr
{
    if(srcStr.length){
        NSString *charactersToEscape = @"\n?!@#$^&%*+,:;='\"`<>()[]{}/\\| ";
        NSCharacterSet *allowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:charactersToEscape] invertedSet];
        NSString *encodedUrl = [srcStr stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
        return [encodedUrl copy];
    }
    return @"";
}


+ (void)translateWord:(NSString*)word whenComplete:(void(^)(WordModel* word))completiongBlock{
    if (word.length == 0) {
        if (completiongBlock) {
            completiongBlock(nil);
        }
        return;
    }
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSString* requestUrlString = [NSString stringWithFormat:@"https://translation.googleapis.com/language/translate/v2?key=%@&target=zh&q=%@",@"AIzaSyB3b91n5jZHKLdBsy-o83ws5ao4lZsCaZI",[self URLSymbolConvert:word]];
//    NSString* requestUrlString = [NSString stringWithFormat:@"https://translation.googleapis.com/language/translate/v2?key=%@&target=zh&q=%@&model=nmt",@"AIzaSyB3b91n5jZHKLdBsy-o83ws5ao4lZsCaZI",word];
    NSURL *URL = [NSURL URLWithString:requestUrlString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    [[manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            NSLog(@"error %@",error);
            if (completiongBlock) {
                completiongBlock(nil);
            }
        }else{
            NSLog(@"result %@",responseObject);
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                NSDictionary* data = responseObject[@"data"];
                if ([data isKindOfClass:[NSDictionary class]]) {
                    NSArray* translations = data[@"translations"];
                    if ([translations isKindOfClass:[NSArray class]] && translations.count){
                        NSDictionary* trans = translations[0];
                        NSString* transText = trans[@"translatedText"];
                        if (transText.length) {
                            WordModel* newWord = [[WordModel alloc] init];
                            newWord->_originalWord = word;
                            newWord->_translatedWord = transText;
                            if (completiongBlock) {
                                completiongBlock(newWord);
                            }
                            return;
                        }
                    }
                }
            }
            if (completiongBlock) {
                completiongBlock(nil);
            }
        }
    }] resume];
}

@end
