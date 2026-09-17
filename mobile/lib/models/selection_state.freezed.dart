// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'selection_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SelectionState {

 String get text; List<String> get blockIds; List<String> get pageIds; Rect get anchorRect; Rect get firstBlockRect; Rect get lastBlockRect;
/// Create a copy of SelectionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SelectionStateCopyWith<SelectionState> get copyWith => _$SelectionStateCopyWithImpl<SelectionState>(this as SelectionState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SelectionState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SelectionState&&(identical(other.text, _this.text) || other.text == _this.text)&&const DeepCollectionEquality().equals(other.blockIds, _this.blockIds)&&const DeepCollectionEquality().equals(other.pageIds, _this.pageIds)&&(identical(other.anchorRect, _this.anchorRect) || other.anchorRect == _this.anchorRect)&&(identical(other.firstBlockRect, _this.firstBlockRect) || other.firstBlockRect == _this.firstBlockRect)&&(identical(other.lastBlockRect, _this.lastBlockRect) || other.lastBlockRect == _this.lastBlockRect));
}


@override
int get hashCode {
  final _this = this as SelectionState;
  return Object.hash(runtimeType,_this.text,const DeepCollectionEquality().hash(_this.blockIds),const DeepCollectionEquality().hash(_this.pageIds),_this.anchorRect,_this.firstBlockRect,_this.lastBlockRect);
}

@override
String toString() {
  final _this = this as SelectionState;
  return 'SelectionState(text: ${_this.text}, blockIds: ${_this.blockIds}, pageIds: ${_this.pageIds}, anchorRect: ${_this.anchorRect}, firstBlockRect: ${_this.firstBlockRect}, lastBlockRect: ${_this.lastBlockRect})';
}


}

/// @nodoc
abstract mixin class $SelectionStateCopyWith<$Res>  {
  factory $SelectionStateCopyWith(SelectionState value, $Res Function(SelectionState) _then) = _$SelectionStateCopyWithImpl;
@useResult
$Res call({
 String text, List<String> blockIds, List<String> pageIds, Rect anchorRect, Rect firstBlockRect, Rect lastBlockRect
});




}
/// @nodoc
class _$SelectionStateCopyWithImpl<$Res>
    implements $SelectionStateCopyWith<$Res> {
  _$SelectionStateCopyWithImpl(this._self, this._then);

  final SelectionState _self;
  final $Res Function(SelectionState) _then;

/// Create a copy of SelectionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? text = null,Object? blockIds = null,Object? pageIds = null,Object? anchorRect = null,Object? firstBlockRect = null,Object? lastBlockRect = null,}) {
  return _then(SelectionState(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,blockIds: null == blockIds ? _self.blockIds : blockIds // ignore: cast_nullable_to_non_nullable
as List<String>,pageIds: null == pageIds ? _self.pageIds : pageIds // ignore: cast_nullable_to_non_nullable
as List<String>,anchorRect: null == anchorRect ? _self.anchorRect : anchorRect // ignore: cast_nullable_to_non_nullable
as Rect,firstBlockRect: null == firstBlockRect ? _self.firstBlockRect : firstBlockRect // ignore: cast_nullable_to_non_nullable
as Rect,lastBlockRect: null == lastBlockRect ? _self.lastBlockRect : lastBlockRect // ignore: cast_nullable_to_non_nullable
as Rect,
  ));
}

}


/// Adds pattern-matching-related methods to [SelectionState].
extension SelectionStatePatterns on SelectionState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SelectionState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SelectionState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SelectionState value)  $default,){
final _that = this;
switch (_that) {
case _SelectionState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SelectionState value)?  $default,){
final _that = this;
switch (_that) {
case _SelectionState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String text,  List<String> blockIds,  List<String> pageIds,  Rect anchorRect,  Rect firstBlockRect,  Rect lastBlockRect)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SelectionState() when $default != null:
return $default(_that.text,_that.blockIds,_that.pageIds,_that.anchorRect,_that.firstBlockRect,_that.lastBlockRect);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String text,  List<String> blockIds,  List<String> pageIds,  Rect anchorRect,  Rect firstBlockRect,  Rect lastBlockRect)  $default,) {final _that = this;
switch (_that) {
case _SelectionState():
return $default(_that.text,_that.blockIds,_that.pageIds,_that.anchorRect,_that.firstBlockRect,_that.lastBlockRect);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String text,  List<String> blockIds,  List<String> pageIds,  Rect anchorRect,  Rect firstBlockRect,  Rect lastBlockRect)?  $default,) {final _that = this;
switch (_that) {
case _SelectionState() when $default != null:
return $default(_that.text,_that.blockIds,_that.pageIds,_that.anchorRect,_that.firstBlockRect,_that.lastBlockRect);case _:
  return null;

}
}

}

