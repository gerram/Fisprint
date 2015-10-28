//
//  MERPrinterDummy.m
//  Fisprint
//
//  Created by George Malushkin on 28/10/15.
//  Copyright © 2015 George Malushkin. All rights reserved.
//

#import "MERPrinterDummy.h"
#import "MERErrors.h"

@interface MERPrinterDummy ()
@property (nonatomic, strong) dispatch_queue_t printerDelayQ;
@end

@implementation MERPrinterDummy

#pragma mark - Properties
- (dispatch_queue_t)printerDelayQ
{
    if (!_printerDelayQ) {
        _printerDelayQ = dispatch_queue_create("com.mera.printerDelayQueue", NULL);
    }
    return _printerDelayQ;
}


- (void)inputPrinter:(NSData *)request completion:(void(^)(NSData *response, NSError *error))completion
{
    
    //float delayF = logf(arc4random() % 100);
    float delayF = logf(arc4random() % 50);
    //int delay = (int) delayF;
    int delay = ceilf(delayF);
    //NSLog(@"%f, %i", delayF, delay);
    
    char i = (delay != 3) ? 0x06 : 0x00;
    NSData *output = [NSData dataWithBytes:&i length:1];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), self.printerDelayQ, ^{
        NSError *error = (i == 0x00) ? [NSError errorWithDomain:MERDomainError code:0 userInfo:nil] : nil ;
        completion(output, error);
    });
}

@end
