import 'package:flutter/material.dart';

@immutable
class HomeState {
  final TextEditingController urlController;
  final GlobalKey<FormState> formKey;

  const HomeState({required this.urlController, required this.formKey});
}
