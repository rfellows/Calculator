//
//  CalculatorBrain.h
//  Calculator
//
//  Created by Rob Fellows on 5/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalculatorBrain : NSObject

- (void) pushOperand:(double)operand;
- (void) pushVariable:(NSString *)variable;
- (double) performOperation:(NSString *)operation;
- (void) clear;
- (void) undo;

@property (readonly) id program;

+ (double) runProgram:(id)program;
+ (double) runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues;
+ (NSString *) descriptionOfProgram:(id)program;
+ (NSSet *) variablesUsedInProgram:(id)program;


@end
