import '../entities/property_entity.dart';

/// Clean Architecture Repository contract for property feed operations.
abstract class PropertyRepository {
  /// Fetches the feed of available properties.
  Future<List<PropertyEntity>> getProperties();

  /// Retrieves user's saved/liked properties from local storage.
  Future<List<PropertyEntity>> getSavedProperties();

  /// Saves/likes a property into local storage.
  Future<void> saveProperty(PropertyEntity property);

  /// Removes a property from saved list.
  Future<void> removeSavedProperty(String propertyId);

  /// Submits a private tour booking request.
  Future<bool> bookTour(String propertyId, DateTime tourDate);
}
