import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/constants/app_colors.dart';
import 'core/di/injection_container.dart';
import 'core/theme/app_theme.dart';
import 'features/co_living/presentation/bloc/co_living_bloc.dart';
import 'features/explore_feed/presentation/bloc/explore_feed_bloc.dart';
import 'features/explore_feed/presentation/bloc/explore_feed_event.dart';
import 'features/explore_feed/presentation/views/explore_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Dark edge-to-edge system navigation styling
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.backgroundDark,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize Hive storage and GetIt dependencies
  await initDependencies();

  runApp(const NestifyApp());
}

/// NestifyApp root application widget configuring dark luxury theme and global BLoCs.
class NestifyApp extends StatelessWidget {
  const NestifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ExploreFeedBloc>(
          create: (context) =>
              sl<ExploreFeedBloc>()..add(const LoadExploreFeedEvent()),
        ),
        BlocProvider<CoLivingBloc>(
          create: (context) => sl<CoLivingBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'Nestify',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const ExploreScreen(),
      ),
    );
  }
}
