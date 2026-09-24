import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import '../Utils/AppConst/app_const.dart';

class RouteService {
  /// Fetches real road routing between origin and destination.
  /// 1. First attempts Google Directions API if a valid key is provided.
  /// 2. If Google Directions is unavailable/fails, fetches from OSRM
  ///    (Open Source Routing Machine), which provides 100% REAL ROAD geometries
  ///    tracing actual roads, streets, intersections, and highways worldwide.
  static Future<List<LatLng>> getRoadRoute({
    required LatLng origin,
    required LatLng destination,
  }) async {
    // 1. Try Google Directions API
    try {
      final googleRoute = await _fetchGoogleDirections(origin, destination);
      if (googleRoute.isNotEmpty) {
        debugPrint('[RouteService] Using Google Directions route (${googleRoute.length} points)');
        return googleRoute;
      }
    } catch (e) {
      debugPrint('[RouteService] Google Directions note: $e');
    }

    // 2. Try OSRM (100% Real Roads Worldwide with exact street geometry)
    try {
      final osrmRoute = await _fetchOsrmRoute(origin, destination);
      if (osrmRoute.isNotEmpty) {
        debugPrint('[RouteService] Using OSRM Real Road route (${osrmRoute.length} points)');
        return osrmRoute;
      }
    } catch (e) {
      debugPrint('[RouteService] OSRM Route error: $e');
    }

    // Fallback: direct line between origin and destination
    return [origin, destination];
  }

  /// Query OSRM Driving API (Free, high-accuracy real-road network)
  static Future<List<LatLng>> _fetchOsrmRoute(
    LatLng origin,
    LatLng destination,
  ) async {
    final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/'
      '${origin.longitude},${origin.latitude};'
      '${destination.longitude},${destination.latitude}'
      '?overview=full&geometries=geojson',
    );

    final res = await http.get(url).timeout(const Duration(seconds: 6));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      if (data['code'] == 'Ok' &&
          data['routes'] is List &&
          data['routes'].isNotEmpty) {
        final geometry = data['routes'][0]['geometry'];
        if (geometry != null && geometry['coordinates'] is List) {
          final List rawCoords = geometry['coordinates'];
          final List<LatLng> path = [];
          for (var pt in rawCoords) {
            if (pt is List && pt.length >= 2) {
              final lng = (pt[0] as num).toDouble();
              final lat = (pt[1] as num).toDouble();
              path.add(LatLng(lat, lng));
            }
          }
          if (path.isNotEmpty) {
            return path;
          }
        }
      }
    }
    return [];
  }

  /// Query Google Directions API
  static Future<List<LatLng>> _fetchGoogleDirections(
    LatLng origin,
    LatLng destination,
  ) async {
    final key = AppConstants.googleMapsApiKey;
    if (key.isEmpty) return [];

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json?'
      'origin=${origin.latitude},${origin.longitude}&'
      'destination=${destination.latitude},${destination.longitude}&'
      'mode=driving&'
      'key=$key',
    );

    final res = await http.get(url).timeout(const Duration(seconds: 6));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      if (data['status'] == 'OK' &&
          data['routes'] is List &&
          data['routes'].isNotEmpty) {
        final points = data['routes'][0]['overview_polyline']?['points'];
        if (points != null && points is String) {
          return decodePolyline(points);
        }
      }
    }
    return [];
  }

  /// Decode Google Encoded Polyline String
  static List<LatLng> decodePolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      poly.add(LatLng((lat / 1E5), (lng / 1E5)));
    }
    return poly;
  }

  /// Computes distance in kilometers between two coordinates
  static double calculateDistanceKm(LatLng a, LatLng b) {
    const double p = 0.017453292519943295;
    final double c = 0.5 -
        cos((b.latitude - a.latitude) * p) / 2 +
        cos(a.latitude * p) *
            cos(b.latitude * p) *
            (1 - cos((b.longitude - a.longitude) * p)) /
            2;
    return 12742 * asin(sqrt(c));
  }

  /// Estimated driving minutes based on city driving speed (30 km/h)
  static int estimateMinutes(double distanceKm) {
    final min = (distanceKm / 30 * 60).round() + 2;
    return min < 2 ? 2 : min;
  }
}
