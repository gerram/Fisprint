//
//  MERDetailVC.m
//  Fisprint
//
//  Created by George Malushkin on 27/10/15.
//  Copyright © 2015 George Malushkin. All rights reserved.
//

#import "MERDetailVC.h"
#import "MERPrinterDummy.h"
#import "MEROperationPrinter.h"

#import "MERSaleTransactionCommands.h"
#import "MERPrinterStatusCommands.h"

#define ERROR_COUNTER_MAX 10

@interface MERDetailVC () <NSStreamDelegate>

@property (nonatomic, strong) MERSaleTransactionCommands *stc;
@property (nonatomic, strong) MERPrinterStatusCommands *psc;
@property (nonatomic, strong) MERPrinterDummy *printerDummy;
@property (nonatomic, assign) BOOL isPrinterStateFiscal;
@property (nonatomic, strong) NSOperationQueue *printerQ;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, assign) NSInteger errorCounter;

@property (nonatomic, strong) NSOutputStream *oStream;
@property (nonatomic, strong) NSInputStream *iStream;
@property (nonatomic, strong) NSMutableData *streamData;
@property (nonatomic, strong) NSData *streamedData;
@property (nonatomic, assign) unsigned long streamDataIndexOffset;

@property (weak, nonatomic) IBOutlet UIButton *turnOnPrinter;
@property (weak, nonatomic) IBOutlet UIButton *printReceipt;
@property (weak, nonatomic) IBOutlet UITextView *consoleText;

@end



@implementation MERDetailVC

- (IBAction)startPrinter:(id)sender {
    [self startPrinterAction];
}


- (IBAction)printReceipt:(id)sender {
    [self printReceiptAction];
    self.printReceipt.enabled = FALSE;
    self.consoleText.text = @"> New print of Receipt";
}


#pragma mark - Properties
- (MERPrinterStatusCommands *)psc
{
    if (!_psc) {
        _psc = [[MERPrinterStatusCommands alloc] init];
    }
    return _psc;
}


- (MERSaleTransactionCommands *)stc
{
    if (!_stc) {
        _stc = [[MERSaleTransactionCommands alloc] init];
    }
    return _stc;
}


- (MERPrinterDummy *)printerDummy
{
    if (!_printerDummy) {
        _printerDummy = [MERPrinterDummy sharedManager];
    }
    return _printerDummy;
}

- (NSMutableData *)streamData
{
    if (!_streamData) {
        _streamData = [[NSMutableData alloc] init];
    }
    return _streamData;
}



//- (NSOutputStream *)oStream
//{
//    if (!_oStream) {
//        _oStream = [[NSOutputStream alloc] initToMemory];
//    }
//    return _oStream;
//}

- (NSOperationQueue *)printerQ
{
    if (!_printerQ) {
        _printerQ = [[NSOperationQueue alloc] init];
        _printerQ.name = @"com.mera.PrinterNSOperationQueue";
        //_printerQ.maxConcurrentOperationCount = 1;
        _printerQ.qualityOfService = NSQualityOfServiceBackground;
    }
    return _printerQ;
}


- (NSError *)error
{
    if (!_error) {
        _error = [[NSError alloc] init];
    }
    return _error;
}


/*
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //[self addObserver:self forKeyPath:@"error" options:NSKeyValueObservingOptionNew context:nil];
}

//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
//{
//    if ([keyPath isEqualToString:@"error"]) {
//        [self.printerQ cancelAllOperations];
//    }
//}
*/
 
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Cancel Bad Receipt
- (void)cancelBadReceiptAndReprint
{
    if (_isPrinterStateFiscal) {
        NSLog(@"--- --- fiscal repeat --- ---");
        [self printerCloseReceipt];
    } else {
        NSLog(@"--- --- non-fiscal repeat --- ---");
        [self printReceiptAction];
    }
}

// TODO: These method for model
- (void)printerCloseReceipt
{
    if (_errorCounter <= ERROR_COUNTER_MAX) {
        NSArray *cancelBuffer = [self printerCloseReceiptBuffer];
        NSArray *reprintBuffer = [self printReceiptBuffer];
        NSArray *cancelReprintBuffer = [cancelBuffer arrayByAddingObjectsFromArray:reprintBuffer];
        [cancelReprintBuffer[1] addDependency:cancelReprintBuffer.firstObject];
        
        [self.printerQ addOperations:cancelReprintBuffer waitUntilFinished:FALSE];
        
    } else {
        [self stopWithNoService];
    }
    
}

