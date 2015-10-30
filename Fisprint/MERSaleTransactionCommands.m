//
//  MERSaleTransactionCommands.m
//  Fisprint
//
//  Created by George Malushkin on 21/10/15.
//  Copyright © 2015 George Malushkin. All rights reserved.
//

#import "MERSaleTransactionCommands.h"
#import "MERErrors.h"

@implementation MERSaleTransactionCommands



- (NSData *)openReceiptOrInvoce:(NSString *)invoceNumber
                          error:(NSError *__autoreleasing *)error
{
    /*
    4.3.1 Open Receipt / Invoice
    Format:
    ESC MFB C [<invoice_number>] ESC MFE
    Example:
    ESC MFB 'C' ESC MFE
    ACK
     */
    
    
#pragma TODO: !!! check via right parser (invoceNumber)
    // 1. check
    /*
    NSData *tmp = [invoceNumber dataUsingEncoding:NSASCIIStringEncoding];
    for (int i = 0; i <= tmp.length; i++) {
        char buffer;
        [tmp getBytes:&buffer range:NSMakeRange(i, 1)];
        //NSLog(@"%d", (int)buffer);
    }
     */
    
    
    NSMutableData *resultData = [[NSMutableData alloc] init];
    [resultData appendData:[super prefixLineData]];
    
    char chC = 0x43;
    [resultData appendBytes:&chC length:sizeof(1)]; // 'C'
    
    if (invoceNumber) {
        [resultData appendBytes:&invoceNumber length:sizeof(resultData)];
    }
    
    [resultData appendData:[self postfixLineData]];
    
    return resultData;
}


- (NSData *)salesTransactionLine:(NSString *)itemName
                        comment1:(NSString *)comment1
                        comment2:(NSString *)comment2
                        comment3:(NSString *)comment3
                           value:(NSNumber *)value
                             vat:(NSString *)vat
                           error:(NSError *__autoreleasing *)error
{
    /*
    4.3.2 Sales transaction line
    Format:
    ESC MFB D <item name> 0x00 <comment1> LF CR <comment2> LF CR <comment3> ESC MFB1 a <value> ESC MFB2 <VAT> ESC MFE
    or
    ESC MFB D <item name> 0x0A <comment1> LF CR <comment2> LF CR <comment3> ESC MFB1 a <value> ESC MFB2 <VAT> ESC MFE
    Example:
    ESC MFB 'DTOWAR-A' NUL '1 szt * 10.00 zl' LF CR 'komentarz 2' LF CR 'komentarz 3' ESC MFB1 'a10.00' ESC MFB2 'A' ESC MFE
    ACK
    ESC MFB 'DTOWAR-A' NUL '1 szt * 10.00 zl' LF CR 'rabat 1.99' LF CR 'komentarz 3' ESC MFB1 'a8.01' ESC MFB2 'A' ESC MFE
    ACK
    ESC MFB 'DTOWAR-A' NUL '0,9999 szt * 100.00 zl' LF CR 'rabat 1.99' LF CR 'komentarz 3' ESC MFB1 'a98.00' ESC MFB2 'A' ESC MFE
    ACK
     */
    
    NSMutableData *resultData = [[NSMutableData alloc] init];
    [resultData appendData:[self prefixLineData]];
    
    char chD = 0x44;
    [resultData appendBytes:&chD length:sizeof(1)]; // 'D'
    
    [resultData appendBytes:&itemName length:sizeof(itemName)];
    
    char chA = 0x41;
    [resultData appendBytes:&chA length:sizeof(1)];
    [resultData appendBytes:&comment1 length:sizeof(comment1)];
    [resultData appendData:[self returnLineData]];
    
    [resultData appendBytes:&comment2 length:sizeof(comment2)];
    [resultData appendData:[self returnLineData]];
    
    [resultData appendBytes:&comment3 length:sizeof(comment3)];
    [resultData appendData:[self escmfb1LineData]];
    
    char cha = 0x61;
    [resultData appendBytes:&cha length:1]; // 'a'
    [resultData appendBytes:&value length:sizeof(value)];
    [resultData appendData:[self escmfb2LineData]];
    
    [resultData appendBytes:&vat length:sizeof(vat)];
    
    [resultData appendData:[self postfixLineData]];
    
    return resultData;
}


