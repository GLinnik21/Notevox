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
    [self.remindDatePicker setDate:self.reminder.dateToRemind];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[self taskDescription] setDelegate:self];
    
    [self configureView];
}

- (void)viewWillDisappear:(BOOL)animated {
    self.reminder.dateToRemind = self.remindDatePicker.date;
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
