//
//  MEROperationPrinter.m
//  Fisprint
//
//  Created by George Malushkin on 28/10/15.
//  Copyright © 2015 George Malushkin. All rights reserved.
//

#import "MEROperationPrinter.h"

@interface MEROperationPrinter ()
@property (nonatomic, assign) BOOL isCompleted;
@property (nonatomic, strong) MERPrinterDummy *printerDummy;
@end

@implementation MEROperationPrinter

#pragma mark - Properties
- (MERPrinterDummy *)printerDummy
{
    if (!_printerDummy) {
        _printerDummy = [MERPrinterDummy sharedManager];
    }
    return _printerDummy;
}

- (BOOL)isCompleted
{
    if (!_isCompleted) {
        _isCompleted = FALSE;
    }
    return _isCompleted;
}

- (id)initWithData:(NSData *)data
     operationName:(NSString *)operationName
          delegate:(id<PrinterDummyLink>)delegate
{
    if (self = [self init]) {
        self.data = data;
        self.name = operationName;
        self.delegate = delegate;
    }
    return self;
}


- (void)main
{
    if (!self.isCancelled) {
        [self.printerDummy inputPrinter:self.data completion: ^(NSData *response, NSError *error) {
            if (!error) {
                NSLog(@"%@ %@", self.name, response);
                self.isCompleted = TRUE;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_delegate operationResponse:response WithError:nil forOperation:self.name];
                });
                [self finish];
                
            } else {
                //self.error = error;
                NSLog(@"Error - %@", self.name);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_delegate operationResponse:nil WithError:error forOperation:self.name];
                });
            }
        }];
    }
}


- (BOOL)isFinished
{
    if (self.isCompleted) {
        return TRUE;
    }
    return FALSE;
}


- (void)finish
{
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    
//    _isExecuting = NO;
//    _isFinished = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

@end