- (NSData *)discountComment:(NSString *)text
                      error:(NSError *__autoreleasing *)error
{
    /*
    4.3.3 Discount comment
    Format:
    ESC MFB S <text> ESC MFE
    Example:
    ESC MFB 'S' SP 'świąteczny 10.00' ESC MFE
    ACK
     */
    
    NSMutableData *resultData = [[NSMutableData alloc] init];
    [resultData appendData:[self prefixLineData]];
    
    char chS = 0x53;
    [resultData appendBytes:&chS length:sizeof(1)]; // S
    char chSP = 0x20;
    [resultData appendBytes:&chSP length:1]; // SP
    [resultData appendBytes:&text length:sizeof(text)];
    
    [resultData appendData:[self postfixLineData]];
    
    return resultData;
}


- (NSData *)voidItemSale:(NSString *)itemName
                 comment:(NSString *)comment
                   value:(NSInteger)value
                     vat:(NSString *)vat
                   error:(NSError *__autoreleasing *)error
{
   /*
   4.3.4 Void item sale
   Format:
   ESC MFB D <item name> 0x00 <comment> ESC MFB1 c <value> ESC MFB2 <VAT> ESC MFE
   Example:
   ESC MFB 'DTOWAR-A' NUL '1' SP 'szt' SP '*' SP '1.00' SP 'zl' ESC MFB1 'c-1.00' ESC MFB2 'A' ESC MFE
   ACK
    */
    
    
    NSMutableData *resultData = [[NSMutableData alloc] init];
    [resultData appendData:[self prefixLineData]];
    
    char chD = 0x44;
    [resultData appendBytes:&chD length:1]; // 'D'
    [resultData appendBytes:&itemName length:sizeof(itemName)];
    char ch00 = 0x00;
    [resultData appendBytes:&ch00 length:1]; // NULL
    
    [resultData appendBytes:&comment length:sizeof(comment)];
    [resultData appendData:[self escmfb1LineData]];
    
    char chc = 0x63;
    [resultData appendBytes:&chc length:1]; // 'c'
    [resultData appendBytes:&value length:sizeof(value)];
    [resultData appendData:[self escmfb2LineData]];
    
    [resultData appendBytes:&vat length:1];
    
    [resultData appendData:[self postfixLineData]];
    
    return resultData;
}


- (NSData *)amountDiscountOrUpliftOnItemSale:(NSString *)itemName
                                applyCorrect:(NSString *)apply_correct
                              discountAplift:(NSString *)discount_uplift
                                       value:(NSNumber *)value
                                         vat:(NSString *)vat
                                       error:(NSError *__autoreleasing *)error
{
   /*
   4.3.5 Amount discount or uplift on item sale
   Format:
   ESC MFB d <item name> 0x00 <a-apply | c-correct> ESC MFB1 <A-discount | U – uplift> <value> ESC MFB2 <VAT> ESC MFE
   Example:
   ESC MFB 'dTOWAR-A' NUL 'a' ESC MFB1 'A0.10' ESC MFB2 'A' ESC MFE
   ACK
   ESC MFB 'dTOWAR-A' NUL 'c' ESC MFB1 'A0.10' ESC MFB2 'A' ESC MFE
   ACK
    */
    
    NSMutableData *resultData = [[NSMutableData alloc] init];
    [resultData appendData:[self prefixLineData]];
   
    char chd = 0x64;
    [resultData appendBytes:&chd length:1]; // 'd'
    [resultData appendBytes:&itemName length:sizeof(itemName)];
    char ch00 = 0x00;
    [resultData appendBytes:&ch00 length:1]; // NULL
    
    [resultData appendBytes:&apply_correct length:sizeof(apply_correct)];
    [resultData appendData:[self escmfb1LineData]];
    
    [resultData appendBytes:&discount_uplift length:sizeof(discount_uplift)];
    [resultData appendBytes:&value length:sizeof(value)];
    [resultData appendData:[self escmfb2LineData]];
    
    [resultData appendBytes:&vat length:sizeof(vat)];
    
    [resultData appendData:[self postfixLineData]];
    
    return resultData;
}


