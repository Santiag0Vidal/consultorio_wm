santi@santi-System-Product-Name:~/PROYECTO/consultorio_wm$ flutter run
Resolving dependencies... 
Downloading packages... 
  characters 1.4.0 (1.4.1 available)
  csv 5.1.1 (6.0.0 available)
  flutter_lints 5.0.0 (6.0.0 available)
  intl 0.18.1 (0.20.2 available)
  leak_tracker 10.0.9 (11.0.1 available)
  leak_tracker_flutter_testing 3.0.9 (3.0.10 available)
  leak_tracker_testing 3.0.1 (3.0.2 available)
  lints 5.1.1 (6.0.0 available)
  material_color_utilities 0.11.1 (0.13.0 available)
  meta 1.16.0 (1.17.0 available)
  permission_handler 11.4.0 (12.0.1 available)
  permission_handler_android 12.1.0 (13.0.1 available)
  test_api 0.7.4 (0.7.7 available)
  vector_math 2.1.4 (2.2.0 available)
  vm_service 15.0.0 (15.0.2 available)
Got dependencies!
15 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
Launching lib/main.dart on sdk gphone64 x86 64 in debug mode...
Your project is configured with Android NDK 26.3.11579264, but the following plugin(s) depend on a different Android NDK version:
- flutter_plugin_android_lifecycle requires Android NDK 27.0.12077973
- image_picker_android requires Android NDK 27.0.12077973
- path_provider_android requires Android NDK 27.0.12077973
- permission_handler_android requires Android NDK 27.0.12077973
- sqflite_android requires Android NDK 27.0.12077973
Fix this issue by using the highest Android NDK version (they are backward compatible).
Add the following to /home/santi/PROYECTO/consultorio_wm/android/app/build.gradle.kts:

    android {
        ndkVersion = "27.0.12077973"
        ...
    }
Error: Couldn't resolve the package 'kinesiology_app' in 'package:kinesiology_app/screens/user_list_screen.dart'.
Error: Couldn't resolve the package 'kinesiology_app' in 'package:kinesiology_app/database/db_helper.dart'.
lib/main.dart:3:8: Error: Not found: 'package:kinesiology_app/screens/user_list_screen.dart'
import 'package:kinesiology_app/screens/user_list_screen.dart';
       ^
lib/main.dart:4:8: Error: Not found: 'package:kinesiology_app/database/db_helper.dart'
import 'package:kinesiology_app/database/db_helper.dart';
       ^
lib/main.dart:11:9: Error: Method not found: 'DatabaseHelper'.
  await DatabaseHelper().initDb();
        ^^^^^^^^^^^^^^
lib/main.dart:50:19: Error: Couldn't find constructor 'UserListScreen'.
      home: const UserListScreen(), // La pantalla inicial es la lista de usuarios
                  ^^^^^^^^^^^^^^
lib/main.dart:43:20: Error: The argument type 'CardTheme' can't be assigned to the parameter type 'CardThemeData?'.
 - 'CardTheme' is from 'package:flutter/src/material/card_theme.dart' ('../../flutter/packages/flutter/lib/src/material/card_theme.dart').
 - 'CardThemeData' is from 'package:flutter/src/material/card_theme.dart' ('../../flutter/packages/flutter/lib/src/material/card_theme.dart').
        cardTheme: CardTheme(
                   ^
Unhandled exception:
FileSystemException(uri=org-dartlang-untranslatable-uri:package%3Akinesiology_app%2Fscreens%2Fuser_list_screen.dart; message=StandardFileSystem only supports file:* and data:* URIs)
#0      StandardFileSystem.entityForUri (package:front_end/src/api_prototype/standard_file_system.dart:45)
#1      asFileUri (package:vm/kernel_front_end.dart:984)
#2      writeDepfile (package:vm/kernel_front_end.dart:1147)
<asynchronous suspension>
#3      FrontendCompiler.compile (package:frontend_server/frontend_server.dart:713)
<asynchronous suspension>
#4      starter (package:frontend_server/starter.dart:109)
<asynchronous suspension>
#5      main (file:///b/s/w/ir/x/w/sdk/pkg/frontend_server/bin/frontend_server_starter.dart:13)
<asynchronous suspension>

Target kernel_snapshot_program failed: Exception


FAILURE: Build failed with an exception.

* What went wrong:
Execution failed for task ':app:compileFlutterBuildDebug'.
> Process 'command '/home/santi/flutter/bin/flutter'' finished with non-zero exit value 1

* Try:
> Run with --stacktrace option to get the stack trace.
> Run with --info or --debug option to get more log output.
> Run with --scan to get full insights.
> Get more help at https://help.gradle.org.

BUILD FAILED in 2s
Running Gradle task 'assembleDebug'...                              3,1s
Error: Gradle task assembleDebug failed with exit code 1