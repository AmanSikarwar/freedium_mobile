import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/core/constants/app_constants.dart';
import 'package:freedium_mobile/core/services/update_service.dart';
import 'package:freedium_mobile/features/home/application/home_provider.dart';
import 'package:freedium_mobile/features/home/presentation/widgets/about_dialog.dart';
import 'package:freedium_mobile/features/home/presentation/widgets/theme_chooser_bottom_sheet.dart';
import 'package:freedium_mobile/features/home/presentation/widgets/update_card.dart';
import 'package:google_fonts/google_fonts.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppConstants.appName,
          style: GoogleFonts.playfairDisplay(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: .bold,
          ),
        ),
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 24,
          fontWeight: .bold,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () => showThemeChooserBottomSheet(context),
            tooltip: 'Theme',
          ),
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () => showAppAboutDialog(context, ref),
            tooltip: 'About',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.sizeOf(context).height - kToolbarHeight - 96,
            ),
            child: Align(
              child: Column(
                spacing: 24,
                mainAxisAlignment: .center,
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
                          borderRadius: BorderRadius.all(Radius.circular(24)),
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.paste),
                          onPressed: homeNotifier.pasteFromClipboard,
                        ),
                      ),
                      keyboardType: .url,
                      textInputAction: .done,
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
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => homeNotifier.getArticle(context),
                      child: const Text('Get Article'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
