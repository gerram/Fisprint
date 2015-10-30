//
//  MERErrors.m
//  Fisprint
//
//  Created by George Malushkin on 23/10/15.
//  Copyright © 2015 George Malushkin. All rights reserved.
//

#import "MERErrors.h"

NSString * const MERDomainError = @"com.merann.fisprint.ErrorDomain";

@implementation MERErrors

+ (NSError *)errorWithCode:(NSInteger)code
                     title:(NSString *)title
               description:(NSString *)description
{
// TODO: To make userInfo dict
    NSDictionary *userInfo = @{};
    
    NSError *error = [NSError errorWithDomain:MERDomainError code:code userInfo:userInfo];
    
    return error;
}

@end
