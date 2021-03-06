//
//  loginView.m
//  ZER0trace External
//
//  Created by Robert Crosby on 11/13/17.
//  Copyright © 2017 fully toasted. All rights reserved.
//

#define animationSpeed 0.5f

#import "loginView.h"



@interface loginView ()



@end

@implementation loginView



- (void)viewDidLoad {
    currentCard = 0;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated {
    signIn.alpha = 0;
    jobCode.alpha = 0;
    signUp.alpha = 0;
    [References cornerRadius:card radius:16.0f];
    [References cardshadow:card];
    cardOrigin = scroll.bounds;
    scroll.frame = CGRectMake(0, scroll.frame.origin.y+[References screenHeight], [References screenWidth], [References screenHeight]);
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"client"]) {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isPending"] == YES) {
            [UIView animateWithDuration:1.0f animations:^(void){
                header.text = [NSString stringWithFormat:@"Almost Ready, %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"client"]];
                subHeader.text = @"You'll recieve an email when your account is ready";
                header.frame = CGRectMake(header.frame.origin.x, header.frame.origin.y+100, header.frame.size.width, header.frame.size.height);
                subHeader.frame = CGRectMake(subHeader.frame.origin.x, subHeader.frame.origin.y+100, subHeader.frame.size.width, subHeader.frame.size.height);
                forceSignInButton.hidden = NO;
            } completion:^(bool complete){
                if (complete) {
                    nil;
                }
            }];
        } else {
            [UIView animateWithDuration:1.0f animations:^(void){
                header.text = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"client"]];
                subHeader.hidden = YES;
            } completion:^(bool complete){
            }];
        }
    }
}

-(void)viewDidAppear:(BOOL)animated {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isPending"] == YES) {
    } else {
        if (![[NSUserDefaults standardUserDefaults] objectForKey:@"client"]) {
            [self prepareScene];
        } else {
            [UIView animateWithDuration:1.0f animations:^(void){
                header.frame = CGRectMake(header.frame.origin.x, 20, header.frame.size.width, header.frame.size.height);
            } completion:^(bool complete){
                if (complete) {
                    double delayInSeconds = 1.0;
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
                        clientView *controller = [mainStoryboard instantiateViewControllerWithIdentifier: @"clientView"];
                        controller.modalTransitionStyle   = UIModalTransitionStyleCrossDissolve;
                        controller.modalPresentationStyle = UIModalPresentationFullScreen;
                        [self presentViewController:controller animated:YES completion:nil];
                    });
                }
            }];
        }
    }
}

