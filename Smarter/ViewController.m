//
//  ViewController.m
//  PagaYa
//
//  Created by developer on 28/05/17.
//  Copyright © 2017 developer. All rights reserved.
//

#import "ViewController.h"
#import "LoginViewController.h"
#import "FLAnimatedImage.h"

@interface ViewController ()
{
    NSTimer * timer;
    int currentIndex;
}
@property (weak, nonatomic) IBOutlet UIImageView *m_imgView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [SVProgressHUD setForegroundColor:MAIN_COLOR];
    currentIndex = 0;
   timer = [NSTimer scheduledTimerWithTimeInterval:5.f/ 45.f target:self selector:@selector(onTimeFire:) userInfo:nil repeats:YES];
    [timer fire];
    
}
- (void) onTimeFire:(NSTimer*)timeMachine
{
    if(currentIndex < 45){
        [self.m_imgView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"splash%d", currentIndex]]];
        currentIndex++;
    }else{
        [timer invalidate];
        [self performSelector:@selector(gotoNextFlow) withObject:nil afterDelay:0.1f];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void) gotoNextFlow
{
    [self.m_imgView stopAnimating];
    LoginViewController *vc = (LoginViewController *)[Util getUIViewControllerFromStoryBoard:@"LoginViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
