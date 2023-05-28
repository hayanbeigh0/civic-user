class GrievanceNotification {
  String? createdByName;
  String? address;
  String? priority;
  String? locationLong;
  String? grievanceId;
  String? contactNumber;
  String? description;
  String? expectedCompletion;
  String? status;
  String? locationLat;
  String? municipalityId;
  String? createdDate;
  String? lastModifiedDate;
  String? location;
  String? createdBy;
  bool? mobileContactStatus;
  String? wardNumber;
  String? grievanceType;

  GrievanceNotification({
    this.createdByName,
    this.address,
    this.priority,
    this.locationLong,
    this.grievanceId,
    this.contactNumber,
    this.description,
    this.expectedCompletion,
    this.status,
    this.locationLat,
    this.municipalityId,
    this.createdDate,
    this.lastModifiedDate,
    this.location,
    this.createdBy,
    this.mobileContactStatus,
    this.wardNumber,
    this.grievanceType,
  });

  GrievanceNotification.fromJson(Map<String, dynamic> json) {
    createdByName = json['CreatedByName'];
    address = json['Address'];
    priority = json['Priority'];
    locationLong = json['LocationLong'];
    grievanceId = json['GrievanceID'];
    contactNumber = json['ContactNumber'];
    description = json['Description'];
    expectedCompletion = json['ExpectedCompletion'];
    status = json['Status'];
    locationLat = json['LocationLat'];
    municipalityId = json['MunicipalityID'];
    createdDate = json['CreatedDate'];
    lastModifiedDate = json['LastModifiedDate'];
    location = json['Location'];
    createdBy = json['CreatedBy'];
    mobileContactStatus = json['MobileContactStatus'];
    wardNumber = json['WardNumber'];
    grievanceType = json['GrievanceType'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['CreatedByName'] = createdByName;
    data['Address'] = address;
    data['Priority'] = priority;
    data['LocationLong'] = locationLong;
    data['GrievanceID'] = grievanceId;
    data['ContactNumber'] = contactNumber;
    data['Description'] = description;
    data['ExpectedCompletion'] = expectedCompletion;
    data['Status'] = status;
    data['LocationLat'] = locationLat;
    data['MunicipalityID'] = municipalityId;
    data['CreatedDate'] = createdDate;
    data['LastModifiedDate'] = lastModifiedDate;
    data['Location'] = location;
    data['CreatedBy'] = createdBy;
    data['MobileContactStatus'] = mobileContactStatus;
    data['WardNumber'] = wardNumber;
    data['GrievanceType'] = grievanceType;
    return data;
  }
}