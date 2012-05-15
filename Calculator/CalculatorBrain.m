//
//  CalculatorBrain.m
//  Calculator
//
//  Created by Rob Fellows on 5/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CalculatorBrain.h"
#import "math.h"

// private interface
@interface CalculatorBrain()

@property (nonatomic, strong) NSMutableArray *operandStack;

@end



@implementation CalculatorBrain

@synthesize operandStack = _operandStack;

- (NSMutableArray *) operandStack {
  if (!_operandStack) {
    _operandStack = [[NSMutableArray alloc] init];
  }
  return _operandStack;
}

- (void) pushOperand: (double)operand {
  NSNumber *operandObject = [NSNumber numberWithDouble:operand];
  NSLog(@"Pushing { %g } onto the stack", operand);
  [self.operandStack addObject:operandObject];
}

- (double) popOperand {
  NSNumber *operandObject = [self.operandStack lastObject];
  if (operandObject) {
    [self.operandStack removeLastObject];
  }
  NSLog(@"Popped { %@ } from the stack", operandObject);
  return [operandObject doubleValue];
}

- (double) performOperation: (NSString *)operation {
  
  double result = 0;
  
  // perform the operation here, return the result
  if ([@"+" isEqualToString:operation]) {
    result = [self popOperand] + [self popOperand];
  } else if ([@"*" isEqualToString:operation]) {
    result = [self popOperand] * [self popOperand];
  } else if ([@"-" isEqualToString:operation]) {
    double subtrahend = [self popOperand];
    result = [self popOperand] - subtrahend;
  } else if ([@"/" isEqualToString:operation]) {
    double divisor = [self popOperand];
    // don't divide by 0
    if (divisor > 0) {
      result = [self popOperand] / divisor;
    }
  } else if ([@"sin" isEqualToString: operation]) {
    result = sin([self popOperand]);
  } else if ([@"cos" isEqualToString: operation]) {
    result = cos([self popOperand]);
  } else if ([@"√" isEqualToString: operation]) {
    result = sqrt([self popOperand]);
  } else if ([@"π" isEqualToString: operation]) {
    result = 3.14159265;
  } else if ([@"+/-" isEqualToString:operation]) {
    result = -1 * [self popOperand];
  }
  
  // push the reult back onto the stack
  [self pushOperand:result];
  
  return result;
  
}

- (void) clear {
  [self.operandStack removeAllObjects];
}

@end
