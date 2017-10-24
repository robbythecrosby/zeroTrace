//
//  homeView.m
//  ZER0trace Internal
//
//  Created by Robert Crosby on 10/9/17.
//  Copyright © 2017 fully toasted. All rights reserved.
//

#import "homeView.h"

@interface homeView ()

@end

@implementation homeView

- (void)viewDidLoad {
    
    [createJobs setBackgroundColor:[UIColor clearColor]];
    [recentJobs setBackgroundColor:[UIColor clearColor]];
    [upcomingJobs setBackgroundColor:[UIColor clearColor]];
    [References blurView:menuBar];
    [References createLine:self.view xPos:0 yPos:menuBar.frame.size.height inFront:YES];
    scrollView.contentSize = CGSizeMake([References screenWidth], recentJobs.frame.origin.y+recentJobs.frame.size.height+16);
    scrollView.frame = CGRectMake(0, 0, [References screenWidth], [References screenHeight]);
    [super viewDidLoad];
    // Create the reader object
    QRCodeReader *reader = [QRCodeReader readerWithMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    
    // Instantiate the view controller
    vc = [QRCodeReaderViewController readerWithCancelButtonTitle:@"Cancel" codeReader:reader startScanningAtLoad:YES showSwitchCameraButton:NO showTorchButton:NO];
    
    // Set the presentation style
    vc.modalPresentationStyle =  UIModalPresentationFormSheet;
    
    // Define the delegate receiver
    vc.delegate = self;
    // Or use blocks
    [reader setCompletionWithBlock:^(NSString *resultAsString) {
        [vc dismissViewControllerAnimated:YES completion:^(void) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"code = '%@'",resultAsString]];
            CKQuery *query = [[CKQuery alloc] initWithRecordType:@"Job" predicate:predicate];
            
            [[CKContainer defaultContainer].publicCloudDatabase performQuery:query
                                                                inZoneWithID:nil
                                                           completionHandler:^(NSArray *results, NSError *error) {
                                                               if (results.count > 0) {
                                                                   CKRecord *record = results[0];
                                                                   dispatch_sync(dispatch_get_main_queue(), ^{
                                                                           UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
                                                                           recorderView *controller = [mainStoryboard instantiateViewControllerWithIdentifier: @"recorderView"];
                                                                           controller.jobRecord = record;
                                                                           //menu is only an example
                                                                           [self presentViewController:controller animated:YES completion:nil];
                                                                       // Update the UI on the main thread.
                                                                   });
                                                                   
                                                               } else {
                                                                   dispatch_sync(dispatch_get_main_queue(), ^{
                                                                       [References toastMessage:@"Error" andView:self andClose:NO];
                                                                       // Update the UI on the main thread.
                                                                   });
                                                                   
                                                               }
                                                           }];
        }];
    }];
    [self getUpcoming:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createdNewJob) name:@"refreshJobs" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [References createLine:self.view xPos:0 yPos:menuBar.frame.size.height inFront:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        alert = [UIAlertController alertControllerWithTitle:@"Connecting"
                                                    message:@"Looking for Scanner..."
                                             preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:alert animated:YES completion:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [scannerCheck becomeFirstResponder];
        });
    });
    
    // Do any additional setup after loading the view.
}

-(void)createdNewJob {
    refreshingJobs = [UIAlertController alertControllerWithTitle:@"Publishing New Job"
                                                message:@"One Second..."
                                         preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:refreshingJobs animated:YES completion:nil];
    [self setVisibility];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self getUpcoming:YES];
    });
}

-(void)viewDidAppear:(BOOL)animated {
    if ([References screenWidth] > 1024) {
        [References toastMessage:@"ZER0trace is not optimized for this iPad. Please use a 9.7\" device." andView:self andClose:NO];
    }
}

