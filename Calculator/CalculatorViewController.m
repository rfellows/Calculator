//
//  CalculatorViewController.m
//  Calculator
//
//  Created by Rob Fellows on 5/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CalculatorViewController.h"
#import "CalculatorBrain.h"

@interface CalculatorViewController()
@property (nonatomic) BOOL userIsInTheMiddleOfEnteringANumber;
@property (nonatomic, strong) CalculatorBrain *brain;
- (void) logEntry:(NSString *)value;
@end

@implementation CalculatorViewController

@synthesize display = _display;
@synthesize brainContents = _brainContents;
@synthesize userIsInTheMiddleOfEnteringANumber = _userIsInTheMiddleOfEnteringANumber;
@synthesize brain = _brain;

- (CalculatorBrain *)brain {
  if (!_brain) {
    _brain = [[CalculatorBrain alloc] init];
  }
  return _brain;
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
  [self logEntry:self.display.text];
  [self.brain pushOperand:[self.display.text doubleValue]];
  self.userIsInTheMiddleOfEnteringANumber = NO;
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
  [self logEntry:[operation stringByAppendingString:@" ="]];
}

- (void) logEntry:(NSString *)value {
  self.brainContents.text = [self.brainContents.text stringByAppendingFormat:@"%@ ",value];
}

- (void)viewDidUnload {
  [self setBrainContents:nil];
  [super viewDidUnload];
}

- (IBAction)clearPressed {
  self.brainContents.text = @"";
  self.display.text = @"0";
  [self.brain clear]; 
}

- (IBAction)backspacePressed {
  NSUInteger length = [self.display.text length];
  if(length > 1) {
    self.display.text = [self.display.text substringToIndex:length-1];
  } else {
    self.display.text = @"0";
  }
}

@end
