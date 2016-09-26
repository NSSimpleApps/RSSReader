//
//  WebViewController.m
//  RSSReader
//
//  Created by NSSimpleApps on 31.05.15.
//  Copyright (c) 2015 NSSimpleApps. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation WebViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = (self.webLink).host;
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.webLink]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