- (void) keyboardWillShow:(NSNotification *)notification
{
    
    NSDictionary* userInfo = [notification userInfo];
    CGRect keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect keyboard = [self.view convertRect:keyboardFrame fromView:self.view.window];
    NSLog(@"%f",keyboard.size.height);
    if (keyboard.size.height > 100) {
        [checkScannerButton setTitle:@"No Scanner Found" forState:UIControlStateNormal];
    } else {
         [checkScannerButton setTitle:@"Scanner Connected" forState:UIControlStateNormal];
    }
    
    [scannerCheck resignFirstResponder];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [alert dismissViewControllerAnimated:YES completion:nil];
    });
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView.tag == 1) {
        // upcoming
        return nextJobs.count;
    } else if (collectionView.tag == 2){
        // past
         return completedJobs.count;
    } else {
        // new
        return 3;
    }
   
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (collectionView.tag == 1) {
        // upcoming
        static NSString *identifier = @"Cell";
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
        UILabel *card = (UILabel *)[cell viewWithTag:1];
        jobObject *job = nextJobs[indexPath.row];
        UILabel *client = (UILabel *)[cell viewWithTag:2];
        UILabel *code = (UILabel *)[cell viewWithTag:3];
        UIButton *deleteJob = (UIButton*)[cell viewWithTag:11];
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:deleteJob.bounds byRoundingCorners:(UIRectCornerBottomLeft | UIRectCornerBottomRight) cornerRadii:CGSizeMake(24.0, 24.0)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.view.bounds;
        maskLayer.path  = maskPath.CGPath;
        deleteJob.layer.mask = maskLayer;
        client.text = job.client;
        code.text = job.code;
        [References cornerRadius:card radius:24.0f];
        deleteJob.tag = (int)indexPath.row;
        [deleteJob addTarget:self action:@selector(handleDeleteButton:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    } else if (collectionView.tag == 2){
        // past
        jobObject *job = completedJobs[indexPath.row];
        static NSString *identifier = @"Cell";
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
        UILabel *card = (UILabel *)[cell viewWithTag:1];
        UILabel *date = (UILabel *)[cell viewWithTag:2];
        NSDateFormatter * formatter =  [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"EEEE, MMMM d"];
        date.text = [[formatter stringFromDate:job.dateCompleted] uppercaseString];
        UILabel *client = (UILabel *)[cell viewWithTag:3];
        client.text = job.client;
        UILabel *code = (UILabel *)[cell viewWithTag:4];
        code.text = job.code;
        UILabel *drives = (UILabel *)[cell viewWithTag:5];
        drives.text = [NSString stringWithFormat:@"%lu DRIVES",(unsigned long)job.driveTimes.count];
        [References cornerRadius:card radius:24.0f];
        return cell;
    } else {
        static NSString *identifier = @"Cell";
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
        UILabel *card = (UILabel *)[cell viewWithTag:1];
        UIImageView *icon = (UIImageView *)[cell viewWithTag:2];
        UILabel *title = (UILabel *)[cell viewWithTag:3];
        if (indexPath.row == 0) {
            [icon setImage:[UIImage imageNamed:@"code.png"]];
            title.text = @"Scan Code";
        }
        if (indexPath.row == 1) {
            [icon setImage:[UIImage imageNamed:@"text.png"]];
            title.text = @"Enter Code";
        }
        if (indexPath.row == 2) {
            [icon setImage:[UIImage imageNamed:@"plus.png"]];
            title.text = @"New Job";
        }
        [References cornerRadius:card radius:24.0f];
        return cell;
    }
    
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView.tag == 1) {
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
            recorderView *controller = [mainStoryboard instantiateViewControllerWithIdentifier: @"recorderView"];
            controller.jobRecord = nextJobRecords[indexPath.row];
            //menu is only an example
            [self presentViewController:controller animated:YES completion:nil];
    } else if (collectionView.tag == 2) {
        // past
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        pastJobView *controller = [mainStoryboard instantiateViewControllerWithIdentifier: @"pastJobView"];
        controller.modalPresentationStyle = UIModalPresentationFormSheet;
        controller.job = completedJobs[indexPath.row];
        //menu is only an example
        [self presentViewController:controller animated:YES completion:nil];
    } else {
        if (indexPath.row == 0) {
            [self presentViewController:vc animated:YES completion:nil];
        }
        if (indexPath.row == 1) {
            [References toastMessage:@"Not Activated" andView:self andClose:NO];
//            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Enter Code" message:@"Code is 5 characters long" preferredStyle:UIAlertControllerStyleAlert];
//            [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
//                textField.placeholder = @"00000";
//                textField.textAlignment = NSTextAlignmentCenter;
//            }];
//            UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Next" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                [self manualCode:[[alertController textFields][0] text]];
//            }];
//            [alertController addAction:confirmAction];
//            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//
//            }];
//            [alertController addAction:cancelAction];
//            [self presentViewController:alertController animated:YES completion:nil];
        }
        if (indexPath.row == 2) {
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
            manualJobViewViewController *controller = [mainStoryboard instantiateViewControllerWithIdentifier: @"manualJobViewViewController"];
            controller.modalPresentationStyle = UIModalPresentationFormSheet;
            //menu is only an example
            [self presentViewController:controller animated:YES completion:nil];
                // Update the UI on the main thread.
            
        }
    }
}


