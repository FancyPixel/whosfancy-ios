//
//  FPViewController.m
//  WhosFancy
//
//  Created by Andrea Mazzini on 30/06/14.
//  Copyright (c) 2014 Fancy Pixel. All rights reserved.
//

#import "FPViewController.h"
#import "FPBeaconHelper.h"

@interface FPViewController () <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITextField *emailText;
@property (nonatomic, weak) IBOutlet UITextField *passwordText;
@property (nonatomic, weak) IBOutlet UISwitch *trackSwitch;

@end

@implementation FPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:@"Who's Fancy?"];
    
    [self.emailText setText:[FPBeaconHelper sharedHelper].email];
    [self.passwordText setText:[FPBeaconHelper sharedHelper].password];
    [self.trackSwitch setOn:[FPBeaconHelper sharedHelper].track];
    
    [self.emailText.layer setBorderColor:[UIColor colorWithRed:192.0/255.0 green:57.0/255.0 blue:43.0/255.0 alpha:1].CGColor];
    [self.passwordText.layer setBorderColor:[UIColor colorWithRed:192.0/255.0 green:57.0/255.0 blue:43.0/255.0 alpha:1].CGColor];
    [self.emailText.layer setBorderWidth:2];
    [self.passwordText.layer setBorderWidth:2];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [textField setText:[textField.text stringByReplacingCharactersInRange:range withString:string]];

    [[FPBeaconHelper sharedHelper] setEmail:self.emailText.text];
    [[FPBeaconHelper sharedHelper] setPassword:self.passwordText.text];
    [[FPBeaconHelper sharedHelper] saveUser];

    return NO;
}

- (IBAction)actionSwitch:(UISwitch *)sender
{
    [[FPBeaconHelper sharedHelper] setTrack:sender.isOn];
    [[FPBeaconHelper sharedHelper] saveUser];
    
    if (sender.isOn) {
        [[FPBeaconHelper sharedHelper] startMonitoring];
    } else {
        [[FPBeaconHelper sharedHelper] stopMonitoring];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UIView* view in self.view.subviews) {
        if ([view isKindOfClass:[UITextField class]])
			[view resignFirstResponder];
    }
}

@end
