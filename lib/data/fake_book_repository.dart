import '../core/app_exception.dart';
import '../domain/book.dart';
import '../domain/book_repository.dart';

class FakeBookRepository implements BookRepository {
  final List<Book> _books = [
    const Book(
      id: 'B001',
      title: 'Laskar Pelangi',
      author: 'Andrea Hirata',
      status: ReadingStatus.reading,
    ),
    const Book(
      id: 'B002',
      title: 'Atomic Habits',
      author: 'James Clear',
      status: ReadingStatus.wishlist,
    ),
    const Book(
      id: 'B003',
      title: 'Filosofi Teras',
      author: 'Henry Manampiring',
      status: ReadingStatus.completed,
      rating: 5,
    ),
  ];

  @override
  Future<List<Book>> fetchBooks() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_books);
  }

  @override
  Future<void> addBook(Book book) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (_books.any((b) => b.id == book.id)) {
      throw const AppException('Buku dengan ID tersebut sudah ada.');
    }
    _books.add(book);
  }

  @override
  Future<void> updateBook(Book book) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _books.indexWhere((b) => b.id == book.id);
    if (index == -1) {
      throw const AppException('Buku tidak ditemukan untuk diperbarui.');
    }
    _books[index] = book;
  }

  @override
  Future<void> deleteBook(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _books.removeWhere((b) => b.id == id);
  }
}