-(void)manualCode :(NSString*)code{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"code = '%@'",code]];
    CKQuery *query = [[CKQuery alloc] initWithRecordType:@"Job" predicate:predicate];
    
    [[CKContainer defaultContainer].publicCloudDatabase performQuery:query
                                                        inZoneWithID:nil
                                                   completionHandler:^(NSArray *results, NSError *error) {
                                                       if (results.count > 0) {
                                                           CKRecord *record = results[0];
                                                           dispatch_sync(dispatch_get_main_queue(), ^{
                                                               [UIView animateWithDuration:0.3 animations:^(void){
                                                                   //
                                                               }];
                                                               double delayInSeconds = 2.0;
                                                               dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                                                               dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                                                   UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
                                                                   recorderView *controller = [mainStoryboard instantiateViewControllerWithIdentifier: @"recorderView"];
                                                                   controller.jobRecord = record;
                                                                   //menu is only an example
                                                                   [self presentViewController:controller animated:YES completion:nil];
                                                               });
                                                               // Update the UI on the main thread.
                                                           });
                                                           
                                                       } else {
                                                           dispatch_sync(dispatch_get_main_queue(), ^{
                                                               [References toastMessage:@"Job Not Found" andView:self andClose:NO];
                                                               // Update the UI on the main thread.
                                                           });
                                                           
                                                       }
                                                   }];
}

-(void)newJob:(NSString *)title{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:@"Enter the clients code" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Client Code";
        textField.keyboardType = UIKeyboardTypeNumberPad;
        textField.secureTextEntry = NO;
    }];
    UIAlertAction *create = [UIAlertAction actionWithTitle:@"Create" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *code = [References randomIntWithLength:5];
        
        NSString *clientCode = [[alertController textFields][0] text];
        NSString __block *clientName = @"";
        CKRecordID *recordID = [[CKRecordID alloc] initWithRecordName:clientCode];
        [[CKContainer defaultContainer].publicCloudDatabase fetchRecordWithID:recordID completionHandler:^(CKRecord *record, NSError *error) {
            if (error) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                [self newJob:@"No Client Found"];
                });
                return;
            }
            clientName = [record valueForKey:@"clientName"];
            NSMutableArray *allJobCodes = [[NSMutableArray alloc] initWithArray:[record objectForKey:@"allJobCodes"]];
        
            [allJobCodes addObject:code];
            NSDateFormatter * formatter =  [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"EEEE, MMMM d"];
            NSMutableArray *allJobDates = [[NSMutableArray alloc] initWithArray:[record objectForKey:@"allJobDates"]];
            [allJobDates addObject:[formatter stringFromDate:[NSDate date]]];
            record[@"allJobCodes"] = allJobCodes;
            record[@"allJobDates"] = allJobDates;
            [[CKContainer defaultContainer].publicCloudDatabase saveRecord:record completionHandler:^(CKRecord *record, NSError *error) {
                NSLog(@"%@",error.localizedDescription);
                dispatch_sync(dispatch_get_main_queue(), ^{
                    CKRecord *record = [[CKRecord alloc] initWithRecordType:@"Job" recordID:[[CKRecordID alloc] initWithRecordName:code]];
                    record[@"client"] = clientName;
                    record[@"code"] = code;
                    [[CKContainer defaultContainer].publicCloudDatabase saveRecord:record completionHandler:^(CKRecord *record, NSError *error) {
                        if (!error) {
                            dispatch_sync(dispatch_get_main_queue(), ^{
                                [nextJobs addObject:[[jobObject alloc] initWithType:[record valueForKey:@"client"] andClientCode:[record valueForKey:@"clientCode"] andCode:[record valueForKey:@"code"] andURL:nil andDate:nil andSerials:nil andTimes:nil andSignature:nil]];
                                [nextJobRecords addObject:record];
                                [upcomingJobs reloadData];
                                [self setVisibility];
                            });
                        } else {
                            NSLog(@"%@",error.localizedDescription);
                        }

                    }];
                    });
            }];
        }];
        //compare the current password and do action here
        
    }];
    [alertController addAction:create];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    UIAlertAction *searchAction = [UIAlertAction actionWithTitle:@"See List of Codes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [References toastMessage:@"Coming Soon" andView:self andClose:NO];
    }];
    [alertController addAction:searchAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)reader:(QRCodeReaderViewController *)reader didScanResult:(NSString *)result
{
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"%@", result);
    }];
}

