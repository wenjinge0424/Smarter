//
//  Config.h
//
//  Created by IOS7 on 12/16/14.
//  Copyright (c) 2014 iOS. All rights reserved.
//

#import "AppStateManager.h"
/* ***************************************************************************/
/* ***************************** Paypal config ********************************/
/* ***************************************************************************/


/* ***************************************************************************/
/* ***************************** Stripe config ********************************/
/* ***************************************************************************/

#define STRIPE_KEY                                              @""
//#define STRIPE_KEY                              @""
#define STRIPE_URL                                              @"https://api.stripe.com/v1"
#define STRIPE_CHARGES                                          @"charges"
#define STRIPE_CUSTOMERS                                        @"customers"
#define STRIPE_TOKENS                                           @"tokens"
#define STRIPE_ACCOUNTS                                         @"accounts"
#define STRIPE_CONNECT_URL                                      @"https://stripe.smarter.brainyapps.tk"


#define APP_NAME                                                @"Smarter"

/* Friend / SO status values */
#define FRIEND_INVITE_SEND                                      @"Invite"
#define FRIEND_INVITE_ACCEPT                                    @"Accept"
#define FRIEND_INVITE_REJECT                                    @"Reject"

#define SO_INVITE_SEND                                          @"SOInviteSend"
#define SO_INVITE_ACCEPT                                        @"SOInviteAccept"
#define SO_INVITE_REJECT                                        @"SOInviteReject"

/* Pending Type values */
#define PENDING_TYPE_FRIEND_INVITE                              @"Pending_Friend_Invite"
#define PENDING_TYPE_SO_SEND                                    @"Pending_SO_Send"
#define PENDING_TYPE_INTANGIBLE_SEND                            @"Pending_Intangible_Send"

// Push Notification
#define PARSE_CLASS_NOTIFICATION_FIELD_TYPE                     @"type"
#define PARSE_CLASS_NOTIFICATION_FIELD_DATAINFO                 @"dataInfo"
#define PARSE_NOTIFICATION_APP_ACTIVE                           @"app_active"

/* Pagination values  */
#define PAGINATION_DEFAULT_COUNT                                10000
#define PAGINATION_START_INDEX                                  1

/* IWant Type values */
#define IWANT_INTANGIBLE_CATEGORY                                @"Intangible"

/* Notification values */
#define NOTIFICATION_SHOW_PENDING_PAGE                          @"ShowPending"
#define NOTIFICATION_HIDE_PENDING_PAGE                          @"HidePending"

#define NOTIFICATION_SHOW_INPUTSO_PAGE                          @"ShowInputSO"
#define NOTIFICATION_HIDE_INPUTSO_PAGE                          @"HideInputSO"

#define NOTIFICATION_SHOW_INTANGIBLE_PAGE                       @"ShowIntangible"
#define NOTIFICATION_HIDE_INTANGIBLE_PAGE                       @"HideIntangible"

#define NOTIFICATION_SHOW_SOPREVIEW_PAGE                        @"ShowSOPreview"
#define NOTIFICATION_HIDE_SOPREVIEW_PAGE                        @"HideSOPreview"

#define MAIN_COLOR                                              [UIColor colorWithRed:0/255.f green:202/255.f blue:37/255.f alpha:1.f]
#define MAIN_BORDER_COLOR                                       [UIColor colorWithRed:186/255.f green:186/255.f blue:186/255.f alpha:1.f]
#define MAIN_BORDER1_COLOR                                      [UIColor colorWithRed:209/255.f green:209/255.f blue:209/255.f alpha:1.f]
#define MAIN_BORDER2_COLOR                                      [UIColor colorWithRed:95/255.f green:95/255.f blue:95/255.f alpha:1.f]
#define MAIN_HEADER_COLOR                                       [UIColor colorWithRed:103/255.f green:103/255.f blue:103/255.f alpha:1.f]
#define MAIN_SWDEL_COLOR                                        [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
#define MAIN_DESEL_COLOR                                        [UIColor colorWithRed:206/255.f green:89/255.f blue:37/255.f alpha:1.f]
#define MAIN_HOLDER_COLOR                                       [UIColor colorWithRed:170/255.f green:170/255.f blue:170/255.f alpha:1.f]
#define MAIN_TRANS_COLOR                                        [UIColor colorWithRed:204/255.f green:227/255.f blue:244/255.f alpha:1.f]

/* Page Notifcation */
#define NOTIFICATION_START_PAGE                                 @"StartMainPage"
#define NOTIFICATION_SIGNIN_PAGE                                @"SignInPage"
#define NOTIFICATION_PASSWDRESET_PAGE                           @"PasswdResetPage"
#define NOTIFICATION_WANTLIST_PAGE                              @"WantListPage"
#define NOTIFICATION_PROFILE_PAGE                               @"ProfilePage"
#define NOTIFICATION_FRIENDS_PAGE                               @"FriendsPage"
#define NOTIFICATION_INVITE_PAGE                                @"InvitePage"
#define NOTIFICATION_INSTRUCTIONS_PAGE                          @"InstructionsPage"
#define NOTIFICATION_NEWITEM_PAGE                               @"NewItemPage"
#define NOTIFICATION_NEWCATEGORY_PAGE                           @"NewCategoryPage"
#define NOTIFICATION_HIDENEW_PAGE                               @"HideNewPage"

