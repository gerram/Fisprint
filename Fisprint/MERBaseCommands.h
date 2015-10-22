//
//  MERBaseCommands.h
//  Fisprint
//
//  Created by George Malushkin on 21/10/15.
//  Copyright © 2015 George Malushkin. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ESC     0x1B
#define MFB     0x80 // identifier of command beginning
#define MFE     0x83 // identifier of command end
#define MFB1    0x81 // identifier of code sequence beginning
#define MFB2    0x82 // identifier of code sequence end
#define SEP     0x00 // separator
#define LF      0x0A // separator

#define ESC_MFB ESC+MFB // start line
#define ESC_MFE (<#args#>)


@interface MERBaseCommands : NSObject

@end
