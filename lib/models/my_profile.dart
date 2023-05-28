class MyProfile {
  String? emailID;
  String? address;
  String? notificationToken;
  String? userLatitude;
  String? userWardNumber;
  String? municipalityID;
  String? modifiedBy;
  String? mobileNumber;
  String? userID;
  String? profilePicture;
  String? countryCode;
  String? createdDate;
  String? lastModifiedDate;
  String? createdBy;
  String? about;
  String? firstName;
  bool? active;
  String? userLongitude;

  MyProfile(
      {this.emailID,
      this.address,
      this.notificationToken,
      this.userLatitude,
      this.userWardNumber,
      this.municipalityID,
      this.modifiedBy,
      this.mobileNumber,
      this.userID,
      this.profilePicture,
      this.countryCode,
      this.createdDate,
      this.lastModifiedDate,
      this.createdBy,
      this.about,
      this.firstName,
      this.active,
      this.userLongitude});

  MyProfile.fromJson(Map<String, dynamic> json) {
    emailID = json['EmailID'];
    address = json['Address'];
    notificationToken = json['NotificationToken'];
    userLatitude = json['UserLatitude'];
    userWardNumber = json['UserWardNumber'];
    municipalityID = json['MunicipalityID'];
    modifiedBy = json['ModifiedBy'];
    mobileNumber = json['MobileNumber'];
    userID = json['UserID'];
    profilePicture = json['ProfilePicture'];
    countryCode = json['CountryCode'];
    createdDate = json['CreatedDate'];
    lastModifiedDate = json['LastModifiedDate'];
    createdBy = json['CreatedBy'];
    about = json['About'];
    firstName = json['FirstName'];
    active = json['Active'];
    userLongitude = json['UserLongitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['EmailID'] = emailID;
    data['Address'] = address;
    data['NotificationToken'] = notificationToken;
    data['UserLatitude'] = userLatitude;
    data['UserWardNumber'] = userWardNumber;
    data['MunicipalityID'] = municipalityID;
    data['ModifiedBy'] = modifiedBy;
    data['MobileNumber'] = mobileNumber;
    data['UserID'] = userID;
    data['ProfilePicture'] =profilePicture;
    data['CountryCode'] = countryCode;
    data['CreatedDate'] = createdDate;
    data['LastModifiedDate'] = lastModifiedDate;
    data['CreatedBy'] = createdBy;
    data['About'] = about;
    data['FirstName'] = firstName;
    data['Active'] = active;
    data['UserLongitude'] = userLongitude;
    return data;
  }
}