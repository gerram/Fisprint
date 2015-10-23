//
//  MERSaleTransactionCommands.h
//  Fisprint
//
//  Created by George Malushkin on 21/10/15.
//  Copyright © 2015 George Malushkin. All rights reserved.
//

#import "MERBaseCommands.h"

@interface MERSaleTransactionCommands : MERBaseCommands

- (NSData *)openReceiptOrInvoce:(NSString *)invoceNumber
                          error:(NSError **)error;

- (NSData *)salesTransactionLine:(NSString *)itemName
                        comment1:(NSString *)comment1
                        comment2:(NSString *)comment2
                        comment3:(NSString *)comment3
                           error:(NSError **)error;

- (NSData *)discountComment:(NSString *)text
                      error:(NSError **)error;

- (NSData *)voidItemSale:(NSString *)itemName
                 comment:(NSString *)comment
                   value:(NSInteger)value
                     vat:(NSString *)vat
                   error:(NSError **)error;

- (NSData *)amountDiscountOrUpliftOnItemSale:(NSString *)itemName
                                          applyCorrect:(NSString *)apply_correct
                                       discountAplift:(NSString *)discount_uplift
                                       value:(NSNumber *)value
                                         vat:(NSString *)vat
                                       error:(NSError **)error;

- (NSData *)transactionSubtotal:(NSNumber *)subtotal
                          error:(NSError **)error;

- (NSData *)percentageDiscountOrUpliftOnSubtotal:(NSString *)discount_uplift
                                         percent:(NSString *)percent
                                           error:(NSError **)error;

- (NSData *)amountDiscountOrUpliftOnSubtotal:(NSString *)discount_uplift
                                    amountAG:(NSArray *)amountAG
                              correctionFlag:(NSString *)correctionFlag
                                 totalAmount:(NSNumber *)totalAmount
                                       error:(NSError **)error;

- (NSData *)readingDivisionOfDiscountOrUpliftAmountToSum:(NSString *)discount_uplift
                                                  amount:(NSNumber *)amount
                                                   error:(NSError **)error;

- (NSData *)transactionTotal:(NSNumber *)total
                       error:(NSError **)error;

//- (NSData *)receiptOrInvoiceFooter:(NSUInteger)index
//                         parameter:(NSUInteger)parameter;

@end
