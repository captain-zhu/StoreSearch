//
//  Search.h
//  StoreSearch
//
//  Created by zhu yongxuan on 15/9/10.
//  Copyright (c) 2015年 zhu yongxuan. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^SearchBlock)(BOOL sucess);
@interface Search : NSObject

@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, readonly, strong) NSMutableArray *searchResults;

- (void)performSearchForText:(NSString *)text
                    category:(NSInteger)category
                  completion:(SearchBlock)block;

@end
