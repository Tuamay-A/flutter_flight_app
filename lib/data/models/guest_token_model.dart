class GuestTokenResponse {
  final String guestToken;
  final String agencyType;
  final int expiresIn;
  final String message;

  GuestTokenResponse({
    required this.guestToken,
    this.agencyType = '',
    this.expiresIn = 3600,
    this.message = '',
  });

  factory GuestTokenResponse.fromJson(Map<String, dynamic> json) {
    return GuestTokenResponse(
      guestToken: json['guestToken'] ?? json['guest_token'] ?? '',
      agencyType: json['agencyType'] ?? '',
      expiresIn: json['expiresIn'] ?? 3600,
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'guestToken': guestToken,
      'agencyType': agencyType,
      'expiresIn': expiresIn,
      'message': message,
    };
  }
}
