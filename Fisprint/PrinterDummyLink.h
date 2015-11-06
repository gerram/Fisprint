//
//  PrinterDummyLink.h
//  Fisprint
//
//  Created by George Malushkin on 06/11/15.
//  Copyright © 2015 George Malushkin. All rights reserved.
//

@protocol PrinterDummyLink <NSObject>
- (void)operationResponse:(NSData *)data
                WithError:(NSError *)error
             forOperation:(NSString *)nameOperation;
@end
