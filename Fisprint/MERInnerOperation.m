//
//  MERInnerOperation.m
//  Fisprint
//
//  Created by George Malushkin on 05/11/15.
//  Copyright © 2015 George Malushkin. All rights reserved.
//

#import "MERInnerOperation.h"

@interface MERInnerOperation () <NSStreamDelegate>
@property (nonatomic, assign) BOOL isCompleted;

@property (nonatomic, strong) NSOutputStream *oStream;
@property (nonatomic, strong) NSInputStream *iStream;
@property (nonatomic, strong) NSMutableData *streamData;
@property (nonatomic, strong) NSData *streamedData;
@property (nonatomic, assign) NSUInteger streamDataIndexOffset;
@end

@implementation MERInnerOperation
{
    
    BOOL executing;
    BOOL finished;
}

#pragma mark - Properties
- (BOOL)isCompleted
{
    if (!_isCompleted) {
        _isCompleted = FALSE;
    }
    return _isCompleted;
}

- (NSMutableData *)streamData
{
    if (!_streamData) {
        _streamData = [[NSMutableData alloc] init];
    }
    return _streamData;
}


- (id)initWithData:(NSData *)data
{
    if (self = [self init]) {
        [self.streamData appendData:data];
        executing = FALSE;
        finished = FALSE;
    }
    return self;
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


- (void)main
{
    if (!self.isCancelled) {
        
        if ([self.streamData length]) {
            [self createStreamOutput];
            
        } else {
            NSString *response = @"I'm response from printer";
            [self createStreamInputForData:[NSData dataWithBytes:&response length:sizeof(response)]];
        }
        
    }
}



#pragma mark - NSStream
- (void)createStreamOutput
{
    self.oStream = [[NSOutputStream alloc] initToMemory];
    self.oStream.delegate = self;
    [self.oStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [self.oStream open];
}

- (void)createStreamInputForData:(NSData *)data
{
    self.iStream = [[NSInputStream alloc] initWithData:data];
    self.iStream.delegate = self;
    [self.iStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [self.iStream open];
}

- (void)processMemoryToPrinter
{
    NSLog(@">> StreamedData to printer is: %@", self.streamedData);
    //self.isCompleted = TRUE;
    //[self finish];
    NSString *response = @"I'm response from printer";
    [self createStreamInputForData:[NSData dataWithBytes:&response length:sizeof(response)]];
 }

- (void)processInputData
{
    NSLog(@"<< StreamData from printer is: %@", self.streamData);
    self.isCompleted = TRUE;
    [self finish];
}

- (void)processStreamError:(NSStream *)aStream
{
    
}


#pragma mark - NSStreamDelegate
- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    switch (eventCode) {
            
        case NSStreamEventHasSpaceAvailable:
        {
            //NSLog(@"outputStream HasSpaceAvailable");
            //uint8_t *readBytes = (uint8_t *)[self.streamData mutableBytes];
            uint8_t *readBytes = (uint8_t *)[self.streamData bytes];
            readBytes += self.streamDataIndexOffset;
            NSUInteger data_len = [_streamData length];
            NSUInteger len = (data_len - self.streamDataIndexOffset >= 1024) ? 1024 : (data_len -  self.streamDataIndexOffset);
            
            uint8_t buffer[len];
            (void)memcpy(buffer, readBytes, len);
            len = [(NSOutputStream *)aStream write:(const uint8_t *)buffer maxLength:len];
            self.streamDataIndexOffset += len;
            
            break;
        }
            
        case NSStreamEventHasBytesAvailable:
        {
            //NSLog(@"inputStream HasByteAvalible: %@", aStream);
            while ([(NSInputStream *)aStream hasBytesAvailable]) {
                uint8_t buffer[1024];
                NSInteger bytesRead = [(NSInputStream *)aStream read:buffer maxLength:1024];
                
                if (bytesRead) {
                    [self.streamData appendBytes:(const void *)buffer length:bytesRead];
                } else {
                    NSLog(@"inputStream buffer is empty");
                }
            }
            
            break;
        }
            
        case NSStreamEventEndEncountered:
        {
            if (aStream == _oStream) {
                self.streamedData = nil;
                self.streamedData = [aStream propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
                
                if (![_streamedData length]) {
                    NSLog(@"We get nothing in to memory from outputStream!");
                } else {
                    [self processMemoryToPrinter];
                }
                self.streamData = nil;
                
            } else if (aStream == _iStream) {
                if (![self.streamData length]) {
                    NSLog(@"We get nothing from inputStream!");
                } else {
                    [self processInputData];
                }
                self.streamData = nil;
                self.streamDataIndexOffset = 0;
            }
            
            [aStream close];
            [aStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            aStream = nil;
            
            break;
        }
            
        case NSStreamEventErrorOccurred:
        {
            NSLog(@"stream error");
            
            /*
            NSError *error = [aStream streamError];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Stream Alert"
                                                                           message:[NSString stringWithFormat:@"Error: %li", (long)[error code]]                                                                   preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:TRUE completion:nil];
            */
            
            [self processStreamError:aStream];
            
            [aStream close];
            [aStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            aStream = nil;
            
            break;
        }
            
        default:
            break;
    }
}

@end
