import 'dart:io';

import 'package:flutter_avif_linux/flutter_avif_linux.dart';
import 'package:flutter_avif_macos/flutter_avif_macos.dart';
import 'package:flutter_avif_windows/flutter_avif_windows.dart';

class LibLoader {
  LibLoader._(){
    if (Platform.isMacOS) {
      FlutterAvifMacos.registerWith();
    } else if (Platform.isLinux) {
      FlutterAvifLinux.registerWith();
    }else if (Platform.isWindows) {
      FlutterAvifWindows.registerWith();
    }
  }
  static final LibLoader _instance = LibLoader._();
  factory LibLoader.getInstance() {
    return _instance;
  }
}