/// @nodoc


class _SelectionState implements SelectionState {
  const _SelectionState({required this.text, required  List<String> blockIds, required  List<String> pageIds, required this.anchorRect, required this.firstBlockRect, required this.lastBlockRect}): _blockIds = blockIds,_pageIds = pageIds;
  

@override final  String text;
 final  List<String> _blockIds;
@override List<String> get blockIds {
  if (_blockIds is EqualUnmodifiableListView) return _blockIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_blockIds);
}

 final  List<String> _pageIds;
@override List<String> get pageIds {
  if (_pageIds is EqualUnmodifiableListView) return _pageIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_pageIds);
}

@override final  Rect anchorRect;
@override final  Rect firstBlockRect;
@override final  Rect lastBlockRect;

/// Create a copy of SelectionState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SelectionStateCopyWith<_SelectionState> get copyWith => __$SelectionStateCopyWithImpl<_SelectionState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SelectionState&&(identical(other.text, text) || other.text == text)&&const DeepCollectionEquality().equals(other.blockIds, _blockIds)&&const DeepCollectionEquality().equals(other.pageIds, _pageIds)&&(identical(other.anchorRect, anchorRect) || other.anchorRect == anchorRect)&&(identical(other.firstBlockRect, firstBlockRect) || other.firstBlockRect == firstBlockRect)&&(identical(other.lastBlockRect, lastBlockRect) || other.lastBlockRect == lastBlockRect));
}


@override
int get hashCode {
    return Object.hash(runtimeType,text,const DeepCollectionEquality().hash(_blockIds),const DeepCollectionEquality().hash(_pageIds),anchorRect,firstBlockRect,lastBlockRect);
}

@override
String toString() {
    return 'SelectionState(text: $text, blockIds: $blockIds, pageIds: $pageIds, anchorRect: $anchorRect, firstBlockRect: $firstBlockRect, lastBlockRect: $lastBlockRect)';
}


}

/// @nodoc
abstract mixin class _$SelectionStateCopyWith<$Res> implements $SelectionStateCopyWith<$Res> {
  factory _$SelectionStateCopyWith(_SelectionState value, $Res Function(_SelectionState) _then) = __$SelectionStateCopyWithImpl;
@override @useResult
$Res call({
 String text, List<String> blockIds, List<String> pageIds, Rect anchorRect, Rect firstBlockRect, Rect lastBlockRect
});




}
/// @nodoc
class __$SelectionStateCopyWithImpl<$Res>
    implements _$SelectionStateCopyWith<$Res> {
  __$SelectionStateCopyWithImpl(this._self, this._then);

  final _SelectionState _self;
  final $Res Function(_SelectionState) _then;

/// Create a copy of SelectionState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? text = null,Object? blockIds = null,Object? pageIds = null,Object? anchorRect = null,Object? firstBlockRect = null,Object? lastBlockRect = null,}) {
  return _then(_SelectionState(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,blockIds: null == blockIds ? _self._blockIds : blockIds // ignore: cast_nullable_to_non_nullable
as List<String>,pageIds: null == pageIds ? _self._pageIds : pageIds // ignore: cast_nullable_to_non_nullable
as List<String>,anchorRect: null == anchorRect ? _self.anchorRect : anchorRect // ignore: cast_nullable_to_non_nullable
as Rect,firstBlockRect: null == firstBlockRect ? _self.firstBlockRect : firstBlockRect // ignore: cast_nullable_to_non_nullable
as Rect,lastBlockRect: null == lastBlockRect ? _self.lastBlockRect : lastBlockRect // ignore: cast_nullable_to_non_nullable
as Rect,
  ));
}


}

// dart format on
