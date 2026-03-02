import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeline/bloc_provider.dart' hide AppInitState;
import 'package:timeline/colors.dart';
import 'package:timeline/main_menu/main_menu.dart';
import 'package:timeline/providers/app_providers.dart';
import 'package:timeline/search_manager.dart';

/// The app is wrapped by a [ProviderScope] for Riverpod state management
/// and a [BlocProvider] for backward compatibility with existing code.
class TimelineApp extends StatelessWidget {
  const TimelineApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return ProviderScope(
      child: const _AppInitializer(),
    );
  }
}

/// Widget that handles initialization state using Riverpod
class _AppInitializer extends ConsumerWidget {
  const _AppInitializer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initState = ref.watch(appInitStateProvider);
    final errorMessage = ref.watch(appErrorMessageProvider);

    // Show loading screen while initializing
    if (initState == AppInitState.loading) {
      return MaterialApp(
        title: 'History & Future of Everything',
        theme: ThemeData(scaffoldBackgroundColor: background),
        home: const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    // Show error screen if initialization failed
    if (initState == AppInitState.error) {
      return MaterialApp(
        title: 'History & Future of Everything',
        theme: ThemeData(scaffoldBackgroundColor: background),
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  errorMessage ?? 'An error occurred',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.read(appInitProvider.notifier).retry(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Initialization successful, show the main app with BlocProvider for backward compatibility
    final timeline = ref.read(timelineProvider);
    final favoritesBloc = ref.read(favoritesBlocProvider);
    final searchManager = ref.read(searchManagerProvider);

    return BlocProvider(
      platform: Theme.of(context).platform,
      t: timeline,
      fb: favoritesBloc,
      sm: searchManager,
      child: MaterialApp(
        title: 'History & Future of Everything',
        theme: ThemeData(scaffoldBackgroundColor: background),
        home: const MenuPage(),
      ),
    );
  }
}

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(appBar: null, body: MainMenuWidget());
  }
}

void main() => runApp(const TimelineApp());