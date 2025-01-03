import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_avif_platform_interface/flutter_avif_platform_interface.dart' as avif_platform;
import 'package:exif/exif.dart' as exif;
import 'exif_encoder.dart';
import 'package:image/image.dart' as img;

Future<Uint8List> encodeAvif(
  Uint8List input, {
  maxThreads = 4,
  speed = 10,
  maxQuantizer = 40,
  minQuantizer = 25,
  maxQuantizerAlpha = 40,
  minQuantizerAlpha = 25,
  keepExif = false,
}) async {
  final avifFfi = avif_platform.FlutterAvifPlatform.api;
  final List<avif_platform.EncodeFrame> encodeFrames = [];
  int averageFps = 0, width = 0, height = 0;

  Uint8List exifData = Uint8List(0);
  int orientation = 1;
  if (keepExif) {
    final decodedExif = await exif.readExifFromBytes(input);
    exifData = encodeExif(decodedExif);
    orientation = decodedExif['Image Orientation']?.values.toList()[0] ??
        decodedExif['EXIF Orientation']?.values.toList()[0] ??
        decodedExif['Thumbnail Orientation']?.values.toList()[0] ??
        decodedExif['Interoperability Orientation']?.values.toList()[0] ??
        1;
  }

    final decodedImage = img.decodeImage(input);
    final List<img.Image> frames = [];
    int totalDurationMs = 0;

    if(decodedImage == null){
      throw Exception('Unsupported Image Type');
    }

    for (final frame in decodedImage.frames) {
      totalDurationMs += frame.frameDuration;
      frames.add(frame);
    }

    width = frames[0].width;
    height = frames[0].height;
    averageFps = decodedImage.frames.length > 1 && totalDurationMs > 0
        ? (1000 * decodedImage.frames.length / totalDurationMs).round()
        : 1;
    final timebaseMs = (1000 / averageFps).round();

    for (int i = 0; i < frames.length; i += 1) {
      final imageData = frames[i].getBytes(order: img.ChannelOrder.rgba);
      encodeFrames.add(avif_platform.EncodeFrame(
        data: imageData.buffer.asUint8List(),
        durationInTimescale: (frames[i].frameDuration / timebaseMs).round(),
      ));
    }

  final output = await avifFfi.encodeAvif(
    width: width,
    height: height,
    maxThreads: maxThreads,
    speed: speed,
    timescale: averageFps,
    maxQuantizer: maxQuantizer,
    minQuantizer: minQuantizer,
    maxQuantizerAlpha: maxQuantizerAlpha,
    minQuantizerAlpha: minQuantizerAlpha,
    imageSequence: encodeFrames,
    exifData: exifData,
  );

  return output;
}
