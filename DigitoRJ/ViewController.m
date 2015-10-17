//
//  ViewController.m
//  DigitoRJ
//
//  Created by Eduardo on 01/02/13.
//  Copyright (c) 2013 Solution4Mac. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize bmigrar;
@synthesize peoplePickerPopoverController;
@synthesize lsufixo;
@synthesize lasufixo;
@synthesize lafundoCor;
@synthesize snewName;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    bnovo = YES;
    [snewName setOn:YES];
    [lsufixo setText:@"DigitoRJ"];
    [snewName setOn:bnovo];
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    [theTextField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [lsufixo resignFirstResponder];
}

-(IBAction)swapName:(id) sender {
    if ([snewName isOn]) {
        lsufixo.hidden = NO;
        lasufixo.hidden = NO;
        lafundoCor.hidden = NO;
        
    }else {
        lsufixo.hidden = YES;
        lasufixo.hidden = YES;
        lafundoCor.hidden = YES;
    }
}

-(void)startFixed {
    ABAddressBookRef addressBook = ABAddressBookCreate();
    NSArray *array = (__bridge NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFErrorRef anError = NULL;
    NSString *npNumber;
    for (int i = 0; i < [array count]; i++) {
        alter = NO;
        ABRecordRef person = (__bridge ABRecordRef) array[i];
        NSString *Label;        
        ABMultiValueRef multiPhones = ABRecordCopyValue((__bridge ABRecordRef)(array[i]),kABPersonPhoneProperty);
        ABMutableMultiValueRef multi = ABMultiValueCreateMutableCopy(multiPhones);
        for(CFIndex j=0;j<ABMultiValueGetCount(multi);++j) {
            CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(multiPhones, j);
            Label = (__bridge NSString *)(ABMultiValueCopyLabelAtIndex(multiPhones, j));
            NSString *pNumber = (__bridge NSString *) phoneNumberRef;
            pNumber = [[[[[pNumber stringByReplacingOccurrencesOfString:@"-" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""]stringByReplacingOccurrencesOfString:@"+" withString:@""] stringByReplacingOccurrencesOfString:@"(" withString:@""] stringByReplacingOccurrencesOfString:@")" withString:@""];
            npNumber = [self startFormat:pNumber];
            if (![npNumber isEqualToString:pNumber]) {
                alter = YES;
                if (bnovo){
                    Label = [NSString stringWithFormat:@"%@ - %@",[[Label stringByReplacingOccurrencesOfString:@"_$!<" withString:@""]stringByReplacingOccurrencesOfString:@">!$_" withString:@""], [lsufixo text]];
                }
                ABMultiValueAddValueAndLabel(multi, (__bridge CFStringRef)npNumber, (__bridge CFStringRef)(Label), NULL);
            }
        }
        if (alter) {
            if (!bnovo) {
                for(CFIndex j=0;j<ABMultiValueGetCount(multi);++j) {
                    CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(multi, j);
                    NSString *pNumber = (__bridge NSString *) phoneNumberRef;
                    pNumber = [[[[[pNumber stringByReplacingOccurrencesOfString:@"-" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""]stringByReplacingOccurrencesOfString:@"+" withString:@""] stringByReplacingOccurrencesOfString:@"(" withString:@""] stringByReplacingOccurrencesOfString:@")" withString:@""];
                    npNumber = [self startFormat:pNumber];
                    if (![npNumber isEqualToString:pNumber]) {
                        BOOL didRemove = ABMultiValueRemoveValueAndLabelAtIndex(multi,j);
                        BOOL didSet = ABRecordSetValue(person, kABPersonPhoneProperty, multi, nil);
                        ABRecordSetValue((__bridge ABRecordRef)(array[i]), kABPersonPhoneProperty, multi, &anError);
                        j--;

                    }
                }
            }
            ABRecordSetValue((__bridge ABRecordRef)(array[i]), kABPersonPhoneProperty, multi, &anError);
            ABAddressBookRef aBook;
            CFErrorRef error = NULL;
            aBook = ABAddressBookCreate();
            BOOL isAdded = ABAddressBookAddRecord (addressBook, (__bridge ABRecordRef)(array[i]), &error);
            BOOL isSaved = ABAddressBookSave (addressBook,NULL);
        }
    }
    CFRelease(addressBook);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)saveContact:(id) sender {
     alertsearch = [[UIAlertView alloc] initWithTitle:@"Migrando Contatos ..." message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles: nil];

    [alertsearch setTag:555];
    [alertsearch show];
    
    [bmigrar setEnabled:FALSE];
    bnovo = [snewName isOn];
    NSString *msg = nil;
    
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {

            [self startFixed];
        });
        msg = @"Seus contatos foram alterados com sucesso. Obrigado por usar DigitoRJ";
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        // The user has previously given access, add the contact
        [self startFixed];
        msg = @"Seus contatos foram alterados com sucesso. Obrigado por usar DigitoRJ";
    }
    else {

        msg = @"O DigitoRJ não tem permissão para rodar nesse dispositivo. Altere as permissões de antes rodar o DigitoRJ. Obrigado por usar DigitoRJ";
    }
    [alertsearch dismissWithClickedButtonIndex:0 animated:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"DigitoRJ" message:msg delegate:nil cancelButtonTitle:@"OK"otherButtonTitles: nil];
    [alert show];
}

- (void)peoplePickerNavigationControllerDidCancel:
(ABPeoplePickerNavigationController *)peoplePicker {
    [self dismissModalViewControllerAnimated:YES];
}

- (BOOL)peoplePickerNavigationController:
(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    
    [self displayPerson:person];
    [self dismissModalViewControllerAnimated:YES];
    
    return NO;
}

- (BOOL)peoplePickerNavigationController:
(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier
{
    return NO;
}

- (void)displayPerson:(ABRecordRef)person
{
    //NSString* name = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    NSString* phone = nil;
    ABMultiValueRef phoneNumbers = ABRecordCopyValue(person,
                                                     kABPersonPhoneProperty);
    if (ABMultiValueGetCount(phoneNumbers) > 0) {
        phone = (__bridge_transfer NSString*)
        ABMultiValueCopyValueAtIndex(phoneNumbers, 0);
    } else {
        phone = @"[None]";
    }
    CFRelease(phoneNumbers);
}

-(NSString *)startFormat:(NSString *)Number {
    if (Number != Nil){
        if ([Number  length] > 7) {
            int tam = [Number length];
            NSRange range1, range2, range4, range7, rangeE;
            if (tam == 8) {
                range1 = [Number rangeOfString:@"3"];
                range2 = [Number rangeOfString:@"2"];
                range4 = [Number rangeOfString:@"4"];
                range7 = [Number rangeOfString:@"7"];
                rangeE = [Number rangeOfString:@"*"];
                if (range1.location != 0 && range2.location != 0 && range4.location != 0 && range7.location != 0 && rangeE.length == 0 ) {
                    Number = [NSString stringWithFormat:@"9%@",Number];

                    return Number;
                }
            }else if (tam == 10) {
                range1 = [Number rangeOfString:@"21"];
                if (range1.location == 0) {
                    range1 = [Number rangeOfString:@"3"];
                    range4 = [Number rangeOfString:@"4"];
                    range7 = [Number rangeOfString:@"7"];
                    rangeE = [Number rangeOfString:@"*"];
                    if (range1.location != 2 &&  ![[Number substringWithRange:NSMakeRange(2, 1)] isEqual: @"2"] && range4.location != 2 && range7.location != 2 && rangeE.length == 0 ) {
                        Number = [NSString stringWithFormat:@"219%@",[Number substringWithRange:NSMakeRange(2, 8)]];
    
                        return Number;
                    }                    
                }
                
                range1 = [Number rangeOfString:@"22"];
                if (range1.location == 0) {
                    range1 = [Number rangeOfString:@"3"];
                    range4 = [Number rangeOfString:@"4"];
                    range7 = [Number rangeOfString:@"7"];
                    rangeE = [Number rangeOfString:@"*"];

                    if (range1.location != 2 &&  ![[Number substringWithRange:NSMakeRange(2, 1)] isEqual: @"2"] && range4.location != 2 && range7.location != 2 && rangeE.length == 0 ) {
                        Number = [NSString stringWithFormat:@"229%@",[Number substringWithRange:NSMakeRange(2, 8)]];
                        return Number;
                    }
                }

                range1 = [Number rangeOfString:@"24"];
                if (range1.location == 0) {
                    range1 = [Number rangeOfString:@"3"];
                    range4 = [Number rangeOfString:@"4"];
                    range7 = [Number rangeOfString:@"7"];
                    rangeE = [Number rangeOfString:@"*"];

                    if (range1.location != 2 &&  ![[Number substringWithRange:NSMakeRange(2, 1)] isEqual: @"2"] && range4.location != 2 && range7.location != 2 && rangeE.length == 0 ) {
                        Number = [NSString stringWithFormat:@"249%@",[Number substringWithRange:NSMakeRange(2, 8)]];
                        return Number;
                    }
                }
 
            }else if (tam == 12) {
                range1 = [Number rangeOfString:@"5521"];
                if (range1.location == 0) {
                    range1 = [Number rangeOfString:@"3"];
                    range4 = [Number rangeOfString:@"4"];
                    range7 = [Number rangeOfString:@"7"];
                    rangeE = [Number rangeOfString:@"*"];

                    if (range1.location != 4 && ![[Number substringWithRange:NSMakeRange(4, 1)] isEqual: @"2"] && range4.location != 4 && range7.location != 4 && rangeE.length == 0 ) {

                        Number = [NSString stringWithFormat:@"+55219%@",[Number substringWithRange:NSMakeRange(4, 8)]];
                        return Number;
                    }
                }
                
                range1 = [Number rangeOfString:@"5522"];
                if (range1.location == 0) {
                    range1 = [Number rangeOfString:@"3"];
                    range4 = [Number rangeOfString:@"4"];
                    range7 = [Number rangeOfString:@"7"];
                    rangeE = [Number rangeOfString:@"*"];

                    if (range1.location != 4 && ![[Number substringWithRange:NSMakeRange(4, 1)] isEqual: @"2"] && range4.location != 4 && range7.location != 4 && rangeE.length == 0 ) {

                        Number = [NSString stringWithFormat:@"+55229%@",[Number substringWithRange:NSMakeRange(4, 8)]];
                
                        return Number;
                    }
                }
                
                range1 = [Number rangeOfString:@"5524"];
                if (range1.location == 0) {
                    range1 = [Number rangeOfString:@"3"];
                    range4 = [Number rangeOfString:@"4"];
                    range7 = [Number rangeOfString:@"7"];
                    rangeE = [Number rangeOfString:@"*"];

                    if (range1.location != 4 && ![[Number substringWithRange:NSMakeRange(4, 1)] isEqual: @"2"] && range4.location != 4 && range7.location != 4 && rangeE.length == 0 ) {
   
                        Number = [NSString stringWithFormat:@"+55249%@",[Number substringWithRange:NSMakeRange(4, 8)]];

                        return Number;
                    }
                }
                
            }else if (tam == 13) {
                range1 = [Number rangeOfString:@"0"];
                range2 = [Number rangeOfString:@"21"];
                if (range1.location == 0 && range2.location == 3) {
                    range1 = [Number rangeOfString:@"3"];
                    range4 = [Number rangeOfString:@"4"];
                    range7 = [Number rangeOfString:@"7"];
                    rangeE = [Number rangeOfString:@"*"];

                    if (range1.location != 5 && ![[Number substringWithRange:NSMakeRange(5, 1)] isEqual: @"2"] && range4.location != 5 && range7.location != 5 && rangeE.length == 0 ) {
                        Number = [NSString stringWithFormat:@"0%@219%@",[Number substringWithRange:NSMakeRange(1, 2)], [Number  substringWithRange:NSMakeRange(5, 8)]];

                        return Number;
                    }
                }
                
                range1 = [Number rangeOfString:@"0"];
                range2 = [Number rangeOfString:@"22"];
                if (range1.location == 0 && range2.location == 3) {
                    range1 = [Number rangeOfString:@"3"];
                    range4 = [Number rangeOfString:@"4"];
                    range7 = [Number rangeOfString:@"7"];
                    rangeE = [Number rangeOfString:@"*"];

                    if (range1.location != 5 && ![[Number substringWithRange:NSMakeRange(5, 1)] isEqual: @"2"] && range4.location != 5 && range7.location != 5 && rangeE.length == 0 ) {
                        Number = [NSString stringWithFormat:@"0%@229%@",[Number substringWithRange:NSMakeRange(1, 2)], [Number  substringWithRange:NSMakeRange(5, 8)]];
  
                        return Number;
                    }
                }
                
                range1 = [Number rangeOfString:@"0"];
                range2 = [Number rangeOfString:@"24"];
                if (range1.location == 0 && range2.location == 3) {
                    range1 = [Number rangeOfString:@"3"];
                    range4 = [Number rangeOfString:@"4"];
                    range7 = [Number rangeOfString:@"7"];
                    rangeE = [Number rangeOfString:@"*"];

                    if (range1.location != 5 && ![[Number substringWithRange:NSMakeRange(5, 1)] isEqual: @"2"] && range4.location != 5 && range7.location != 5 && rangeE.length == 0 ) {
                        Number = [NSString stringWithFormat:@"0%@249%@",[Number substringWithRange:NSMakeRange(1, 2)], [Number  substringWithRange:NSMakeRange(5, 8)]];

                        return Number;
                    }
                }
                
            }else if (tam == 15) {
                range1 = [Number rangeOfString:@"550"];
                range2 = [Number rangeOfString:@"21"];
                if (range1.location == 0 && range2.location == 5) {
                    range1 = [Number rangeOfString:@"3"];
                    range2 = [Number rangeOfString:@"2"];
                    range4 = [Number rangeOfString:@"4"];
                    range7 = [Number rangeOfString:@"7"];
                    rangeE = [Number rangeOfString:@"*"];

                    if (range1.location != 7 && ![[Number substringWithRange:NSMakeRange(7, 1)] isEqual: @"2"] && range4.location != 7 && range7.location != 7 && rangeE.length == 0 ) {
                        Number = [NSString stringWithFormat:@"+550%@219%@",[Number  substringWithRange:NSMakeRange(3, 2)], [Number  substringWithRange:NSMakeRange(7, 8)]];
               
                        return Number;
                    }
                }
                
                range1 = [Number rangeOfString:@"550"];
                range2 = [Number rangeOfString:@"22"];
                if (range1.location == 0 && range2.location == 5) {
                    range1 = [Number rangeOfString:@"3"];
                    range2 = [Number rangeOfString:@"2"];
                    range4 = [Number rangeOfString:@"4"];
                    range7 = [Number rangeOfString:@"7"];
                    rangeE = [Number rangeOfString:@"*"];

                    if (range1.location != 7 && ![[Number substringWithRange:NSMakeRange(7, 1)] isEqual: @"2"] && range4.location != 7 && range7.location != 7 && rangeE.length == 0 ) {
                        Number = [NSString stringWithFormat:@"+550%@229%@",[Number  substringWithRange:NSMakeRange(3, 2)], [Number  substringWithRange:NSMakeRange(7, 8)]];

                        return Number;
                    }
                }
                
                range1 = [Number rangeOfString:@"550"];
                range2 = [Number rangeOfString:@"24"];
                if (range1.location == 0 && range2.location == 5) {
                    range1 = [Number rangeOfString:@"3"];
                    range2 = [Number rangeOfString:@"2"];
                    range4 = [Number rangeOfString:@"4"];
                    range7 = [Number rangeOfString:@"7"];
                    rangeE = [Number rangeOfString:@"*"];

                    if (range1.location != 7 && ![[Number substringWithRange:NSMakeRange(7, 1)] isEqual: @"2"] && range4.location != 7 && range7.location != 7 && rangeE.length == 0 ) {
                        Number = [NSString stringWithFormat:@"+550%@249%@",[Number  substringWithRange:NSMakeRange(3, 2)], [Number  substringWithRange:NSMakeRange(7, 8)]];
                
                        return Number;
                    }
                }
            }else return Number;
        }
    }
    return Number;
}

- (IBAction)OpenLinkS4M:(id)sender{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.solution4mac.com.br"]];
}

-(IBAction)Info:(id) sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"DigitoRJ" message:@"Será mantido uma cópia de seus contatos, preservando o histórico de outros APPs que utilizam a listagem de contatos." delegate:nil cancelButtonTitle:@"OK"otherButtonTitles: nil];
    [alert show];
    
}

@end
