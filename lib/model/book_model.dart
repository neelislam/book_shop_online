import 'package:json_annotation/json_annotation.dart';

part 'book_model.g.dart';

// Run this in terminal:
// dart pub run build_runner build --delete-conflicting-outputs

@JsonSerializable()
class Product {
  @JsonKey(name: "id")
  String? id;

  @JsonKey(name: "name")
  String? name;

  @JsonKey(name: "author")
  String? author;

  @JsonKey(name: "genre")
  String? genre;

  @JsonKey(name: "language")
  String? language;

  @JsonKey(name: "image")
  String? image;

  @JsonKey(name: "price")
  int? price;

  @JsonKey(name: "stock")
  bool? stock;

  @JsonKey(name: "isRecommended")
  bool? isRecommended;

  @JsonKey(name: "isBestseller")
  bool? isBestseller;

  @JsonKey(name: "isDiscounted")
  bool? isDiscounted;

  Product({
    this.id,
    this.name,
    this.author,
    this.genre,
    this.language,
    this.image,
    this.price,
    this.stock,
    this.isRecommended,
    this.isBestseller,
    this.isDiscounted,
  });

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);
  Map<String, dynamic> toJson() => _$ProductToJson(this);
}
