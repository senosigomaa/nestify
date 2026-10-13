import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/di/injection_container.dart';
import 'core/localization/app_localizations.dart';
import 'core/localization/locale_bloc/locale_bloc.dart';
import 'core/localization/locale_bloc/locale_event.dart';
import 'core/localization/locale_bloc/locale_state.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_bloc/theme_bloc.dart';
import 'core/theme/theme_bloc/theme_event.dart';
import 'core/theme/theme_bloc/theme_state.dart';
import 'features/co_living/presentation/bloc/co_living_bloc.dart';
import 'features/explore_feed/presentation/bloc/explore_feed_bloc.dart';
import 'features/explore_feed/presentation/bloc/explore_feed_event.dart';
import 'features/navigation/presentation/views/main_navigation_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive storage and GetIt dependencies
  await initDependencies();

  runApp(const NestifyApp());
}

/// NestifyApp root application widget with dynamic locale & dual-theme switching and MainNavigationShell.
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
        BlocProvider<ThemeBloc>(
          create: (context) =>
              sl<ThemeBloc>()..add(const LoadSavedThemeEvent()),
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
          return BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, themeState) {
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
                theme: AppTheme.getNordicLightTheme(isArabic: localeState.isArabic),
                darkTheme: AppTheme.getDarkTheme(isArabic: localeState.isArabic),
                themeMode: themeState.themeMode,
                home: const MainNavigationShell(),
              );
            },
          );
        },
      ),
    );
  }
}
