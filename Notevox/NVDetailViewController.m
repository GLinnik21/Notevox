//
//  NVDetailViewController.m
//  Notevox
//
//  Created by Linnik Gleb on 19.01.17.
//  Copyright © 2017 A&K. All rights reserved.
//

#import "NVDetailViewController.h"
#import "NSDate+DateTools.h"

@interface NVDetailViewController ()

@property (weak, nonatomic) IBOutlet UISwitch *dateToRemindSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *remindWithVoiceSwitch;

@property (weak, nonatomic) IBOutlet UITextField *taskDescription;
@property (weak, nonatomic) IBOutlet UILabel *remindDateLabel;
@property (weak, nonatomic) IBOutlet UIDatePicker *remindDatePicker;

@property (weak, nonatomic) IBOutlet UITableViewCell *labelsCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *datePickerCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *remindWithVoiceCell;

@end

@implementation NVDetailViewController

- (void)configureView {
    // Update the user interface for the detail item.
    [self.taskDescription setText:self.reminder.reminderTitle];
    [self.remindWithVoiceSwitch setOn:self.reminder.isCustomSound ? YES : NO];
    
    if (self.reminder.dateToRemind) {
        [self.remindDatePicker setDate:self.reminder.dateToRemind];
        [self.remindDatePicker setTimeZone:[NSTimeZone systemTimeZone]];
        [self.remindDateLabel setText:[NSDateFormatter localizedStringFromDate:self.reminder.dateToRemind dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterShortStyle]];
        [self.dateToRemindSwitch setOn:YES];
    } else {
        [self.dateToRemindSwitch setOn:NO];
        [self hideDateCells];
    }
}

- (IBAction)dateChanged:(id)sender {
    [self.remindDateLabel setText:[NSDateFormatter localizedStringFromDate:self.remindDatePicker.date dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterShortStyle]];
}

- (IBAction)descriptionChanged:(id)sender {
    if ([self.taskDescription.text isEqual: @""]) {
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
    } else {
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
    }
}

- (IBAction)switchChanged:(id)sender {
    if (sender == self.dateToRemindSwitch) {
        if (!self.dateToRemindSwitch.isOn) {
            [self hideDateCells];
            self.reminder.dateToRemind = nil;
        } else {
            [self showDateCells];
        }

    } else {
        if (self.remindWithVoiceSwitch.isOn) {
            self.reminder.isCustomSound = YES;
        } else {
            self.reminder.isCustomSound = NO;
        }
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
    [self.remindDateLabel setText:[NSDateFormatter localizedStringFromDate:self.remindDatePicker.date dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterShortStyle]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureView];
}

- (void)viewWillDisappear:(BOOL)animated {
    if (self.dateToRemindSwitch.isOn) {
        NSDateComponents *comps = [self.remindDatePicker.calendar components:
                                   (NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute)
                                                            fromDate:self.remindDatePicker.date];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        self.reminder.dateToRemind = [calendar dateFromComponents:comps];
    }
    self.reminder.reminderTitle = self.taskDescription.text;
    [super viewWillAppear:animated];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    return [textField resignFirstResponder];
}



@end
