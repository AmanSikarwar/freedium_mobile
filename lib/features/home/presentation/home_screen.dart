import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/core/constants/app_constants.dart';
import 'package:freedium_mobile/features/home/application/home_provider.dart';
import 'package:freedium_mobile/features/home/presentation/widgets/about_dialog.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeProvider);
    final homeNotifier = ref.read(homeProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppConstants.appName,
          style: GoogleFonts.playfairDisplay(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () => showAppAboutDialog(context),
            tooltip: 'About',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            spacing: 24,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                AppConstants.appDescription,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              Form(
                key: homeState.formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
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
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.done,
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
    );
  }
}
