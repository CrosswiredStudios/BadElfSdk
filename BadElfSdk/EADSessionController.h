//
//  EADSessionController.h
//  BadElfSdk
//
//  Created by Matthew Wood on 5/24/24.
//

#import <Foundation/Foundation.h>
#import <ExternalAccessory/ExternalAccessory.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *EADSessionDataReceivedNotification;

@interface EADSessionController : NSObject <EAAccessoryDelegate, NSStreamDelegate>

+ (EADSessionController *)sharedController;

- (void)setupControllerForAccessory:(EAAccessory *)accessory withProtocolString:(NSString *)protocolString;

- (BOOL)openSession;
- (void)closeSession;

- (void)writeData:(NSData *)data;

- (NSUInteger)readBytesAvailable;
- (NSData *)readData:(NSUInteger)bytesToRead;

@property (nonatomic, readonly) EAAccessory *accessory;
@property (nonatomic, readonly) NSString *protocolString;

@end

#ifdef __cplusplus
extern "C" {
#endif

void BadElfSdk_SetupControllerForAccessory(EAAccessory *accessory, const char *protocolString);
bool BadElfSdk_OpenSession(void);
void BadElfSdk_CloseSession(void);
void BadElfSdk_WriteData(const char *data);
unsigned int BadElfSdk_ReadBytesAvailable(void);
const char *BadElfSdk_ReadData(unsigned int bytesToRead);
void BadElfSdk_FreePointer(const char *ptr);

#ifdef __cplusplus
}
#endif

NS_ASSUME_NONNULL_END
