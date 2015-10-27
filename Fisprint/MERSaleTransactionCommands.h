//
//  MERSaleTransactionCommands.h
//  Fisprint
//
//  Created by George Malushkin on 21/10/15.
//  Copyright © 2015 George Malushkin. All rights reserved.
//

#import "MERBaseCommands.h"

@interface MERSaleTransactionCommands : MERBaseCommands

// 4.3.1 Open Receipt / Invoice
- (NSData *)openReceiptOrInvoce:(NSString *)invoceNumber
                          error:(NSError **)error;

// 4.3.2 Sales transaction line
- (NSData *)salesTransactionLine:(NSString *)itemName
                        comment1:(NSString *)comment1
                        comment2:(NSString *)comment2
                        comment3:(NSString *)comment3
                           value:(NSNumber *)value
                             vat:(NSString *)vat
                           error:(NSError **)error;

// 4.3.3 Discount comment
- (NSData *)discountComment:(NSString *)text
                      error:(NSError **)error;

// 4.3.4 Void item sale
- (NSData *)voidItemSale:(NSString *)itemName
                 comment:(NSString *)comment
                   value:(NSInteger)value
                     vat:(NSString *)vat
                   error:(NSError **)error;

// 4.3.5 Amount discount or uplift on item sale
- (NSData *)amountDiscountOrUpliftOnItemSale:(NSString *)itemName
                                          applyCorrect:(NSString *)apply_correct
                                       discountAplift:(NSString *)discount_uplift
                                       value:(NSNumber *)value
                                         vat:(NSString *)vat
                                       error:(NSError **)error;

// 4.3.6 Transaction Subtotal
- (NSData *)transactionSubtotal:(NSNumber *)subtotal
                          error:(NSError **)error;

// 4.3.7 Percentage discount or uplift on subtotal.
- (NSData *)percentageDiscountOrUpliftOnSubtotal:(NSString *)discount_uplift
                                         percent:(NSString *)percent
                                           error:(NSError **)error;

// 4.3.8 Amount Discount / Uplift On Subtotal
- (NSData *)amountDiscountOrUpliftOnSubtotal:(NSString *)discount_uplift
                                    amountAG:(NSArray *)amountAG
                              correctionFlag:(NSString *)correctionFlag
                                 totalAmount:(NSNumber *)totalAmount
                                       error:(NSError **)error;

// 4.3.9 Reading division of discount/uplift amount to sum
- (NSData *)readingDivisionOfDiscountOrUpliftAmountToSum:(NSString *)discount_uplift
                                                  amount:(NSNumber *)amount
                                                   error:(NSError **)error;

// 4.3.10 Transaction total
- (NSData *)transactionTotal:(NSNumber *)total
                       error:(NSError **)error;

//- (NSData *)receiptOrInvoiceFooter:(NSUInteger)index
//                         parameter:(NSUInteger)parameter;

@end
