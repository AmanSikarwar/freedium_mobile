import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/core/constants/app_constants.dart';
import 'package:freedium_mobile/core/services/update_service.dart';
import 'package:freedium_mobile/features/home/application/home_provider.dart';
import 'package:freedium_mobile/features/home/presentation/widgets/about_dialog.dart';
import 'package:freedium_mobile/features/home/presentation/widgets/update_card.dart';
import 'package:freedium_mobile/features/settings/presentation/settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isUpdateCardDismissed = false;

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeProvider);
    final homeNotifier = ref.read(homeProvider.notifier);
    final updateAsync = ref.watch(updateCheckProvider);
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          AppConstants.appName,
          style: TextStyle(
            fontFamily: 'PlayfairDisplay',
            color: Theme.of(context).colorScheme.primary,
            fontWeight: .bold,
          ),
        ),
        titleTextStyle: const TextStyle(
          fontFamily: 'PlayfairDisplay',
          fontSize: 24,
          fontWeight: .bold,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
            tooltip: 'Settings',
          ),
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () {
              HapticFeedback.lightImpact();
              showAppAboutDialog(context, ref);
            },
            tooltip: 'About',
          ),
        ],
      ),
      body: Padding(
        padding: const .symmetric(horizontal: 16, vertical: 16),
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: .only(bottom: keyboardInset),
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              keyboardDismissBehavior: .onDrag,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Align(
                  child: Column(
                    spacing: 24,
                    mainAxisSize: .min,
                    children: [
                      updateAsync.when(
                        data: (updateInfo) {
                          if (updateInfo != null && !_isUpdateCardDismissed) {
                            return UpdateCard(
                              updateInfo: updateInfo,
                              onDismissed: () =>
                                  setState(() => _isUpdateCardDismissed = true),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (err, stack) => const SizedBox.shrink(),
                      ),
                      const Text(
                        AppConstants.appDescription,
                        textAlign: .center,
                        style: TextStyle(fontSize: 32, fontWeight: .bold),
                      ),
                      Form(
                        key: homeState.formKey,
                        autovalidateMode: .onUserInteraction,
                        child: TextFormField(
                          controller: homeState.urlController,
                          decoration: InputDecoration(
                            hintText: 'Medium URL',
                            prefixIcon: const Icon(Icons.link),
                            border: const OutlineInputBorder(
                              borderRadius: .all(.circular(24)),
                            ),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.paste),
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                homeNotifier.pasteFromClipboard();
                              },
                            ),
                          ),
                          keyboardType: .url,
                          textInputAction: .done,
                          scrollPadding: const .only(bottom: 120),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a URL';
                            }
                            final urlRegExp = RegExp(
                              AppConstants.urlRegExp,
                              caseSensitive: false,
                            );
                            if (!urlRegExp.hasMatch(value)) {
                              return 'Please enter a valid URL';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(
                        width: .infinity,
                        child: FilledButton(
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            homeNotifier.getArticle(context);
                          },
                          child: const Text('Get Article'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
