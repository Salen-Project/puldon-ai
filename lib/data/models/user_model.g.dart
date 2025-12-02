// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: json['id'] as String,
  phoneNumber: json['phone_number'] as String,
  fullName: json['full_name'] as String,
  gender: json['gender'] as String?,
  dateOfBirth: json['date_of_birth'] as String?,
  email: json['email'] as String?,
  imageId: json['image_id'] as String?,
  createdAt: json['created_at'] as String,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'phone_number': instance.phoneNumber,
  'full_name': instance.fullName,
  'gender': instance.gender,
  'date_of_birth': instance.dateOfBirth,
  'email': instance.email,
  'image_id': instance.imageId,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};

SignUpRequest _$SignUpRequestFromJson(Map<String, dynamic> json) =>
    SignUpRequest(
      phoneNumber: json['phone_number'] as String,
      fullName: json['full_name'] as String,
      gender: json['gender'] as String?,
      dateOfBirth: json['date_of_birth'] as String?,
      email: json['email'] as String?,
      imageId: json['image_id'] as String?,
    );

Map<String, dynamic> _$SignUpRequestToJson(SignUpRequest instance) =>
    <String, dynamic>{
      'phone_number': instance.phoneNumber,
      'full_name': instance.fullName,
      'gender': instance.gender,
      'date_of_birth': instance.dateOfBirth,
      'email': instance.email,
      'image_id': instance.imageId,
    };

SignUpResponse _$SignUpResponseFromJson(Map<String, dynamic> json) =>
    SignUpResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      userId: json['user_id'] as String,
    );

Map<String, dynamic> _$SignUpResponseToJson(SignUpResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'user_id': instance.userId,
    };

OtpRequest _$OtpRequestFromJson(Map<String, dynamic> json) =>
    OtpRequest(phoneNumber: json['phone_number'] as String);

Map<String, dynamic> _$OtpRequestToJson(OtpRequest instance) =>
    <String, dynamic>{'phone_number': instance.phoneNumber};

OtpResponse _$OtpResponseFromJson(Map<String, dynamic> json) => OtpResponse(
  message: json['message'] as String,
  otpCode: json['otp_code'] as String?,
);

Map<String, dynamic> _$OtpResponseToJson(OtpResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'otp_code': instance.otpCode,
    };

VerifyOtpRequest _$VerifyOtpRequestFromJson(Map<String, dynamic> json) =>
    VerifyOtpRequest(
      phoneNumber: json['phone_number'] as String,
      otp: json['otp'] as String,
    );

Map<String, dynamic> _$VerifyOtpRequestToJson(VerifyOtpRequest instance) =>
    <String, dynamic>{
      'phone_number': instance.phoneNumber,
      'otp': instance.otp,
    };

TokenResponse _$TokenResponseFromJson(Map<String, dynamic> json) =>
    TokenResponse(
      accessToken: json['access_token'] as String,
      tokenType: json['token_type'] as String,
    );

Map<String, dynamic> _$TokenResponseToJson(TokenResponse instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'token_type': instance.tokenType,
    };

UpdateProfileRequest _$UpdateProfileRequestFromJson(
  Map<String, dynamic> json,
) => UpdateProfileRequest(
  fullName: json['full_name'] as String?,
  gender: json['gender'] as String?,
  dateOfBirth: json['date_of_birth'] as String?,
  email: json['email'] as String?,
  imageId: json['image_id'] as String?,
);

Map<String, dynamic> _$UpdateProfileRequestToJson(
  UpdateProfileRequest instance,
) => <String, dynamic>{
  'full_name': instance.fullName,
  'gender': instance.gender,
  'date_of_birth': instance.dateOfBirth,
  'email': instance.email,
  'image_id': instance.imageId,
};

UpdateProfileResponse _$UpdateProfileResponseFromJson(
  Map<String, dynamic> json,
) => UpdateProfileResponse(
  success: json['success'] as bool,
  message: json['message'] as String,
  user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
);

Map<String, dynamic> _$UpdateProfileResponseToJson(
  UpdateProfileResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'user': instance.user,
};
