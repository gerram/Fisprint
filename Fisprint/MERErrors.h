//
//  MERErrors.h
//  Fisprint
//
//  Created by George Malushkin on 23/10/15.
//  Copyright © 2015 George Malushkin. All rights reserved.
//

#import <Foundation/Foundation.h>
extern NSString * const MERDomainError;

@interface MERErrors : NSObject

+ (NSError *)errorWithCode:(NSInteger)code
                     title:(NSString *)title
               description:(NSString *)description;


@end
