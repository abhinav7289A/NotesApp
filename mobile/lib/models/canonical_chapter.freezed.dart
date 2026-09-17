// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'canonical_chapter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChapterPage {

@JsonKey(name: 'page_id') String get pageId; int get index;@JsonKey(name: 'width_pt') double get widthPt;@JsonKey(name: 'height_pt') double get heightPt; int get rotation;@JsonKey(name: 'image_key') String? get imageKey;@JsonKey(name: 'has_text_layer') bool? get hasTextLayer;
/// Create a copy of ChapterPage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChapterPageCopyWith<ChapterPage> get copyWith => _$ChapterPageCopyWithImpl<ChapterPage>(this as ChapterPage, _$identity);

  /// Serializes this ChapterPage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ChapterPage;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChapterPage&&(identical(other.pageId, _this.pageId) || other.pageId == _this.pageId)&&(identical(other.index, _this.index) || other.index == _this.index)&&(identical(other.widthPt, _this.widthPt) || other.widthPt == _this.widthPt)&&(identical(other.heightPt, _this.heightPt) || other.heightPt == _this.heightPt)&&(identical(other.rotation, _this.rotation) || other.rotation == _this.rotation)&&(identical(other.imageKey, _this.imageKey) || other.imageKey == _this.imageKey)&&(identical(other.hasTextLayer, _this.hasTextLayer) || other.hasTextLayer == _this.hasTextLayer));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ChapterPage;
  return Object.hash(runtimeType,_this.pageId,_this.index,_this.widthPt,_this.heightPt,_this.rotation,_this.imageKey,_this.hasTextLayer);
}

@override
String toString() {
  final _this = this as ChapterPage;
  return 'ChapterPage(pageId: ${_this.pageId}, index: ${_this.index}, widthPt: ${_this.widthPt}, heightPt: ${_this.heightPt}, rotation: ${_this.rotation}, imageKey: ${_this.imageKey}, hasTextLayer: ${_this.hasTextLayer})';
}


}

