import 'package:flutter/material.dart';

class M3ShowcaseScreen extends StatefulWidget {
  const M3ShowcaseScreen({super.key});

  @override
  State<M3ShowcaseScreen> createState() => _M3ShowcaseScreenState();
}

class _M3ShowcaseScreenState extends State<M3ShowcaseScreen> {
  int _navIndex = 0;

  static const _pages = [
    _ButtonsPage(),
    _SelectionPage(),
    _CardsPage(),
    _InputsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Material 3 Showcase'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'About',
            onPressed: () => _showAboutDialog(context),
          ),
        ],
      ),
      body: _pages[_navIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navIndex,
        onDestinationSelected: (i) => setState(() => _navIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.smart_button_outlined),
            selectedIcon: Icon(Icons.smart_button),
            label: 'Buttons',
          ),
          NavigationDestination(
            icon: Icon(Icons.check_box_outlined),
            selectedIcon: Icon(Icons.check_box),
            label: 'Selection',
          ),
          NavigationDestination(
            icon: Icon(Icons.credit_card_outlined),
            selectedIcon: Icon(Icons.credit_card),
            label: 'Cards',
          ),
          NavigationDestination(
            icon: Icon(Icons.input_outlined),
            selectedIcon: Icon(Icons.input),
            label: 'Inputs',
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        icon: const Icon(Icons.palette_outlined),
        title: const Text('Material 3 Showcase'),
        content: const Text(
          'This screen demonstrates Material 3 Expressive components '
          'with dynamic color and spring-based motion.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

// ── BUTTONS PAGE ──────────────────────────────────────────────────────────────

class _ButtonsPage extends StatelessWidget {
  const _ButtonsPage();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _SectionHeader('Buttons'),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton(onPressed: () {}, child: const Text('Filled')),
            FilledButton.tonal(onPressed: () {}, child: const Text('Tonal')),
            ElevatedButton(onPressed: () {}, child: const Text('Elevated')),
            OutlinedButton(onPressed: () {}, child: const Text('Outlined')),
            TextButton(onPressed: () {}, child: const Text('Text')),
          ],
        ),
        const SizedBox(height: 24),
        _SectionHeader('Icon Buttons'),
        Wrap(
          spacing: 8,
          children: [
            IconButton.filled(onPressed: () {}, icon: const Icon(Icons.favorite)),
            IconButton.filledTonal(onPressed: () {}, icon: const Icon(Icons.bookmark)),
            IconButton.outlined(onPressed: () {}, icon: const Icon(Icons.share)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz)),
          ],
        ),
        const SizedBox(height: 24),
        _SectionHeader('FABs'),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            FloatingActionButton.small(
              heroTag: 'fab-small',
              onPressed: () {},
              child: const Icon(Icons.add),
            ),
            FloatingActionButton(
              heroTag: 'fab-regular',
              onPressed: () {},
              child: const Icon(Icons.edit),
            ),
            FloatingActionButton.large(
              heroTag: 'fab-large',
              onPressed: () {},
              child: const Icon(Icons.camera_alt),
            ),
            FloatingActionButton.extended(
              heroTag: 'fab-extended',
              onPressed: () {},
              icon: const Icon(Icons.send),
              label: const Text('Send'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _SectionHeader('Chips'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ActionChip(
              avatar: const Icon(Icons.local_offer_outlined),
              label: const Text('Action'),
              onPressed: () {},
            ),
            FilterChip(
              label: const Text('Filter'),
              selected: true,
              onSelected: (_) {},
            ),
            InputChip(
              label: const Text('Input'),
              onDeleted: () {},
            ),
            ActionChip(
              avatar: const Icon(Icons.auto_awesome),
              label: const Text('Assist'),
              onPressed: () {},
            ),
            ChoiceChip(
              label: const Text('Choice'),
              selected: false,
              onSelected: (_) {},
            ),
          ],
        ),
        const SizedBox(height: 24),
        _SectionHeader('Badges'),
        Row(
          children: [
            Badge(label: const Text('3'), child: const Icon(Icons.notifications_outlined, size: 32)),
            const SizedBox(width: 24),
            Badge(child: const Icon(Icons.email_outlined, size: 32)),
            const SizedBox(width: 24),
            Badge(
              backgroundColor: cs.error,
              label: const Text('99+'),
              child: const Icon(Icons.shopping_cart_outlined, size: 32),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _SectionHeader('Progress Indicators'),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(),
            SizedBox(height: 16),
            Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 24),
                CircularProgressIndicator(value: 0.7),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

// ── SELECTION PAGE ────────────────────────────────────────────────────────────

class _SelectionPage extends StatefulWidget {
  const _SelectionPage();

  @override
  State<_SelectionPage> createState() => _SelectionPageState();
}

class _SelectionPageState extends State<_SelectionPage> {
  bool _switch1 = true;
  bool _switch2 = false;
  bool _check1 = true;
  bool _check2 = false;
  bool _check3 = true;
  int _radio = 1;
  double _slider = 0.4;
  RangeValues _range = const RangeValues(0.2, 0.7);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _SectionHeader('Switches'),
        Row(
          children: [
            Switch(value: _switch1, onChanged: (v) => setState(() => _switch1 = v)),
            const SizedBox(width: 16),
            Switch(value: _switch2, onChanged: (v) => setState(() => _switch2 = v)),
            const SizedBox(width: 16),
            Switch(
              value: _switch1,
              onChanged: (v) => setState(() => _switch1 = v),
              thumbIcon: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) return const Icon(Icons.check, size: 16);
                return const Icon(Icons.close, size: 16);
              }),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _SectionHeader('Checkboxes'),
        Row(
          children: [
            Checkbox(value: _check1, onChanged: (v) => setState(() => _check1 = v!)),
            Checkbox(value: _check2, onChanged: (v) => setState(() => _check2 = v!)),
            Checkbox(value: _check3, tristate: true, onChanged: (v) => setState(() => _check3 = v ?? false)),
            const Checkbox(value: false, onChanged: null), // disabled
          ],
        ),
        const SizedBox(height: 24),
        _SectionHeader('Radio Buttons'),
        RadioGroup<int>(
          groupValue: _radio,
          onChanged: (val) => setState(() => _radio = val!),
          child: Row(
            children: [1, 2, 3].map((v) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Radio<int>(value: v),
                  Text('Option $v'),
                  const SizedBox(width: 8),
                ],
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 24),
        _SectionHeader('Sliders'),
        Slider(
          value: _slider,
          onChanged: (v) => setState(() => _slider = v),
          divisions: 10,
          label: '${(_slider * 100).round()}%',
        ),
        const SizedBox(height: 8),
        RangeSlider(
          values: _range,
          onChanged: (v) => setState(() => _range = v),
          divisions: 10,
          labels: RangeLabels(
            '${(_range.start * 100).round()}%',
            '${(_range.end * 100).round()}%',
          ),
        ),
        const SizedBox(height: 24),
        _SectionHeader('Date & Time Pickers'),
        Row(
          children: [
            FilledButton.tonal(
              onPressed: () async {
                await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
              },
              child: const Text('Date Picker'),
            ),
            const SizedBox(width: 12),
            FilledButton.tonal(
              onPressed: () async {
                await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
              },
              child: const Text('Time Picker'),
            ),
          ],
        ),
      ],
    );
  }
}

// ── CARDS PAGE ────────────────────────────────────────────────────────────────

class _CardsPage extends StatelessWidget {
  const _CardsPage();

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _SectionHeader('Cards'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Elevated Card', style: tt.titleMedium),
                const SizedBox(height: 8),
                Text('Default card with elevation and shadow.', style: tt.bodyMedium),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () {}, child: const Text('Dismiss')),
                    const SizedBox(width: 8),
                    FilledButton(onPressed: () {}, child: const Text('Action')),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card.filled(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Filled Card', style: tt.titleMedium),
                const SizedBox(height: 8),
                Text('Uses surfaceContainerHighest background.', style: tt.bodyMedium),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card.outlined(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Outlined Card', style: tt.titleMedium),
                const SizedBox(height: 8),
                Text('Defined by a border with no elevation.', style: tt.bodyMedium),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        _SectionHeader('List Tiles'),
        Card.outlined(
          child: Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: cs.primaryContainer,
                  child: Icon(Icons.person, color: cs.onPrimaryContainer),
                ),
                title: const Text('Alice'),
                subtitle: const Text('Last seen just now'),
                trailing: IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
              ),
              const Divider(indent: 72, height: 1),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: cs.secondaryContainer,
                  child: Icon(Icons.group, color: cs.onSecondaryContainer),
                ),
                title: const Text('Design Team'),
                subtitle: const Text('3 new messages'),
                trailing: Badge(
                  label: const Text('3'),
                  child: IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
                ),
              ),
              const Divider(indent: 72, height: 1),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: cs.tertiaryContainer,
                  child: Icon(Icons.work, color: cs.onTertiaryContainer),
                ),
                title: const Text('Project Updates'),
                subtitle: const Text('No new messages'),
                trailing: IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _SectionHeader('Dialogs & Sheets'),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            OutlinedButton(
              onPressed: () => _showDialog(context),
              child: const Text('Alert Dialog'),
            ),
            OutlinedButton(
              onPressed: () => _showBottomSheet(context),
              child: const Text('Bottom Sheet'),
            ),
            OutlinedButton(
              onPressed: () => _showSnackBar(context),
              child: const Text('Snack Bar'),
            ),
          ],
        ),
      ],
    );
  }

  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded),
        title: const Text('Delete item?'),
        content: const Text('This action cannot be undone. The item will be permanently removed.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Delete')),
        ],
      ),
    );
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Share via', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ShareOption(Icons.message_outlined, 'Message'),
                _ShareOption(Icons.mail_outline, 'Email'),
                _ShareOption(Icons.link, 'Copy link'),
                _ShareOption(Icons.more_horiz, 'More'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Item deleted'),
        action: SnackBarAction(label: 'Undo', onPressed: () {}),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _ShareOption extends StatelessWidget {
  const _ShareOption(this.icon, this.label);
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: cs.primaryContainer,
          child: Icon(icon, color: cs.onPrimaryContainer),
        ),
        const SizedBox(height: 8),
        Text(label, style: Theme.of(context).textTheme.labelMedium),
      ],
    );
  }
}