- (NSData *)transactionSubtotal:(NSNumber *)subtotal
                          error:(NSError *__autoreleasing *)error
{
    /*
    4.3.6 Transaction Subtotal
    Format:
    ESC MFB Q ESC MFB1 <subtotal> ESC MFE
    Example:
    ESC MFB 'Q' ESC MFB1 '125,00' ESC MFE
    ACK
     */
    
    NSMutableData *resultData = [[NSMutableData alloc] init];
    [resultData appendData:[self prefixLineData]];
    
    char chQ = 0x51;
    [resultData appendBytes:&chQ length:1]; // 'Q'
    [resultData appendData:[self escmfb1LineData]];
    
    [resultData appendBytes:&subtotal length:1];
    
    [resultData appendData:[self postfixLineData]];
    
    return resultData;
}


- (NSData *)percentageDiscountOrUpliftOnSubtotal:(NSString *)discount_uplift
                                         percent:(NSString *)percent
                                           error:(NSError *__autoreleasing *)error
{
    /*
    4.3.7 Percentage discount or uplift on subtotal.
    Format:
    ESC MFB F <A-discount | U-uplift> ESC MFB1 <percent> ESC MFE
    Example:
    ESC MFB 'FA' ESC MFB1 '10.00%' ESC MFE
    ACK
     */
    
    NSMutableData *resultData = [[NSMutableData alloc] init];
    [resultData appendData:[self prefixLineData]];
    
    char chF = 0x46;
    [resultData appendBytes:&chF length:1]; // 'F'
    [resultData appendBytes:&discount_uplift length:sizeof(discount_uplift)];
    [resultData appendData:[self escmfb1LineData]];
    
    [resultData appendBytes:&percent length:sizeof(percent)];
    
    [resultData appendData:[self postfixLineData]];
    
    return resultData;
}


- (NSData *)amountDiscountOrUpliftOnSubtotal:(NSString *)discount_uplift
                                    amountAG:(NSArray *)amountAG
                              correctionFlag:(NSString *)correctionFlag
                                 totalAmount:(NSNumber *)totalAmount
                                       error:(NSError *__autoreleasing *)error
{
    /*
    4.3.8 Amount Discount / Uplift On Subtotal
    Format:
    ESC MFB f <A-discount | U-uplift> ESC MFB1 [<amount_A> LF ... <amount_G> ESC MFB2] <correction flag> <total amount> ESC MFE
    Or
    ESC MFB f <A-discount | U-uplift> ESC MFB1 <correction flag> <total amount> ESC MFE
    Example:
    ESC MFB 'fA' ESC MFB1 '84.25' LF '84.25' LF '84.25' LF '0.00' LF '0.00' LF '0.00' LF '84.25' ESC MFB2 'a337.00' ESC MFE
    ACK
    ESC MFB 'fa' ESC MFB1 'a337.00' ESC MFE
    ACK
     */
    NSMutableData *resultData = [[NSMutableData alloc] init];
    [resultData appendData:[self prefixLineData]];
    
    char chf = 0x66;
    [resultData appendBytes:&chf length:1]; // 'f'
    [resultData appendBytes:&discount_uplift length:sizeof(discount_uplift)];
    [resultData appendData:[self escmfb1LineData]];
    
    for (NSString *amount in amountAG) {
        [resultData appendBytes:&amount length:sizeof(amount)];
        if (amount == [amountAG lastObject]) {
            [resultData appendData:[self escmfb2LineData]];
        } else {
            char chLF = 0x0A;
            [resultData appendBytes:&chLF length:1]; // LF
        }
    }
    
    [resultData appendBytes:&correctionFlag length:sizeof(correctionFlag)];
    [resultData appendBytes:&totalAmount length:sizeof(totalAmount)];
    
    [resultData appendData:[self postfixLineData]];
    
    return resultData;
}


