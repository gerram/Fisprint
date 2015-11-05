//
//  MEROperationPrinter.m
//  Fisprint
//
//  Created by George Malushkin on 28/10/15.
//  Copyright © 2015 George Malushkin. All rights reserved.
//

#import "MEROperationPrinter.h"
#import "MERInnerOperation.h"

@interface MEROperationPrinter ()
@property (nonatomic, assign) BOOL isCompleted;
@property (nonatomic, strong) MERPrinterDummy *printerDummy;
@property (nonatomic, strong) NSData *data;
@end

@implementation MEROperationPrinter
{
    BOOL executing;
    BOOL finished;
}

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
        //[self.streamData appendData:data];
        self.name = operationName;
        self.delegate = delegate;
        
        executing = FALSE;
        finished = FALSE;
    }
    return self;
}


- (void)main
{
    if (!self.isCancelled) {
        NSOperationQueue *innerQ = [[NSOperationQueue alloc] init];
        innerQ.name = @"com.mera.streamerNSOperationQueue";
        innerQ.qualityOfService = NSQualityOfServiceBackground;
        
        // streamer - stream our data to streamToMemory
        MERInnerOperation *operationOutputStream = [[MERInnerOperation alloc] initWithData:self.data];
        
        //MERInnerOperation *operationInputStream = [[MERInnerOperation alloc] init];
        //[operationInputStream addDependency:operationOutputStream];
        
        
        
        // !!! We dont have device and will send to virtual data
        // data to virtual printer
        NSOperation *operationSendVirtualPrinter = [[NSOperation alloc] init];
        operationSendVirtualPrinter.completionBlock = ^{
            [self.printerDummy inputPrinter:self.data completion: ^(NSData *response, NSError *error) {
                if (!self.isCancelled && !error) {
                    NSLog(@"%@ %@", self.name, response);
                    self.isCompleted = TRUE;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_delegate operationResponse:response WithError:nil forOperation:self.name];
                    });
                    [self finish];
                    
                } else if (!self.isCancelled) {
                    //self.error = error;
                    NSLog(@"Error - %@", self.name);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_delegate operationResponse:nil WithError:error forOperation:self.name];
                    });
                }
            }];    
        };
        
        [operationSendVirtualPrinter addDependency:operationOutputStream];
        
        
        
        [innerQ addOperations:@[operationOutputStream, operationSendVirtualPrinter] waitUntilFinished:FALSE];
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
    
    executing = FALSE;
    finished = TRUE;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}


@end