- (void)readerDidCancel:(QRCodeReaderViewController *)reader
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(void)getUpcoming:(BOOL)isNewJob{
    [nextJobs removeAllObjects];
    [completedJobs removeAllObjects];
    [nextJobRecords removeAllObjects];
    [completedJobs removeAllObjects];
    upcomingJobs.hidden = YES;
    recentJobs.hidden = YES;
    locallySaved = [[NSMutableArray alloc] init];
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSURL *documentsURL = [NSURL fileURLWithPath:documentsDirectory];
    for (NSString *file in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:&error]) {
        [locallySaved addObject:file];
    }
    nextJobs = [[NSMutableArray alloc] init];
    completedJobs = [[NSMutableArray alloc] init];
    nextJobRecords = [[NSMutableArray alloc] init];
    completedJobsRecord = [[NSMutableArray alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"TRUEPREDICATE"]];
    CKQuery *query = [[CKQuery alloc] initWithRecordType:@"Job" predicate:predicate];
    query.sortDescriptors = [NSArray arrayWithObject:[[NSSortDescriptor alloc]initWithKey:@"creationDate" ascending:false]];
    [[CKContainer defaultContainer].publicCloudDatabase performQuery:query
                                                        inZoneWithID:nil
                                                   completionHandler:^(NSArray *results, NSError *error) {
                                                       if (error) {
                                                           UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Unable To Connect" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
                                                           UIAlertAction *settings = [UIAlertAction actionWithTitle:@"Open Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
                                                               
                                                               [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"App-prefs:"]];
                                                           }];
                                                           UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action){
                                                               
                                                           }];
                                                           [alert addAction:settings];
                                                           [alert addAction:cancel];
                                                           [self presentViewController:alert animated:YES completion:nil];
                                                       }
                                                       if (results.count > 0) {
                                                           
                                                           for (int a = 0; a < results.count; a++) {
                                                               CKRecord *record = results[a];
                                                               if ([record valueForKey:@"videoURL"]) {
                                                                   NSArray *driveTimes = [record objectForKey:@"driveTimes"];
                                                                   NSArray *driveSerials = [record objectForKey:@"driveSerials"];
                                                                   NSData *signature = [record objectForKey:@"signatureData"];
                                                                   [completedJobs addObject:[[jobObject alloc] initWithType:[record valueForKey:@"client"]  andClientCode:[record valueForKey:@"clientCode"] andCode:[record valueForKey:@"code"] andURL:[record valueForKey:@"videoURL"] andDate:[record objectForKey:@"dateCompleted"] andSerials:driveSerials andTimes:driveTimes andSignature:signature]];
                                                                   [completedJobsRecord addObject:record];
                                                               } else {
                                                                   [nextJobs addObject:[[jobObject alloc] initWithType:[record valueForKey:@"client"] andClientCode:[record valueForKey:@"clientCode"] andCode:[record valueForKey:@"code"] andURL:nil andDate:nil andSerials:nil andTimes:nil andSignature:nil]];
                                                                   [nextJobRecords addObject:record];
                                                               }
                                                           }
                                                           dispatch_sync(dispatch_get_main_queue(), ^{
                                                               [upcomingJobs reloadData];
                                                               [recentJobs reloadData];
                                                               [self setVisibility];
                                                               // Update the UI on the main thread.
                                                           });
                                                           
                                                       } else {
                                                           dispatch_sync(dispatch_get_main_queue(), ^{
                                                               
                                                               [self setVisibility];
                                                               // Update the UI on the main thread.
                                                           });
                                                       }
                                                   }];
    if (isNewJob == YES) {
         [refreshingJobs dismissViewControllerAnimated:YES completion:nil];
    }
   
}

