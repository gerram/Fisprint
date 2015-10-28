//
//  MERPrinterDummy.m
//  Fisprint
//
//  Created by George Malushkin on 28/10/15.
//  Copyright © 2015 George Malushkin. All rights reserved.
//

#import "MERPrinterDummy.h"

@implementation MERPrinterDummy

+ (NSData *)inputPrinter:(NSData *)request
{
    NSData *output = [NSData dataWithBytes:(int *)0x06 length:1];
    
    double delay = logf(arc4random() % 100);
    
    
    return output;
}

@end
