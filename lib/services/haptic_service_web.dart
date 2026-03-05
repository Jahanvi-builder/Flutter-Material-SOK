import 'dart:js_interop';

@JS('triggerHaptic')
external JSPromise _triggerHaptic(JSString preset);

class HapticService {
  static void tap() => _triggerHaptic('light'.toJS);
  static void paymentSuccess() => _triggerHaptic('success'.toJS);
}