-(void)setVisibility {
    if (nextJobs.count < 1) {
        [References fadeIn:noUpcomingJobs];
        [References fadeLabelText:noUpcomingJobs newText:@"No Upcoming Jobs"];
    } else {
        [References fadeOut:noUpcomingJobs];
        [References fadeIn:upcomingJobs];
    }
    if (completedJobs.count < 1) {
        [References fadeIn:noPastJobs];
        [References fadeLabelText:noPastJobs newText:@"No Recent Jobs"];
    } else {
        [References fadeOut:noPastJobs];
        [References fadeIn:recentJobs];
    }
}
- (IBAction)checkScanner:(id)sender {
    alert = [UIAlertController alertControllerWithTitle:@"Connecting"
                                                message:@"Looking for Scanner..."
                                         preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alert animated:YES completion:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [scannerCheck becomeFirstResponder];
    });
}

- (IBAction)refreshButton:(id)sender {
    [self getUpcoming:NO];
}

-(void)handleDeleteButton:(id)sender {
    UIButton *button = (UIButton*)sender;
    [self deleteJobAtIndex:(int)button.tag];
}

-(void)deleteJobAtIndex:(int)indexInArray{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Confirm Cancellation of Job" message:@"This action is irreversible" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Cancel Job" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            deletingJob = [UIAlertController alertControllerWithTitle:@"Cancelling Job"
                                                              message:@"One Second..."
                                                       preferredStyle:UIAlertControllerStyleAlert];
            [self presentViewController:deletingJob animated:YES completion:nil];
            jobObject *job = nextJobs[indexInArray];
            CKRecordID *recordID = [[CKRecordID alloc] initWithRecordName:job.clientCode];
            [[CKContainer defaultContainer].publicCloudDatabase fetchRecordWithID:recordID completionHandler:^(CKRecord *record, NSError *error) {
                if (error) {
                    return;
                }
                NSMutableArray *jobCodes = [[NSMutableArray alloc] initWithArray:[record objectForKey:@"allJobCodes"]];
                NSMutableArray *jobDates = [[NSMutableArray alloc] initWithArray:[record objectForKey:@"allJobDates"]];
                for (int a = 0; a < jobCodes.count; a++) {
                    if ([jobCodes[a] isEqualToString:job.code]) {
                        [jobCodes removeObjectAtIndex:a];
                        [jobDates removeObjectAtIndex:a];
                        break;
                    }
                }
                record[@"allJobCodes"] = jobCodes;
                record[@"allJobDates"] = jobDates;
                [[CKContainer defaultContainer].publicCloudDatabase saveRecord:record completionHandler:^(CKRecord *record, NSError *error) {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        CKRecordID *recordID = [[CKRecordID alloc] initWithRecordName:job.code];
                        [[CKContainer defaultContainer].publicCloudDatabase deleteRecordWithID:recordID completionHandler:^(CKRecordID *recordID, NSError *error) {
                            dispatch_sync(dispatch_get_main_queue(), ^{
                                [deletingJob dismissViewControllerAnimated:YES completion:nil];
                                [self getUpcoming:NO];
                            });
                        }];
                        // Update the UI on the main thread.
                    });
                }];
            }];
        }];
    [alertController addAction:confirmAction];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Back" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}
@end
