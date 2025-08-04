import 'dart:ffi';

import 'result_native.dart';

typedef ResultChannelVoidFunction = NativeFunction<Void Function()>;

typedef ResultChannelVoidFunctionDart = void Function();

typedef ResultChannelVoidFunctionWithArgs =
    NativeFunction<Void Function(Pointer<ResultNative>)>;

typedef ResultChannelVoidFunctionWithArgsDart =
    void Function(Pointer<ResultNative>);

typedef ResultChannelFunction =
    NativeFunction<Pointer<ResultNative> Function()>;

typedef ResultChannelFunctionDart = Pointer<ResultNative> Function();

typedef ResultChannelFunctionWithArgs =
    NativeFunction<Pointer<ResultNative> Function(Pointer<ResultNative>)>;

typedef ResultChannelFunctionWithArgsDart =
    Pointer<ResultNative> Function(Pointer<ResultNative>);

typedef ResultChannelCallback = Void Function(Pointer<ResultNative>);

typedef ResultChannelCallbackNative =
    Pointer<NativeFunction<ResultChannelCallback>>;

typedef ResultChannelCallbackDart = void Function(Pointer<ResultNative>);

typedef ResultChannelCallbackFunction =
    NativeFunction<Void Function(ResultChannelCallbackNative)>;

typedef ResultChannelCallbackFunctionDart =
    void Function(ResultChannelCallbackNative);

typedef ResultChannelCallbackFunctionWithArgs =
    NativeFunction<
      Void Function(Pointer<ResultNative>, ResultChannelCallbackNative)
    >;

typedef ResultChannelCallbackFunctionWithArgsDart =
    void Function(Pointer<ResultNative>, ResultChannelCallbackNative);
