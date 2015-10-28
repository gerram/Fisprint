//
//  MERDetailVC.h
//  Fisprint
//
//  Created by George Malushkin on 27/10/15.
//  Copyright © 2015 George Malushkin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MEROperationPrinter.h"

@interface MERDetailVC : UIViewController <PrinterDummyLink>
- (IBAction)startPrinter:(id)sender;
@end