- (NSData *)readingDivisionOfDiscountOrUpliftAmountToSum:(NSString *)discount_uplift
                                                  amount:(NSNumber *)amount
                                                   error:(NSError *__autoreleasing *)error
{
    /*
    4.3.9 Reading division of discount/uplift amount to sum
    Format:
    ESC MFB 'Ld' <A-discount/U-uplift> <amount> ESC MFE
    Example:
    ESC MFB 'LdA' '0.10' ESC MFE
    ACK
    ESC 'r' NUL 0x23 '0,07' LF '0,03' LF '0,00' LF '0,00' LF '0,00' LF '0,00' LF '0,00' LF
    ACK
     */
    
    NSMutableData *resultData = [[NSMutableData alloc] init];
    [resultData appendData:[self prefixLineData]];
    
    NSString *Ld = @"Ld";
    [resultData appendBytes:&Ld length:sizeof(Ld)];
    [resultData appendBytes:&discount_uplift length:sizeof(discount_uplift)];
    [resultData appendBytes:&amount length:sizeof(amount)];
    
    [resultData appendData:[self postfixLineData]];
    
    return resultData;
}


- (NSData *)transactionTotal:(NSNumber *)total
                       error:(NSError *__autoreleasing *)error
{
    /*
    4.3.10 Transaction total
    Format:
    ESC MFB T ESC MFB1 a <total> ESC MFE
    Example:
    ESC MFB 'T' ESC MFB1 'a128,00' ESC MFE
    ACK
     */
    
    NSMutableData *resultData = [[NSMutableData alloc] init];
    [resultData appendData:[self prefixLineData]];
    
    char chT = 0x54;
    [resultData appendBytes:&chT length:1]; // 'T'
    [resultData appendData:[self escmfb1LineData]];
    
    char cha = 0x61;
    [resultData appendBytes:&cha length:1]; // 'a'
    [resultData appendBytes:&total length:sizeof(total)];
    
    [resultData appendData:[self postfixLineData]];
    
    return resultData;
}

//- (NSData *)receiptOrInvoiceFooter:(NSString *)source
//{
//    /*
//    4.3.11 Receipt / Invoice footer
//    Format:
//    ESC MFB R ['+'] <index> <parameter> [LF <parameter>] ESC MFE
//    Example:
//    ESC MFB 'RA100.00' ESC MFE
//    ACK
//    ESC MFB 'RB99.00' ESC MFE
//    ACK
//    ESC MFB 'RyZapraszamy ponownie !' ESC MFE
//    ACK
//     */
//    
//}


//- (NSData *)cancelReceiptOrVatInvoice:(NSNumber *)total
- (NSData *)cancelReceiptOrVatInvoice
{
    /*
    4.3.15 Cancel receipt or VAT invoice
    Format:
    ESC MFB T ESC MFB1 c [total] ESC MFE
    Example:
    ESC MFB 'T' ESC MFB1 'c' ESC MFE
    ACK
     */
    
    NSMutableData *resultData = [[NSMutableData alloc] init];
    [resultData appendData:[self prefixLineData]];
    
    char chT = 0x54;
    [resultData appendBytes:&chT length:1]; // 'T'
    
    [resultData appendData:[self escmfb1LineData]];
    char chc = 0x63;
    [resultData appendBytes:&chc length:1]; // 'c'
    //[resultData appendBytes:&total length:sizeof(total)];
    
    [resultData appendData:[self postfixLineData]];
    
    return resultData;
}


- (NSData *)endOfSalesTransaction:(NSString *)saleDate
{
    /*
    Format:
    ESC MFB E[<sale_date>] ESC MFE
    Example:
    ESC MFB 'E' ESC MFE
    ACK
     */
    
    NSMutableData *resultData = [[NSMutableData alloc] init];
    [resultData appendData:[self prefixLineData]];
    
    char chE = 0x45;
    [resultData appendBytes:&chE length:1]; // 'E'
    
    [resultData appendBytes:&saleDate length:sizeof(saleDate)];
    
    [resultData appendData:[self postfixLineData]];
    
    return resultData;
}

@end
