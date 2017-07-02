//
//  ViewController.m
//  projectmtest
//
//  Created by Benjamin Baron on 7/2/17.
//  Copyright © 2017 Ben Baron. All rights reserved.
//

#import "ViewController.h"
#import "ProjectMView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    ProjectMView *e = [[ProjectMView alloc] init];
    e.frame = CGRectMake(0, 0, 512, 512);
    [self.view addSubview:e];
    
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
