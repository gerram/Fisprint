//
//  MERSaleTransactionCommands.h
//  Fisprint
//
//  Created by George Malushkin on 21/10/15.
//  Copyright © 2015 George Malushkin. All rights reserved.
//

#import "MERBaseCommands.h"

@interface MERSaleTransactionCommands : MERBaseCommands

- (NSData *)openReceiptOrInvoce:(NSString *)invoceNumber;

- (NSData *)salesTransactionLine:(NSString *)itemName
                        comment1:(NSString *)comment1
                        comment2:(NSString *)comment2
                        comment3:(NSString *)comment3;

- (NSData *)discountComment:(NSString *)text;

- (NSData *)voidItemSale:(NSString *)itemName
                 comment:(NSString *)comment
                   value:(NSInteger)value
                     vat:(NSString *)vat;

- (NSData *)amountDiscountOrUpliftOnItemSale:(NSString *)itemName
                                          applyCorrect:(NSString *)apply_correct
                                       discountAplift:(NSString *)discount_uplift
                                       value:(NSNumber *)value
                                         vat:(NSString *)vat;

- (NSData *)transactionSubtotal:(NSNumber *)subtotal;

- (NSData *)percentageDiscountOrUpliftOnSubtotal:(NSString *)discount_uplift
                                         percent:(NSString *)percent;

- (NSData *)amountDiscountOrUpliftOnSubtotal:(NSString *)discount_uplift
                                    amountAG:(NSArray *)amountAG
                              correctionFlag:(NSString *)correctionFlag
                                 totalAmount:(NSNumber *)totalAmount;

- (NSData *)readingDivisionOfDiscountOrUpliftAmountToSum:(NSString *)discount_uplift
                                                  amount:(NSNumber *)amount;

- (NSData *)transactionTotal:(NSNumber *)total;

//- (NSData *)receiptOrInvoiceFooter:(NSUInteger)index
//                         parameter:(NSUInteger)parameter;

@end
