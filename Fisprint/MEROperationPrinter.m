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
@end

@implementation MEROperationPrinter

#pragma mark - Properties
- (MERPrinterDummy *)printerDummy
{
    if (!_printerDummy) {
        _printerDummy = [[MERPrinterDummy alloc] init];
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

- (void)main
{
    if (!self.isCancelled) {
        [self.printerDummy inputPrinter:[[NSData alloc] init] completion: ^(NSData *response, NSError *error) {
            if (!error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"%@ %@", self.name, response);
                });
                self.isCompleted = TRUE;
                [self finish];
                
            } else {
                //self.error = error;
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"Error - %@", self.name);
                });
                //[self.printerQ cancelAllOperations];
                [self.delegate finishedWithError:error];
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
