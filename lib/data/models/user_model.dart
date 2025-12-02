import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final String id;
  @JsonKey(name: 'phone_number')
  final String phoneNumber;
  @JsonKey(name: 'full_name')
  final String fullName;
  final String? gender;
  @JsonKey(name: 'date_of_birth')
  final String? dateOfBirth;
  final String? email;
  @JsonKey(name: 'image_id')
  final String? imageId;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  UserModel({
    required this.id,
    required this.phoneNumber,
    required this.fullName,
    this.gender,
    this.dateOfBirth,
    this.email,
    this.imageId,
    required this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}

@JsonSerializable()
class SignUpRequest {
  @JsonKey(name: 'phone_number')
  final String phoneNumber;
  @JsonKey(name: 'full_name')
  final String fullName;
  final String? gender;
  @JsonKey(name: 'date_of_birth')
  final String? dateOfBirth;
  final String? email;
  @JsonKey(name: 'image_id')
  final String? imageId;

  SignUpRequest({
    required this.phoneNumber,
    required this.fullName,
    this.gender,
    this.dateOfBirth,
    this.email,
    this.imageId,
  });

  factory SignUpRequest.fromJson(Map<String, dynamic> json) =>
      _$SignUpRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SignUpRequestToJson(this);
}

@JsonSerializable()
class SignUpResponse {
  final bool success;
  final String message;
  @JsonKey(name: 'user_id')
  final String userId;

  SignUpResponse({
    required this.success,
    required this.message,
    required this.userId,
  });

  factory SignUpResponse.fromJson(Map<String, dynamic> json) =>
      _$SignUpResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SignUpResponseToJson(this);
}

@JsonSerializable()
class OtpRequest {
  @JsonKey(name: 'phone_number')
  final String phoneNumber;

  OtpRequest({required this.phoneNumber});

  factory OtpRequest.fromJson(Map<String, dynamic> json) =>
      _$OtpRequestFromJson(json);

  Map<String, dynamic> toJson() => _$OtpRequestToJson(this);
}

@JsonSerializable()
class OtpResponse {
  final String message;
  @JsonKey(name: 'otp_code')
  final String? otpCode;

  OtpResponse({
    required this.message,
    this.otpCode,
  });

  factory OtpResponse.fromJson(Map<String, dynamic> json) =>
      _$OtpResponseFromJson(json);

  Map<String, dynamic> toJson() => _$OtpResponseToJson(this);
}

@JsonSerializable()
class VerifyOtpRequest {
  @JsonKey(name: 'phone_number')
  final String phoneNumber;
  final String otp;

  VerifyOtpRequest({
    required this.phoneNumber,
    required this.otp,
  });

  factory VerifyOtpRequest.fromJson(Map<String, dynamic> json) =>
      _$VerifyOtpRequestFromJson(json);

  Map<String, dynamic> toJson() => _$VerifyOtpRequestToJson(this);
}

@JsonSerializable()
class TokenResponse {
  @JsonKey(name: 'access_token')
  final String accessToken;
  @JsonKey(name: 'token_type')
  final String tokenType;

  TokenResponse({
    required this.accessToken,
    required this.tokenType,
  });

  factory TokenResponse.fromJson(Map<String, dynamic> json) =>
      _$TokenResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TokenResponseToJson(this);
}

@JsonSerializable()
class UpdateProfileRequest {
  @JsonKey(name: 'full_name')
  final String? fullName;
  final String? gender;
  @JsonKey(name: 'date_of_birth')
  final String? dateOfBirth;
  final String? email;
  @JsonKey(name: 'image_id')
  final String? imageId;

  UpdateProfileRequest({
    this.fullName,
    this.gender,
    this.dateOfBirth,
    this.email,
    this.imageId,
  });

  factory UpdateProfileRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateProfileRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateProfileRequestToJson(this);
}

@JsonSerializable()
class UpdateProfileResponse {
  final bool success;
  final String message;
  final UserModel user;

  UpdateProfileResponse({
    required this.success,
    required this.message,
    required this.user,
  });

  factory UpdateProfileResponse.fromJson(Map<String, dynamic> json) =>
      _$UpdateProfileResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateProfileResponseToJson(this);
}