/// @nodoc
abstract mixin class $ChapterPageCopyWith<$Res>  {
  factory $ChapterPageCopyWith(ChapterPage value, $Res Function(ChapterPage) _then) = _$ChapterPageCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'page_id') String pageId, int index,@JsonKey(name: 'width_pt') double widthPt,@JsonKey(name: 'height_pt') double heightPt, int rotation,@JsonKey(name: 'image_key') String? imageKey,@JsonKey(name: 'has_text_layer') bool? hasTextLayer
});




}
/// @nodoc
class _$ChapterPageCopyWithImpl<$Res>
    implements $ChapterPageCopyWith<$Res> {
  _$ChapterPageCopyWithImpl(this._self, this._then);

  final ChapterPage _self;
  final $Res Function(ChapterPage) _then;

/// Create a copy of ChapterPage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pageId = null,Object? index = null,Object? widthPt = null,Object? heightPt = null,Object? rotation = null,Object? imageKey = freezed,Object? hasTextLayer = freezed,}) {
  return _then(ChapterPage(
pageId: null == pageId ? _self.pageId : pageId // ignore: cast_nullable_to_non_nullable
as String,index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,widthPt: null == widthPt ? _self.widthPt : widthPt // ignore: cast_nullable_to_non_nullable
as double,heightPt: null == heightPt ? _self.heightPt : heightPt // ignore: cast_nullable_to_non_nullable
as double,rotation: null == rotation ? _self.rotation : rotation // ignore: cast_nullable_to_non_nullable
as int,imageKey: freezed == imageKey ? _self.imageKey : imageKey // ignore: cast_nullable_to_non_nullable
as String?,hasTextLayer: freezed == hasTextLayer ? _self.hasTextLayer : hasTextLayer // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [ChapterPage].
extension ChapterPagePatterns on ChapterPage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChapterPage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChapterPage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChapterPage value)  $default,){
final _that = this;
switch (_that) {
case _ChapterPage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChapterPage value)?  $default,){
final _that = this;
switch (_that) {
case _ChapterPage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'page_id')  String pageId,  int index, @JsonKey(name: 'width_pt')  double widthPt, @JsonKey(name: 'height_pt')  double heightPt,  int rotation, @JsonKey(name: 'image_key')  String? imageKey, @JsonKey(name: 'has_text_layer')  bool? hasTextLayer)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChapterPage() when $default != null:
return $default(_that.pageId,_that.index,_that.widthPt,_that.heightPt,_that.rotation,_that.imageKey,_that.hasTextLayer);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'page_id')  String pageId,  int index, @JsonKey(name: 'width_pt')  double widthPt, @JsonKey(name: 'height_pt')  double heightPt,  int rotation, @JsonKey(name: 'image_key')  String? imageKey, @JsonKey(name: 'has_text_layer')  bool? hasTextLayer)  $default,) {final _that = this;
switch (_that) {
case _ChapterPage():
return $default(_that.pageId,_that.index,_that.widthPt,_that.heightPt,_that.rotation,_that.imageKey,_that.hasTextLayer);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'page_id')  String pageId,  int index, @JsonKey(name: 'width_pt')  double widthPt, @JsonKey(name: 'height_pt')  double heightPt,  int rotation, @JsonKey(name: 'image_key')  String? imageKey, @JsonKey(name: 'has_text_layer')  bool? hasTextLayer)?  $default,) {final _that = this;
switch (_that) {
case _ChapterPage() when $default != null:
return $default(_that.pageId,_that.index,_that.widthPt,_that.heightPt,_that.rotation,_that.imageKey,_that.hasTextLayer);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChapterPage implements ChapterPage {
  const _ChapterPage({@JsonKey(name: 'page_id') required this.pageId, required this.index, @JsonKey(name: 'width_pt') required this.widthPt, @JsonKey(name: 'height_pt') required this.heightPt, this.rotation = 0, @JsonKey(name: 'image_key') this.imageKey, @JsonKey(name: 'has_text_layer') this.hasTextLayer});
  factory _ChapterPage.fromJson(Map<String, dynamic> json) => _$ChapterPageFromJson(json);

@override@JsonKey(name: 'page_id') final  String pageId;
@override final  int index;
@override@JsonKey(name: 'width_pt') final  double widthPt;
@override@JsonKey(name: 'height_pt') final  double heightPt;
@override@JsonKey() final  int rotation;
@override@JsonKey(name: 'image_key') final  String? imageKey;
@override@JsonKey(name: 'has_text_layer') final  bool? hasTextLayer;

/// Create a copy of ChapterPage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChapterPageCopyWith<_ChapterPage> get copyWith => __$ChapterPageCopyWithImpl<_ChapterPage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChapterPageToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChapterPage&&(identical(other.pageId, pageId) || other.pageId == pageId)&&(identical(other.index, index) || other.index == index)&&(identical(other.widthPt, widthPt) || other.widthPt == widthPt)&&(identical(other.heightPt, heightPt) || other.heightPt == heightPt)&&(identical(other.rotation, rotation) || other.rotation == rotation)&&(identical(other.imageKey, imageKey) || other.imageKey == imageKey)&&(identical(other.hasTextLayer, hasTextLayer) || other.hasTextLayer == hasTextLayer));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,pageId,index,widthPt,heightPt,rotation,imageKey,hasTextLayer);
}

@override
String toString() {
    return 'ChapterPage(pageId: $pageId, index: $index, widthPt: $widthPt, heightPt: $heightPt, rotation: $rotation, imageKey: $imageKey, hasTextLayer: $hasTextLayer)';
}


}

/// @nodoc
abstract mixin class _$ChapterPageCopyWith<$Res> implements $ChapterPageCopyWith<$Res> {
  factory _$ChapterPageCopyWith(_ChapterPage value, $Res Function(_ChapterPage) _then) = __$ChapterPageCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'page_id') String pageId, int index,@JsonKey(name: 'width_pt') double widthPt,@JsonKey(name: 'height_pt') double heightPt, int rotation,@JsonKey(name: 'image_key') String? imageKey,@JsonKey(name: 'has_text_layer') bool? hasTextLayer
});




}
/// @nodoc
class __$ChapterPageCopyWithImpl<$Res>
    implements _$ChapterPageCopyWith<$Res> {
  __$ChapterPageCopyWithImpl(this._self, this._then);

  final _ChapterPage _self;
  final $Res Function(_ChapterPage) _then;

/// Create a copy of ChapterPage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pageId = null,Object? index = null,Object? widthPt = null,Object? heightPt = null,Object? rotation = null,Object? imageKey = freezed,Object? hasTextLayer = freezed,}) {
  return _then(_ChapterPage(
pageId: null == pageId ? _self.pageId : pageId // ignore: cast_nullable_to_non_nullable
as String,index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,widthPt: null == widthPt ? _self.widthPt : widthPt // ignore: cast_nullable_to_non_nullable
as double,heightPt: null == heightPt ? _self.heightPt : heightPt // ignore: cast_nullable_to_non_nullable
as double,rotation: null == rotation ? _self.rotation : rotation // ignore: cast_nullable_to_non_nullable
as int,imageKey: freezed == imageKey ? _self.imageKey : imageKey // ignore: cast_nullable_to_non_nullable
as String?,hasTextLayer: freezed == hasTextLayer ? _self.hasTextLayer : hasTextLayer // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}


/// @nodoc
mixin _$ChapterBlock {

@JsonKey(name: 'block_id') String get blockId;@JsonKey(name: 'page_id') String get pageId; BlockType get type; String? get text; List<double> get bbox; int get order; int? get level; double? get confidence;@JsonKey(name: 'image_key') String? get imageKey;
/// Create a copy of ChapterBlock
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChapterBlockCopyWith<ChapterBlock> get copyWith => _$ChapterBlockCopyWithImpl<ChapterBlock>(this as ChapterBlock, _$identity);

  /// Serializes this ChapterBlock to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ChapterBlock;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChapterBlock&&(identical(other.blockId, _this.blockId) || other.blockId == _this.blockId)&&(identical(other.pageId, _this.pageId) || other.pageId == _this.pageId)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.text, _this.text) || other.text == _this.text)&&const DeepCollectionEquality().equals(other.bbox, _this.bbox)&&(identical(other.order, _this.order) || other.order == _this.order)&&(identical(other.level, _this.level) || other.level == _this.level)&&(identical(other.confidence, _this.confidence) || other.confidence == _this.confidence)&&(identical(other.imageKey, _this.imageKey) || other.imageKey == _this.imageKey));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ChapterBlock;
  return Object.hash(runtimeType,_this.blockId,_this.pageId,_this.type,_this.text,const DeepCollectionEquality().hash(_this.bbox),_this.order,_this.level,_this.confidence,_this.imageKey);
}

@override
String toString() {
  final _this = this as ChapterBlock;
  return 'ChapterBlock(blockId: ${_this.blockId}, pageId: ${_this.pageId}, type: ${_this.type}, text: ${_this.text}, bbox: ${_this.bbox}, order: ${_this.order}, level: ${_this.level}, confidence: ${_this.confidence}, imageKey: ${_this.imageKey})';
}


}

/// @nodoc
abstract mixin class $ChapterBlockCopyWith<$Res>  {
  factory $ChapterBlockCopyWith(ChapterBlock value, $Res Function(ChapterBlock) _then) = _$ChapterBlockCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'block_id') String blockId,@JsonKey(name: 'page_id') String pageId, BlockType type, String? text, List<double> bbox, int order, int? level, double? confidence,@JsonKey(name: 'image_key') String? imageKey
});




}
/// @nodoc
class _$ChapterBlockCopyWithImpl<$Res>
    implements $ChapterBlockCopyWith<$Res> {
  _$ChapterBlockCopyWithImpl(this._self, this._then);

  final ChapterBlock _self;
  final $Res Function(ChapterBlock) _then;

/// Create a copy of ChapterBlock
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? blockId = null,Object? pageId = null,Object? type = null,Object? text = freezed,Object? bbox = null,Object? order = null,Object? level = freezed,Object? confidence = freezed,Object? imageKey = freezed,}) {
  return _then(ChapterBlock(
blockId: null == blockId ? _self.blockId : blockId // ignore: cast_nullable_to_non_nullable
as String,pageId: null == pageId ? _self.pageId : pageId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as BlockType,text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,bbox: null == bbox ? _self.bbox : bbox // ignore: cast_nullable_to_non_nullable
as List<double>,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,level: freezed == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int?,confidence: freezed == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double?,imageKey: freezed == imageKey ? _self.imageKey : imageKey // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ChapterBlock].
extension ChapterBlockPatterns on ChapterBlock {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChapterBlock value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChapterBlock() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChapterBlock value)  $default,){
final _that = this;
switch (_that) {
case _ChapterBlock():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChapterBlock value)?  $default,){
final _that = this;
switch (_that) {
case _ChapterBlock() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'block_id')  String blockId, @JsonKey(name: 'page_id')  String pageId,  BlockType type,  String? text,  List<double> bbox,  int order,  int? level,  double? confidence, @JsonKey(name: 'image_key')  String? imageKey)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChapterBlock() when $default != null:
return $default(_that.blockId,_that.pageId,_that.type,_that.text,_that.bbox,_that.order,_that.level,_that.confidence,_that.imageKey);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'block_id')  String blockId, @JsonKey(name: 'page_id')  String pageId,  BlockType type,  String? text,  List<double> bbox,  int order,  int? level,  double? confidence, @JsonKey(name: 'image_key')  String? imageKey)  $default,) {final _that = this;
switch (_that) {
case _ChapterBlock():
return $default(_that.blockId,_that.pageId,_that.type,_that.text,_that.bbox,_that.order,_that.level,_that.confidence,_that.imageKey);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'block_id')  String blockId, @JsonKey(name: 'page_id')  String pageId,  BlockType type,  String? text,  List<double> bbox,  int order,  int? level,  double? confidence, @JsonKey(name: 'image_key')  String? imageKey)?  $default,) {final _that = this;
switch (_that) {
case _ChapterBlock() when $default != null:
return $default(_that.blockId,_that.pageId,_that.type,_that.text,_that.bbox,_that.order,_that.level,_that.confidence,_that.imageKey);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChapterBlock implements ChapterBlock {
  const _ChapterBlock({@JsonKey(name: 'block_id') required this.blockId, @JsonKey(name: 'page_id') required this.pageId, required this.type, this.text, required  List<double> bbox, required this.order, this.level, this.confidence, @JsonKey(name: 'image_key') this.imageKey}): _bbox = bbox;
  factory _ChapterBlock.fromJson(Map<String, dynamic> json) => _$ChapterBlockFromJson(json);

@override@JsonKey(name: 'block_id') final  String blockId;
@override@JsonKey(name: 'page_id') final  String pageId;
@override final  BlockType type;
@override final  String? text;
 final  List<double> _bbox;
@override List<double> get bbox {
  if (_bbox is EqualUnmodifiableListView) return _bbox;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_bbox);
}

@override final  int order;
@override final  int? level;
@override final  double? confidence;
@override@JsonKey(name: 'image_key') final  String? imageKey;

/// Create a copy of ChapterBlock
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChapterBlockCopyWith<_ChapterBlock> get copyWith => __$ChapterBlockCopyWithImpl<_ChapterBlock>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChapterBlockToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChapterBlock&&(identical(other.blockId, blockId) || other.blockId == blockId)&&(identical(other.pageId, pageId) || other.pageId == pageId)&&(identical(other.type, type) || other.type == type)&&(identical(other.text, text) || other.text == text)&&const DeepCollectionEquality().equals(other.bbox, _bbox)&&(identical(other.order, order) || other.order == order)&&(identical(other.level, level) || other.level == level)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.imageKey, imageKey) || other.imageKey == imageKey));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,blockId,pageId,type,text,const DeepCollectionEquality().hash(_bbox),order,level,confidence,imageKey);
}