// ── INPUTS PAGE ───────────────────────────────────────────────────────────────

class _InputsPage extends StatefulWidget {
  const _InputsPage();

  @override
  State<_InputsPage> createState() => _InputsPageState();
}

class _InputsPageState extends State<_InputsPage> {
  final _filledController = TextEditingController();
  final _outlinedController = TextEditingController();
  bool _obscure = true;
  String? _dropdownValue;

  @override
  void dispose() {
    _filledController.dispose();
    _outlinedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _SectionHeader('Text Fields'),
        TextField(
          controller: _filledController,
          decoration: const InputDecoration(
            filled: true,
            labelText: 'Filled text field',
            hintText: 'Enter some text',
            prefixIcon: Icon(Icons.search),
            helperText: 'Helper text',
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _outlinedController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Outlined text field',
            hintText: 'Enter some text',
            suffixIcon: Icon(Icons.clear),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          obscureText: _obscure,
          decoration: InputDecoration(
            filled: true,
            labelText: 'Password',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const TextField(
          maxLines: 3,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Multi-line',
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 24),
        _SectionHeader('Dropdown'),
        DropdownButtonFormField<String>(
          initialValue: _dropdownValue,
          decoration: const InputDecoration(
            filled: true,
            labelText: 'Select an option',
          ),
          items: const [
            DropdownMenuItem(value: 'opt1', child: Text('Option 1')),
            DropdownMenuItem(value: 'opt2', child: Text('Option 2')),
            DropdownMenuItem(value: 'opt3', child: Text('Option 3')),
          ],
          onChanged: (v) => setState(() => _dropdownValue = v),
        ),
        const SizedBox(height: 24),
        _SectionHeader('Color Palette'),
        _ColorPaletteGrid(),
      ],
    );
  }
}

class _ColorPaletteGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final swatches = [
      (cs.primary, cs.onPrimary, 'primary'),
      (cs.primaryContainer, cs.onPrimaryContainer, 'primaryContainer'),
      (cs.secondary, cs.onSecondary, 'secondary'),
      (cs.secondaryContainer, cs.onSecondaryContainer, 'secondaryContainer'),
      (cs.tertiary, cs.onTertiary, 'tertiary'),
      (cs.tertiaryContainer, cs.onTertiaryContainer, 'tertiaryContainer'),
      (cs.error, cs.onError, 'error'),
      (cs.errorContainer, cs.onErrorContainer, 'errorContainer'),
      (cs.surface, cs.onSurface, 'surface'),
      (cs.surfaceContainerHighest, cs.onSurface, 'surfaceContainer'),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.8,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: swatches.length,
      itemBuilder: (context, i) {
        final (bg, fg, label) = swatches[i];
        return Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      },
    );
  }
}

// ── SHARED HELPERS ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              letterSpacing: 0.5,
            ),
      ),
    );
  }
}
