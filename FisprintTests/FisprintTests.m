//
//  FisprintTests.m
//  FisprintTests
//
//  Created by George Malushkin on 21/10/15.
//  Copyright © 2015 George Malushkin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MERSaleTransactionCommands.h"

@interface FisprintTests : XCTestCase
@property (nonatomic, strong) MERSaleTransactionCommands *fisprint;
@end

@implementation FisprintTests

- (MERSaleTransactionCommands *)fisprint
{
    if (!_fisprint) {
        _fisprint = [[MERSaleTransactionCommands alloc] init];
    }
    return _fisprint;
}

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}


- (void)test0penReceiptOrInvoce
{
    NSString *invoceNumber = @"ASD1234adoi";
    NSString *expectedInvoceNumber = @"6053c5d8 fa7f0000";
#pragma TODO: Converter Raw repro string -> NSData
    NSData *expectedData = [[NSData alloc] init];
    NSData *retData = [self.fisprint openReceiptOrInvoce:invoceNumber error:nil];
    XCTAssertEqualObjects(expectedData, retData, @"0penReceiptOrInvoce generated not right data.");
    
    
    NSString *invoceNumberLong = @"abcdef adsf ljklasdf lkjljl asdfdsfds ljljlk";
    NSData *retDataLong = [self.fisprint openReceiptOrInvoce:invoceNumberLong error:nil];
    XCTAssertTrue(retDataLong.length <= 20, @"OpenReceiptOrInvoce generated so long line.");
    
}



@end
