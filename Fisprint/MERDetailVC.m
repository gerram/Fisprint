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



@interface MERDetailVC ()
@property (nonatomic, strong) MERSaleTransactionCommands *stc;
@property (nonatomic, strong) MERPrinterStatusCommands *psc;
@property (nonatomic, strong) MERPrinterDummy *printerDummy;
@property (nonatomic, strong) NSOperationQueue *printerQ;
@property (nonatomic, strong) NSError *error;


@property (weak, nonatomic) IBOutlet UIButton *turnOnPrinter;
@property (weak, nonatomic) IBOutlet UIButton *printReceipt;
@property (weak, nonatomic) IBOutlet UITextView *consoleText;

@end


@implementation MERDetailVC
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
        _printerDummy = [[MERPrinterDummy alloc] init];
    }
    return _printerDummy;
}

- (NSOperationQueue *)printerQ
{
    if (!_printerQ) {
        _printerQ = [[NSOperationQueue alloc] init];
        _printerQ.name = @"com.mera.PrinterNSOperationQueue";
        _printerQ.maxConcurrentOperationCount = 1;
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


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (BOOL)makeTransaction
{
    NSData *printerStartData = [self.stc openReceiptOrInvoce:@"asd ljew 113434" error:nil];
    MEROperationPrinter *printerStart = [[MEROperationPrinter alloc] init];
    printerStart.delegate = self;
    printerStart.name = @"printerStart";
    printerStart.data = printerStartData;
    //printerStart.printerDummy = self.printerDummy;
    
    MEROperationPrinter *operationA = [[MEROperationPrinter alloc] init];
    operationA.delegate = self;
    operationA.name = @"operationA";
    //operationA.printerDummy = self.printerDummy;
    
    MEROperationPrinter *operationB = [[MEROperationPrinter alloc] init];
    operationB.delegate = self;
    operationB.name = @"operationB";
    //operationB.printerDummy = self.printerDummy;
    
    MEROperationPrinter *operationC = [[MEROperationPrinter alloc] init];
    operationC.delegate = self;
    operationC.name = @"operationC";
    //operationC.printerDummy = self.printerDummy;
    
    [operationA addDependency:printerStart];
    [operationB addDependency:operationA];
    [operationC addDependency:operationB];
    
    
    [self.printerQ addOperations:@[printerStart, operationA, operationB, operationC] waitUntilFinished:FALSE];
    
    return TRUE;
}

typedef NS_OPTIONS(NSUInteger, ManagedPrinterStatesObject) {
    MPSP_idle =         1 << 0,
    MPSP_nonfiscal =    1 << 1,
    MPSP_fiscal =       1 << 2,
};

- (void)printerState
{
    NSData *queryPrinterStateData = [self.psc queryPrinterExtendedStatus];
    MEROperationPrinter *printerState = [[MEROperationPrinter alloc] initWithData:queryPrinterStateData operationName:OID001 delegate:self];
    [printerState start];
    self.consoleText.text = @"> Checking printer...";
}

- (IBAction)startPrinter:(id)sender {
    [self printerState];
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
                    NSLog(@"%d", i);
                    break;
                case 0x42:
                    // B - NonFiscal mode
                    self.turnOnPrinter.enabled = FALSE ;
                    self.printReceipt.enabled = TRUE;
                    self.consoleText.text = @"> Printer mode: NON FISCAL";
                    NSLog(@"%d", i);
                    break;
                case 0x43:
                    // C - Fiscal mode
                    self.turnOnPrinter.enabled = FALSE;
                    self.printReceipt.enabled = TRUE;
                    self.consoleText.text = @"> Printer mode: FISCAL";
                    NSLog(@"%d", i);
                    break;
                default:
                    break;
            }
        }
        
    } else {
        [self.printerQ cancelAllOperations];
        self.printerQ = nil;
    }
}

@end