// TODO: These method for model
- (NSArray *)printerCloseReceiptBuffer
{
    NSData *cancelReceiptData = [self.stc cancelReceiptOrVatInvoice];
    MEROperationPrinter *operation_cancelReceiptData = [[MEROperationPrinter alloc] initWithData:cancelReceiptData operationName:OID005 delegate:self];
    
    return @[operation_cancelReceiptData];
    //[self.printerQ addOperation:operation_cancelReceiptData];
}

#pragma mark - Print Receipt
// TODO: These method for model
- (void)printReceiptAction
{
    if (self.errorCounter <= ERROR_COUNTER_MAX) {
        [self.printerQ addOperations:[self printReceiptBuffer] waitUntilFinished:FALSE];
    } else {
        [self stopWithNoService];
    }
}

- (NSArray *)printReceiptBuffer
{
    NSMutableArray *operationsBuffer = [[NSMutableArray alloc] init];
    
    // Open receipt
    NSData *receipt = [self.stc openReceiptOrInvoce:@"AB123" error:nil];
    MEROperationPrinter *operation_OpenReceipt = [[MEROperationPrinter alloc] initWithData:receipt
                                                                  operationName:OID002
                                                                       delegate:self];
    
    [operationsBuffer addObject:operation_OpenReceipt];
    
    // Lines with items
    NSDictionary *item = @{@"itemName": @"aaa", @"comment": @"Comment template", @"value": @12.50, @"vat": @"A"};
    NSArray *items = @[item, item, item];
    
    [items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSData *salesTransactionLineData = [self.stc salesTransactionLine:[[NSProcessInfo processInfo] globallyUniqueString]
                                                             comment1:item[@"comment"]
                                                             comment2:item[@"comment"]
                                                             comment3:item[@"comment"]
                                                                value:item[@"value"]
                                                                  vat:item[@"vat"]
                                                                error:nil];
        
        MEROperationPrinter *operation_salesTransactionLine = [[MEROperationPrinter alloc] initWithData:salesTransactionLineData operationName:OID003 delegate:self];
        
        if (!idx) {
            // first line of receipt
            [operation_salesTransactionLine addDependency:operation_OpenReceipt];
        } else {
            // any next line what is not first
            [operation_salesTransactionLine addDependency:operationsBuffer.lastObject];
        }
        
        [operationsBuffer addObject:operation_salesTransactionLine];
    }];
    
    // Total
    NSData *totalData = [self.stc transactionTotal:@125.01 error:nil];
    MEROperationPrinter *operation_Total = [[MEROperationPrinter alloc] initWithData:totalData
                                                                       operationName:OID004
                                                                            delegate:self];
    
    [operation_Total addDependency:operationsBuffer.lastObject];
    [operationsBuffer addObject:operation_Total];
    
    // Close receipt
    NSData *endSaleTransactionData = [self.stc endOfSalesTransaction:[NSDate date].description];
    MEROperationPrinter *operation_endSaleTransaction = [[MEROperationPrinter alloc] initWithData:endSaleTransactionData operationName:OID006 delegate:self];
    
    [operation_endSaleTransaction addDependency:operation_Total];
    [operationsBuffer addObject:operation_endSaleTransaction];
    
    return operationsBuffer;
    //[self.printerQ addOperations:operationsBuffer waitUntilFinished:FALSE];
}




#pragma mark - Turn On printer
// TODO: This method for model
- (void)startPrinterAction
{
    NSData *queryPrinterStateData = [self.psc queryPrinterExtendedStatus];
    MEROperationPrinter *printerState = [[MEROperationPrinter alloc] initWithData:queryPrinterStateData operationName:OID001 delegate:self];
    [printerState start];
    self.consoleText.text = @"> Checking printer...";
}


// TODO: To make normal handler for input signals
- (void)stopWithNoService
{
    [self.printerQ cancelAllOperations];
    self.printerQ = nil;
    self.errorCounter = 0;
    
    self.turnOnPrinter.enabled = TRUE;
    self.printReceipt.enabled = FALSE;
    self.consoleText.text = @"> Printer in error mode";
}

