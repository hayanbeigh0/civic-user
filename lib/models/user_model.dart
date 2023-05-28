class User {
  String? about;
  bool? active;
  String? address;
  String? countryCode;
  String? staffId;
  String? createdDate;
  String? emailId;
  String? firstName;
  String? lastModifiedDate;
  String? lastName;
  String? mobileNumber;
  String? municipalityId;
  String? notificationToken;
  String? profilePicture;
  String? latitude;
  String? longitude;
  String? wardNumber;

  User(
      {this.about,
      this.active,
      this.address,
      this.countryCode,
      this.staffId,
      this.createdDate,
      this.emailId,
      this.firstName,
      this.lastModifiedDate,
      this.lastName,
      this.mobileNumber,
      this.municipalityId,
      this.notificationToken,
      this.profilePicture,
      this.latitude,
      this.longitude,
      this.wardNumber});

  User.fromJson(Map<String, dynamic> json) {
    about = json['about'];
    active = json['active'];
    address = json['address'];
    countryCode = json['countryCode'];
    staffId = json['staffId'];
    createdDate = json['createdDate'];
    emailId = json['emailId'];
    firstName = json['firstName'];
    lastModifiedDate = json['lastModifiedDate'];
    lastName = json['lastName'];
    mobileNumber = json['mobileNumber'];
    municipalityId = json['municipalityId'];
    notificationToken = json['notificationToken'];
    profilePicture = json['profilePicture'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    wardNumber = json['wardNumber'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['about'] = about;
    data['active'] = active;
    data['address'] = address;
    data['countryCode'] = countryCode;
    data['staffId'] = staffId;
    data['createdDate'] = createdDate;
    data['emailId'] = emailId;
    data['firstName'] = firstName;
    data['lastModifiedDate'] = lastModifiedDate;
    data['lastName'] = lastName;
    data['mobileNumber'] = mobileNumber;
    data['municipalityId'] = municipalityId;
    data['notificationToken'] = notificationToken;
    data['profilePicture'] = profilePicture;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['wardNumber'] = wardNumber;
    return data;
  }
}