/* Refresh Notifcation */
#define NOTIFICATION_REFRESH_FRIENDS                            @"RefreshFriends"
#define NOTIFICATION_REFRESH_MYLIST                             @"RefreshMyList"
#define NOTIFICATION_CHANGED_PAGE                               @"ChangedPage"
#define NOTIFICATION_REFRESH_BADGE                              @"RefreshBadge"

/* Remote Notification Type values */
#define REMOTE_NF_TYPE_NEW_ITEM                                 @"New_Iwant_Item"
#define REMOTE_NF_TYPE_NEW_CATEGORY                             @"New_Category"
#define REMOTE_NF_TYPE_FRIEND_INVITE                            @"Friend_Invite"
#define REMOTE_NF_TYPE_INVITE_ACCEPT                            @"Invite_Result_Accept"
#define REMOTE_NF_TYPE_INVITE_REJECT                            @"Invite_Result_Reject"
#define REMOTE_NF_TYPE_CLICK_EMPTY_CATEGORY                     @"Click_Empty_Category"

#define NOTIFICATION_PAY_SUCCESS_EVENT                          @"payment_success"
#define NOTIFICATION_CREATE_SUCCESS                             @"create_success"
#define NOTIFICATION_SYNC_ACCEPTED                              @"sync_accepted"
#define NOTIFICATION_SYNC_PENDING                              @"sync_pending"

/* Smarter */
#define NOTIFICATION_JOIN_CLASS                                 1
#define NOTIFICATION_PARENT_SYNC                                2
#define NOTIFICATION_ACCEPTED                                   3
#define NOTIFICATION_DECLINED                                   4
#define NOTIFICATION_LEAVE                                      5
#define NOTIFICATION_REMOVE                                     6
#define NOTIFICATION_START_STUDY                                7

#define NOTIFICATION_STATE_PENDING                              0
#define NOTIFICATION_STATE_ACCEPT                               1
#define NOTIFICATION_STATE_REJECT                               2


/* JCWheelView Notification */
#define NOTIFICATION_SPIN_STOP                                  @"spin_stopped"

/* Spin Notification Data */
#define SPIN_POINT_X                                             @"point_x"
#define SPIN_POINT_Y                                             @"point_y"

#define USER_TYPE                                               [AppStateManager sharedInstance].user_type

enum {
    USER_TYPE_PARENT = 100,
    USER_TYPE_STUDENT = 200,
    USER_TYPE_TEACHER = 300
};

enum {
    FLAG_TERMS_OF_SERVERICE,
    FLAG_PRIVACY_POLICY,
    FLAG_ABOUT_THE_APP
};

/* Parse Table */
#define PARSE_FIELD_OBJECT_ID                                   @"objectId"
#define PARSE_FIELD_USER                                        @"user"
#define PARSE_FIELD_CHANNELS                                    @"channels"
#define PARSE_FIELD_CREATED_AT                                  @"createdAt"
#define PARSE_FIELD_UPDATED_AT                                  @"updatedAt"

/* User Table */
#define PARSE_TABLE_USER                                        @"User"
#define PARSE_USER_FULLNAME                                     @"fullName"
#define PARSE_USER_NAME                                         @"username"
#define PARSE_USER_EMAIL                                        @"email"
#define PARSE_USER_PASSWORD                                     @"password"
#define PARSE_USER_LOCATION                                     @"location"
#define PARSE_USER_TYPE                                         @"type"
#define PARSE_USER_AVATAR                                       @"avatar"
#define PARSE_USER_FACEBOOKID                                   @"facebookid"
#define PARSE_USER_GOOGLEID                                     @"googleid"
#define PARSE_USER_BUSINESS_ACCOUNT_ID                          @"accountId"
#define PARSE_USER_IS_BANNED                                    @"isBanned"
#define PARSE_USER_PARENT                                       @"parent"
#define PARSE_USER_TEACHER_LIST                                 @"teacherList"
#define PARSE_USER_STUDENT_LIST                                 @"studentList"
#define PARSE_USER_ACCOUNT_ID                                   @"accountId"

/* Guides Table */
#define PARSE_TABLE_GUIDES                                      @"Guides"
#define PARSE_GUIDES_PRICE                                      @"price"
#define PARSE_GUIDES_REFERENCE                                  @"reference"
#define PARSE_GUIDES_SUBJECT                                    @"subject"
#define PARSE_GUIDES_GRADE_LEVEL                                @"gradeLevel"
#define PARSE_GUIDES_OWNER                                      @"owner"
#define PARSE_GUIDES_TITLE                                      @"title"
#define PARSE_GUIDES_DESCRIPTION                                @"description"
#define PARSE_GUIDES_TEACHER_LIST                               @"teacherList"

