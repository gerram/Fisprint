//
//  MERSaleTransactionCommands.h
//  Fisprint
//
//  Created by George Malushkin on 21/10/15.
//  Copyright © 2015 George Malushkin. All rights reserved.
//

#import "MERBaseCommands.h"

@interface MERSaleTransactionCommands : MERBaseCommands

- (NSData *)openReceiptOrInvoce:(NSString *)source;
- (NSData *)salesTransactionLine:(NSString *)source;
- (NSData *)discountComment:(NSString *)source;
- (NSData *)voidItemSale:(NSString *)source;
- (NSData *)amountDiscountOrUpliftOnItemSale:(NSString *)source;
- (NSData *)transactionSubtotal:(NSString *)source;
- (NSData *)percentageDiscountOrUpliftOnSubtotal:(NSString *)source;
- (NSData *)amountDiscountOrUpliftOnSubtotal:(NSString *)source;
- (NSData *)readingDivisionOfDiscountOrUpliftAmountToSum:(NSString *)source;
- (NSData *)transactionTotal:(NSString *)source;
- (NSData *)receiptOrInvoiceFooter:(NSString *)source;

@end
