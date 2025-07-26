import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:freedium_mobile/screens/webview_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _urlController;

  @override
  void initState() {
    _urlController = TextEditingController();
    super.initState();
  }

  Future<void> _pasteUrl() async {
    try {
      final ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
      if (data != null && data.text != null && data.text!.isNotEmpty) {
        _urlController.text = data.text!;
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Clipboard is empty')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error accessing clipboard: $e')),
        );
      }
    }
  }

  void _showAboutFreediumDialog() {
    showAboutDialog(
      context: context,
      applicationIcon: Image.asset(
        'assets/icon/icon.png',
        width: 48,
        height: 48,
      ),
      applicationName: 'Freedium',
      applicationVersion: '0.3.1',
      children: [
        Text(
          'Freedium is a paywall bypasser for Medium articles.\n\n'
          'Just paste the URL of the article you want to read and '
          'Freedium will take care of the rest!\n\n',
        ),
        Wrap(
          alignment: WrapAlignment.start,
          children: [
            const Text('Source code available on '),
            GestureDetector(
              onTap:
                  () => _launchUri(
                    Uri.https('github.com', 'amansikarwar/freedium_mobile'),
                  ),
              child: Text(
                'GitHub',
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Made with ❤️ by', style: const TextStyle(fontSize: 12)),
            TextButton(
              onPressed:
                  () => _launchUri(Uri.https('github.com', 'amansikarwar')),
              child: const Text(
                'Aman Sikarwar',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _launchUri(Uri uri) async {
    try {
      await launchUrl(uri);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not launch URL: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Freedium',
          style: GoogleFonts.playfairDisplay(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        titleTextStyle: const TextStyle(
          color: Colors.green,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: _showAboutFreediumDialog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Your paywall breakthrough for Medium!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: TextFormField(
                  controller: _urlController,
                  decoration: InputDecoration(
                    hintText: 'Medium URL',
                    prefixIcon: const Icon(Icons.link),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(24)),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.paste),
                      onPressed: _pasteUrl,
                    ),
                  ),
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a URL';
                    }
                    final urlRegExp = RegExp(
                      r'^https?:\/\/([\w-]+\.)+[\w-]+(\/[\w-./?%&=@]*)?$',
                      caseSensitive: false,
                    );
                    if (!urlRegExp.hasMatch(value)) {
                      return 'Please enter a valid URL';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  WebviewScreen(url: _urlController.text),
                        ),
                      );
                    }
                  },
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