#pragma mark - PrinterDummyLink delegate
- (void)operationResponse:(NSData *)data
                WithError:(NSError *)error
             forOperation:(NSString *)nameOperation
{
    if (!error) {
        if ([nameOperation isEqualToString:OID001]) {
            // Check printer status
            int i = (int)*(char*)([data bytes]);
            switch (i) {
                case 0x41:
                    // A - Idle mode
                    self.turnOnPrinter.enabled = FALSE;
                    self.printReceipt.enabled = TRUE;
                    self.consoleText.text = @"> Printer mode: IDLE";
                    break;
                case 0x42:
                    // B - NonFiscal mode
                    self.isPrinterStateFiscal = FALSE;
                    self.turnOnPrinter.enabled = FALSE ;
                    self.printReceipt.enabled = TRUE;
                    self.consoleText.text = @"> Printer mode: NON FISCAL";
                    break;
                case 0x43:
                    // C - Fiscal mode
                    self.isPrinterStateFiscal = TRUE;
                    self.turnOnPrinter.enabled = FALSE;
                    self.printReceipt.enabled = TRUE;
                    self.consoleText.text = @"> Printer mode: FISCAL";
                    break;
                default:
                    break;
            }
            
        } else if ([nameOperation isEqualToString:OID006]) {
            self.errorCounter = 0;
            // Success!!!
            self.consoleText.text = [NSString stringWithFormat:@"> Receipt was printed SUCCESSFULLY in %@ mode", self.isPrinterStateFiscal ? @"fiscal" : @"non-fiscal"];
            self.printReceipt.enabled = TRUE;
        
        } else if ([nameOperation isEqualToString:OID005]) {
            // Canceled receipt
            self.consoleText.text = @"> Receipt in fiscal mode was canceled";
        }
        
    } else {
        self.errorCounter++;
        
        if ([nameOperation isEqualToString:OID001]) {
            self.consoleText.text = @"> Turn On printer";
            [self.printerQ cancelAllOperations];
            self.printerQ = nil;
            
        } else {
            self.consoleText.text = @"> Previous operation finished with Error. Trying again right now";
            [self.printerQ cancelAllOperations];
            self.printerQ = nil;
            [self cancelBadReceiptAndReprint];
        }
    }
}


#pragma mark - NSStream
- (IBAction)streamTestAction:(id)sender {
    NSString *testString = @"Testo 777";
    
    [self.streamData appendBytes:&testString length:sizeof(testString)];
    [self createStreamOutput];
    
}


- (void)createStreamOutput
{
    self.oStream = [[NSOutputStream alloc] initToMemory];
    self.oStream.delegate = self;
    [_oStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_oStream open];
}

- (void)createStreamInputForData:(NSData *)data
{
    self.iStream = [[NSInputStream alloc] initWithData:data];
    self.iStream.delegate = self;
    [_iStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_iStream open];
}

- (void)processMemoryToPrinter
{
    NSLog(@"StreamedData is: %@", _streamedData);
    
    // tmp
    [self createStreamInputForData:_streamedData];
}

- (void)processInputData
{
    NSLog(@"StreamData is: %@", self.streamData);
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
            NSLog(@"outputStream HasSpaceAvailable");
            uint8_t *readBytes = (uint8_t *)[self.streamData mutableBytes];
            readBytes += _streamDataIndexOffset;
            NSUInteger data_len = [_streamData length];
            NSUInteger len = (data_len - _streamDataIndexOffset >= 1024) ? 1024 : (data_len -  _streamDataIndexOffset);
            
            uint8_t buffer[len];
            (void)memcpy(buffer, readBytes, len);
            len = [(NSOutputStream *)aStream write:(const uint8_t *)buffer maxLength:len];
            self.streamDataIndexOffset += len;
            
            break;
        }
            
        case NSStreamEventHasBytesAvailable:
        {
            NSLog(@"inputStream HasByteAvalible: %@", aStream);
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
            
            NSError *error = [aStream streamError];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Stream Alert"
                                                                           message:[NSString stringWithFormat:@"Error: %li", (long)[error code]]                                                                   preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:TRUE completion:nil];
            
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
