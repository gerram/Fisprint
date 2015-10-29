//
//  MERPrinterDummy.h
//  Fisprint
//
//  Created by George Malushkin on 28/10/15.
//  Copyright © 2015 George Malushkin. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface MERPrinterDummy : NSObject

- (void)inputPrinter:(NSData *)request completion:(void (^) (NSData *response, NSError *error))completion;

@end
