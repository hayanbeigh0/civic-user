class Grievances {
  String? municipalityId;
  String? grievanceId;
  String? address;
  String? contactNumber;
  String? createdBy;
  String? createdByName;
  String? createdDate;
  String? description;
  String? expectedCompletion;
  String? grievanceType;
  String? lastModifiedDate;
  String? location;
  String? latitude;
  String? longitude;
  String? newHouseAddress;
  String? planDetails;
  String? deceasedName;
  String? relation;
  bool? contactByPhoneEnabled;
  String? priority;
  String? status;
  String? wardNumber;
  Map? assets;

  Grievances({
    this.municipalityId,
    this.grievanceId,
    this.address,
    this.contactNumber,
    this.createdBy,
    this.createdByName,
    this.createdDate,
    this.description,
    this.expectedCompletion,
    this.grievanceType,
    this.lastModifiedDate,
    this.location,
    this.latitude,
    this.longitude,
    this.contactByPhoneEnabled,
    this.priority,
    this.status,
    this.wardNumber,
    this.assets,
    this.newHouseAddress,
    this.planDetails,
    this.deceasedName,
    this.relation,
  });

  Grievances.fromJson(Map<String, dynamic> json) {
    municipalityId = json['MunicipalityID'];
    grievanceId = json['GrievanceID'];
    address = json['Address'];
    contactNumber = json['ContactNumber'];
    createdBy = json['CreatedBy'];
    createdByName = json['CreatedByName'];
    createdDate = json['CreatedDate'];
    description = json['Description'];
    expectedCompletion = json['ExpectedCompletion'];
    grievanceType = json['GrievanceType'];
    lastModifiedDate = json['LastModifiedDate'];
    location = json['Location'];
    latitude = json['LocationLat'];
    longitude = json['LocationLong'];
    contactByPhoneEnabled = json['MobileContactStatus'];
    priority = json['Priority'];
    status = json['Status'];
    wardNumber = json['WardNumber'];
    assets = json['Assets'];
    grievanceType = json['grievanceType'];
    status = json['status'];
    priority = json['priority'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    wardNumber = json['wardNumber'];
    description = json['description'];
    contactByPhoneEnabled = json['contactByPhoneEnabled'];
    newHouseAddress = json['NewHouseAddress'];
    planDetails = json['PlanDetails'];
    deceasedName = json['DeceasedName'];
    relation = json['Relation'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['MunicipalityID'] = municipalityId;
    data['GrievanceID'] = grievanceId;
    data['Address'] = address;
    data['ContactNumber'] = contactNumber;
    data['CreatedBy'] = createdBy;
    data['CreatedByName'] = createdByName;
    data['CreatedDate'] = createdDate;
    data['ExpectedCompletion'] = expectedCompletion;
    data['Description'] = description;
    data['GrievanceType'] = grievanceType;
    data['LastModifiedDate'] = lastModifiedDate;
    data['Location'] = location;
    data['LocationLat'] = latitude;
    data['LocationLong'] = longitude;
    data['MobileContactStatus'] = contactByPhoneEnabled;
    data['Priority'] = priority;
    data['Status'] = status;
    data['WardNumber'] = wardNumber;
    data['Assets'] = assets;
    data['expectedCompletion'] = expectedCompletion;
    data['grievanceType'] = grievanceType;
    data['status'] = status;
    data['priority'] = priority;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['wardNumber'] = wardNumber;
    data['description'] = description;
    data['contactByPhoneEnabled'] = contactByPhoneEnabled;
    data['NewHouseAddress'] = newHouseAddress;
    data['PlanDetails'] = planDetails;
    data['DeceasedName'] = deceasedName;
    data['Relation'] = relation;
    return data;
  }
}
