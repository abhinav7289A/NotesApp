// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'document.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$IngestError {

 IngestErrorCode get code; String get message;
/// Create a copy of IngestError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IngestErrorCopyWith<IngestError> get copyWith => _$IngestErrorCopyWithImpl<IngestError>(this as IngestError, _$identity);

  /// Serializes this IngestError to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as IngestError;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IngestError&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.message, _this.message) || other.message == _this.message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as IngestError;
  return Object.hash(runtimeType,_this.code,_this.message);
}

@override
String toString() {
  final _this = this as IngestError;
  return 'IngestError(code: ${_this.code}, message: ${_this.message})';
}


}

/// @nodoc
abstract mixin class $IngestErrorCopyWith<$Res>  {
  factory $IngestErrorCopyWith(IngestError value, $Res Function(IngestError) _then) = _$IngestErrorCopyWithImpl;
@useResult
$Res call({
 IngestErrorCode code, String message
});




}
/// @nodoc
class _$IngestErrorCopyWithImpl<$Res>
    implements $IngestErrorCopyWith<$Res> {
  _$IngestErrorCopyWithImpl(this._self, this._then);

  final IngestError _self;
  final $Res Function(IngestError) _then;

/// Create a copy of IngestError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? message = null,}) {
  return _then(IngestError(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as IngestErrorCode,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [IngestError].
extension IngestErrorPatterns on IngestError {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IngestError value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IngestError() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IngestError value)  $default,){
final _that = this;
switch (_that) {
case _IngestError():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IngestError value)?  $default,){
final _that = this;
switch (_that) {
case _IngestError() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( IngestErrorCode code,  String message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IngestError() when $default != null:
return $default(_that.code,_that.message);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( IngestErrorCode code,  String message)  $default,) {final _that = this;
switch (_that) {
case _IngestError():
return $default(_that.code,_that.message);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( IngestErrorCode code,  String message)?  $default,) {final _that = this;
switch (_that) {
case _IngestError() when $default != null:
return $default(_that.code,_that.message);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _IngestError implements IngestError {
  const _IngestError({required this.code, required this.message});
  factory _IngestError.fromJson(Map<String, dynamic> json) => _$IngestErrorFromJson(json);

@override final  IngestErrorCode code;
@override final  String message;

/// Create a copy of IngestError
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IngestErrorCopyWith<_IngestError> get copyWith => __$IngestErrorCopyWithImpl<_IngestError>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IngestErrorToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _IngestError&&(identical(other.code, code) || other.code == code)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,code,message);
}

@override
String toString() {
    return 'IngestError(code: $code, message: $message)';
}


}

/// @nodoc
abstract mixin class _$IngestErrorCopyWith<$Res> implements $IngestErrorCopyWith<$Res> {
  factory _$IngestErrorCopyWith(_IngestError value, $Res Function(_IngestError) _then) = __$IngestErrorCopyWithImpl;
@override @useResult
$Res call({
 IngestErrorCode code, String message
});




}
/// @nodoc
class __$IngestErrorCopyWithImpl<$Res>
    implements _$IngestErrorCopyWith<$Res> {
  __$IngestErrorCopyWithImpl(this._self, this._then);

  final _IngestError _self;
  final $Res Function(_IngestError) _then;

/// Create a copy of IngestError
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? message = null,}) {
  return _then(_IngestError(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as IngestErrorCode,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$DocumentSummary {

@JsonKey(name: 'document_id') String get documentId; String get title; DocumentStatus get status; int get progress;@JsonKey(name: 'page_count') int? get pageCount; IngestError? get error;
/// Create a copy of DocumentSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DocumentSummaryCopyWith<DocumentSummary> get copyWith => _$DocumentSummaryCopyWithImpl<DocumentSummary>(this as DocumentSummary, _$identity);

  /// Serializes this DocumentSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DocumentSummary;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DocumentSummary&&(identical(other.documentId, _this.documentId) || other.documentId == _this.documentId)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.progress, _this.progress) || other.progress == _this.progress)&&(identical(other.pageCount, _this.pageCount) || other.pageCount == _this.pageCount)&&(identical(other.error, _this.error) || other.error == _this.error));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DocumentSummary;
  return Object.hash(runtimeType,_this.documentId,_this.title,_this.status,_this.progress,_this.pageCount,_this.error);
}

@override
String toString() {
  final _this = this as DocumentSummary;
  return 'DocumentSummary(documentId: ${_this.documentId}, title: ${_this.title}, status: ${_this.status}, progress: ${_this.progress}, pageCount: ${_this.pageCount}, error: ${_this.error})';
}


}

/// @nodoc
abstract mixin class $DocumentSummaryCopyWith<$Res>  {
  factory $DocumentSummaryCopyWith(DocumentSummary value, $Res Function(DocumentSummary) _then) = _$DocumentSummaryCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'document_id') String documentId, String title, DocumentStatus status, int progress,@JsonKey(name: 'page_count') int? pageCount, IngestError? error
});


$IngestErrorCopyWith<$Res>? get error;

}
/// @nodoc
class _$DocumentSummaryCopyWithImpl<$Res>
    implements $DocumentSummaryCopyWith<$Res> {
  _$DocumentSummaryCopyWithImpl(this._self, this._then);

  final DocumentSummary _self;
  final $Res Function(DocumentSummary) _then;

/// Create a copy of DocumentSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? documentId = null,Object? title = null,Object? status = null,Object? progress = null,Object? pageCount = freezed,Object? error = freezed,}) {
  return _then(DocumentSummary(
documentId: null == documentId ? _self.documentId : documentId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DocumentStatus,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as int,pageCount: freezed == pageCount ? _self.pageCount : pageCount // ignore: cast_nullable_to_non_nullable
as int?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as IngestError?,
  ));
}
/// Create a copy of DocumentSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IngestErrorCopyWith<$Res>? get error {
    if (_self.error == null) {
    return null;
  }

  return $IngestErrorCopyWith<$Res>(_self.error!, (value) {
    return _then(_self.copyWith(error: value));
  });
}
}


/// Adds pattern-matching-related methods to [DocumentSummary].
extension DocumentSummaryPatterns on DocumentSummary {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DocumentSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DocumentSummary() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DocumentSummary value)  $default,){
final _that = this;
switch (_that) {
case _DocumentSummary():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DocumentSummary value)?  $default,){
final _that = this;
switch (_that) {
case _DocumentSummary() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'document_id')  String documentId,  String title,  DocumentStatus status,  int progress, @JsonKey(name: 'page_count')  int? pageCount,  IngestError? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DocumentSummary() when $default != null:
return $default(_that.documentId,_that.title,_that.status,_that.progress,_that.pageCount,_that.error);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'document_id')  String documentId,  String title,  DocumentStatus status,  int progress, @JsonKey(name: 'page_count')  int? pageCount,  IngestError? error)  $default,) {final _that = this;
switch (_that) {
case _DocumentSummary():
return $default(_that.documentId,_that.title,_that.status,_that.progress,_that.pageCount,_that.error);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'document_id')  String documentId,  String title,  DocumentStatus status,  int progress, @JsonKey(name: 'page_count')  int? pageCount,  IngestError? error)?  $default,) {final _that = this;
switch (_that) {
case _DocumentSummary() when $default != null:
return $default(_that.documentId,_that.title,_that.status,_that.progress,_that.pageCount,_that.error);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DocumentSummary implements DocumentSummary {
  const _DocumentSummary({@JsonKey(name: 'document_id') required this.documentId, required this.title, required this.status, this.progress = 0, @JsonKey(name: 'page_count') this.pageCount, this.error});
  factory _DocumentSummary.fromJson(Map<String, dynamic> json) => _$DocumentSummaryFromJson(json);

@override@JsonKey(name: 'document_id') final  String documentId;
@override final  String title;
@override final  DocumentStatus status;
@override@JsonKey() final  int progress;
@override@JsonKey(name: 'page_count') final  int? pageCount;
@override final  IngestError? error;

/// Create a copy of DocumentSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DocumentSummaryCopyWith<_DocumentSummary> get copyWith => __$DocumentSummaryCopyWithImpl<_DocumentSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DocumentSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DocumentSummary&&(identical(other.documentId, documentId) || other.documentId == documentId)&&(identical(other.title, title) || other.title == title)&&(identical(other.status, status) || other.status == status)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.pageCount, pageCount) || other.pageCount == pageCount)&&(identical(other.error, error) || other.error == error));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,documentId,title,status,progress,pageCount,error);
}

@override
String toString() {
    return 'DocumentSummary(documentId: $documentId, title: $title, status: $status, progress: $progress, pageCount: $pageCount, error: $error)';
}


}

/// @nodoc
abstract mixin class _$DocumentSummaryCopyWith<$Res> implements $DocumentSummaryCopyWith<$Res> {
  factory _$DocumentSummaryCopyWith(_DocumentSummary value, $Res Function(_DocumentSummary) _then) = __$DocumentSummaryCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'document_id') String documentId, String title, DocumentStatus status, int progress,@JsonKey(name: 'page_count') int? pageCount, IngestError? error
});


