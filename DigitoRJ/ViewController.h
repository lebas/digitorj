//
//  ViewController.h
//  DigitoRJ
//
//  Created by Eduardo on 01/02/13.
//  Copyright (c) 2013 Solution4Mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@interface ViewController : UIViewController < ABPeoplePickerNavigationControllerDelegate,ABPersonViewControllerDelegate, ABNewPersonViewControllerDelegate, ABUnknownPersonViewControllerDelegate>{
 
    IBOutlet UITextField *lsufixo;
    IBOutlet UISwitch *snewName;
    IBOutlet UIButton *bmigrar;
    IBOutlet UILabel *lasufixo, *lafundoCor;
    IBOutlet UIPopoverController *peoplePickerPopoverController;
    UIAlertView *alertsearch;
    Boolean alter, bnovo;
}
@property (nonatomic, retain) IBOutlet UITextField *lsufixo;
@property (nonatomic, retain) IBOutlet UISwitch *snewName;
@property (nonatomic, retain) IBOutlet UIButton *bmigrar;
@property (nonatomic, retain) IBOutlet UILabel *lasufixo, *lafundoCor;
@property (nonatomic, retain) IBOutlet UIPopoverController *peoplePickerPopoverController;

-(IBAction)saveContact:(id) sender;
-(IBAction)swapName:(id) sender;
-(IBAction)Info:(id) sender;
-(IBAction)OpenLinkS4M:(id)sender;
-(void)startFixed;
-(NSString *)startFormat:(NSString *)Number;

@end
