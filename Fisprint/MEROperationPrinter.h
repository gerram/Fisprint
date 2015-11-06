//
//  MEROperationPrinter.h
//  Fisprint
//
//  Created by George Malushkin on 28/10/15.
//  Copyright © 2015 George Malushkin. All rights reserved.
//


#define OID001  @"QueryPrinterState"
#define OID002  @"OpenReceipt"
#define OID003  @"SalesTransactionLine"
#define OID004  @"TransactionTotal"
#define OID005  @"CancelReceipt"
#define OID006  @"EndSaleTransaction"

#import <Foundation/Foundation.h>
#import "MERPrinterDummy.h"
#import "PrinterDummyLink.h"


@interface MEROperationPrinter : NSOperation

@property (nonatomic, weak) id <PrinterDummyLink> delegate;

- (id)initWithData:(NSData *)data
     operationName:(NSString *)operationName
          delegate:(id<PrinterDummyLink>)delegate;

@end