@override
String toString() {
    return 'ChapterBlock(blockId: $blockId, pageId: $pageId, type: $type, text: $text, bbox: $bbox, order: $order, level: $level, confidence: $confidence, imageKey: $imageKey)';
}


}

/// @nodoc
abstract mixin class _$ChapterBlockCopyWith<$Res> implements $ChapterBlockCopyWith<$Res> {
  factory _$ChapterBlockCopyWith(_ChapterBlock value, $Res Function(_ChapterBlock) _then) = __$ChapterBlockCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'block_id') String blockId,@JsonKey(name: 'page_id') String pageId, BlockType type, String? text, List<double> bbox, int order, int? level, double? confidence,@JsonKey(name: 'image_key') String? imageKey
});




}
/// @nodoc
class __$ChapterBlockCopyWithImpl<$Res>
    implements _$ChapterBlockCopyWith<$Res> {
  __$ChapterBlockCopyWithImpl(this._self, this._then);

  final _ChapterBlock _self;
  final $Res Function(_ChapterBlock) _then;

/// Create a copy of ChapterBlock
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? blockId = null,Object? pageId = null,Object? type = null,Object? text = freezed,Object? bbox = null,Object? order = null,Object? level = freezed,Object? confidence = freezed,Object? imageKey = freezed,}) {
  return _then(_ChapterBlock(
blockId: null == blockId ? _self.blockId : blockId // ignore: cast_nullable_to_non_nullable
as String,pageId: null == pageId ? _self.pageId : pageId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as BlockType,text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,bbox: null == bbox ? _self._bbox : bbox // ignore: cast_nullable_to_non_nullable
as List<double>,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,level: freezed == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int?,confidence: freezed == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double?,imageKey: freezed == imageKey ? _self.imageKey : imageKey // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$CanonicalChapter {

@JsonKey(name: 'schema_version') int get schemaVersion;@JsonKey(name: 'chapter_id') String get chapterId;@JsonKey(name: 'content_hash') String get contentHash; String get title;@JsonKey(name: 'source_filename') String? get sourceFilename; String get language;@JsonKey(name: 'page_count') int get pageCount;@JsonKey(name: 'ocr_engine') String? get ocrEngine;@JsonKey(name: 'created_at') String? get createdAt; List<ChapterPage> get pages; List<ChapterBlock> get blocks;
/// Create a copy of CanonicalChapter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CanonicalChapterCopyWith<CanonicalChapter> get copyWith => _$CanonicalChapterCopyWithImpl<CanonicalChapter>(this as CanonicalChapter, _$identity);

  /// Serializes this CanonicalChapter to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CanonicalChapter;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CanonicalChapter&&(identical(other.schemaVersion, _this.schemaVersion) || other.schemaVersion == _this.schemaVersion)&&(identical(other.chapterId, _this.chapterId) || other.chapterId == _this.chapterId)&&(identical(other.contentHash, _this.contentHash) || other.contentHash == _this.contentHash)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.sourceFilename, _this.sourceFilename) || other.sourceFilename == _this.sourceFilename)&&(identical(other.language, _this.language) || other.language == _this.language)&&(identical(other.pageCount, _this.pageCount) || other.pageCount == _this.pageCount)&&(identical(other.ocrEngine, _this.ocrEngine) || other.ocrEngine == _this.ocrEngine)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&const DeepCollectionEquality().equals(other.pages, _this.pages)&&const DeepCollectionEquality().equals(other.blocks, _this.blocks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CanonicalChapter;
  return Object.hash(runtimeType,_this.schemaVersion,_this.chapterId,_this.contentHash,_this.title,_this.sourceFilename,_this.language,_this.pageCount,_this.ocrEngine,_this.createdAt,const DeepCollectionEquality().hash(_this.pages),const DeepCollectionEquality().hash(_this.blocks));
}

@override
String toString() {
  final _this = this as CanonicalChapter;
  return 'CanonicalChapter(schemaVersion: ${_this.schemaVersion}, chapterId: ${_this.chapterId}, contentHash: ${_this.contentHash}, title: ${_this.title}, sourceFilename: ${_this.sourceFilename}, language: ${_this.language}, pageCount: ${_this.pageCount}, ocrEngine: ${_this.ocrEngine}, createdAt: ${_this.createdAt}, pages: ${_this.pages}, blocks: ${_this.blocks})';
}


}

/// @nodoc
abstract mixin class $CanonicalChapterCopyWith<$Res>  {
  factory $CanonicalChapterCopyWith(CanonicalChapter value, $Res Function(CanonicalChapter) _then) = _$CanonicalChapterCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'schema_version') int schemaVersion,@JsonKey(name: 'chapter_id') String chapterId,@JsonKey(name: 'content_hash') String contentHash, String title,@JsonKey(name: 'source_filename') String? sourceFilename, String language,@JsonKey(name: 'page_count') int pageCount,@JsonKey(name: 'ocr_engine') String? ocrEngine,@JsonKey(name: 'created_at') String? createdAt, List<ChapterPage> pages, List<ChapterBlock> blocks
});




}
/// @nodoc
class _$CanonicalChapterCopyWithImpl<$Res>
    implements $CanonicalChapterCopyWith<$Res> {
  _$CanonicalChapterCopyWithImpl(this._self, this._then);

  final CanonicalChapter _self;
  final $Res Function(CanonicalChapter) _then;

/// Create a copy of CanonicalChapter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? schemaVersion = null,Object? chapterId = null,Object? contentHash = null,Object? title = null,Object? sourceFilename = freezed,Object? language = null,Object? pageCount = null,Object? ocrEngine = freezed,Object? createdAt = freezed,Object? pages = null,Object? blocks = null,}) {
  return _then(CanonicalChapter(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,chapterId: null == chapterId ? _self.chapterId : chapterId // ignore: cast_nullable_to_non_nullable
as String,contentHash: null == contentHash ? _self.contentHash : contentHash // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,sourceFilename: freezed == sourceFilename ? _self.sourceFilename : sourceFilename // ignore: cast_nullable_to_non_nullable
as String?,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,pageCount: null == pageCount ? _self.pageCount : pageCount // ignore: cast_nullable_to_non_nullable
as int,ocrEngine: freezed == ocrEngine ? _self.ocrEngine : ocrEngine // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,pages: null == pages ? _self.pages : pages // ignore: cast_nullable_to_non_nullable
as List<ChapterPage>,blocks: null == blocks ? _self.blocks : blocks // ignore: cast_nullable_to_non_nullable
as List<ChapterBlock>,
  ));
}

}


