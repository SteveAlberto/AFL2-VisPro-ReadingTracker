import 'package:equatable/equatable.dart';
import '../../domain/book.dart';

sealed class ReadingState extends Equatable {
  const ReadingState();

  @override
  List<Object?> get props => [];
}

final class ReadingInitial extends ReadingState {
  const ReadingInitial();
}

final class ReadingLoading extends ReadingState {
  const ReadingLoading();
}

final class ReadingLoaded extends ReadingState {
  final List<Book> books;
  final ReadingStatus? selectedFilter;

  const ReadingLoaded({
    required this.books,
    this.selectedFilter,
  });

  List<Book> get filteredBooks {
    if (selectedFilter == null) return books;
    return books.where((b) => b.status == selectedFilter).toList();
  }

  int countByStatus(ReadingStatus status) {
    return books.where((b) => b.status == status).length;
  }

  @override
  List<Object?> get props => [books, selectedFilter];
}

final class ReadingFailure extends ReadingState {
  final String message;

  const ReadingFailure(this.message);

  @override
  List<Object?> get props => [message];
}