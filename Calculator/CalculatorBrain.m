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

@property (nonatomic, strong) NSMutableArray *programStack;

+ (BOOL) isOperation:(NSString *)operation;

@end



@implementation CalculatorBrain

@synthesize programStack = _programStack;

- (NSMutableArray *) programStack {
  if (!_programStack) {
    _programStack = [[NSMutableArray alloc] init];
  }
  return _programStack;
}

- (id)program {
  return [self.programStack copy];
}

- (void) pushOperand: (double)operand {
  NSNumber *operandObject = [NSNumber numberWithDouble:operand];
  NSLog(@"Pushing double { %g } onto the stack", operand);
  [self.programStack addObject:operandObject];
}

- (void) pushVariable:(NSString *)variable {
  NSLog(@"Pushing variable { %@ } onto the stack", variable);
  [self.programStack addObject:variable];
}

- (double) performOperation:(NSString *)operation {
  [self.programStack addObject:operation];
  return [[self class] runProgram:self.program];
}

+ (double) popOperandOffProgramStack: (NSMutableArray *)stack {
  
  double result = 0;
  
  id top = [stack lastObject];
  if(top) {
    [stack removeLastObject];
  }
  
  if([top isKindOfClass:[NSNumber class]]) {
    // get the double value
    result = [top doubleValue];
    
  } else if ([top isKindOfClass:[NSString class]]) {
    // it's a string, get it and operate on the stack
    NSString *operation = top;
    
    // perform the operation here, return the result
    if ([@"+" isEqualToString:operation]) {
      result = [self popOperandOffProgramStack:stack] + [self popOperandOffProgramStack:stack];
    } else if ([@"*" isEqualToString:operation]) {
      result = [self popOperandOffProgramStack:stack] * [self popOperandOffProgramStack:stack];
    } else if ([@"-" isEqualToString:operation]) {
      double subtrahend = [self popOperandOffProgramStack:stack];
      result = [self popOperandOffProgramStack:stack] - subtrahend;
    } else if ([@"/" isEqualToString:operation]) {
      double divisor = [self popOperandOffProgramStack:stack];
      // don't divide by 0
      if (divisor > 0) {
        result = [self popOperandOffProgramStack:stack] / divisor;
      }
    } else if ([@"sin" isEqualToString: operation]) {
      result = sin([self popOperandOffProgramStack:stack]);
    } else if ([@"cos" isEqualToString: operation]) {
      result = cos([self popOperandOffProgramStack:stack]);
    } else if ([@"√" isEqualToString: operation]) {
      result = sqrt([self popOperandOffProgramStack:stack]);
    } else if ([@"π" isEqualToString: operation]) {
      result = 3.14159265;
    } else if ([@"+/-" isEqualToString:operation]) {
      result = -1 * [self popOperandOffProgramStack:stack];
    }
  }
  return result;
  
}

- (void) clear {
  [self.programStack removeAllObjects];
}

- (void) undo {
  if([self.programStack lastObject]) {
    [self.programStack removeLastObject];
  }
}

+ (double) runProgram:(id)program {
  NSMutableArray *stack;
  if([program isKindOfClass:[NSArray class]]) {
    stack = [program mutableCopy];
  }
  return [self popOperandOffProgramStack:stack];
}

+ (double)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues {
  NSMutableArray *stack;
  if([program isKindOfClass:[NSArray class]]) {
    stack = [program mutableCopy];
  }
  // replace the variables with their assigned values
  NSSet *variables = [self variablesUsedInProgram:program];
  
  for (NSString *variable in variables) {
    double value = [[variableValues objectForKey:variable] doubleValue];
    int i;
    for (i = 0; i < [stack count]; i++) {
      id obj = [stack objectAtIndex:i];
      if([obj isKindOfClass:[NSString class]] && [obj isEqualToString:variable]) {
        [stack replaceObjectAtIndex:i withObject:[NSNumber numberWithDouble:value]];
      }
    }    
  }
  
  return [self popOperandOffProgramStack:stack];
  
}

+ (NSSet *) variablesUsedInProgram:(id)program {
  NSMutableSet *set = nil;
  if([program isKindOfClass:[NSArray class]]) {
    set = [[NSMutableSet alloc] init];
    for (id obj in program) {
      if([obj isKindOfClass:[NSString class]]) {
        NSString *s = (NSString *) obj;
        if(![self isOperation:s]) {
          [set addObject:s];
        }
      }
    }
  }  
  return [set copy];
}

+ (NSString *) descriptionOfTopOfStack:(NSMutableArray *)stack {
  // get the last operand off of the stack
  id operand = [stack lastObject];
  if(operand) {
    [stack removeLastObject];
  }
  NSString *description = @"";
  
  if ([operand isKindOfClass:[NSString class]]) {
    int num = [self operandsForOperation:operand];
    if (num == 2) {
      int rightNum = [self operandsForOperation:[stack lastObject]];
      NSString *right = [self descriptionOfTopOfStack:stack];
      BOOL rightParens = rightNum > 1;

      int leftNum = [self operandsForOperation:[stack lastObject]];
      NSString *left = [self descriptionOfTopOfStack:stack];
      BOOL leftParens = leftNum > 1;

      
      NSString *pattern = @"%@";
      NSString *patternWithParens = @"(%@)";
      NSString *format = @"";
      if (leftParens) {
        format = [format stringByAppendingString:patternWithParens];
      } else {
        format = [format stringByAppendingString:pattern];
      }
      format = [format stringByAppendingString:@" %@ "];
      if (rightParens) {
        format = [format stringByAppendingString:patternWithParens];
      } else {
        format = [format stringByAppendingString:pattern];
      }
      
      description = [NSString stringWithFormat:format, left, operand, right];
    } else if (num == 1) {
      description = [NSString stringWithFormat:@"%@(%@)", operand, [self descriptionOfTopOfStack:stack]];          
    } else {      
      description = [NSString stringWithFormat:@"%@", operand];  
    }
  } else if (operand) {
    // variable or number
    description = [NSString stringWithFormat:@"%@", operand];
  }
  return description;
}

+ (NSString *)descriptionOfProgram:(id)program {
  NSMutableArray *stack = [program mutableCopy];
  return [self descriptionOfTopOfStack:stack];
}


+ (BOOL) isOperation:(NSString *)operation {
  return [operation isEqualToString:@"+"] ||
     [operation isEqualToString:@"-"] ||
     [operation isEqualToString:@"*"] ||
     [operation isEqualToString:@"/"] ||
     [operation isEqualToString:@"sin"] ||
     [operation isEqualToString:@"cos"] ||
     [operation isEqualToString:@"+/-"] ||
     [operation isEqualToString:@"π"] ||
     [operation isEqualToString:@"√"];
}

+ (int) operandsForOperation:(id)operation {
  int operands = 0;
  
  if([operation isKindOfClass:[NSString class]]) {
    if([operation isEqualToString:@"+"] ||
       [operation isEqualToString:@"-"] ||
       [operation isEqualToString:@"*"] ||
       [operation isEqualToString:@"/"]) {
      operands = 2;
    } else if ([operation isEqualToString:@"sin"] ||
               [operation isEqualToString:@"cos"] ||
               [operation isEqualToString:@"√"]) {
      operands = 1;
    }
  }  
  return operands;
}

@end