/// Adds pattern-matching-related methods to [CanonicalChapter].
extension CanonicalChapterPatterns on CanonicalChapter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CanonicalChapter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CanonicalChapter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CanonicalChapter value)  $default,){
final _that = this;
switch (_that) {
case _CanonicalChapter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CanonicalChapter value)?  $default,){
final _that = this;
switch (_that) {
case _CanonicalChapter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'schema_version')  int schemaVersion, @JsonKey(name: 'chapter_id')  String chapterId, @JsonKey(name: 'content_hash')  String contentHash,  String title, @JsonKey(name: 'source_filename')  String? sourceFilename,  String language, @JsonKey(name: 'page_count')  int pageCount, @JsonKey(name: 'ocr_engine')  String? ocrEngine, @JsonKey(name: 'created_at')  String? createdAt,  List<ChapterPage> pages,  List<ChapterBlock> blocks)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CanonicalChapter() when $default != null:
return $default(_that.schemaVersion,_that.chapterId,_that.contentHash,_that.title,_that.sourceFilename,_that.language,_that.pageCount,_that.ocrEngine,_that.createdAt,_that.pages,_that.blocks);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'schema_version')  int schemaVersion, @JsonKey(name: 'chapter_id')  String chapterId, @JsonKey(name: 'content_hash')  String contentHash,  String title, @JsonKey(name: 'source_filename')  String? sourceFilename,  String language, @JsonKey(name: 'page_count')  int pageCount, @JsonKey(name: 'ocr_engine')  String? ocrEngine, @JsonKey(name: 'created_at')  String? createdAt,  List<ChapterPage> pages,  List<ChapterBlock> blocks)  $default,) {final _that = this;
switch (_that) {
case _CanonicalChapter():
return $default(_that.schemaVersion,_that.chapterId,_that.contentHash,_that.title,_that.sourceFilename,_that.language,_that.pageCount,_that.ocrEngine,_that.createdAt,_that.pages,_that.blocks);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'schema_version')  int schemaVersion, @JsonKey(name: 'chapter_id')  String chapterId, @JsonKey(name: 'content_hash')  String contentHash,  String title, @JsonKey(name: 'source_filename')  String? sourceFilename,  String language, @JsonKey(name: 'page_count')  int pageCount, @JsonKey(name: 'ocr_engine')  String? ocrEngine, @JsonKey(name: 'created_at')  String? createdAt,  List<ChapterPage> pages,  List<ChapterBlock> blocks)?  $default,) {final _that = this;
switch (_that) {
case _CanonicalChapter() when $default != null:
return $default(_that.schemaVersion,_that.chapterId,_that.contentHash,_that.title,_that.sourceFilename,_that.language,_that.pageCount,_that.ocrEngine,_that.createdAt,_that.pages,_that.blocks);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CanonicalChapter implements CanonicalChapter {
  const _CanonicalChapter({@JsonKey(name: 'schema_version') required this.schemaVersion, @JsonKey(name: 'chapter_id') required this.chapterId, @JsonKey(name: 'content_hash') required this.contentHash, required this.title, @JsonKey(name: 'source_filename') this.sourceFilename, required this.language, @JsonKey(name: 'page_count') required this.pageCount, @JsonKey(name: 'ocr_engine') this.ocrEngine, @JsonKey(name: 'created_at') this.createdAt, required  List<ChapterPage> pages, required  List<ChapterBlock> blocks}): _pages = pages,_blocks = blocks;
  factory _CanonicalChapter.fromJson(Map<String, dynamic> json) => _$CanonicalChapterFromJson(json);

@override@JsonKey(name: 'schema_version') final  int schemaVersion;
@override@JsonKey(name: 'chapter_id') final  String chapterId;
@override@JsonKey(name: 'content_hash') final  String contentHash;
@override final  String title;
@override@JsonKey(name: 'source_filename') final  String? sourceFilename;
@override final  String language;
@override@JsonKey(name: 'page_count') final  int pageCount;
@override@JsonKey(name: 'ocr_engine') final  String? ocrEngine;
@override@JsonKey(name: 'created_at') final  String? createdAt;
 final  List<ChapterPage> _pages;
@override List<ChapterPage> get pages {
  if (_pages is EqualUnmodifiableListView) return _pages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_pages);
}

 final  List<ChapterBlock> _blocks;
@override List<ChapterBlock> get blocks {
  if (_blocks is EqualUnmodifiableListView) return _blocks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_blocks);
}


/// Create a copy of CanonicalChapter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CanonicalChapterCopyWith<_CanonicalChapter> get copyWith => __$CanonicalChapterCopyWithImpl<_CanonicalChapter>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CanonicalChapterToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CanonicalChapter&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.chapterId, chapterId) || other.chapterId == chapterId)&&(identical(other.contentHash, contentHash) || other.contentHash == contentHash)&&(identical(other.title, title) || other.title == title)&&(identical(other.sourceFilename, sourceFilename) || other.sourceFilename == sourceFilename)&&(identical(other.language, language) || other.language == language)&&(identical(other.pageCount, pageCount) || other.pageCount == pageCount)&&(identical(other.ocrEngine, ocrEngine) || other.ocrEngine == ocrEngine)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other.pages, _pages)&&const DeepCollectionEquality().equals(other.blocks, _blocks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,schemaVersion,chapterId,contentHash,title,sourceFilename,language,pageCount,ocrEngine,createdAt,const DeepCollectionEquality().hash(_pages),const DeepCollectionEquality().hash(_blocks));
}

