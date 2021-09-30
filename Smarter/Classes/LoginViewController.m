//
//  LoginViewController.m
//  Smarter
//
//  Created by gao on 8/7/17.
//  Copyright © 2017 developer. All rights reserved.
//

#import "LoginViewController.h"
#import "PagerViewController.h"
#import "UserOptionViewController.h"
#import "ResetPasswordViewController.h"
#import "StudentViewController.h"
#import "ParentViewController.h"
#import "TeacherViewController.h"

#import "FLAnimatedImage.h"

@interface LoginViewController ()<GIDSignInUIDelegate, GIDSignInDelegate>
{
    IBOutlet UITextField *txtEmail;
    IBOutlet UITextField *txtPassword;
}
@property (weak, nonatomic) IBOutlet UIImageView *login_image;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [Util appDelegate].rootNavigationViewController = self.navigationController;
    
    
    NSURL * imageFileUrl = [[NSBundle mainBundle] URLForResource:@"splash" withExtension:@"gif"];
    FLAnimatedImage * image = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfURL:imageFileUrl]];
    FLAnimatedImageView * img_splash =  [[FLAnimatedImageView alloc] initWithFrame:self.login_image.bounds];
    [img_splash setAnimatedImage:image];
    [self.login_image addSubview:img_splash];
    
    
    if ([Util getLoginUserName].length > 0){
        txtEmail.text = [Util getLoginUserName];
        txtPassword.text = [Util getLoginUserPassword];
        [self onLogin:nil];
    }
    
    [GIDSignIn sharedInstance].delegate = self;
    [GIDSignIn sharedInstance].uiDelegate = self;
    
    txtEmail.delegate = self;
    txtPassword.delegate = self;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    txtEmail.text = [Util getLoginUserName];
    txtPassword.text = [Util getLoginUserPassword];
    
    [Util setBorderView:txtEmail color:COLOR_TRANSPARENT width:1.0];
    [Util setBorderView:txtPassword color:COLOR_TRANSPARENT width:1.0];
    [txtEmail resignFirstResponder];
    [txtPassword resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onGoogle:(id)sender {
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Error" message:@"No internet connectivity detected."];
        return;
    }
    [[GIDSignIn sharedInstance] signIn];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (IBAction)onFacebook:(id)sender {
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Error" message:@"No internet connectivity detected."];
        return;
    }
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [PFFacebookUtils logInInBackgroundWithReadPermissions:@[@"public_profile", @"email", @"user_friends"] block:^(PFUser *user, NSError *error)
     {
         if (user != nil) {
             if (user[@"facebookid"] == nil) {
                 PFUser *puser = [PFUser user];
                 puser = user;
                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                 [self requestFacebook:puser];
             } else {
                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                 [self userLoggedIn:user];
             }
         } else {
             [MBProgressHUD hideHUDForView:self.view animated:YES];
             [Util showAlertTitle:self title:@"" message:@"Failed to login via Facebook."];
         }
     }];
}

- (void)requestFacebook:(PFUser *)user
{
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    [parameters setValue:@"id,name,first_name,last_name,birthday,email" forKey:@"fields"];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me"
                                                                   parameters:parameters];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        if (error == nil)
        {
            NSDictionary *userData = (NSDictionary *)result;
            [self processFacebook:user UserData:userData];
        }
        else
        {
            [Util setLoginUserName:@"" password:@""];
            [PFUser logOut];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [Util showAlertTitle:self title:@"Oops!" message:@"Failed to fetch Facebook profile."];
        }
    }];
}

