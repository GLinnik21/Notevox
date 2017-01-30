//
//  NVDetailViewController.m
//  Notevox
//
//  Created by Глеб Линник on 19.01.17.
//  Copyright © 2017 ARobot. All rights reserved.
//

#import "NVDetailViewController.h"

@interface NVDetailViewController ()

@end

@implementation NVDetailViewController

- (void)configureView {
    // Update the user interface for the detail item.
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissViewController)];
    self.navigationItem.rightBarButtonItem = doneButton;
    
    [self.taskDescription setText:self.reminder.reminderTitle];
    [self.remindWithVoiceSwitch setOn:self.reminder.isCustomSound ? YES : NO];
    
    if (self.reminder.dateToRemind) {
        [self.remindDatePicker setDate:self.reminder.dateToRemind];
        [self.remindDatePicker setTimeZone:[NSTimeZone systemTimeZone]];
        [self.remindDateLabel setText:[self formateDateStringfromDate:self.reminder.dateToRemind]];
        [self.dateToRemindSwitch setOn:YES];
    } else {
        [self.dateToRemindSwitch setOn:NO];
        [self hideDateCells];
    }
}

- (IBAction)dateChanged:(id)sender {
    [self.remindDateLabel setText:[self formateDateStringfromDate:self.remindDatePicker.date]];
}

- (IBAction)descriptionChanged:(id)sender {
    if ([self.taskDescription.text isEqual: @""]) {
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
    } else {
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
    }
}

- (IBAction)dateSwitchChanged:(id)sender {
    if (!self.dateToRemindSwitch.isOn) {
        [self hideDateCells];
        self.reminder.dateToRemind = nil;
    } else {
        [self showDateCells];
    }
}

- (IBAction)voiceSwitchChanged:(id)sender {
    if (self.remindWithVoiceSwitch.isOn) {
        self.reminder.isCustomSound = YES;
    } else {
        self.reminder.isCustomSound = NO;
    }
}

- (void)hideDateCells {
    [self.labelsCell setHidden:YES];
    [self.datePickerCell setHidden:YES];
    [self.remindWithVoiceCell setHidden:YES];
}

- (void)showDateCells {
    [self.labelsCell setHidden:NO];
    [self.datePickerCell setHidden:NO];
    [self.remindWithVoiceCell setHidden:NO];
    [self.remindDateLabel setText:[self formateDateStringfromDate:self.remindDatePicker.date]];
}

- (NSString *)formateDateStringfromDate:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [NSLocale currentLocale];
    dateFormatter.timeZone = [NSTimeZone systemTimeZone];
    dateFormatter.dateFormat = @"EEE, dd MMM yyyy HH:mm";
    return [dateFormatter stringFromDate:date];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[self taskDescription] setDelegate:self];
    
    [self configureView];
}

- (void)viewWillDisappear:(BOOL)animated {
    if (self.dateToRemindSwitch.isOn) {
        NSDateComponents *comps = [self.remindDatePicker.calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute)
                                                            fromDate:self.remindDatePicker.date];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        self.reminder.dateToRemind = [calendar dateFromComponents:comps];
    }
    self.reminder.reminderTitle = self.taskDescription.text;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dismissViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    return [textField resignFirstResponder];
}



@end
