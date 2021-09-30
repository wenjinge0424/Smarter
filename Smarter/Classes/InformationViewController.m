//
//  InformationViewController.m
//  Smarter
//
//  Created by gao on 8/31/17.
//  Copyright © 2017 developer. All rights reserved.
//

#import "InformationViewController.h"

@interface InformationViewController ()
{
    IBOutlet UILabel *lblTitle;
    
    IBOutlet UIWebView *webView;
}
@end

@implementation InformationViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [Util setCornerView:webView];
    
    NSString *docName = @"";
    if (self.type == FLAG_TERMS_OF_SERVERICE){
        docName = @"termsofservice";
        lblTitle.text = @"Terms and Conditions";
    } else if (self.type == FLAG_PRIVACY_POLICY){
        docName = @"privacypolicy";
        lblTitle.text = @"Privacy Policy";
    } else if (self.type == FLAG_ABOUT_THE_APP){
        docName = @"aboutapp";
        lblTitle.text = @"About the App";
    }
    
    NSString *htmlFile = [[NSBundle mainBundle] pathForResource:docName ofType:@"html"];
    NSString *htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSStringEncodingConversionAllowLossy  error:nil];
    [webView loadHTMLString:htmlString baseURL:[[NSBundle mainBundle] bundleURL]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
