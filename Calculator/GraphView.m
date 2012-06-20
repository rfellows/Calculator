//
//  GraphView.m
//  Calculator
//
//  Created by Rob Fellows on 6/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GraphView.h"
#import "AxesDrawer.h"

@implementation GraphView

- (void)setup
{
  self.contentMode = UIViewContentModeRedraw; // if our bounds changes, redraw ourselves
}

- (void)awakeFromNib
{
  [self setup]; // get initialized when we come out of a storyboard
}

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    [self setup]; // get initialized if someone uses alloc/initWithFrame: to create us
  }
  return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
//  CGContextRef context = UIGraphicsGetCurrentContext();
  
  CGPoint midPoint; // center of our bounds in our coordinate system
  midPoint.x = self.bounds.origin.x + self.bounds.size.width/2;
  midPoint.y = self.bounds.origin.y + self.bounds.size.height/2;
  
  //CGFloat size = self.bounds.size.width / 2;
  //if (self.bounds.size.height < self.bounds.size.width) size = self.bounds.size.height / 2;
  //size *= self.scale; // scale is percentage of full view size
  
//  CGContextSetLineWidth(context, 5.0);
//  [[UIColor blueColor] setStroke];
  
  [AxesDrawer drawAxesInRect:rect originAtPoint:midPoint scale:1.0];
}


@end
