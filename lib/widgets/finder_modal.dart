import 'package:flutter/material.dart';
import 'package:kralupy_streets/utils/custom_logger.dart';

import 'package:kralupy_streets/utils/storage_helper.dart';
import 'package:kralupy_streets/widgets/ui/custom_filled_button.dart';

/// Bottom modal which returns username as String?
/// returns null if username is empty
/// Can be closed only with "Skip" or "Submit" buttons
class FinderModal extends StatefulWidget {
  const FinderModal({super.key});

  @override
  State<FinderModal> createState() => _FinderModalState();
}

class _FinderModalState extends State<FinderModal> {
  static const usernamePrefsKey = 'username';
  final storage = StorageHelper();
  final log = CustomLogger('FinderModal');

  final _usernameTextController = TextEditingController();

  bool hasError = false;

  @override
  void initState() {
    _usernameTextController.text =
        storage.getStringValue(usernamePrefsKey) ?? '';
    super.initState();
  }

  @override
  void dispose() {
    _usernameTextController.dispose();
    super.dispose();
  }

  void _sendFinder() {
    final username = _getUsername();
    // validation check
    if (username == null ||
        username.length < 2 ||
        username.length > 15 ||
        !_containsOnlyLetters(username)) {
      setState(() => hasError = true);
      log.trace('Username invalid, displaying error message');
      return;
    }
    log.trace('Username valid, closing modal');
    Navigator.of(context).pop(_getUsername());
    storage.setStringValue(usernamePrefsKey, username);
  }

  String? _getUsername() {
    final username = _usernameTextController.text.trim();
    return username.isEmpty ? null : username;
  }

  bool _containsOnlyLetters(String input) {
    final RegExp regex = RegExp(r'^[a-zA-Z]+$');
    return regex.hasMatch(input);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Gratulujeme!',
            style: Theme.of(context).textTheme.labelLarge!.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            'Jste první, kdo ulovil tuto ulici. Vyplňte svou přezdívku a ukažte všem, že právě vy jste tuto záhadu vyřešili!',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _usernameTextController,
            onChanged: (value) => setState(() => hasError = false),
            maxLength: 15,
            autocorrect: false,
            decoration: const InputDecoration(
              label: Text('Přezdívka'),
            ),
          ),
          if (hasError)
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                const Icon(
                  Icons.warning,
                  color: Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 6),
                Text(
                  'Přezdívka by měla obsahovat minimálně 2 písmena a žádné jiné znaky.',
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Colors.red,
                      ),
                ),
              ],
            ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              log.trace('Username skipped, closing modal');
              Navigator.of(context).pop(null);
            },
            child: const Text('Přeskočit'),
          ),
          const SizedBox(height: 8),
          CustomFilledButton(
            'Odeslat',
            fitMaxWidth: true,
            onPressed: _sendFinder,
          ),
        ],
      ),
    );
  }
}
