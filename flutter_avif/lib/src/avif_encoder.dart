import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_avif_platform_interface/flutter_avif_platform_interface.dart' as avif_platform;
import 'package:image/image.dart' as img;

Future<Uint8List> encodeAvif(
  Uint8List input, {
  maxThreads = 4,
  speed = 10,
  maxQuantizer = 40,
  minQuantizer = 25,
  maxQuantizerAlpha = 40,
  minQuantizerAlpha = 25,
}) async {
  final avifFfi = avif_platform.FlutterAvifPlatform.api;
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

  final averageFps = decodedImage.frames.length > 1 && totalDurationMs > 0
      ? (1000 * decodedImage.frames.length / totalDurationMs).round()
      : 1;
  final timebaseMs = (1000 / averageFps).round();
  final List<avif_platform.EncodeFrame> encodeFrames = [];
  for (int i = 0; i < frames.length; i += 1) {
      encodeFrames.add(avif_platform.EncodeFrame(
        data: frames[i].getBytes(order: img.ChannelOrder.rgba),
        durationInTimescale:
            (frames[i].frameDuration / timebaseMs).round(),
      ));
  }

  final output = await avifFfi.encodeAvif(
    width: frames[0].width,
    height: frames[0].height,
    maxThreads: maxThreads,
    speed: speed,
    timescale: averageFps,
    maxQuantizer: maxQuantizer,
    minQuantizer: minQuantizer,
    maxQuantizerAlpha: maxQuantizerAlpha,
    minQuantizerAlpha: minQuantizerAlpha,
    imageSequence: encodeFrames,
  );

  return output;
}
