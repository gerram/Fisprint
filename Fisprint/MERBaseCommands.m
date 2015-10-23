//
//  MERBaseCommands.m
//  Fisprint
//
//  Created by George Malushkin on 21/10/15.
//  Copyright © 2015 George Malushkin. All rights reserved.
//

#import "MERBaseCommands.h"

@interface MERBaseCommands ()
//@property (nonatomic, strong) NSArray *argumentCharsSet;
@end

@implementation MERBaseCommands


#pragma mark - Combinations
- (NSData *)prefixLineData
{
    int esc = ESC;
    NSMutableData *line = [NSMutableData dataWithBytes:&esc length:sizeof(esc)];
    int mfb = MFB;
    [line appendBytes:&mfb length:sizeof(mfb)];
    
    return line;
}

- (NSData *)postfixLineData
{
    int esc = ESC;
    NSMutableData *line = [NSMutableData dataWithBytes:&esc length:sizeof(esc)];
    int mfe = MFE;
    [line appendBytes:&mfe length:sizeof(mfe)];
    
    return line;
}

- (NSData *)returnLineData
{
    int lf = LF;
    NSMutableData *line = [NSMutableData dataWithBytes:&lf length:sizeof(lf)];
    int cr = CR;
    [line appendBytes:&cr length:sizeof(cr)];
    
    return line;
}


/*
- (NSArray *)argumentCharsSet
{
    if (!_argumentCharsSet) {
#pragma TODO: +Capital Letters (CP852), +digits,
        _argumentCharsSet = @[
                              @0x20, @0x21, @0x22, @0x23, @0x24, @0x25, @0x26, @0x27, @0x28,
                              @0x29, @0x2A, @0x2B, @0x2C, @0x2D, @0x2E, @0x2F,
                              @0x3A, @0x3B
                              ];
    }
    return _argumentCharsSet;
}
 */

@end