- (void)processFacebook:(PFUser *)user UserData:(NSDictionary *)userData
{
    NSString *link = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", userData[@"id"]];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:link]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFImageResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         if (responseObject) {
             user.username = userData[@"name"];
             user.password = [Util randomStringWithLength:20];
             user[PARSE_USER_FULLNAME] = [NSString stringWithFormat:@"%@ %@", userData[@"first_name"], userData[@"last_name"]];
             user[PARSE_USER_FACEBOOKID] = userData[@"id"];
             if (userData[@"email"]) {
                 user.email = userData[@"email"];
                 user.username = user.email;
             } else {
                 NSString *name = [[userData[@"name"] lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
                 user.email = [NSString stringWithFormat:@"%@@facebook.com",name];
                 user.username = user.email;
             }
             
             UIImage *profileImage = [Util getUploadingImageFromImage:responseObject];
             NSData *imageData = UIImageJPEGRepresentation(profileImage, 0.8);
             NSString *filename = [NSString stringWithFormat:@"avatar.png"];
             PFFile *imageFile = [PFFile fileWithName:filename data:imageData];
             user[PARSE_USER_AVATAR] = imageFile;
             
             //             [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
             //              {
             //                  [MBProgressHUD hideHUDForView:self.view animated:YES];
             //                  [Util setLoginUserName:user.email password:user.password type:0];
             //                  [PFUser logOutInBackgroundWithBlock:^(NSError *error) {
             //                      self.emailField.text = user.email;
             //                      self.passwdField.text = user.password;
             //                      [self onLogin:nil];
             //                  }];
             //              }];
             [MBProgressHUD hideHUDForView:self.view animated:YES];
             UserOptionViewController *vc = (UserOptionViewController *)[Util getUIViewControllerFromStoryBoard:@"UserOptionViewController"];
             vc.user = user;
             [self.navigationController pushViewController:vc animated:YES];
             
         } else {
             [Util setLoginUserName:@"" password:@""];
             [PFUser logOut];
             [MBProgressHUD hideHUDForView:self.view animated:YES];
             [Util showAlertTitle:self title:@"Oops!" message:@"Failed to fetch Facebook profile picture."];
         }
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         [Util setLoginUserName:@"" password:@""];
         [PFUser logOut];
         [MBProgressHUD hideHUDForView:self.view animated:YES];
         [Util showAlertTitle:self title:@"Oops!" message:@"Failed to fetch Facebook profile picture."];
     }];
    
    [[NSOperationQueue mainQueue] addOperation:operation];
}

- (void)userLoggedIn:(PFUser *)user {
    /* login */
    user.password = [Util randomStringWithLength:20];
    [Util setLoginUserName:user.email password:user.password];
    [SVProgressHUD showWithStatus:@"Please Wait..." maskType:SVProgressHUDMaskTypeGradient];
    [user saveInBackgroundWithBlock:^(BOOL success, NSError *error) {
        [PFUser logOutInBackgroundWithBlock:^(NSError *error) {
            [SVProgressHUD dismiss];
            txtEmail.text = user.email;
            txtPassword.text = user.password;
            [self onLogin:nil];
        }];
    }];
}

/* Google Login */
//  "Sign in with Google" delegate
- (void)signInWillDispatch:(GIDSignIn *)signIn error:(NSError *)error {
}

// Present a view that prompts the user to sign in with Google
- (void)signIn:(GIDSignIn *)signIn presentViewController:(UIViewController *)viewController {
    [self presentViewController:viewController animated:YES completion:nil];
}
- (void)signIn:(GIDSignIn *)signIn dismissViewController:(UIViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    if (error) {
        [Util showAlertTitle:self title:@"Oops!" message:@"Failed to login Google."];
    } else {
        NSString *passwd = [Util randomStringWithLength:20];
        NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                              user.profile.email, @"username",
                              user.userID, @"googleid",
                              passwd, @"password",
                              nil];
        
        [SVProgressHUD showWithStatus:@"Please Wait..." maskType:SVProgressHUDMaskTypeGradient];
        [SVProgressHUD setForegroundColor:MAIN_COLOR];
        PFQuery *query = [PFUser query];
        [query whereKey:PARSE_USER_EMAIL equalTo:user.profile.email];
        [query whereKeyDoesNotExist:PARSE_USER_GOOGLEID];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *obj, NSError *error){
            if (obj){
                [SVProgressHUD dismiss];
                [[GIDSignIn sharedInstance] signOut];
                [Util showAlertTitle:self title:@"Error" message:@"Account already exists for this email."];
            } else {
                [PFCloud callFunctionInBackground:@"resetGooglePasswd" withParameters:data block:^(id object, NSError *err) {
                    if (err) { // this user is not registered on parse server
                        PFUser *puser = [PFUser user];
                        puser.password = passwd;
                        puser[PARSE_USER_FULLNAME] = [NSString stringWithFormat:@"%@ %@", user.profile.givenName, user.profile.familyName];
                        puser[PARSE_USER_GOOGLEID] = user.userID;
                        puser.email = user.profile.email;
                        puser.username = puser.email;
                        
                        if (user.profile.hasImage) {
                            NSURL *imageURL = [user.profile imageURLWithDimension:50*50];
                            UIImage *im = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageURL]];
                            UIImage *profileImage = [Util getUploadingImageFromImage:im];
                            NSData *imageData = UIImageJPEGRepresentation(profileImage, 0.8);
                            NSString *filename = [NSString stringWithFormat:@"avatar.png"];
                            PFFile *imageFile = [PFFile fileWithName:filename data:imageData];
                            puser[PARSE_USER_AVATAR] = imageFile;
                        }
                        
                        //                [puser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        //                    [SVProgressHUD dismiss];
                        //                    if (!error) {
                        //                        _txtUserEmail.text = user.profile.email;
                        //                        _txtPassword.text = passwd;
                        //                        [self onLogin:nil];
                        //                    } else {
                        //                        [Util showAlertTitle:self title:@"" message:@"This email has already been used. Please try logging in."];
                        //                    }
                        //                }];
                        [SVProgressHUD dismiss];
                        UserOptionViewController *vc = (UserOptionViewController *)[Util getUIViewControllerFromStoryBoard:@"UserOptionViewController"];
                        vc.user = puser;
                        [self.navigationController pushViewController:vc animated:YES];
                    } else { // this server is registerd on parse server
                        double delayInSeconds = 1.0;
                        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                            txtEmail.text = user.profile.email;
                            txtPassword.text = passwd;
                            [self onLogin:nil];
                        });
                    }
                }];
            }
        }];
    }
}


