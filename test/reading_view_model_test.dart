import 'package:flutter_test/flutter_test.dart';
import 'package:afl2_vispro/core/app_exception.dart';
import 'package:afl2_vispro/data/fake_book_repository.dart';
import 'package:afl2_vispro/domain/book.dart';
import 'package:afl2_vispro/domain/book_repository.dart';
import 'package:afl2_vispro/presentation/viewmodels/reading_state.dart';
import 'package:afl2_vispro/presentation/viewmodels/reading_view_model.dart';

class _FailingBookRepository implements BookRepository {
  @override
  Future<List<Book>> fetchBooks() async {
    throw const AppException('Koneksi penyimpanan bermasalah.');
  }

  @override
  Future<void> addBook(Book book) async {}

  @override
  Future<void> updateBook(Book book) async {}

  @override
  Future<void> deleteBook(String id) async {}
}

void main() {
  group('ReadingViewModel Tests', () {
    test('1. loadBooks memuat data awal dan mengubah state menjadi ReadingLoaded', () async {
      final viewModel = ReadingViewModel(FakeBookRepository());

      await viewModel.loadBooks();

      expect(viewModel.state, isA<ReadingLoaded>());
      final loaded = viewModel.state as ReadingLoaded;
      expect(loaded.books.length, 3);
    });

    test('2. addBook menambah buku baru ke Wishlist dan menolak judul kosong', () async {
      final viewModel = ReadingViewModel(FakeBookRepository());
      await viewModel.loadBooks();

      final errorEmpty = await viewModel.addBook('   ', 'Penulis Test');
      expect(errorEmpty, isNotNull);

      final errorValid = await viewModel.addBook('Clean Code', 'Robert C. Martin');
      expect(errorValid, isNull);

      final loaded = viewModel.state as ReadingLoaded;
      expect(loaded.books.length, 4);
      expect(loaded.books.last.status, ReadingStatus.wishlist);
    });

    test('3. Transisi status wishlist -> reading -> completed berjalan sesuai aturan', () async {
      final viewModel = ReadingViewModel(FakeBookRepository());
      await viewModel.loadBooks();

      final startError = await viewModel.startReading('B002');
      expect(startError, isNull);

      var loaded = viewModel.state as ReadingLoaded;
      var book = loaded.books.firstWhere((b) => b.id == 'B002');
      expect(book.status, ReadingStatus.reading);

      final completeError = await viewModel.completeBook('B002', 5);
      expect(completeError, isNull);

      loaded = viewModel.state as ReadingLoaded;
      book = loaded.books.firstWhere((b) => b.id == 'B002');
      expect(book.status, ReadingStatus.completed);
      expect(book.rating, 5);
    });

    test('4. completeBook menolak rating tidak valid atau buku yang belum dibaca', () async {
      final viewModel = ReadingViewModel(FakeBookRepository());
      await viewModel.loadBooks();

      final invalidRating = await viewModel.completeBook('B001', 6);
      expect(invalidRating, isNotNull);

      final skipStatus = await viewModel.completeBook('B002', 4);
      expect(skipStatus, isNotNull);
    });

    test('5. deleteBook menghapus buku dari repositori', () async {
      final viewModel = ReadingViewModel(FakeBookRepository());
      await viewModel.loadBooks();

      final deleteError = await viewModel.deleteBook('B001');
      expect(deleteError, isNull);

      final loaded = viewModel.state as ReadingLoaded;
      expect(loaded.books.any((b) => b.id == 'B001'), isFalse);
    });

    test('6. loadBooks mengubah state menjadi ReadingFailure saat repository error', () async {
      final viewModel = ReadingViewModel(_FailingBookRepository());

      await viewModel.loadBooks();

      expect(viewModel.state, isA<ReadingFailure>());
      final failure = viewModel.state as ReadingFailure;
      expect(failure.message, 'Koneksi penyimpanan bermasalah.');
    });
  });
}