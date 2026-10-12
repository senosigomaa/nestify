import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/mock_properties_data.dart';
import '../../domain/entities/property_entity.dart';
import '../../domain/repositories/property_repository.dart';
import '../models/property_model.dart';

/// Implementation of PropertyRepository backed by mock remote data with simulated
/// network latency and persistent Hive local storage for saved properties and tours.
class PropertyRepositoryImpl implements PropertyRepository {
  final ApiClient apiClient;
  final Box favoritesBox;

  PropertyRepositoryImpl({
    required this.apiClient,
    required this.favoritesBox,
  });

  @override
  Future<List<PropertyEntity>> getProperties() async {
    // Simulate real-world network latency
    await Future.delayed(const Duration(milliseconds: 650));

    try {
      final List<Map<String, dynamic>> rawList =
          MockPropertiesData.rawProperties;
      final properties = rawList
          .map((json) => PropertyModel.fromJson(json))
          .toList(growable: false);
      return properties;
    } catch (e) {
      throw Exception('Failed to fetch property feed: $e');
    }
  }

  @override
  Future<List<PropertyEntity>> getSavedProperties() async {
    try {
      final List<PropertyEntity> saved = [];
      for (final key in favoritesBox.keys) {
        final raw = favoritesBox.get(key);
        if (raw != null) {
          final Map<String, dynamic> json =
              raw is String ? jsonDecode(raw) : Map<String, dynamic>.from(raw);
          saved.add(PropertyModel.fromJson(json));
        }
      }
      return saved;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> saveProperty(PropertyEntity property) async {
    final model = PropertyModel.fromEntity(property);
    await favoritesBox.put(property.id, jsonEncode(model.toJson()));
  }

  @override
  Future<void> removeSavedProperty(String propertyId) async {
    await favoritesBox.delete(propertyId);
  }

  @override
  Future<bool> bookTour(String propertyId, DateTime tourDate) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Persist booking confirmation locally
    final tourBox = await Hive.openBox('nestify_tours');
    await tourBox.put(
      'tour_${propertyId}_${tourDate.millisecondsSinceEpoch}',
      {
        'propertyId': propertyId,
        'date': tourDate.toIso8601String(),
        'status': 'confirmed',
      },
    );
    return true;
  }
}
