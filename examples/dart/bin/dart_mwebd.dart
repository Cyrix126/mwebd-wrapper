import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'dart:io';

final DynamicLibrary lib =
    Platform.isLinux
        ? DynamicLibrary.open('../../libmwebd.so')
        : Platform.isMacOS
        ? DynamicLibrary.open('../../libmwebd.dylib')
        : Platform.isWindows
        ? DynamicLibrary.open('../../libmwebd.dll')
        : Platform.isAndroid
        ? DynamicLibrary.open('../../libmwebd_android.so')
        : DynamicLibrary.open('../../libmwebd.a');

typedef CreateServerC =
    Int64 Function(
      Pointer<Utf8> chain,
      Pointer<Utf8> dataDir,
      Pointer<Utf8> peer,
      Pointer<Utf8> proxy,
    );

typedef CreateServerDart =
    int Function(
      Pointer<Utf8> chain,
      Pointer<Utf8> dataDir,
      Pointer<Utf8> peer,
      Pointer<Utf8> proxy,
    );
final createServer = lib.lookupFunction<CreateServerC, CreateServerDart>(
  'CreateServer',
);

typedef StartServerC = Int32 Function(Int64 server, Int32 port);
typedef StartServerDart = int Function(int server, int port);
final StartServerDart startServer =
    lib.lookup<NativeFunction<StartServerC>>('StartServer').asFunction();

typedef StopServerC = Void Function(Int64 server);
typedef StopServerDart = void Function(int server);
final StopServerDart stopServer =
    lib.lookup<NativeFunction<StopServerC>>('StopServer').asFunction();

void main() {
  final test = createServer(
    'testnet'.toNativeUtf8(),
    '/home/lm/Desktop/testnet'.toNativeUtf8(),
    ''.toNativeUtf8(),
    ''.toNativeUtf8(),
  );
  startServer(test, 12345);
  final main = createServer(
    ''.toNativeUtf8(),
    '/home/lm/Desktop/mainnet'.toNativeUtf8(),
    ''.toNativeUtf8(),
    ''.toNativeUtf8(),
  );
  startServer(main, 12346);
  sleep(Duration(seconds: 30));
  stopServer(main);
  stopServer(test);
}
