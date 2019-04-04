//
//  DetailsViewController.m
//  RSSReader
//
//  Created by NSSimpleApps on 31.05.15.
//  Copyright (c) 2015 NSSimpleApps. All rights reserved.
//

#import "DetailsViewController.h"
#import "WebViewController.h"
@interface DetailsViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation DetailsViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithData:[self.details dataUsingEncoding:NSUnicodeStringEncoding]
                                                                            options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType }
                                                                 documentAttributes:nil
                                                                              error:nil];
    self.textView.attributedText = attributedString;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"ShowWebViewSegue"]) {
        
        WebViewController *webViewController = segue.destinationViewController;
        webViewController.webLink = self.webLink;
    }
}

@end
