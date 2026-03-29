// ignore_for_file: avoid_print

import 'passenger_model.dart';
import 'flight_shopping_model.dart';

class BookingHoldRequest {
  final bool bookingHold;
  final String executionId;
  final String offerPriceId;
  final String provider;
  final List<OfferItem> offerItems;
  final List<Passenger> customerInfos;
  final Travellers travellers;
  final Map<String, dynamic> verifyRequest;

  BookingHoldRequest({
    this.bookingHold = true,
    required this.executionId,
    required this.offerPriceId,
    required this.provider,
    required this.offerItems,
    required this.customerInfos,
    required this.travellers,
    required this.verifyRequest,
  });

  Map<String, dynamic> toJson() {
    return {
      'bookingHold': bookingHold,
      'executionId': executionId,
      'offerPriceId': offerPriceId,
      'provider': provider,
      'offerItems': offerItems.map((e) => e.toJson()).toList(),
      'customerInfos': customerInfos.map((p) => p.toJson()).toList(),
      'travellers': travellers.toJson(),
      'verifyRequest': verifyRequest,
    };
  }
}

class BookingHoldResponse {
  final String bookingLocator; // pnr e.g. "XMHB5G"
  final String orderId; // e.g. "69c64bfc8cc4bc613841c871"
  final String status; // e.g. "ON_HOLD"
  final List<PaymentOption> paymentOptions;

  BookingHoldResponse({
    required this.bookingLocator,
    required this.orderId,
    required this.status,
    this.paymentOptions = const [],
  });

  factory BookingHoldResponse.fromJson(Map<String, dynamic> json) {
    print('BookingHoldResponse.fromJson raw keys: ${json.keys.toList()}');
    final data = json['data'] ?? json;

    // pnr is the real booking reference shown to the user
    final pnr =
        data['pnr']?.toString() ??
        data['bookingReference']?.toString() ??
        data['bookingLocator']?.toString() ??
        data['id']?.toString() ??
        '';

    final orderId = data['id']?.toString() ?? '';
    final status =
        data['bookingStatus']?.toString() ?? data['status']?.toString() ?? '';

    // Payment options are already in the hold response — no need for a separate call
    List<PaymentOption> options = [];
    try {
      final cards = data['paymentOptions']?['cards'] as List?;
      if (cards != null) {
        options = cards.map((c) => PaymentOption.fromJson(c)).toList();
      }
    } catch (_) {}

    print(
      '✅ BookingHoldResponse: pnr=$pnr | orderId=$orderId | status=$status | paymentOptions=${options.length}',
    );
    return BookingHoldResponse(
      bookingLocator: pnr,
      orderId: orderId,
      status: status,
      paymentOptions: options,
    );
  }
}

class ConfirmBookingRequest {
  final String bookingLocator;
  final PaymentOption payOption;
  final bool isCardMethod;
  final CardInfo? cardInfo;

  ConfirmBookingRequest({
    required this.bookingLocator,
    required this.payOption,
    this.isCardMethod = true,
    this.cardInfo,
  });

  Map<String, dynamic> toJson() {
    return {
      'bookingLocator': bookingLocator,
      'payOption': payOption.toJson(),
      'isCardMethod': isCardMethod,
      'cardInfo': cardInfo?.toJson(),
    };
  }
}

class PaymentOption {
  final int id;
  final String? name;
  final String? type;
  final String? logo;

  PaymentOption({required this.id, this.name, this.type, this.logo});

  Map<String, dynamic> toJson() => {'id': id};

  factory PaymentOption.fromJson(Map<String, dynamic> json) {
    return PaymentOption(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      name: json['displayName'] ?? json['name'],
      type: json['type'],
      logo: json['logo'],
    );
  }
}

class CardInfo {
  final String cardHolder;
  final String cardNumber;
  final String expireMonth;
  final String expireYear;
  final String cvv;

  CardInfo({
    required this.cardHolder,
    required this.cardNumber,
    required this.expireMonth,
    required this.expireYear,
    required this.cvv,
  });

  Map<String, dynamic> toJson() {
    return {
      'cardHolder': cardHolder,
      'cardNumber': cardNumber,
      'expireMonth': expireMonth,
      'expireYear': expireYear,
      'cvv': cvv,
    };
  }
}

class PaymentCallbackRequest {
  final String status;
  final String traceNumber;
  final String txnref;

  PaymentCallbackRequest({
    required this.status,
    required this.traceNumber,
    required this.txnref,
  });

  Map<String, dynamic> toJson() {
    return {'status': status, 'traceNumber': traceNumber, 'txnref': txnref};
  }
}
