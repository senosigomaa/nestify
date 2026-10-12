import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/constants/app_colors.dart';
import 'core/di/injection_container.dart';
import 'core/localization/app_localizations.dart';
import 'core/localization/locale_bloc/locale_bloc.dart';
import 'core/localization/locale_bloc/locale_event.dart';
import 'core/localization/locale_bloc/locale_state.dart';
import 'core/theme/app_theme.dart';
import 'features/co_living/presentation/bloc/co_living_bloc.dart';
import 'features/explore_feed/presentation/bloc/explore_feed_bloc.dart';
import 'features/explore_feed/presentation/bloc/explore_feed_event.dart';
import 'features/navigation/presentation/views/main_navigation_shell.dart';

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

/// NestifyApp root application widget with dynamic locale switching and MainNavigationShell.
class NestifyApp extends StatelessWidget {
  const NestifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LocaleBloc>(
          create: (context) =>
              sl<LocaleBloc>()..add(const LoadSavedLocaleEvent()),
        ),
        BlocProvider<ExploreFeedBloc>(
          create: (context) =>
              sl<ExploreFeedBloc>()..add(const LoadExploreFeedEvent()),
        ),
        BlocProvider<CoLivingBloc>(
          create: (context) => sl<CoLivingBloc>(),
        ),
      ],
      child: BlocBuilder<LocaleBloc, LocaleState>(
        builder: (context, localeState) {
          return MaterialApp(
            title: 'Nestify',
            debugShowCheckedModeBanner: false,
            locale: localeState.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: AppTheme.getTheme(isArabic: localeState.isArabic),
            home: const MainNavigationShell(),
          );
        },
      ),
    );
  }
}