-(void)prepareScene {
    double delayInSeconds = 1.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [UIView animateWithDuration:1.0f animations:^(void){
            scroll.frame = CGRectMake(0, scroll.frame.origin.y-[References screenHeight], [References screenWidth], [References screenHeight]);
            signUp.alpha = 1;
            signIn.alpha = 1;
            jobCode.alpha = 1;
        }];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(bool)textFieldShouldReturn:(UITextField *)textField {
    if (currentCard == 0) {
        if (textField == username) {
            [password becomeFirstResponder];
        } else {
            [textField resignFirstResponder];
        }
    }
    if (currentCard == 1) {
        [textField resignFirstResponder];
    }
    if (currentCard == 2) {
        if (textField == username) {
            [password becomeFirstResponder];
        }
        if (textField == password) {
            [contactName becomeFirstResponder];
            [UIView animateWithDuration:0.5f animations:^(void){
                scroll.frame = CGRectMake(0, scroll.frame.origin.y-55, scroll.frame.size.width, scroll.frame.size.height);
            }];
        }
        if (textField == contactName) {
            [contactPhone becomeFirstResponder];
            [UIView animateWithDuration:0.5f animations:^(void){
                scroll.frame = CGRectMake(0, scroll.frame.origin.y-55, scroll.frame.size.width, scroll.frame.size.height);
            }];
        }
        if (textField == contactPhone) {
            [companyName becomeFirstResponder];
            [UIView animateWithDuration:0.5f animations:^(void){
                scroll.frame = CGRectMake(0, scroll.frame.origin.y-60, scroll.frame.size.width, scroll.frame.size.height);
            }];
        }
        if (textField == companyName) {
            [textField resignFirstResponder];
            [UIView animateWithDuration:0.5f animations:^(void){
                scroll.frame = CGRectMake(0, scroll.frame.origin.y+165, scroll.frame.size.width, scroll.frame.size.height);
            }];
        }
        
    }
    
    return YES;
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (IBAction)goToSignIn:(id)sender {
    if (currentCard == 0) {
        [UIView animateWithDuration:0.15f animations:^(void){
            scroll.frame = CGRectMake(0, scroll.frame.origin.y+50, [References screenWidth], [References screenHeight]);
        } completion:^(bool complete){
            [UIView animateWithDuration:0.15f animations:^(void){
                scroll.frame = CGRectMake(0, scroll.frame.origin.y-50, [References screenWidth], [References screenHeight]);
            }];
        }];
    } else {
        currentCard = 0;
        [UIView animateWithDuration:animationSpeed animations:^(void){
            scroll.frame = CGRectMake(0, scroll.frame.origin.y+[References screenHeight], [References screenWidth], [References screenHeight]);
        } completion:^(bool complete){
            username.placeholder = @"example@email.com";
            usernameHeader.text = @"ACCOUNT EMAIL ADDRESS";
            companyName.hidden = YES;
            companyNameHeader.hidden = YES;
            usernameHeader.hidden = NO;
            username.hidden = NO;
            password.hidden = NO;
            passwordHeader.hidden = NO;
            contactName.hidden = YES;
            contactNameHeader.hidden = YES;
            contactPhone.hidden = YES;
            contactPhoneHeader.hidden = YES;
            [UIView animateWithDuration:animationSpeed animations:^(void){
                scroll.frame = CGRectMake(0, scroll.frame.origin.y-[References screenHeight], [References screenWidth], [References screenHeight]);
            }];
        }];
    }
}

- (IBAction)goToJobCode:(id)sender {
    if (currentCard == 1) {
        [UIView animateWithDuration:0.15f animations:^(void){
            scroll.frame = CGRectMake(0, scroll.frame.origin.y+50, [References screenWidth], [References screenHeight]);
        } completion:^(bool complete){
            [UIView animateWithDuration:0.15f animations:^(void){
                scroll.frame = CGRectMake(0, scroll.frame.origin.y-50, [References screenWidth], [References screenHeight]);
            }];
        }];
    } else {
        currentCard = 1;
        [UIView animateWithDuration:animationSpeed animations:^(void){
            scroll.frame = CGRectMake(0, scroll.frame.origin.y+[References screenHeight], [References screenWidth], [References screenHeight]);
        } completion:^(bool complete){
            usernameHeader.text = @"JOB CODE";
            username.placeholder = @"00000";
            username.text = @"";
            password.text = @"";
            companyName.hidden = YES;
            companyNameHeader.hidden = YES;
            usernameHeader.hidden = NO;
            username.hidden = NO;
            password.hidden = YES;
            passwordHeader.hidden = YES;
            contactName.hidden = YES;
            contactNameHeader.hidden = YES;
            contactPhone.hidden = YES;
            contactPhoneHeader.hidden = YES;
            [UIView animateWithDuration:animationSpeed animations:^(void){
                scroll.frame = CGRectMake(0, scroll.frame.origin.y-[References screenHeight], [References screenWidth], [References screenHeight]);
            }];
        }];
    }
}

- (IBAction)goToSignUp:(id)sender {
    if (currentCard == 2) {
        [UIView animateWithDuration:0.15f animations:^(void){
            scroll.frame = CGRectMake(0, scroll.frame.origin.y+50, [References screenWidth], [References screenHeight]);
        } completion:^(bool complete){
            [UIView animateWithDuration:0.15f animations:^(void){
                scroll.frame = CGRectMake(0, scroll.frame.origin.y-50, [References screenWidth], [References screenHeight]);
            }];
        }];
    } else {
        currentCard = 2;
        [UIView animateWithDuration:animationSpeed animations:^(void){
            scroll.frame = CGRectMake(0, scroll.frame.origin.y+[References screenHeight], [References screenWidth], [References screenHeight]);
        } completion:^(bool complete){
            username.text = @"";
            password.text = @"";
            usernameHeader.text = @"ACCOUNT EMAIL ADDRESS";
            username.placeholder = @"email@company.com";
            usernameHeader.hidden = NO;
            companyName.hidden = NO;
            companyNameHeader.hidden = NO;
            username.hidden = NO;
            password.hidden = NO;
            passwordHeader.hidden = NO;
            contactName.hidden = NO;
            contactNameHeader.hidden = NO;
            contactPhone.hidden = NO;
            contactPhoneHeader.hidden = NO;
            [UIView animateWithDuration:animationSpeed animations:^(void){
                scroll.frame = CGRectMake(0, scroll.frame.origin.y-[References screenHeight], [References screenWidth], [References screenHeight]);
            }];
        }];
    }
}

- (IBAction)continueButton:(id)sender {
    if (currentCard == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
        [[FIRAuth auth] signInWithEmail:username.text
                               password:password.text
                             completion:^(FIRUser *user, NSError *error) {
                                 if (error) {
                                           [References toastMessage:error.localizedDescription andView:self andClose:YES];
                                     return;
                                 }
                                 NSArray *usernameText = [username.text componentsSeparatedByString:@"@"];
                                 FIRDatabaseReference *reference = [[[FIRDatabase database] reference] child:usernameText[0]];
                                 [reference observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                                     NSDictionary *user = snapshot.value;
                                     [[NSUserDefaults standardUserDefaults] setObject:[user valueForKey:@"email"] forKey:@"email"];
                                     [[NSUserDefaults standardUserDefaults] setObject:[user valueForKey:@"phone"] forKey:@"phone"];
                                     [[NSUserDefaults standardUserDefaults] setObject:[user valueForKey:@"code"] forKey:@"code"];
                                     [[NSUserDefaults standardUserDefaults] setObject:[user valueForKey:@"client"] forKey:@"client"];
                                     [reference removeAllObservers];
                                     [[NSUserDefaults standardUserDefaults] synchronize];
                                     [UIView animateWithDuration:1.0f animations:^(void){
                                         header.text = [NSString stringWithFormat:@"Hi, %@",[user valueForKey:@"client"]];
                                         subHeader.text = @"One second...";
                                         header.frame = CGRectMake(header.frame.origin.x, header.frame.origin.y+100, header.frame.size.width, header.frame.size.height);
                                         subHeader.frame = CGRectMake(subHeader.frame.origin.x, subHeader.frame.origin.y+100, subHeader.frame.size.width, subHeader.frame.size.height);
                                         signIn.frame = CGRectMake(signIn.frame.origin.x, signIn.frame.origin.y+[References screenHeight], signIn.frame.size.width, signIn.frame.size.height);
                                         signUp.frame = CGRectMake(signUp.frame.origin.x, signUp.frame.origin.y+[References screenHeight], signUp.frame.size.width, signUp.frame.size.height);
                                         jobCode.frame = CGRectMake(jobCode.frame.origin.x, jobCode.frame.origin.y+[References screenHeight], jobCode.frame.size.width, jobCode.frame.size.height);
                                         scroll.frame = CGRectMake(scroll.frame.origin.x, scroll.frame.origin.y+[References screenHeight], scroll.frame.size.width, scroll.frame.size.height);
                                     } completion:^(bool complete){
                                         if (complete) {
                                             double delayInSeconds = 1.0;
                                             dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                                             dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                                 UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
                                                 clientView *controller = [mainStoryboard instantiateViewControllerWithIdentifier: @"clientView"];
                                                 [self presentViewController:controller animated:YES completion:nil];
                                             });
                                         }
                                     }];
                                 }];
                             }];
              });
    } else if (currentCard == 2) {
        FIRDatabaseReference *refJobs = [[FIRDatabase database] reference];
        NSString *code = [References randomIntWithLength:5];
        NSArray *usernameText = [username.text componentsSeparatedByString:@"@"];
        [[FIRAuth auth] createUserWithEmail:username.text
                                   password:password.text
                                 completion:^(FIRUser *_Nullable user, NSError *_Nullable error){
                                     if (!error) {
                                         [[refJobs child:code] setValue:@{} withCompletionBlock:^(NSError * _Nullable __strong error, FIRDatabaseReference * _Nonnull __strong ref){
               if (!error) {
                           FIRDatabaseReference *reference = [[FIRDatabase database] reference];
                    [[reference child:usernameText[0]] setValue:@{
                                  @"client" : companyName.text,
                                  @"email" : username.text,
                                  @"contact" : contactName.text,
                                  @"phone"   : contactPhone.text,
                                  @"code"    : code
                                  } withCompletionBlock:^(NSError * _Nullable __strong error, FIRDatabaseReference * _Nonnull __strong ref){
                                      if (!error) {
                                          [[NSUserDefaults standardUserDefaults] setObject:contactPhone.text forKey:@"phone"];
                                          [[NSUserDefaults standardUserDefaults] setObject:username.text forKey:@"email"];
                                          [[NSUserDefaults standardUserDefaults] setObject:code forKey:@"code"];
                                          [[NSUserDefaults standardUserDefaults] setObject:companyName.text forKey:@"client"];
                                          [[NSUserDefaults standardUserDefaults] synchronize];
                                          [UIView animateWithDuration:1.0f animations:^(void){
                                              header.text = [NSString stringWithFormat:@"Hi, %@",companyName.text];
                                              subHeader.text = @"One second...";
                                              header.frame = CGRectMake(header.frame.origin.x, header.frame.origin.y+100, header.frame.size.width, header.frame.size.height);
                                              subHeader.frame = CGRectMake(subHeader.frame.origin.x, subHeader.frame.origin.y+100, subHeader.frame.size.width, subHeader.frame.size.height);
                                              signIn.frame = CGRectMake(signIn.frame.origin.x, signIn.frame.origin.y+[References screenHeight], signIn.frame.size.width, signIn.frame.size.height);
                                              signUp.frame = CGRectMake(signUp.frame.origin.x, signUp.frame.origin.y+[References screenHeight], signUp.frame.size.width, signUp.frame.size.height);
                                              jobCode.frame = CGRectMake(jobCode.frame.origin.x, jobCode.frame.origin.y+[References screenHeight], jobCode.frame.size.width, jobCode.frame.size.height);
                                              scroll.frame = CGRectMake(scroll.frame.origin.x, scroll.frame.origin.y+[References screenHeight], scroll.frame.size.width, scroll.frame.size.height);
                                          } completion:^(bool complete){
                                              if (complete) {
                                                  double delayInSeconds = 1.0;
                                                  dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                                                  dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                                      UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
                                                      clientView *controller = [mainStoryboard instantiateViewControllerWithIdentifier: @"clientView"];
                                                      [self presentViewController:controller animated:YES completion:nil];
                                                  });
                                              }
                                          }];
                                      } else {
                                          [References toastMessage:error.localizedDescription andView:self andClose:NO];
                                      }
                                  }];
                                                                                                  }
                                                                                              }];
                                        
                                     } else {
                                         [References toastMessage:error.localizedDescription andView:self andClose:NO];
                                     }
                                     
                                 }];
    }
}

- (IBAction)forceSignIn:(id)sender {
    [self prepareScene];
    forceSignInButton.hidden = YES;
}
@end
