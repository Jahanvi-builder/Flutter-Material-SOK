class Coupon {
  const Coupon({
    required this.code,
    required this.title,
    required this.description,
    required this.isPercent,
    required this.value,
    required this.minOrder,
    this.maxDiscount,
  });

  final String code;
  final String title;
  final String description;
  final bool isPercent;      // true = percent off, false = flat off
  final double value;        // percent (0–100) or rupee amount
  final double minOrder;     // minimum cart subtotal to be eligible
  final double? maxDiscount; // cap for percent-based coupons

  double savings(double subtotal) {
    if (subtotal < minOrder) return 0;
    if (isPercent) {
      final d = subtotal * value / 100;
      return maxDiscount != null ? d.clamp(0.0, maxDiscount!) : d;
    } else {
      return value.clamp(0.0, subtotal);
    }
  }

  String get shortLabel =>
      isPercent ? '${value.round()}% OFF' : '₹${value.round()} OFF';
}

const availableCoupons = <Coupon>[
  Coupon(
    code: 'WELCOME20',
    title: '20% off your first order',
    description: 'Get 20% off (up to ₹100) on orders above ₹200',
    isPercent: true,
    value: 20,
    minOrder: 200,
    maxDiscount: 100,
  ),
  Coupon(
    code: 'FLAT50',
    title: '₹50 flat discount',
    description: 'Flat ₹50 off on orders of ₹300 or more',
    isPercent: false,
    value: 50,
    minOrder: 300,
  ),
  Coupon(
    code: 'TASTY10',
    title: '10% off on any order',
    description: '10% off (up to ₹75) on orders above ₹150',
    isPercent: true,
    value: 10,
    minOrder: 150,
    maxDiscount: 75,
  ),
  Coupon(
    code: 'PINELABS',
    title: '15% Pine Labs reward',
    description: '15% off (up to ₹150) on orders of ₹400 or more',
    isPercent: true,
    value: 15,
    minOrder: 400,
    maxDiscount: 150,
  ),
];

/// Coupon pre-applied when the cart screen opens.
final preAppliedCoupon = availableCoupons[0]; // WELCOME20
