import 'package:flutter/foundation.dart';
import '../../core/app_exception.dart';
import '../../domain/book.dart';
import '../../domain/book_repository.dart';
import 'reading_state.dart';

class ReadingViewModel extends ChangeNotifier {
  final BookRepository _repository;
  final DateTime Function() _now;

  ReadingState _state = const ReadingInitial();
  ReadingState get state => _state;

  bool _isDisposed = false;

  ReadingViewModel(this._repository, {DateTime Function()? clock})
      : _now = clock ?? DateTime.now;

  void _set(ReadingState newState) {
    if (_isDisposed) return;
    _state = newState;
    notifyListeners();
  }

  ReadingStatus? get _currentFilter {
    final current = _state;
    if (current is ReadingLoaded) return current.selectedFilter;
    return null;
  }

  Future<void> loadBooks() async {
    _set(const ReadingLoading());
    try {
      final books = await _repository.fetchBooks();
      if (_isDisposed) return;
      _set(ReadingLoaded(books: books, selectedFilter: _currentFilter));
    } on AppException catch (e) {
      if (_isDisposed) return;
      _set(ReadingFailure(e.message));
    } catch (_) {
      if (_isDisposed) return;
      _set(const ReadingFailure('Terjadi kesalahan saat memuat daftar buku.'));
    }
  }

  void setFilter(ReadingStatus? filter) {
    final current = _state;
    if (current is ReadingLoaded) {
      _set(ReadingLoaded(books: current.books, selectedFilter: filter));
    }
  }

  Future<String?> addBook(String title, String author) async {
    if (title.trim().isEmpty) return 'Judul buku tidak boleh kosong.';
    if (author.trim().isEmpty) return 'Nama penulis tidak boleh kosong.';

    final newBook = Book(
      id: 'B${_now().microsecondsSinceEpoch}',
      title: title.trim(),
      author: author.trim(),
      status: ReadingStatus.wishlist,
    );

    try {
      await _repository.addBook(newBook);
      if (_isDisposed) return null;
      final books = await _repository.fetchBooks();
      if (_isDisposed) return null;
      _set(ReadingLoaded(books: books, selectedFilter: _currentFilter));
      return null;
    } on AppException catch (e) {
      return e.message;
    } catch (_) {
      return 'Gagal menambahkan buku baru.';
    }
  }

  Future<String?> startReading(String bookId) async {
    final current = _state;
    if (current is! ReadingLoaded) return 'Data buku belum siap.';

    final index = current.books.indexWhere((b) => b.id == bookId);
    if (index == -1) return 'Buku tidak ditemukan.';

    final book = current.books[index];
    if (book.status != ReadingStatus.wishlist) {
      return 'Hanya buku di Wishlist yang bisa mulai dibaca.';
    }

    try {
      await _repository.updateBook(book.copyWith(status: ReadingStatus.reading));
      if (_isDisposed) return null;
      final books = await _repository.fetchBooks();
      if (_isDisposed) return null;
      _set(ReadingLoaded(books: books, selectedFilter: _currentFilter));
      return null;
    } on AppException catch (e) {
      return e.message;
    } catch (_) {
      return 'Gagal memperbarui status bacaan.';
    }
  }

  Future<String?> completeBook(String bookId, int rating) async {
    if (rating < 1 || rating > 5) {
      return 'Rating harus diisi antara 1 sampai 5 bintang.';
    }

    final current = _state;
    if (current is! ReadingLoaded) return 'Data buku belum siap.';

    final index = current.books.indexWhere((b) => b.id == bookId);
    if (index == -1) return 'Buku tidak ditemukan.';

    final book = current.books[index];
    if (book.status != ReadingStatus.reading) {
      return 'Hanya buku yang sedang dibaca yang bisa diselesaikan.';
    }

    try {
      await _repository.updateBook(
        book.copyWith(status: ReadingStatus.completed, rating: rating),
      );
      if (_isDisposed) return null;
      final books = await _repository.fetchBooks();
      if (_isDisposed) return null;
      _set(ReadingLoaded(books: books, selectedFilter: _currentFilter));
      return null;
    } on AppException catch (e) {
      return e.message;
    } catch (_) {
      return 'Gagal menyelesaikan buku.';
    }
  }

  Future<String?> deleteBook(String bookId) async {
    try {
      await _repository.deleteBook(bookId);
      if (_isDisposed) return null;
      final books = await _repository.fetchBooks();
      if (_isDisposed) return null;
      _set(ReadingLoaded(books: books, selectedFilter: _currentFilter));
      return null;
    } on AppException catch (e) {
      return e.message;
    } catch (_) {
      return 'Gagal menghapus buku.';
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}