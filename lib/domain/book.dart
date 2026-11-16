import 'package:equatable/equatable.dart';

enum ReadingStatus { wishlist, reading, completed }

class Book extends Equatable {
  final String id;
  final String title;
  final String author;
  final ReadingStatus status;
  final int? rating;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    this.status = ReadingStatus.wishlist,
    this.rating,
  });

  Book copyWith({
    String? title,
    String? author,
    ReadingStatus? status,
    int? rating,
  }) {
    return Book(
      id: id,
      title: title ?? this.title,
      author: author ?? this.author,
      status: status ?? this.status,
      rating: rating ?? this.rating,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'author': author,
        'status': status.name,
        'rating': rating,
      };

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      status: ReadingStatus.values.byName(json['status'] as String),
      rating: json['rating'] as int?,
    );
  }

  @override
  List<Object?> get props => [id, title, author, status, rating];
}