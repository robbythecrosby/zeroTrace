//
//  ViewController.h
//  ZER0trace Internal
//
//  Created by Robert Crosby on 10/9/17.
//  Copyright © 2017 fully toasted. All rights reserved.
//

#import "References.h"
#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import <FirebaseStorage/FirebaseStorage.h>
#import <FirebaseDatabase/FIRDatabaseReference.h>
#import <LLSimpleCamera/LLSimpleCamera.h>
#import "driveObject.h"
#import <CloudKit/CloudKit.h>
#import "SignatureDrawView.h"
#import "unconfirmedJobObject.h"


@interface recorderView : UIViewController <UICollectionViewDelegate,UICollectionViewDataSource,UITextFieldDelegate> {
    NSDictionary *jobDict;
    bool finishRecording;
    FIRDatabaseReference *jobListenerObject;
    NSURL *camera1,*camera2;
    bool useSimulator;
    bool firstRecord;
    int clipCount;
    bool beforeRecording;
    __weak IBOutlet UILabel *statusBarReal;
    CKRecordID *newJobRecord;
    int saveProgress;
    NSMutableArray *scannedDrives;
    int driveCount,recorderTimeInt;
    NSTimer *recorderTime;
    NSURL *outputURL;
    NSURL *compressedOutURL;
    bool isRecording;
    __weak IBOutlet UITextField *barcode;
    LLSimpleCamera *recorder;
    __weak IBOutlet UIButton *recordButton;
    __weak IBOutlet UILabel *drivesScanned;
    __weak IBOutlet UIButton *simulateScan;
    __weak IBOutlet UILabel *timeLabel;
    __weak IBOutlet UILabel *drivesCollectionBlur;
    __weak IBOutlet UICollectionView *drivesCollectionView;
    __weak IBOutlet UILabel *jobName;
    NSString *code;
    __weak IBOutlet UIScrollView *completeView;
    __weak IBOutlet UILabel *completeTitle;
    __weak IBOutlet UILabel *completeSubtitle;
    __weak IBOutlet UIProgressView *completeProgress;
    __weak IBOutlet UILabel *signatureCard;
    __weak IBOutlet UILabel *clientCode;
    __weak IBOutlet UILabel *signatureSub;
    __weak IBOutlet UIButton *confirmDestructionButton;
    __weak IBOutlet UIButton *cancel;
    __weak IBOutlet SignatureDrawView *signatureView;
    NSData *signatureData;
    UIImage *signatureImage;
    NSURL *signatureURL;
    __weak IBOutlet UIButton *destructionButton;
    __weak IBOutlet UILabel *statusBar;
    __weak IBOutlet UIButton *comppleteRecordingStep;
    __weak IBOutlet UILabel *cam1Status;
    __weak IBOutlet UILabel *cam2Status;
    __weak IBOutlet UILabel *cam3Status;
    __weak IBOutlet UILabel *cam4Status;
    __weak IBOutlet UIButton *cancelAfterStart;
    
}
- (IBAction)toggleRecording:(id)sender;


- (IBAction)simulateScan:(id)sender;
@property (nonatomic, strong) unconfirmedJobObject *job;
@property (nonatomic, assign) NSString *recordID;
- (IBAction)confirmDestruction:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)completeRecordingStep:(id)sender;
- (IBAction)cancelAfterStart:(id)sender;

@end

