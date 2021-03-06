


#import "ZebraPrinter.h"
#import <ExternalAccessory/ExternalAccessory.h>
#import "MfiBtPrinterConnection.h"

@implementation ZebraPrinter : CDVPlugin

- (void) sendZplOverBluetooth:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
    __block CDVPluginResult* result;
    NSDictionary* printItems = command.arguments[0];
    // NSNumber* printCount = printItems [@"scriptCount"];
    // NSString* printTitle = printItems [@"title"];
    // NSString* printPayMethod = printItems [@"ticketPaymentMethod"];
    NSNumber* printTransId = printItems [@"transactionId"];
    NSString* printBody = printItems [@"printBody"];
    
    // NSString* finalPrint = [NSString stringWithFormat:@"^XA\r\n^FO50,50\r\n^FD%@^FS\r\n^FO50,150\r\n^FDPaid For: %@\r\n^FO50,250\r\n^FDItems On This Ticket: %@\r\n^FO50,350\r\n^FO100,100^BY3^B1N,N,150,Y,N^FD%@^FS^XZ", printTitle, printPayMethod, printCount, printTransId];
    // NSString* finalPrint = [NSString stringWithFormat:@"^XA^CF0,75^A2N,50,50^FO200,100^FD%@^FS^A2N,40,40^FO250,175^FDPaid For: %@^FS^A2N,40,40^FO225,225^FDItems On This Ticket: %@^FS^FO275,300^BY3^B1N,N,150,Y,N^FD%@^FS^XZ", printTitle, printPayMethod, printCount, printTransId];
    // Print Body String
    NSString* finalPrintBody = [NSString stringWithFormat:@"^XA^LL1000^CF0,75^A2N,30,30^FO180,100^FB500,17,5,C^FD%@^FS^FO190,750^BY3^B3N,N,150,Y,N^FD%@^FS^XZ", printBody, printTransId];
    NSLog(@"this is the variable value: %@",printItems[@"printBody"]);

        
        //Dispatch this task to the default queue
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
            
            NSString *serialNumber = @"";
            
            //Find the Zebra Bluetooth Accessory
            EAAccessoryManager *sam = [EAAccessoryManager sharedAccessoryManager];
            NSArray * connectedAccessories = [sam connectedAccessories];
            
            for (EAAccessory *accessory in connectedAccessories) {
                if ([accessory.protocolStrings indexOfObject:@"com.zebra.rawport"] != NSNotFound){
                    serialNumber = accessory.serialNumber;
                    break;
                    //Note: This will find the first printer connected! If you have multiple Zebra printers connected, you should display a list to the user and have him select the one they wish to use
                }
            }
            // Instantiate connection to Zebra Bluetooth accessory
            id<ZebraPrinterConnection, NSObject> thePrinterConn = [[MfiBtPrinterConnection alloc] initWithSerialNumber:serialNumber];
            
            // Open the connection - physical connection is established here.
            BOOL success = [thePrinterConn open];
            
//            if (success != YES) {
//                UIAlertView *errorConnectAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Either the printer is turned off or not connected." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
//                [errorConnectAlert show];
//            }
            
            // This example prints "This is a ZPL test." near the top of the label.
            // NSString *zplData = @"^XA^FO20,20^A0N,25,25^FDThis is a ZPL test.^FS^XZ";
            NSError *error = nil;
            
            // Send the data to printer as a byte array.
            success = success && [thePrinterConn write:[finalPrintBody dataUsingEncoding:NSUTF8StringEncoding] error:&error];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if(success != YES || error != nil) {
                    //UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Either the printer is turned off or not connected." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    
//                    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    

                    //[errorAlert show];
                    
                    
                    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                               messageAsString:[NSString stringWithFormat:
                                                                @"Either the printer is turned off or not connected."]];
                //result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
                    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
                } else {
                    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                               messageAsString:[NSString stringWithFormat:
                                                                @"You have successfully printed the ticket."]];
                    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
                }
            });
            
            // Close the connection to release resources.
            [thePrinterConn close];
        });
        

    }];
    }

