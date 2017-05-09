//
//  WordModel.h
//  InsDict
//
//  Created by Realank on 2017/5/9.
//  Copyright © 2017年 Realank. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WordModel : NSObject

@property (nonatomic, strong, readonly)NSString* originalWord;
@property (nonatomic, strong, readonly)NSString* translatedWord;

+ (void)translateWord:(NSString*)word whenComplete:(void(^)(WordModel* word))completiongBlock;
@end
