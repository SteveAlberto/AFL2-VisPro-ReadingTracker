import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/app_exception.dart';
import '../domain/book.dart';
import '../domain/book_repository.dart';

class LocalBookRepository implements BookRepository {
  static const String _storageKey = 'reading_tracker_books';

  Future<List<Book>> _readAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);

      if (raw == null) {
        final initialBooks = [
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
        ];
        await _writeAll(initialBooks);
        return initialBooks;
      }

      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => Book.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (e is AppException) rethrow;
      throw const AppException('Gagal memuat daftar buku dari penyimpanan lokal.');
    }
  }

  Future<void> _writeAll(List<Book> books) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(books.map((b) => b.toJson()).toList());
      await prefs.setString(_storageKey, encoded);
    } catch (_) {
      throw const AppException('Gagal menyimpan perubahan buku ke perangkat.');
    }
  }

  @override
  Future<List<Book>> fetchBooks() async {
    return _readAll();
  }

  @override
  Future<void> addBook(Book book) async {
    final books = await _readAll();
    if (books.any((b) => b.id == book.id)) {
      throw const AppException('Buku dengan ID tersebut sudah terdaftar.');
    }
    books.add(book);
    await _writeAll(books);
  }

  @override
  Future<void> updateBook(Book book) async {
    final books = await _readAll();
    final index = books.indexWhere((b) => b.id == book.id);
    if (index == -1) {
      throw const AppException('Buku tidak ditemukan untuk diperbarui.');
    }
    books[index] = book;
    await _writeAll(books);
  }

  @override
  Future<void> deleteBook(String id) async {
    final books = await _readAll();
    books.removeWhere((b) => b.id == id);
    await _writeAll(books);
  }
}