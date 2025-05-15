import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'dart:io';

final DynamicLibrary lib =
    Platform.isLinux
        ? DynamicLibrary.open('../../libmwebd.so')
        : Platform.isMacOS
        ? DynamicLibrary.open('../../libmwebd.dylib')
        : DynamicLibrary.open('../../libmwebd.dll');

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

String? callGoFunction(Pointer<Utf8> Function() func) {
  final ptr = func();
  if (ptr.address == 0) return null;
  final result = ptr.toDartString();
  calloc.free(ptr);
  return result;
}

void main() {
  final server = createServer(
    'mainnet'.toNativeUtf8(),
    '/home/lm/git/mwebd'.toNativeUtf8(),
    ''.toNativeUtf8(),
    ''.toNativeUtf8(), // Empty proxy
  );

  final port = startServer(server, 12345); // Port 0 = auto-select
  print('Server started on port: $port');

  // stopServer(server);
}
