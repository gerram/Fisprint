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



@interface MERDetailVC ()
@property (nonatomic, strong) MERPrinterDummy *printerDummy;
@property (nonatomic, strong) NSOperationQueue *printerQ;
@property (nonatomic, strong) NSError *error;
@end


@implementation MERDetailVC
#pragma mark - Properties
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


- (IBAction)startPrinter:(id)sender {
    
    MEROperationPrinter *printerStart = [[MEROperationPrinter alloc] init];
    printerStart.delegate = self;
    printerStart.name = @"printerStart";
    printerStart.printerDummy = self.printerDummy;
    
    MEROperationPrinter *operationA = [[MEROperationPrinter alloc] init];
    operationA.delegate = self;
    operationA.name = @"operationA";
    operationA.printerDummy = self.printerDummy;
    
    MEROperationPrinter *operationB = [[MEROperationPrinter alloc] init];
    operationB.delegate = self;
    operationB.name = @"operationB";
    operationB.printerDummy = self.printerDummy;
    
    MEROperationPrinter *operationC = [[MEROperationPrinter alloc] init];
    operationC.delegate = self;
    operationC.name = @"operationC";
    operationC.printerDummy = self.printerDummy;
    
    [operationA addDependency:printerStart];
    [operationB addDependency:operationA];
    [operationC addDependency:operationB];
    
    
    [self.printerQ addOperations:@[printerStart, operationA, operationB, operationC] waitUntilFinished:FALSE];
}

#pragma mark - PrinterDummyLink delegate
- (void)finishedWithError:(NSError *)error
{
    [self.printerQ cancelAllOperations];
    self.printerQ = nil;
}

@end