@override
String toString() {
    return 'CanonicalChapter(schemaVersion: $schemaVersion, chapterId: $chapterId, contentHash: $contentHash, title: $title, sourceFilename: $sourceFilename, language: $language, pageCount: $pageCount, ocrEngine: $ocrEngine, createdAt: $createdAt, pages: $pages, blocks: $blocks)';
}


}

/// @nodoc
abstract mixin class _$CanonicalChapterCopyWith<$Res> implements $CanonicalChapterCopyWith<$Res> {
  factory _$CanonicalChapterCopyWith(_CanonicalChapter value, $Res Function(_CanonicalChapter) _then) = __$CanonicalChapterCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'schema_version') int schemaVersion,@JsonKey(name: 'chapter_id') String chapterId,@JsonKey(name: 'content_hash') String contentHash, String title,@JsonKey(name: 'source_filename') String? sourceFilename, String language,@JsonKey(name: 'page_count') int pageCount,@JsonKey(name: 'ocr_engine') String? ocrEngine,@JsonKey(name: 'created_at') String? createdAt, List<ChapterPage> pages, List<ChapterBlock> blocks
});




}
/// @nodoc
class __$CanonicalChapterCopyWithImpl<$Res>
    implements _$CanonicalChapterCopyWith<$Res> {
  __$CanonicalChapterCopyWithImpl(this._self, this._then);

  final _CanonicalChapter _self;
  final $Res Function(_CanonicalChapter) _then;

/// Create a copy of CanonicalChapter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? schemaVersion = null,Object? chapterId = null,Object? contentHash = null,Object? title = null,Object? sourceFilename = freezed,Object? language = null,Object? pageCount = null,Object? ocrEngine = freezed,Object? createdAt = freezed,Object? pages = null,Object? blocks = null,}) {
  return _then(_CanonicalChapter(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,chapterId: null == chapterId ? _self.chapterId : chapterId // ignore: cast_nullable_to_non_nullable
as String,contentHash: null == contentHash ? _self.contentHash : contentHash // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,sourceFilename: freezed == sourceFilename ? _self.sourceFilename : sourceFilename // ignore: cast_nullable_to_non_nullable
as String?,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,pageCount: null == pageCount ? _self.pageCount : pageCount // ignore: cast_nullable_to_non_nullable
as int,ocrEngine: freezed == ocrEngine ? _self.ocrEngine : ocrEngine // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,pages: null == pages ? _self._pages : pages // ignore: cast_nullable_to_non_nullable
as List<ChapterPage>,blocks: null == blocks ? _self._blocks : blocks // ignore: cast_nullable_to_non_nullable
as List<ChapterBlock>,
  ));
}


}

// dart format on
