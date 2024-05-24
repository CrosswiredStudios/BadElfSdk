//
//  EADSessionController.m
//  BadElfSdk
//
//  Created by Matthew Wood on 5/24/24.
//

#import "EADSessionController.h"

#define SDK_NAME   @"BadElfSdk"

@interface EADSessionController ()

@property (nonatomic, strong) EASession *session;
@property (nonatomic, strong) NSMutableData *writeData;
@property (nonatomic, strong) NSMutableData *readData;

@end

NSString *EADSessionDataReceivedNotification = @"EADSessionDataReceivedNotification";

@implementation EADSessionController

#pragma mark Internal

- (void)_writeData {
    while (([[_session outputStream] hasSpaceAvailable]) && ([_writeData length] > 0)) {
        NSInteger bytesWritten = [[_session outputStream] write:[_writeData bytes] maxLength:[_writeData length]];
        if (bytesWritten == -1) {
            NSLog(@"%@: write error", SDK_NAME);
            break;
        } else if (bytesWritten > 0) {
            [_writeData replaceBytesInRange:NSMakeRange(0, bytesWritten) withBytes:NULL length:0];
            NSLog(@"%@bytesWritten %ld", SDK_NAME, (long)bytesWritten);
        }
    }
}

- (void)_readData {
#define EAD_INPUT_BUFFER_SIZE 1024
    char buf[EAD_INPUT_BUFFER_SIZE + 1];
    while ([[_session inputStream] hasBytesAvailable]) {
        NSInteger bytesRead = [[_session inputStream] read:buf maxLength:EAD_INPUT_BUFFER_SIZE];
        if (_readData == nil) {
            _readData = [[NSMutableData alloc] init];
        }
        [_readData appendBytes:(void *)buf length:bytesRead];
        NSLog(@"%@: read %ld bytes from input stream", SDK_NAME, (long)bytesRead);

        if (bytesRead > 0) {
            buf[bytesRead] = 0; // NULL terminate
            NSString *ascii = [[NSString alloc] initWithUTF8String:buf];
            NSLog(@"%@:\n%@", SDK_NAME, ascii);
        }
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:EADSessionDataReceivedNotification object:self userInfo:nil];
}

#pragma mark Public Methods

+ (EADSessionController *)sharedController {
    static EADSessionController *sessionController = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sessionController = [[EADSessionController alloc] init];
    });
    return sessionController;
}

- (void)dealloc {
    [self closeSession];
    [self setupControllerForAccessory:nil withProtocolString:nil];
}

- (void)setupControllerForAccessory:(EAAccessory *)accessory withProtocolString:(NSString *)protocolString {
    NSLog(@"%@: setupControllerForAccessory entered protocolString is %@", SDK_NAME, protocolString);
    _accessory = accessory;
    _protocolString = [protocolString copy];
}

- (BOOL)openSession {
    [_accessory setDelegate:self];
    _session = [[EASession alloc] initWithAccessory:_accessory forProtocol:_protocolString];

    if (_session) {
        [[_session inputStream] setDelegate:self];
        [[_session inputStream] scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [[_session inputStream] open];

        [[_session outputStream] setDelegate:self];
        [[_session outputStream] scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [[_session outputStream] open];
    } else {
        NSLog(@"%@: creating session failed", SDK_NAME);
    }

    return (_session != nil);
}

- (void)closeSession {
    [[_session inputStream] close];
    [[_session inputStream] removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [[_session inputStream] setDelegate:nil];
    [[_session outputStream] close];
    [[_session outputStream] removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [[_session outputStream] setDelegate:nil];

    _session = nil;
    _writeData = nil;
    _readData = nil;
}

- (void)writeData:(NSData *)data {
    if (_writeData == nil) {
        _writeData = [[NSMutableData alloc] init];
    }
    [_writeData appendData:data];
    [self _writeData];
}

- (NSData *)readData:(NSUInteger)bytesToRead {
    NSData *data = nil;
    if ([_readData length] >= bytesToRead) {
        NSRange range = NSMakeRange(0, bytesToRead);
        data = [_readData subdataWithRange:range];
        [_readData replaceBytesInRange:range withBytes:NULL length:0];
    }
    return data;
}

- (NSUInteger)readBytesAvailable {
    return [_readData length];
}

#pragma mark EAAccessoryDelegate

- (void)accessoryDidDisconnect:(EAAccessory *)accessory {
    // do something ...
}

#pragma mark NSStreamDelegate

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    switch (eventCode) {
        case NSStreamEventNone:
            break;
        case NSStreamEventOpenCompleted:
            break;
        case NSStreamEventHasBytesAvailable:
            [self _readData];
            break;
        case NSStreamEventHasSpaceAvailable:
            [self _writeData];
            break;
        case NSStreamEventErrorOccurred:
            break;
        case NSStreamEventEndEncountered:
            break;
        default:
            break;
    }
}

@end

void BadElfSdk_SetupControllerForAccessory(EAAccessory *accessory, const char *protocolString) {
    [[EADSessionController sharedController] setupControllerForAccessory:accessory withProtocolString:[NSString stringWithUTF8String:protocolString]];
}

bool BadElfSdk_OpenSession(void) {
    return [[EADSessionController sharedController] openSession];
}

void BadElfSdk_CloseSession(void) {
    [[EADSessionController sharedController] closeSession];
}

void BadElfSdk_WriteData(const char *data) {
    NSString *dataString = [NSString stringWithUTF8String:data];
    NSData *dataToSend = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    [[EADSessionController sharedController] writeData:dataToSend];
}

unsigned int BadElfSdk_ReadBytesAvailable(void) {
    return (unsigned int)[[EADSessionController sharedController] readBytesAvailable];
}

const char *BadElfSdk_ReadData(unsigned int bytesToRead) {
    NSData *data = [[EADSessionController sharedController] readData:bytesToRead];
    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return strdup([dataString UTF8String]);
}

void BadElfSdk_FreePointer(const char *ptr) {
    free((void *)ptr);
}

