//
//  homeView.h
//  ZER0trace Internal
//
//  Created by Robert Crosby on 10/9/17.
//  Copyright © 2017 fully toasted. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "pastJobView.h"
#import <QRCodeReaderViewController/QRCodeReaderViewController.h>
#import <QRCodeReaderViewController/QRCodeReader.h>
#import <CloudKit/CloudKit.h>
#import "References.h"
#import "recorderView.h"
#import "jobObject.h"

@interface homeView : UIViewController <QRCodeReaderDelegate,UITextFieldDelegate,UICollectionViewDelegate,UICollectionViewDataSource> {
    QRCodeReaderViewController *vc;
    NSMutableArray *nextJobs,*completedJobs,*nextJobRecords,*completedJobsRecord,*locallySaved;
    __weak IBOutlet UILabel *menuBar;
    __weak IBOutlet UICollectionView *upcomingJobs;
    __weak IBOutlet UICollectionView *recentJobs;
    __weak IBOutlet UICollectionView *createJobs;
    __weak IBOutlet UIScrollView *scrollView;
    
    
    
    
    
    
}
@end