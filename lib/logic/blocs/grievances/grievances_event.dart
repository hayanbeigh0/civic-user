// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'grievances_bloc.dart';

abstract class GrievancesEvent extends Equatable {
  const GrievancesEvent();
}

class LoadGrievancesEvent extends GrievancesEvent {
  final String municipalityId;
  final String createdBy;

  const LoadGrievancesEvent(
      {required this.municipalityId, required this.createdBy});

  @override
  List<Object> get props => [municipalityId, createdBy];
}

// class GetGrievancesEvent extends GrievancesEvent {
//   @override
//   List<Object> get props => [];
// }

class CloseGrievanceEvent extends GrievancesEvent {
  final String grievanceId;
  const CloseGrievanceEvent({
    required this.grievanceId,
  });
  @override
  List<Object> get props => [grievanceId];
}

class SearchGrievanceByTypeEvent extends GrievancesEvent {
  final String grievanceType;
  const SearchGrievanceByTypeEvent({
    required this.grievanceType,
  });
  @override
  List<Object> get props => [grievanceType];
}

class UpdateGrievanceEvent extends GrievancesEvent {
  final Grievances newGrievance;
  final String grievanceId;
  final String municipalityId;
  const UpdateGrievanceEvent(
      {required this.grievanceId,
      required this.newGrievance,
      required this.municipalityId});

  @override
  List<Object> get props => [grievanceId, newGrievance];
}

class UpdateExpectedCompletionEvent extends GrievancesEvent {
  final String expectedCompletion;
  final String grievanceId;
  const UpdateExpectedCompletionEvent({
    required this.grievanceId,
    required this.expectedCompletion,
  });
  @override
  List<Object> get props => [grievanceId, expectedCompletion];
}

class AddGrievanceCommentEvent extends GrievancesEvent {
  final String grievanceId;
  final String userId;
  final String name;
  final String comment;
  final Map assets;
  const AddGrievanceCommentEvent(
      {required this.grievanceId,
      required this.name,
      required this.userId,
      required this.assets,
      required this.comment});
  @override
  List<Object> get props => [grievanceId, userId, name, assets, comment];
}

class AddGrievanceAudioCommentAssetsEvent extends GrievancesEvent {
  final String encodedCommentFile;
  final String fileType;
  final String grievanceId;
  const AddGrievanceAudioCommentAssetsEvent({
    required this.grievanceId,
    required this.fileType,
    required this.encodedCommentFile,
  });
  @override
  List<Object> get props => [grievanceId, fileType, encodedCommentFile];
}

class AddGrievanceImageCommentAssetsEvent extends GrievancesEvent {
  final String encodedCommentFile;
  final String fileType;
  final String grievanceId;
  const AddGrievanceImageCommentAssetsEvent({
    required this.grievanceId,
    required this.fileType,
    required this.encodedCommentFile,
  });
  @override
  List<Object> get props => [grievanceId, fileType, encodedCommentFile];
}

class AddGrievanceVideoCommentAssetsEvent extends GrievancesEvent {
  final String encodedCommentFile;
  final String fileType;
  final String grievanceId;
  const AddGrievanceVideoCommentAssetsEvent({
    required this.grievanceId,
    required this.fileType,
    required this.encodedCommentFile,
  });
  @override
  List<Object> get props => [grievanceId, fileType, encodedCommentFile];
}

class GetGrievanceByIdEvent extends GrievancesEvent {
  final String municipalityId;
  final String grievanceId;
  const GetGrievanceByIdEvent({
    required this.municipalityId,
    required this.grievanceId,
  });
  @override
  List<Object> get props => [municipalityId, grievanceId];
}

class AddGrievanceEvent extends GrievancesEvent {
  final Grievances grievance;
  const AddGrievanceEvent({
    required this.grievance,
  });
  @override
  List<Object> get props => [grievance];
}

class ShowOnlyOpenGrievancesEvent extends GrievancesEvent {
  @override
  List<Object> get props => [];
}

class UpdateGrievanceStatusEvent extends GrievancesEvent {
  final String status;
  final String grievanceId;
  const UpdateGrievanceStatusEvent({
    required this.grievanceId,
    required this.status,
  });
  @override
  List<Object> get props => [grievanceId, status];
}

class AddGrievanceImageAssetEvent extends GrievancesEvent {
  final String encodedAssetFile;
  final String fileType;
  final String userId;

  const AddGrievanceImageAssetEvent(
      {required this.userId,
      required this.fileType,
      required this.encodedAssetFile});

  @override
  List<Object> get props => [userId, fileType, encodedAssetFile];
}

class AddGrievanceVideoAssetEvent extends GrievancesEvent {
  final String encodedAssetFile;
  final String fileType;
  final String userId;

  const AddGrievanceVideoAssetEvent(
      {required this.userId,
      required this.fileType,
      required this.encodedAssetFile});

  @override
  List<Object> get props => [userId, fileType, encodedAssetFile];
}

class AddGrievanceAudioAssetEvent extends GrievancesEvent {
  final String encodedAssetFile;
  final String fileType;
  final String userId;

  const AddGrievanceAudioAssetEvent(
      {required this.userId,
      required this.fileType,
      required this.encodedAssetFile});

  @override
  List<Object> get props => [userId, fileType, encodedAssetFile];
}

