import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/cart_controller.dart';
import '../../services/haptic_service.dart';
import 'confirmation_screen.dart';

Widget postPaymentDestination({
  required CartController cart,
  required String paymentMethod,
}) {
  if (cart.orderType == OrderType.dineIn) {
    return TableTokenScreen(cart: cart, paymentMethod: paymentMethod);
  }
  return ConfirmationScreen(cart: cart, paymentMethod: paymentMethod);
}

class TableTokenScreen extends StatefulWidget {
  const TableTokenScreen({
    super.key,
    required this.cart,
    required this.paymentMethod,
  });

  final CartController cart;
  final String paymentMethod;

  @override
  State<TableTokenScreen> createState() => _TableTokenScreenState();
}

class _TableTokenScreenState extends State<TableTokenScreen> {
  final _controller = TextEditingController();

  bool get _hasToken => _controller.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.cart.tableToken ?? '';
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Table Details'),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Icon(
                      Icons.table_restaurant_rounded,
                      size: 34,
                      color: cs.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Enter your table number',
                    style: tt.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'We will bring your order directly to your table after it is ready.',
                    style: tt.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
                  ),
                  const SizedBox(height: 28),
                  TextField(
                    controller: _controller,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3),
                    ],
                    style: tt.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Table number',
                      hintText: 'e.g. 12',
                      prefixIcon: const Icon(Icons.pin_outlined),
                      filled: true,
                      fillColor: cs.surfaceContainerLow,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _continue(),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Look for the number on your table tent or table marker.',
                    style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                  ),
                  const SizedBox(height: 28),
                  FilledButton.icon(
                    onPressed: _hasToken ? _continue : null,
                    icon: const Icon(Icons.check_circle_outline_rounded),
                    label: const Text('Continue to Confirmation'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
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

  void _continue() {
    if (!_hasToken) return;
    HapticService.tap();
    widget.cart.setTableToken(_controller.text.trim());
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ConfirmationScreen(
          cart: widget.cart,
          paymentMethod: widget.paymentMethod,
        ),
      ),
    );
  }
}