- (IBAction)onResetPassword:(id)sender {
    ResetPasswordViewController *vc = (ResetPasswordViewController *)[Util getUIViewControllerFromStoryBoard:@"ResetPasswordViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onLogin:(id)sender {
    if (![Util isConnectableInternet]){
        if ([SVProgressHUD isVisible]){
            [SVProgressHUD dismiss];
        }
        [Util showAlertTitle:self title:@"Error" message:@"No internet connectivity detected."];
        return;
    }
    
    if (![self isValid]){
        return;
    }
    
    [SVProgressHUD showWithStatus:@"Please wait..." maskType:SVProgressHUDMaskTypeGradient];
    PFQuery *query = [PFUser query];
    [query whereKey:PARSE_USER_EMAIL equalTo:txtEmail.text];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error && object) {
            PFUser *user = (PFUser *)object;
            NSString *username = user.username;
            [PFUser logInWithUsernameInBackground:username password:txtPassword.text block:^(PFUser *user, NSError *error) {
                [SVProgressHUD dismiss];
                if (user) {
                    [Util setLoginUserName:user.email password:txtPassword.text];
                    if (!user[PARSE_USER_TYPE]){
                        UserOptionViewController *vc = (UserOptionViewController *)[Util getUIViewControllerFromStoryBoard:@"UserOptionViewController"];
                        vc.user = user;
                        [self.navigationController pushViewController:vc animated:YES];
                    } else {
                        [AppStateManager sharedInstance].user_type = [user[PARSE_USER_TYPE] integerValue];
                        [self gotoNextScreen];
                    }
                } else {
                    if (![Util isConnectableInternet]){
                        if ([SVProgressHUD isVisible]){
                            [SVProgressHUD dismiss];
                        }
                        [Util showAlertTitle:self title:@"Error" message:@"No internet connectivity detected."];
                        return;
                    }
                    [Util setBorderView:txtPassword color:COLOR_RED width:1.0];
                    NSString *errorString = @"Incorrect password. Please try again.";
                    [Util showAlertTitle:self title:@"Login Failed" message:errorString finish:^{
                        [txtPassword becomeFirstResponder];
                    }];
                }
            }];
        } else {
            if (![Util isConnectableInternet]){
                if ([SVProgressHUD isVisible]){
                    [SVProgressHUD dismiss];
                }
                [Util showAlertTitle:self title:@"Error" message:@"No internet connectivity detected."];
                return;
            }
            [SVProgressHUD dismiss];
            [Util setLoginUserName:@"" password:@""];
            [Util setBorderView:txtEmail color:COLOR_RED width:1.0];
            
            NSString *msg = @"Unregistered email. Please try again or sign up with a new account.";
            SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
            alert.customViewColor = MAIN_COLOR;
            alert.horizontalButtons = YES;
            [alert addButton:@"Try again" actionBlock:^(void) {
            }];
            [alert addButton:@"Sign Up" actionBlock:^(void) {
                [self onSignUp:self];
            }];
            [alert showError:@"Sign Up" subTitle:msg closeButtonTitle:nil duration:0.0f];
        }
    }];
}