#define PARSE_GUIDES_COUNT                                      @"count"

/* Notification Table */
#define PARSE_TABLE_NOTIFICATION                                @"Notification"
#define PARSE_NOTIFICATION_TO_USER                              @"toUser"
#define PARSE_NOTIFICATION_MESSAGE                              @"message"
#define PARSE_NOTIFICATION_FROM_USER                            @"fromUser"
#define PARSE_NOTIFICATION_STATE                                @"state"
#define PARSE_NOTIFICATION_TYPE                                 @"type"

/* Question Table */
#define PARSE_TABLE_QUESTION                                    @"Question"
#define PARSE_QUESTION_QUESTION                                 @"question"
#define PARSE_QUESTION_CORRECT_NUM                              @"correctAnswer"
#define PARSE_QUESTION_SUBJECT                                  @"subject"
#define PARSE_QUESTION_GRADE                                    @"gradeLevel"
#define PARSE_QUESTION_OWNER                                    @"owner"

#define PARSE_QUESTION_ANSWER_LIST                              @"answerList"

/* Study Logs Table */
#define PARSE_TABLE_STUDY_LOGS                                  @"StudyLogs"
#define PARSE_STUDY_IS_CORRECT                                  @"isCorrect"
#define PARSE_STUDY_QUESTION                                    @"question"
#define PARSE_STUDY_SUB_NUMBER                                  @"subNumber"
#define PARSE_STUDY_STUDY_NUMBER                                @"studyNumber"
#define PARSE_STUDY_OWNER                                       @"owner"
#define PARSE_STUDY_ANSWER                                      @"answer"

#define PARSE_STUDY_COUNT                                       @"count"
#define PARSE_STUDY_CORRECT_COUNT                               @"correctCount"

/* Payment History */
#define PARSE_TABLE_PAYMENT_HISTORY                             @"PaymentHistory"
#define PARSE_PAYMENT_TO_USER                                   @"toUser"
#define PARSE_PAYMENT_FROM_USER                                 @"fromUser"
#define PARSE_PAYMENT_AMOUNT                                    @"amount"
#define PARSE_PAYMENT_GUIDE_LIST                                @"guideList"

/* Assignment Table */
#define PARSE_TABLE_ASSIGNMENT                                  @"Assignment"
#define PARSE_ASSIGN_QUESTION                                   @"question"
#define PARSE_ASSIGN_CORRECT_ANSWER                             @"correctAnswer"
#define PARSE_ASSIGN_SUBNUMBER                                  @"subNumber"
#define PARSE_ASSIGN_OWNER                                      @"owner"
#define PARSE_ASSIGN_NUMBER                                     @"assignmentNumber"
#define PARSE_ASSIGN_TITLE                                      @"title"
#define PARSE_ASSIGN_ANSWER_LIST                                @"answerList"
#define PARSE_ASSIGN_COUNT                                      @"count"

/* Answer Logs */
#define PARSE_TABLE_ANSWER_LOGS                                 @"AnswerLogs"
#define PARSE_ANSWER_CORRECT                                    @"isCorrect"
#define PARSE_ANSWER_ASSIGNMENT                                 @"assignment"
#define PARSE_ANSWER_OWNER                                      @"owner"
#define PARSE_ANSWER_ASSIGNMENT_NUMBER                          @"assignmentNumber"
#define PARSE_ANSWER_ANSWER                                     @"answer"

/* temp */
#define PARSE_TABLE_TEMP                                        @"Temp"
#define PARSE_TEMP_USER                                         @"user"
#define PARSE_TEMP_TOTAL                                        @"total"
#define PARSE_TEMP_CORRECT                                      @"correct"


#define ARRAY_SUBJECT                                           [[NSArray alloc] initWithObjects:@"Art", @"Computer Science", @"English & Literature", @"Foreign Languages", @"Health", @"Home Economics", @"Life Skills", @"Mathematics", @"Music", @"Physical Education", @"Science", @"Social Studies", @"Special Education", @"Others", nil]
#define ARRAY_GRADE                                             [[NSArray alloc] initWithObjects:@"1", @"2", @"3", @"4", @"5", nil]
#define ARRAY_ANSWER                                            [[NSArray alloc] initWithObjects:@"A", @"B", @"C", @"D", @"Skipped", nil]

#define ARRAY_NUMBER_QUESTIONS                                  [AppStateManager sharedInstance].numberofQuestions
#define ARRAY_NUMBER_MINUTES                                    [AppStateManager sharedInstance].minutesofQuestions
#define ARRAY_NUMBER_AGE                                        [AppStateManager sharedInstance].ageofQuestions

#define ADMIN_EMAIL                                             [NSArray arrayWithObjects:@"aron@freesmarterapp.com", nil]
#define ALPHA_ARRAY                                             [NSArray arrayWithObjects:@"A", @"B", @"C", @"D", @"E", @"F", nil]