@override $IngestErrorCopyWith<$Res>? get error;

}
/// @nodoc
class __$DocumentSummaryCopyWithImpl<$Res>
    implements _$DocumentSummaryCopyWith<$Res> {
  __$DocumentSummaryCopyWithImpl(this._self, this._then);

  final _DocumentSummary _self;
  final $Res Function(_DocumentSummary) _then;

/// Create a copy of DocumentSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? documentId = null,Object? title = null,Object? status = null,Object? progress = null,Object? pageCount = freezed,Object? error = freezed,}) {
  return _then(_DocumentSummary(
documentId: null == documentId ? _self.documentId : documentId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DocumentStatus,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as int,pageCount: freezed == pageCount ? _self.pageCount : pageCount // ignore: cast_nullable_to_non_nullable
as int?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as IngestError?,
  ));
}

/// Create a copy of DocumentSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IngestErrorCopyWith<$Res>? get error {
    if (_self.error == null) {
    return null;
  }

  return $IngestErrorCopyWith<$Res>(_self.error!, (value) {
    return _then(_self.copyWith(error: value));
  });
}
}


/// @nodoc
mixin _$CreateDocumentResult {

@JsonKey(name: 'document_id') String get documentId;@JsonKey(name: 'upload_url') String get uploadUrl;
/// Create a copy of CreateDocumentResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateDocumentResultCopyWith<CreateDocumentResult> get copyWith => _$CreateDocumentResultCopyWithImpl<CreateDocumentResult>(this as CreateDocumentResult, _$identity);

  /// Serializes this CreateDocumentResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CreateDocumentResult;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateDocumentResult&&(identical(other.documentId, _this.documentId) || other.documentId == _this.documentId)&&(identical(other.uploadUrl, _this.uploadUrl) || other.uploadUrl == _this.uploadUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CreateDocumentResult;
  return Object.hash(runtimeType,_this.documentId,_this.uploadUrl);
}