- (void) gotoNextScreen {
    if (![Util getBoolValue:@"isFirst"]){
        [Util setBoolValue:@"isFirst" value:YES];
        PagerViewController *vc = (PagerViewController *)[Util getUIViewControllerFromStoryBoard:@"PagerViewController"];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        if (USER_TYPE == USER_TYPE_STUDENT){// student
            StudentViewController *vc = (StudentViewController *)[Util getUIViewControllerFromStoryBoard:@"StudentViewController"];
            [self.navigationController pushViewController:vc animated:YES];
        } else if (USER_TYPE == USER_TYPE_PARENT){// parent
            ParentViewController *vc = (ParentViewController *)[Util getUIViewControllerFromStoryBoard:@"ParentViewController"];
            [self.navigationController pushViewController:vc animated:YES];
        } else if (USER_TYPE == USER_TYPE_TEACHER){// teacher
            TeacherViewController *vc = (TeacherViewController *)[Util getUIViewControllerFromStoryBoard:@"TeacherViewController"];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

- (BOOL) isValid {
    [self.view endEditing:YES];
    NSString *errMsg = @"";
    txtEmail.text = [Util trim:txtEmail.text];
    NSString *email = txtEmail.text;
    NSString *password = txtPassword.text;
    
    [Util setBorderView:txtEmail color:COLOR_TRANSPARENT width:1.0];
    [Util setBorderView:txtPassword color:COLOR_TRANSPARENT width:1.0];
    
    if (![email isEmail] && email.length > 0){
        errMsg = [errMsg stringByAppendingString:@"Please enter valid email."];
        [Util showAlertTitle:self title:@"Error" message:errMsg];
        [Util setBorderView:txtEmail color:COLOR_RED width:1.0];
        return NO;
    }
    
    if ([email containsString:@".."] && email.length > 0){
        errMsg = [errMsg stringByAppendingString:@"Please enter valid email."];
        [Util showAlertTitle:self title:@"Error" message:errMsg];
        [Util setBorderView:txtEmail color:COLOR_RED width:1.0];
        return NO;
    }
    
    if ([password containsString:@" "]){
        [Util setBorderView:txtPassword color:COLOR_RED width:1.0];
        [Util showAlertTitle:self title:@"Error" message:@"Blank space is not allowed in password."];
        return NO;
    }
    
    if (email.length == 0 && password.length == 0){
        [Util setBorderView:txtEmail color:COLOR_RED width:1.0];
        [Util setBorderView:txtPassword color:COLOR_RED width:1.0];
        errMsg = [errMsg stringByAppendingString:@"Please enter your email and password."];
    } else if (email.length > 0 && password.length == 0){
        [Util setBorderView:txtPassword color:COLOR_RED width:1.0];
        errMsg = [errMsg stringByAppendingString:@"Please enter your password."];
    } else if (email.length == 0 && password.length > 0){
        [Util setBorderView:txtEmail color:COLOR_RED width:1.0];
        errMsg = [errMsg stringByAppendingString:@"Please enter your email."];
    }
    
    if (errMsg.length > 0){
        [Util showAlertTitle:self title:@"Error" message:errMsg];
        return NO;
    }
    
    if (![email isEmail] && email.length > 0){
        errMsg = [errMsg stringByAppendingString:@"Please enter valid email."];
        [Util showAlertTitle:self title:@"Error" message:errMsg];
        [Util setBorderView:txtEmail color:COLOR_RED width:1.0];
        return NO;
    }
    
    return YES;
}

- (IBAction)onSignUp:(id)sender {
    UserOptionViewController *vc = (UserOptionViewController *)[Util getUIViewControllerFromStoryBoard:@"UserOptionViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) textFieldDidBeginEditing:(UITextField *)textField {
    [Util setBorderView:txtEmail color:COLOR_TRANSPARENT width:1.0];
    [Util setBorderView:txtPassword color:COLOR_TRANSPARENT width:1.0];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    if (textField == txtEmail){
        [txtPassword becomeFirstResponder];
    } else if (textField == txtPassword){
        [self.view endEditing:YES];
    }
    return YES;
}

@end
