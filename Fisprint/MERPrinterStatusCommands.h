//
//  MERPrinterStatusCommands.h
//  Fisprint
//
//  Created by George Malushkin on 29/10/15.
//  Copyright © 2015 George Malushkin. All rights reserved.
//

#import "MERBaseCommands.h"

@interface MERPrinterStatusCommands : MERBaseCommands
- (NSData *)queryPrinterExtendedStatus;
@end