//-(void)sendZplOverBluetooth:(CDVInvokedUrlCommand*)command{
//	NSString *serialNumber = @"";
//	//Find the Zebra Bluetooth Accessory
//	EAAccessoryManager *sam = [EAAccessoryManager sharedAccessoryManager];
//	NSArray * connectedAccessories = [sam connectedAccessories];
//
//	for (EAAccessory *accessory in connectedAccessories) {
//		if([accessory.protocolStrings indexOfObject:@"com.zebra.rawport"] != NSNotFound){
//		serialNumber = accessory.serialNumber;
//		break;
//		//Note: This will find the first printer connected! If you have multiple Zebra printers connected, you should display a list to the user and have him select the one they wish to use
//		}
//	}
//	// Instantiate connection to Zebra Bluetooth accessory
//	id<ZebraPrinterConnection, NSObject> thePrinterConn = [[MfiBtPrinterConnection alloc] initWithSerialNumber:serialNumber];
//	// Open the connection - physical connection is established here.
//	BOOL success = [thePrinterConn open];
//	// This example prints "This is a ZPL test." near the top of the label.
//	NSString *zplData = @"^XA^FO20,20^A0N,25,25^FDThis is a ZPL test.^FS^XZ";
//	NSError *error = nil;
//	// Send the data to printer as a byte array.
//	success = success && [thePrinterConn write:[zplData dataUsingEncoding:NSUTF8StringEncoding] error:&error];
//	if (success != YES || error != nil) {
//	UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
//	[errorAlert show];
////	[errorAlert release];
//	}
//	// Close the connection to release resources.
//	[thePrinterConn close];
//	// [thePrinterConn release];
//}
//
//
//-(void)sendCpclOverBluetooth {
//NSString *serialNumber = @"";
////Find the Zebra Bluetooth Accessory
//EAAccessoryManager *sam = [EAAccessoryManager sharedAccessoryManager];
//NSArray * connectedAccessories = [sam connectedAccessories];
//for (EAAccessory *accessory in connectedAccessories) {
//if([accessory.protocolStrings indexOfObject:@"com.zebra.rawport"] != NSNotFound){
//serialNumber = accessory.serialNumber;
//break;
////Note: This will find the first printer connected! If you have multiple Zebra printers connected, you should display a list to the user and have him select the one they wish to use
//}
//}
//// Instantiate connection to Zebra Bluetooth accessory
//id<ZebraPrinterConnection, NSObject> thePrinterConn = [[MfiBtPrinterConnection alloc] initWithSerialNumber:serialNumber];
//// Open the connection - physical connection is established here.
//BOOL success = [thePrinterConn open];
//// This example prints "This is a CPCL test." near the top of the label.
//NSString *cpclData = @"! 0 200 200 210 1\r\nTEXT 4 0 30 40 This is a CPCL test.\r\nFORM\r\nPRINT\r\n";
//NSError *error = nil;
//// Send the data to printer as a byte array.
//success = success && [thePrinterConn write:[cpclData dataUsingEncoding:NSUTF8StringEncoding] error:&error];
//if (success != YES || error != nil) {
//UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
//[errorAlert show];
//// [errorAlert release];
//}
//// Close the connection to release resources.
//[thePrinterConn close];
//// [thePrinterConn release];
//}
//
//
//-(void)sampleWithGCD {
////Dispatch this task to the default queue
//dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
//// Instantiate connection to Zebra Bluetooth accessory
//id<ZebraPrinterConnection, NSObject> thePrinterConn = [[MfiBtPrinterConnection alloc] initWithSerialNumber:@"SomeSerialNumer..."];
//// Open the connection - physical connection is established here.
//BOOL success = [thePrinterConn open];
//// This example prints "This is a ZPL test." near the top of the label.
//NSString *zplData = @"^XA^FO20,20^A0N,25,25^FDThis is a ZPL test.^FS^XZ";
//NSError *error = nil;
//// Send the data to printer as a byte array.
//success = success && [thePrinterConn write:[zplData dataUsingEncoding:NSUTF8StringEncoding] error:&error];
////Dispath GUI work back on to the main queue!
//dispatch_async(dispatch_get_main_queue(), ^{
//if (success != YES || error != nil) {
//UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
//[errorAlert show];
//// [errorAlert release];
//}
//});
//// Close the connection to release resources.
//[thePrinterConn close];
//// [thePrinterConn release];
//});
//}
@end
