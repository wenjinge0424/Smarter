//
//  SignUpFourViewController.m
//  Smarter
//
//  Created by gao on 8/7/17.
//  Copyright © 2017 developer. All rights reserved.
//

#import "SignUpFourViewController.h"
#import "CircleImageView.h"
#import "PagerViewController.h"

@interface SignUpFourViewController ()<CircleImageAddDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    IBOutlet CircleImageView *imgAvatar;
    IBOutlet UITextField *txtUsername;
    
    IBOutlet UIButton *btnNotUse;
    IBOutlet UIButton *btnSignUp;
    
    BOOL hasPhoto;
    IBOutlet UIView *viewField;
    
    BOOL isCamera;
    BOOL isGallery;
    NSMutableArray *userNameList;
}
@end

@implementation SignUpFourViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [Util setCornerView:viewField];
    [Util setBorderView:imgAvatar color:[UIColor whiteColor] width:1.0];
    txtUsername.delegate = self;
    imgAvatar.delegate = self;
    isCamera = NO;
    isGallery = NO;
    [txtUsername addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    userNameList = [[NSMutableArray alloc] init];
    btnSignUp.enabled = NO;
    
    PFQuery *query = [PFUser query];
    [query setLimit:1000];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        [SVProgressHUD dismiss];
        if (error){
            [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
        } else {
            for (int i=0;i<objects.count;i++){
                PFUser *user = [objects objectAtIndex:i];
                [userNameList addObject:user[PARSE_USER_FULLNAME]];
            }
        }
    }];
}

-(void)textFieldDidChange :(UITextField *) textField{
    btnNotUse.selected = ![userNameList containsObject:[Util trim:textField.text]];
    btnSignUp.enabled = btnNotUse.selected;
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
- (IBAction)onSignUp:(id)sender {
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Error" message:@"No internet connectivity detected."];
        return;
    }
    if (![self isValid]){
        return;
    }
    if (hasPhoto){
        UIImage *profileImage = [Util getUploadingImageFromImage:imgAvatar.image];
        NSData *imageData = UIImageJPEGRepresentation(profileImage, 0.8);
        self.user[PARSE_USER_AVATAR] = [PFFile fileWithData:imageData];
    }
    self.user[PARSE_USER_FULLNAME] = txtUsername.text;
    self.user[PARSE_USER_STUDENT_LIST] = [NSMutableArray new];
    self.user[PARSE_USER_TEACHER_LIST] = [NSMutableArray new];
    [SVProgressHUD showWithStatus:@"Please wait..." maskType:SVProgressHUDMaskTypeGradient];
    [self.user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [SVProgressHUD dismiss];
        if (!error) {
            [Util setLoginUserName:self.user.username password:self.user.password];
            PagerViewController *vc = (PagerViewController *)[Util getUIViewControllerFromStoryBoard:@"PagerViewController"];
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            NSString *message = [error localizedDescription];
            if ([message containsString:@"already"]){
               message = @"Account already exists for this email.";
            }
            [Util showAlertTitle:self title:@"Error" message:message];
        }
    }];
}

- (BOOL) isValid {
    txtUsername.text = [Util trim:txtUsername.text];
    NSString *name = txtUsername.text;
    if (name.length == 0){
        [Util showAlertTitle:self title:@"Error" message:@"Please enter your username." finish:^(void){
            
        }];
        return NO;
    }
    if (![Util isContainsNumber:name] && ![Util isContainsLowerCase:name] &&![Util isContainsUpperCase:name]){
        [Util showAlertTitle:self title:@"Error" message:@"Please enter valid username."];
        return NO;
    }
    if (name.length > 20){
        [Util showAlertTitle:self title:@"Error" message:@"Username is too long. Please try again." finish:^(void){
            
        }];
        return NO;
    }
    if (name.length < 6){
        [Util showAlertTitle:self title:@"Error" message:@"Username is too short. Please try again." finish:^(void){
            
        }];
        return NO;
    }
    return YES;
}

- (void) tapCircleImageView {
    UIAlertController *actionsheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [actionsheet addAction:[UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self onTakePhoto:nil];
    }]];
    [actionsheet addAction:[UIAlertAction actionWithTitle:@"Gallery" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self onChoosePhoto:nil];
    }]];
    [actionsheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    [self presentViewController:actionsheet animated:YES completion:nil];
}

- (void) textFieldDidBeginEditing:(UITextField *)textField {
    btnNotUse.selected = NO;
    btnSignUp.enabled = NO;
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
    txtUsername.text = [Util trim:txtUsername.text];
//    if (![Util isConnectableInternet]){
//        [Util showAlertTitle:self title:@"Error" message:@"No internet connectivity detected."];
//        return;
//    }
//    NSString *username = txtUsername.text;
//    PFQuery *query = [PFUser query];
//    [query whereKey:PARSE_USER_FULLNAME equalTo:username];
//    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
//        [SVProgressHUD dismiss];
//        if (error){
//            [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
//        } else {
//            if (objects.count>0){
//                btnNotUse.selected = NO;
//                btnSignUp.enabled = NO;
//            } else {
//                btnNotUse.selected = YES;
//                btnSignUp.enabled = YES;
//            }
//        }
//    }];
}
- (void)onChoosePhoto:(id)sender {
    if (![Util isPhotoAvaileble]){
        [Util showAlertTitle:self title:@"Error" message:@"Check your permissions in Settings > Privacy > Photo"];
        return;
    }
    isGallery = YES;
    isCamera = NO;
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
    imagePickerController.delegate = self;
    imagePickerController.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)onTakePhoto:(id)sender {
    if (![Util isCameraAvailable]){
        [Util showAlertTitle:self title:@"Error" message:@"Check your permissions in Settings > Privacy > Cameras"];
        return;
    }
    isCamera = YES;
    isGallery = NO;
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
    imagePickerController.delegate = self;
    imagePickerController.sourceType =  UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    [picker dismissViewControllerAnimated:YES completion:nil];
    if (isCamera && ![Util isCameraAvailable]){
        [Util showAlertTitle:self title:@"Error" message:@"Check your permissions in Settings > Privacy > Cameras"];
        return;
    }
    if (isGallery && ![Util isPhotoAvaileble]){
        [Util showAlertTitle:self title:@"Error" message:@"Check your permissions in Settings > Privacy > Photo"];
        return;
    }
    UIImage *image = (UIImage *)[info valueForKey:UIImagePickerControllerOriginalImage];
    hasPhoto = YES;
    [imgAvatar setImage:image];
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
    if (isGallery && ![Util isPhotoAvaileble]){
        [Util showAlertTitle:self title:@"Error" message:@"Check your permissions in Settings > Privacy > Photo"];
        return;
    }
    if (isCamera && ![Util isCameraAvailable]){
        [Util showAlertTitle:self title:@"Error" message:@"Check your permissions in Settings > Privacy > Cameras"];
        return;
    }
}

@end
