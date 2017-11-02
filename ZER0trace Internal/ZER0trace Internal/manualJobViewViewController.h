//
//  manualJobViewViewController.h
//  ZER0trace Internal
//
//  Created by Robert Crosby on 10/23/17.
//  Copyright © 2017 fully toasted. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CloudKit/CloudKit.h>
#import "References.h"
#import "jobObject.h"
#import "homeView.h"

@interface manualJobViewViewController : UIViewController {
    NSString *code;
    __weak IBOutlet UILabel *codeView;
    CKRecord *newRecord;
    jobObject *newJob;
    __weak IBOutlet UIButton *backspace;
    __weak IBOutlet UIButton *clientList;
}
@property(nonatomic,assign)id delegate;
- (IBAction)append:(id)sender;
- (IBAction)deleteKey:(id)sender;
- (IBAction)next:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)clientList:(id)sender;

@end