@override
String toString() {
  final _this = this as CreateDocumentResult;
  return 'CreateDocumentResult(documentId: ${_this.documentId}, uploadUrl: ${_this.uploadUrl})';
}


}

/// @nodoc
abstract mixin class $CreateDocumentResultCopyWith<$Res>  {
  factory $CreateDocumentResultCopyWith(CreateDocumentResult value, $Res Function(CreateDocumentResult) _then) = _$CreateDocumentResultCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'document_id') String documentId,@JsonKey(name: 'upload_url') String uploadUrl
});




}
/// @nodoc
class _$CreateDocumentResultCopyWithImpl<$Res>
    implements $CreateDocumentResultCopyWith<$Res> {
  _$CreateDocumentResultCopyWithImpl(this._self, this._then);

  final CreateDocumentResult _self;
  final $Res Function(CreateDocumentResult) _then;

/// Create a copy of CreateDocumentResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? documentId = null,Object? uploadUrl = null,}) {
  return _then(CreateDocumentResult(
documentId: null == documentId ? _self.documentId : documentId // ignore: cast_nullable_to_non_nullable
as String,uploadUrl: null == uploadUrl ? _self.uploadUrl : uploadUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateDocumentResult].
extension CreateDocumentResultPatterns on CreateDocumentResult {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateDocumentResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateDocumentResult() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateDocumentResult value)  $default,){
final _that = this;
switch (_that) {
case _CreateDocumentResult():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateDocumentResult value)?  $default,){
final _that = this;
switch (_that) {
case _CreateDocumentResult() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'document_id')  String documentId, @JsonKey(name: 'upload_url')  String uploadUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateDocumentResult() when $default != null:
return $default(_that.documentId,_that.uploadUrl);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'document_id')  String documentId, @JsonKey(name: 'upload_url')  String uploadUrl)  $default,) {final _that = this;
switch (_that) {
case _CreateDocumentResult():
return $default(_that.documentId,_that.uploadUrl);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'document_id')  String documentId, @JsonKey(name: 'upload_url')  String uploadUrl)?  $default,) {final _that = this;
switch (_that) {
case _CreateDocumentResult() when $default != null:
return $default(_that.documentId,_that.uploadUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateDocumentResult implements CreateDocumentResult {
  const _CreateDocumentResult({@JsonKey(name: 'document_id') required this.documentId, @JsonKey(name: 'upload_url') required this.uploadUrl});
  factory _CreateDocumentResult.fromJson(Map<String, dynamic> json) => _$CreateDocumentResultFromJson(json);

@override@JsonKey(name: 'document_id') final  String documentId;
@override@JsonKey(name: 'upload_url') final  String uploadUrl;

/// Create a copy of CreateDocumentResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateDocumentResultCopyWith<_CreateDocumentResult> get copyWith => __$CreateDocumentResultCopyWithImpl<_CreateDocumentResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateDocumentResultToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateDocumentResult&&(identical(other.documentId, documentId) || other.documentId == documentId)&&(identical(other.uploadUrl, uploadUrl) || other.uploadUrl == uploadUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,documentId,uploadUrl);
}

@override
String toString() {
    return 'CreateDocumentResult(documentId: $documentId, uploadUrl: $uploadUrl)';
}


}

/// @nodoc
abstract mixin class _$CreateDocumentResultCopyWith<$Res> implements $CreateDocumentResultCopyWith<$Res> {
  factory _$CreateDocumentResultCopyWith(_CreateDocumentResult value, $Res Function(_CreateDocumentResult) _then) = __$CreateDocumentResultCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'document_id') String documentId,@JsonKey(name: 'upload_url') String uploadUrl
});




}
/// @nodoc
class __$CreateDocumentResultCopyWithImpl<$Res>
    implements _$CreateDocumentResultCopyWith<$Res> {
  __$CreateDocumentResultCopyWithImpl(this._self, this._then);

  final _CreateDocumentResult _self;
  final $Res Function(_CreateDocumentResult) _then;

/// Create a copy of CreateDocumentResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? documentId = null,Object? uploadUrl = null,}) {
  return _then(_CreateDocumentResult(
documentId: null == documentId ? _self.documentId : documentId // ignore: cast_nullable_to_non_nullable
as String,uploadUrl: null == uploadUrl ? _self.uploadUrl : uploadUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
