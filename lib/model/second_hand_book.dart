import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'second_hand_book.g.dart';

//flutter pub run build_runner build --delete-conflicting-outputs

@JsonSerializable()
class SecondHandBook {
  String? id;
  String? userId;
  String? name;
  String? details;
  String? condition;
  int? price;
  String? contact;
  String? image;

  @JsonKey(fromJson: _fromTimestamp, toJson: _toTimestamp)
  DateTime? createdAt;

  SecondHandBook({
    this.id,
    this.userId,
    this.name,
    this.details,
    this.condition,
    this.price,
    this.contact,
    this.image,
    this.createdAt,
  });

  factory SecondHandBook.fromJson(Map<String, dynamic> json) =>
      _$SecondHandBookFromJson(json);

  Map<String, dynamic> toJson() => _$SecondHandBookToJson(this);

  static DateTime? _fromTimestamp(Timestamp? ts) =>
      ts != null ? ts.toDate() : null;

  static Timestamp? _toTimestamp(DateTime? dt) =>
      dt != null ? Timestamp.fromDate(dt) : null;
}