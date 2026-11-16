import 'book.dart';

abstract class BookRepository {
  Future<List<Book>> fetchBooks();
  Future<void> addBook(Book book);
  Future<void> updateBook(Book book);
  Future<void> deleteBook(String id);
}