//
//  MERPrinterDummy.m
//  Fisprint
//
//  Created by George Malushkin on 28/10/15.
//  Copyright © 2015 George Malushkin. All rights reserved.
//

#import "MERPrinterDummy.h"
#import "MERErrors.h"
#import "MERPrinterStatusCommands.h"


typedef NS_ENUM(NSUInteger, PrinterState) {
    PrinterStateIdle,
    PrinterStateNonFiscal,
    PrinterStateFiscal,
};


@interface MERPrinterDummy ()
@property (nonatomic, assign) PrinterState state;
@property (nonatomic, strong) dispatch_queue_t printerDelayQ;
@property (nonatomic, strong) MERPrinterStatusCommands *psc;
@end

@implementation MERPrinterDummy

// Shared Singleton
// Class method that returns a singleton instance
//
// Platform: All
// Language: Objective-C
// Completion Scope: Class Implementation

    
+ (instancetype)sharedManager {
    static MERPrinterDummy *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    
    return _sharedManager;
}


#pragma mark - Properties
- (dispatch_queue_t)printerDelayQ
{
    if (!_printerDelayQ) {
        _printerDelayQ = dispatch_queue_create("com.mera.printerDelayQueue", NULL);
    }
    return _printerDelayQ;
}

- (MERPrinterStatusCommands *)psc
{
    if (!_psc) {
        _psc = [[MERPrinterStatusCommands alloc] init];
    }
    return _psc;
}

- (PrinterState)state
{
    if (!_state) {
        //_state = PrinterStateIdle;
        //_state = PrinterStateFiscal;
        //_state = PrinterStateNonFiscal;
        _state = (NSUInteger)(arc4random() % 2) + 1; // only nonFiscal or Fiscal
    }
    return _state;
}


- (void)inputPrinter:(NSData *)request completion:(void(^)(NSData *response, NSError *error))completion
{
    //NSLog(@"Printer got request: %@", request);
    NSData *output;
    
    NSData *queryPrinterExtendedStatusTemplate = [self.psc queryPrinterExtendedStatus];
    
    float delayF = logf(arc4random() % 100); // for seldom errors
    //float delayF = logf(arc4random() % 20); // for frequently errors
    //NSLog(@"%f", delayF);
    char i = (delayF >= 2) ? 0x06 : 0x15;
    
    
    // printer state
    if ([request isEqualToData:queryPrinterExtendedStatusTemplate]) {
        if (self.state == PrinterStateIdle) {
            char chA = 0x41;
            output = [NSData dataWithBytes:&chA length:1];
        } else if (self.state == PrinterStateNonFiscal) {
            char chB = 0x42;
            output = [NSData dataWithBytes:&chB length:1];
        } else if (self.state == PrinterStateFiscal){
            char chC = 0x43;
            output = [NSData dataWithBytes:&chC length:1];
        }
        
    } else {
        output = [NSData dataWithBytes:&i length:1];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayF * NSEC_PER_SEC)), self.printerDelayQ, ^{
        NSError *error = (i == 0x15) ? [NSError errorWithDomain:MERDomainError code:0 userInfo:nil] : nil ;
        completion(output, error);
    });
}

@end
