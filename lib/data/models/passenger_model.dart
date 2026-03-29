class Passenger {
  final String gender;
  final String birthDate;
  final String phoneNo;
  final String firstName;
  final String lastName;
  final String middleName;
  final String country;
  final String passPort;
  final String title;
  final String email;
  final bool notify;
  final String paxType;
  final String paxId;
  final String accountNumber;
  final String depBarcodeImage;
  final String retBarcodeImage;
  final String depBarcodeCid;
  final String retBarcodeCid;

  Passenger({
    required this.gender,
    required this.birthDate,
    required this.phoneNo,
    required this.firstName,
    required this.lastName,
    this.middleName = '',
    required this.country,
    required this.passPort,
    required this.title,
    required this.email,
    this.notify = true,
    this.paxType = 'ADT',
    required this.paxId,
    this.accountNumber = '',
    this.depBarcodeImage = '',
    this.retBarcodeImage = '',
    this.depBarcodeCid = '',
    this.retBarcodeCid = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'gender': gender.toUpperCase(),
      'birthDate': birthDate,
      'phoneNo': phoneNo,
      'firstName': firstName,
      'lastName': lastName,
      'middleName': middleName,
      'country': country,
      'passPort': passPort,
      'title': title,
      'email': email,
      'notify': notify,
      'paxType': paxType,
      'paxId': paxId,
      'accountNumber': accountNumber,
      'depBarcodeImage': depBarcodeImage,
      'retBarcodeImage': retBarcodeImage,
      'depBarcodeCid': depBarcodeCid,
      'retBarcodeCid': retBarcodeCid,
    };
  }

  factory Passenger.fromJson(Map<String, dynamic> json) {
    return Passenger(
      gender: json['gender'] ?? '',
      birthDate: json['birthDate'] ?? '',
      phoneNo: json['phoneNo'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      middleName: json['middleName'] ?? '',
      country: json['country'] ?? '',
      passPort: json['passPort'] ?? '',
      title: json['title'] ?? '',
      email: json['email'] ?? '',
      notify: json['notify'] ?? true,
      paxType: json['paxType'] ?? 'ADT',
      paxId: json['paxId'] ?? '',
      accountNumber: json['accountNumber'] ?? '',
      depBarcodeImage: json['depBarcodeImage'] ?? '',
      retBarcodeImage: json['retBarcodeImage'] ?? '',
      depBarcodeCid: json['depBarcodeCid'] ?? '',
      retBarcodeCid: json['retBarcodeCid'] ?? '',
    );
  }
}
