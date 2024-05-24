#import <Foundation/Foundation.h>
#import <ExternalAccessory/ExternalAccessory.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *EADSessionDataReceivedNotification;

@interface EADSessionController : NSObject <EAAccessoryDelegate, NSStreamDelegate>

+ (EADSessionController *)sharedController;

- (NSArray<EAAccessory *> *)connectedAccessories;
- (void)setupControllerForAccessory:(EAAccessory *)accessory withProtocolString:(NSString *)protocolString;
- (BOOL)openSession;
- (void)closeSession;
- (void)writeData:(NSData *)data;
- (NSUInteger)readBytesAvailable;
- (NSData *)readData:(NSUInteger)bytesToRead;

@property (nonatomic, readonly) EAAccessory *accessory;
@property (nonatomic, readonly) NSString *protocolString;

@end

typedef struct {
    const char *name;
    const char *modelNumber;
    const char *serialNumber;
    const char *hardwareRevision;
    const char *firmwareRevision;
    const char *protocolString;
} BadElfAccessoryInfo;

#ifdef __cplusplus
extern "C" {
#endif

const BadElfAccessoryInfo *BadElfSdk_GetConnectedDevices(int *deviceCount);
void BadElfSdk_FreeAccessoryInfo(const BadElfAccessoryInfo *infoArray, int count);
void BadElfSdk_SetupControllerForAccessory(int index, const char *protocolString);
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
