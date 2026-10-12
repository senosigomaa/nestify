import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../localization/locale_bloc/locale_bloc.dart';
import '../network/api_client.dart';
import '../../features/explore_feed/domain/repositories/property_repository.dart';
import '../../features/explore_feed/data/repositories/property_repository_impl.dart';
import '../../features/explore_feed/presentation/bloc/explore_feed_bloc.dart';
import '../../features/co_living/presentation/bloc/co_living_bloc.dart';

final sl = GetIt.instance;

/// Global service locator initialization for Nestify Clean Architecture.
Future<void> initDependencies() async {
  // 1. Local Cache (Hive)
  await Hive.initFlutter();
  final favoritesBox = await Hive.openBox('nestify_favorites');
  await Hive.openBox('nestify_settings');

  // 2. Core Network
  sl.registerLazySingleton<ApiClient>(() => ApiClient());

  // 3. Repositories
  sl.registerLazySingleton<PropertyRepository>(
    () => PropertyRepositoryImpl(
      apiClient: sl<ApiClient>(),
      favoritesBox: favoritesBox,
    ),
  );

  // 4. BLoCs
  sl.registerFactory<ExploreFeedBloc>(
    () => ExploreFeedBloc(repository: sl<PropertyRepository>()),
  );

  sl.registerFactory<CoLivingBloc>(
    () => CoLivingBloc(),
  );

  sl.registerFactory<LocaleBloc>(
    () => LocaleBloc(),
  );
}
