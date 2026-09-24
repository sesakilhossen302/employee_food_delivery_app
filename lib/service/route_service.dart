import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import '../Utils/AppConst/app_const.dart';

class RouteService {
  /// Fetches genuine road routing between origin and destination.
  /// 1. Tries BRouter (OpenStreetMap Road Engine) - 100% genuine street paths worldwide.
  /// 2. Tries Valhalla (OpenStreetMap Road Engine).
  /// 3. Tries OSRM Driving Engine.
  /// 4. Tries Google Directions API (if billing enabled).
  /// 5. Fallback: Creates smooth road-approximating segments following city road angles.
  static Future<List<LatLng>> getRoadRoute({
    required LatLng origin,
    required LatLng destination,
  }) async {
    // 1. Try BRouter (Fastest, highest accuracy for Dhaka & international roads, 0 billing required)
    try {
      final brouterRoute = await _fetchBrouterRoute(origin, destination);
      if (brouterRoute.isNotEmpty && brouterRoute.length > 2) {
        debugPrint('[RouteService] Using BRouter road route (${brouterRoute.length} points)');
        return brouterRoute;
      }
    } catch (e) {
      debugPrint('[RouteService] BRouter note: $e');
    }

    // 2. Try Valhalla (OpenStreetMap alternative road engine)
    try {
      final valhallaRoute = await _fetchValhallaRoute(origin, destination);
      if (valhallaRoute.isNotEmpty && valhallaRoute.length > 2) {
        debugPrint('[RouteService] Using Valhalla road route (${valhallaRoute.length} points)');
        return valhallaRoute;
      }
    } catch (e) {
      debugPrint('[RouteService] Valhalla note: $e');
    }

    // 3. Try Google Directions API
    try {
      final googleRoute = await _fetchGoogleDirections(origin, destination);
      if (googleRoute.isNotEmpty) {
        debugPrint('[RouteService] Using Google Directions route (${googleRoute.length} points)');
        return googleRoute;
      }
    } catch (e) {
      debugPrint('[RouteService] Google Directions note: $e');
    }

    // 4. Try OSRM Mirrors
    try {
      final osrmRoute = await _fetchOsrmRoute(origin, destination);
      if (osrmRoute.isNotEmpty && osrmRoute.length > 2) {
        debugPrint('[RouteService] Using OSRM road route (${osrmRoute.length} points)');
        return osrmRoute;
      }
    } catch (e) {
      debugPrint('[RouteService] OSRM Route note: $e');
    }

    // 5. Intelligent Fallback: generate road-following turn points along the grid
    return _generateCityGridRoute(origin, destination);
  }

  /// 1. BRouter Driving API (Free, high-accuracy real-road network)
  static Future<List<LatLng>> _fetchBrouterRoute(
    LatLng origin,
    LatLng destination,
  ) async {
    final url = Uri.parse(
      'https://brouter.de/brouter?'
      'lonlats=${origin.longitude},${origin.latitude}|${destination.longitude},${destination.latitude}'
      '&profile=car-fast&alternativeidx=0&format=geojson',
    );

    final res = await http.get(
      url,
      headers: {'User-Agent': 'FoodDeliveryApp/1.0'},
    ).timeout(const Duration(seconds: 4));

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      if (data['features'] is List && data['features'].isNotEmpty) {
        final feature = data['features'][0];
        final geometry = feature['geometry'];
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

  /// 2. Valhalla Driving API
  static Future<List<LatLng>> _fetchValhallaRoute(
    LatLng origin,
    LatLng destination,
  ) async {
    final body = jsonEncode({
      'locations': [
        {'lat': origin.latitude, 'lon': origin.longitude},
        {'lat': destination.latitude, 'lon': destination.longitude}
      ],
      'costing': 'auto',
    });

    final url = Uri.parse('https://valhalla1.openstreetmap.de/route?json=${Uri.encodeComponent(body)}');
    final res = await http.get(
      url,
      headers: {'User-Agent': 'FoodDeliveryApp/1.0'},
    ).timeout(const Duration(seconds: 4));

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final trip = data['trip'];
      if (trip != null && trip['legs'] is List && trip['legs'].isNotEmpty) {
        final shape = trip['legs'][0]['shape'];
        if (shape is String && shape.isNotEmpty) {
          return decodePolyline(shape, precision: 6);
        }
      }
    }
    return [];
  }

  /// 3. Query OSRM Driving API
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

    final res = await http.get(
      url,
      headers: {'User-Agent': 'FoodDeliveryApp/1.0'},
    ).timeout(const Duration(seconds: 4));

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      if (data['code'] == 'Ok' && data['routes'] is List && data['routes'].isNotEmpty) {
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

  /// 4. Query Google Directions API
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

    final res = await http.get(url).timeout(const Duration(seconds: 4));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      if (data['status'] == 'OK' && data['routes'] is List && data['routes'].isNotEmpty) {
        final points = data['routes'][0]['overview_polyline']?['points'];
        if (points != null && points is String) {
          return decodePolyline(points, precision: 5);
        }
      }
    }
    return [];
  }

  /// 5. Generates a city street grid route (avoids straight diagonal lines through buildings)
  static List<LatLng> _generateCityGridRoute(LatLng origin, LatLng destination) {
    final List<LatLng> pts = [];
    pts.add(origin);

    final midLat = origin.latitude + (destination.latitude - origin.latitude) * 0.45;
    final midLng = origin.longitude + (destination.longitude - origin.longitude) * 0.55;

    // Intermediate turn 1 (along avenue)
    pts.add(LatLng(midLat, origin.longitude));
    // Intermediate turn 2 (along intersection)
    pts.add(LatLng(midLat, midLng));
    // Intermediate turn 3 (along destination road)
    pts.add(LatLng(destination.latitude, midLng));
    // Final destination
    pts.add(destination);

    return pts;
  }

  /// Decode Google / Valhalla Encoded Polyline String
  static List<LatLng> decodePolyline(String encoded, {int precision = 5}) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;
    final double factor = precision == 6 ? 1E6 : 1E5;

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

      poly.add(LatLng((lat / factor), (lng / factor)));
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
