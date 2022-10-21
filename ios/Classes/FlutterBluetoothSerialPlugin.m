#import "FlutterBluetoothSerialPlugin.h"

@implementation FlutterBluetoothSerialPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"flutter_bluetooth_serial"
            binaryMessenger:[registrar messenger]];
  FlutterBluetoothSerialPlugin* instance = [[FlutterBluetoothSerialPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else if([@"getBondedDevices" isEqualToString:call.method]){
    //Code from FlutterBluePlusPlugin.m   
    // Cannot pass blank UUID list for security reasons. Assume all devices have the Generic Access service 0x1800
    NSArray *periphs = [self->_centralManager retrieveConnectedPeripheralsWithServices:@[[CBUUID UUIDWithString:@"1800"]]];
    NSLog(@"getConnectedDevices periphs size: %lu", [periphs count]);
    result([self toFlutterData:[self toConnectedDeviceResponseProto:periphs]]);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (FlutterStandardTypedData*) toFlutterData:(GPBMessage*)proto {
  FlutterStandardTypedData *data = [FlutterStandardTypedData typedDataWithBytes:[[proto data] copy]];
  return data;
}

- (ProtosConnectedDevicesResponse*)toConnectedDeviceResponseProto:(NSArray<CBPeripheral*>*)periphs {
  ProtosConnectedDevicesResponse *result = [[ProtosConnectedDevicesResponse alloc] init];
  NSMutableArray *deviceProtos = [NSMutableArray new];
  for(CBPeripheral *p in periphs) {
    [deviceProtos addObject:[self toDeviceProto:p]];
  }
  [result setDevicesArray:deviceProtos];
  return result;
}

@end
