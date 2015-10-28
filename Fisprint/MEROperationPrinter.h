//
//  MEROperationPrinter.h
//  Fisprint
//
//  Created by George Malushkin on 28/10/15.
//  Copyright © 2015 George Malushkin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MERPrinterDummy.h"

@protocol PrinterDummyLink <NSObject>
- (void)finishedWithError:(NSError *)nameOperation;
@end

@interface MEROperationPrinter : NSOperation

@property (nonatomic, weak) id <PrinterDummyLink> delegate;

@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) MERPrinterDummy *printerDummy;
@end
