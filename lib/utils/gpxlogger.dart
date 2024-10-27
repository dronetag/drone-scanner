import 'package:flutter_opendroneid/models/message_container.dart';

class GPXLogger {
  static String createGPX(
    List<MessageContainer> list,
  ) {
    final gpxBuffer = StringBuffer();

    // GPX header
    gpxBuffer
        .writeln('<?xml version="1.0" encoding="UTF-8" standalone="no" ?>');
    gpxBuffer.writeln(
        '<gpx version="1.1" xmlns="http://www.topografix.com/GPX/1/1">');

    // Iterate through coordinates and create track points
    gpxBuffer.writeln('<trk>');
    gpxBuffer.writeln('<trkseg>');
    for (final pack in list) {
      if (!pack.locationValid) continue;
      gpxBuffer
          .writeln('<trkpt lat="${pack.locationMessage!.location!.latitude}" '
              'lon="${pack.locationMessage!.location!.longitude}">');
      if (pack.locationMessage?.altitudePressure != null) {
        gpxBuffer
            .writeln('<ele>${pack.locationMessage!.altitudePressure}</ele>');
      }
      if (pack.locationMessage?.timestamp != null) {
        gpxBuffer.writeln(
            '<time>${pack.locationMessage!.timestamp.toString()}</time>');
      }
      gpxBuffer.writeln('</trkpt>');
    }
    gpxBuffer.writeln('</trkseg>');
    gpxBuffer.writeln('</trk>');

    // GPX footer
    gpxBuffer.writeln('</gpx>');

    return gpxBuffer.toString();
  }
}
