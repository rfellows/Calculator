//
//  GraphViewViewController.m
//  Calculator
//
//  Created by Rob Fellows on 6/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GraphViewController.h"

@interface GraphViewController ()

@property (weak, nonatomic) IBOutlet GraphView *graphView;

@end

@implementation GraphViewController

@synthesize graphView = _graphView;
@synthesize program = _program;


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
