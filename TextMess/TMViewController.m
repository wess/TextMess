//
//  TMViewController.m
//  TextMess
//
//  Created by Wess Cope on 10/25/12.
//  Copyright (c) 2012 Wess Cope. All rights reserved.
//

#import "TMViewController.h"
#import "TMView.h"

@interface TMViewController ()
@property (strong, nonatomic) TMView *tmView;
@end

@implementation TMViewController

- (id)init
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.autoresizesSubviews   = YES;
    self.view.autoresizingMask      = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    _tmView                   = [[TMView alloc] initWithFrame:self.view.bounds];
    _tmView.autoresizingMask  = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    [self.view addSubview:_tmView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
