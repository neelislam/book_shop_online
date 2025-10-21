// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Product _$ProductFromJson(Map<String, dynamic> json) => Product(
      id: json['id'] as String?,
      name: json['name'] as String?,
      author: json['author'] as String?,
      genre: json['genre'] as String?,
      language: json['language'] as String?,
      image: json['image'] as String?,
      price: (json['price'] as num?)?.toInt(),
      stock: json['stock'] as bool?,
      isRecommended: json['isRecommended'] as bool?,
      isBestseller: json['isBestseller'] as bool?,
      isDiscounted: json['isDiscounted'] as bool?,
    );

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'author': instance.author,
      'genre': instance.genre,
      'language': instance.language,
      'image': instance.image,
      'price': instance.price,
      'stock': instance.stock,
      'isRecommended': instance.isRecommended,
      'isBestseller': instance.isBestseller,
      'isDiscounted': instance.isDiscounted,
    };
