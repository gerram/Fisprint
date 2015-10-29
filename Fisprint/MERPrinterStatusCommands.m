//
//  MERPrinterStatusCommands.m
//  Fisprint
//
//  Created by George Malushkin on 29/10/15.
//  Copyright © 2015 George Malushkin. All rights reserved.
//

#import "MERPrinterStatusCommands.h"
#import "MERErrors.h"

@implementation MERPrinterStatusCommands

- (NSData *)queryPrinterExtendedStatus
{
    /*
     Format:
     ESC + 0x0C
     Answer:
     ESC r MSB LSB <data>
     where:
     <data> = <fiscal module status> <printer status>
     */
    
    NSMutableData *resultData = [[NSMutableData alloc] init];
    
    char chESC = ESC;
    [resultData appendBytes:&chESC length:1];
    
    char chPLUS = PLUS;
    [resultData appendBytes:&chPLUS length:1];
    
    char chFF = 0x0C;
    [resultData appendBytes:&chFF length:1];
    
    return resultData;
}

@end
