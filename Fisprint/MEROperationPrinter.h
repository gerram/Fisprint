//
//  MEROperationPrinter.h
//  Fisprint
//
//  Created by George Malushkin on 28/10/15.
//  Copyright © 2015 George Malushkin. All rights reserved.
//


#define OID001  @"QueryPrinterState"
#define OID002  @"QueryChangePrinterStateToFiscal"

#import <Foundation/Foundation.h>
#import "MERPrinterDummy.h"

@protocol PrinterDummyLink <NSObject>
- (void)operationResponse:(NSData *)data
                WithError:(NSError *)error
             forOperation:(NSString *)nameOperation;
@end

@interface MEROperationPrinter : NSOperation

@property (nonatomic, weak) id <PrinterDummyLink> delegate;

@property (nonatomic, strong) NSData *data;

- (id)initWithData:(NSData *)data
     operationName:(NSString *)operationName
          delegate:(id<PrinterDummyLink>)delegate;

@end
