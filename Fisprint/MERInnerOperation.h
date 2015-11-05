//
//  MERInnerOperation.h
//  Fisprint
//
//  Created by George Malushkin on 05/11/15.
//  Copyright © 2015 George Malushkin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MERInnerOperation : NSOperation

typedef void (^streamCompletion)(NSData *data);

- (id)initWithData:(NSData *)data;

@end
