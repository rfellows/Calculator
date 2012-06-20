//
//  CalculatorViewController.m
//  Calculator
//
//  Created by Rob Fellows on 5/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CalculatorViewController.h"
#import "CalculatorBrain.h"
#import "GraphViewController.h"

@interface CalculatorViewController()

@property (nonatomic) BOOL userIsInTheMiddleOfEnteringANumber;  

@property (nonatomic, strong) CalculatorBrain *brain;

@property (nonatomic, strong) NSDictionary *testVariableValues;

@end

@implementation CalculatorViewController

@synthesize display = _display;
@synthesize brainContents = _brainContents;
@synthesize variableDisplay = _variableDisplay;
@synthesize userIsInTheMiddleOfEnteringANumber = _userIsInTheMiddleOfEnteringANumber;
@synthesize brain = _brain;
@synthesize testVariableValues = _testVariableValues;

- (CalculatorBrain *)brain {
  if (!_brain) {
    _brain = [[CalculatorBrain alloc] init];
  }
  return _brain;
}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if([segue.identifier isEqualToString:@"ShowGraph"]) {
    [segue.destinationViewController setProgram:self.brain.program];
  }
}

- (IBAction)digitPressed:(UIButton *)sender {
  
  NSString *digit = sender.currentTitle;
  
  // let's see if there is a dot (.) in the string. only allow 1 of them
  if ( [@"." isEqualToString:digit] &&
       [self.display.text rangeOfString:@"."].location != NSNotFound) {
    return;
  }
  
  if (self.userIsInTheMiddleOfEnteringANumber) {
    self.display.text = [self.display.text stringByAppendingString:digit];
  } else {
    self.display.text = digit;
    self.userIsInTheMiddleOfEnteringANumber = YES;
  }
  
}

- (IBAction)enterPressed {
//  [self logEntry:self.display.text];
  [self.brain pushOperand:[self.display.text doubleValue]];
  self.userIsInTheMiddleOfEnteringANumber = NO;
  self.brainContents.text = [CalculatorBrain descriptionOfProgram:[self.brain program]];
}

- (IBAction)operationPressed:(UIButton *)sender {

  NSString *operation = sender.currentTitle;

  // save the user... if they press an operation key, implicitly hit enter for them
  if ( [@"+/-" isEqualToString:operation] && self.userIsInTheMiddleOfEnteringANumber) {
    // don't do an operation, just flip the sign in the display
    self.display.text = [NSString stringWithFormat:@"%g", [self.display.text doubleValue] * -1];
    return;
  } else if (self.userIsInTheMiddleOfEnteringANumber) {
    [self enterPressed];
  }
  
  double result = [self.brain performOperation:operation];
  self.display.text = [NSString stringWithFormat:@"%g", result];
  
  // extra credit, add the = sign after an operation to the entry log
  // TODO
  
  self.brainContents.text = [CalculatorBrain descriptionOfProgram:[self.brain program]];
  
}
- (IBAction)variablePressed:(UIButton *)sender {
  if(self.userIsInTheMiddleOfEnteringANumber == YES) {
    [self enterPressed];
  }
  [self.brain pushVariable:sender.currentTitle];
  self.display.text = sender.currentTitle;
  self.brainContents.text = [CalculatorBrain descriptionOfProgram:[self.brain program]];
}

- (IBAction)testPressed:(UIButton *)sender {
  if(self.userIsInTheMiddleOfEnteringANumber == YES) {
    [self enterPressed];
  }

  NSString *text = sender.currentTitle;

  if ([text hasSuffix:@"1"]) {
    self.testVariableValues = [NSDictionary dictionaryWithObjectsAndKeys: 
                                [NSNumber numberWithDouble:-2], @"x",
                                [NSNumber numberWithDouble:13.9], @"y",
                                [NSNumber numberWithDouble:0], @"foo",
                                nil];
  } else if ([text hasSuffix:@"2"]) {
    self.testVariableValues = [NSDictionary dictionaryWithObjectsAndKeys: 
                               [NSNumber numberWithDouble:0.9999], @"x",
                               [NSNumber numberWithDouble:-9999], @"y",
                               [NSNumber numberWithDouble:9999], @"foo",
                               nil];
    
  } else if ([text hasSuffix:@"3"]) {
    self.testVariableValues = [NSDictionary dictionaryWithObjectsAndKeys: 
                               [NSNumber numberWithDouble:-0.00002], @"x",
                               [NSNumber numberWithDouble:100.0002], @"y",
                               [NSNumber numberWithDouble:400.9876], @"foo",
                               nil];
    
  }
  
  [self runCurrentProgram];
}

- (void) runCurrentProgram {
  double result = [CalculatorBrain runProgram:self.brain.program usingVariableValues:self.testVariableValues];
  self.display.text = [NSString stringWithFormat:@"%g", result];
  NSString *formula = [CalculatorBrain descriptionOfProgram:[self.brain program]];

  if(formula != nil) {
    self.brainContents.text = formula;
  } else {
    self.brainContents.text = @"";
  }
  self.variableDisplay.text = [self buildVariableDisplay];
}

- (NSString *) buildVariableDisplay {
  NSString *vars = @"";
  NSSet *variables = [CalculatorBrain variablesUsedInProgram:self.brain.program];
  
  for (NSString *variable in variables) {
    NSNumber *value = [self.testVariableValues valueForKey:variable];
    if (value != nil) {
      NSLog(@"%@ = %g  ", variable, [value doubleValue]);
      vars = [vars stringByAppendingFormat:@"%@ = %g  ", variable, [value doubleValue] ];
      NSLog(@"after format -- %@", vars);
    }
  }
  
  return vars;
}

- (void)viewDidUnload {
  [self setBrainContents:nil];
  [self setVariableDisplay:nil];
  [super viewDidUnload];
}

- (IBAction)clearPressed {
  self.brainContents.text = @"";
  self.display.text = @"0";
  self.variableDisplay.text = @"";
  [self.brain clear]; 
  self.testVariableValues = nil;
}

- (IBAction)backspacePressed {
  NSUInteger length = [self.display.text length];
  if(self.userIsInTheMiddleOfEnteringANumber == YES) {
    if(length > 1) {
      self.display.text = [self.display.text substringToIndex:length-1];
    } else {
      [self runCurrentProgram];
      self.userIsInTheMiddleOfEnteringANumber = FALSE;
    }
  } else {
    // remove the top item from the stack
    [self.brain undo];
    [self runCurrentProgram];
  }
}

@end
