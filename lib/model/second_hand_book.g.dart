// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'second_hand_book.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SecondHandBook _$SecondHandBookFromJson(Map<String, dynamic> json) =>
    SecondHandBook(
          id: json['id'] as String?,
          userId: json['userId'] as String?,
          name: json['name'] as String?,
          details: json['details'] as String?,
          condition: json['condition'] as String?,
          price: (json['price'] as num?)?.toInt(),
          contact: json['contact'] as String?,
          image: json['image'] as String?,
          createdAt: SecondHandBook._fromTimestamp(json['createdAt'] as Timestamp?),
    );

Map<String, dynamic> _$SecondHandBookToJson(SecondHandBook instance) =>
    <String, dynamic>{
          'id': instance.id,
          'userId': instance.userId,
          'name': instance.name,
          'details': instance.details,
          'condition': instance.condition,
          'price': instance.price,
          'contact': instance.contact,
          'image': instance.image,
          'createdAt': SecondHandBook._toTimestamp(instance.createdAt),
    };