import 'package:flutter/material.dart';
import '../../domain/book.dart';
import '../viewmodels/reading_state.dart';
import '../viewmodels/reading_view_model.dart';
import 'widgets/book_card.dart';

class ReadingTrackerScreen extends StatefulWidget {
  final ReadingViewModel viewModel;

  const ReadingTrackerScreen({super.key, required this.viewModel});

  @override
  State<ReadingTrackerScreen> createState() => _ReadingTrackerScreenState();
}

class _ReadingTrackerScreenState extends State<ReadingTrackerScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.loadBooks();
  }

  @override
  void dispose() {
    widget.viewModel.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _openAddBookDialog() {
    showDialog(
      context: context,
      builder: (_) => _AddBookDialog(
        onSubmit: (title, author) async {
          final error = await widget.viewModel.addBook(title, author);
          if (error != null) {
            _showMessage(error);
            return false;
          }
          _showMessage('Buku berhasil ditambahkan ke Wishlist.');
          return true;
        },
      ),
    );
  }

  void _openCompleteBookDialog(Book book) {
    showDialog(
      context: context,
      builder: (_) => _CompleteBookDialog(
        bookTitle: book.title,
        onSubmit: (rating) async {
          final error = await widget.viewModel.completeBook(book.id, rating);
          if (error != null) {
            _showMessage(error);
            return false;
          }
          _showMessage('Selamat! Buku ditandai selesai dibaca.');
          return true;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reading Tracker'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddBookDialog,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Buku'),
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          final state = widget.viewModel.state;

          return switch (state) {
            ReadingInitial() || ReadingLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
            ReadingFailure(:final message) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 12),
                      Text(message, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: widget.viewModel.loadBooks,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              ),
            ReadingLoaded() => _buildLoadedContent(state),
          };
        },
      ),
    );
  }

  Widget _buildLoadedContent(ReadingLoaded state) {
    final books = state.filteredBooks;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              _SummaryBox(
                label: 'Wishlist',
                count: state.countByStatus(ReadingStatus.wishlist),
                color: Colors.orange,
              ),
              const SizedBox(width: 8),
              _SummaryBox(
                label: 'Dibaca',
                count: state.countByStatus(ReadingStatus.reading),
                color: Colors.blue,
              ),
              const SizedBox(width: 8),
              _SummaryBox(
                label: 'Selesai',
                count: state.countByStatus(ReadingStatus.completed),
                color: Colors.green,
              ),
            ],
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              ChoiceChip(
                label: const Text('Semua'),
                selected: state.selectedFilter == null,
                onSelected: (_) => widget.viewModel.setFilter(null),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Wishlist'),
                selected: state.selectedFilter == ReadingStatus.wishlist,
                onSelected: (_) =>
                    widget.viewModel.setFilter(ReadingStatus.wishlist),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Sedang Dibaca'),
                selected: state.selectedFilter == ReadingStatus.reading,
                onSelected: (_) =>
                    widget.viewModel.setFilter(ReadingStatus.reading),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Selesai'),
                selected: state.selectedFilter == ReadingStatus.completed,
                onSelected: (_) =>
                    widget.viewModel.setFilter(ReadingStatus.completed),
              ),
            ],
          ),
        ),
        Expanded(
          child: books.isEmpty
              ? const Center(
                  child: Text('Belum ada buku pada kategori ini.'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final book = books[index];
                    return BookCard(
                      book: book,
                      onStartReading: () async {
                        final error =
                            await widget.viewModel.startReading(book.id);
                        if (error != null) _showMessage(error);
                      },
                      onComplete: () => _openCompleteBookDialog(book),
                      onDelete: () async {
                        final error =
                            await widget.viewModel.deleteBook(book.id);
                        if (error != null) {
                          _showMessage(error);
                        } else {
                          _showMessage('Buku dihapus dari daftar.');
                        }
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _SummaryBox extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _SummaryBox({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _AddBookDialog extends StatefulWidget {
  final Future<bool> Function(String title, String author) onSubmit;

  const _AddBookDialog({required this.onSubmit});

  @override
  State<_AddBookDialog> createState() => _AddBookDialogState();
}

class _AddBookDialogState extends State<_AddBookDialog> {
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tambah Buku Baru'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Judul Buku'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _authorController,
            decoration: const InputDecoration(labelText: 'Nama Penulis'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () async {
            final success = await widget.onSubmit(
              _titleController.text,
              _authorController.text,
            );
            if (success && context.mounted) {
              Navigator.pop(context);
            }
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}

class _CompleteBookDialog extends StatefulWidget {
  final String bookTitle;
  final Future<bool> Function(int rating) onSubmit;

  const _CompleteBookDialog({
    required this.bookTitle,
    required this.onSubmit,
  });

  @override
  State<_CompleteBookDialog> createState() => _CompleteBookDialogState();
}

class _CompleteBookDialogState extends State<_CompleteBookDialog> {
  int _selectedRating = 5;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Selesaikan Bacaan'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Beri rating untuk "${widget.bookTitle}":'),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starValue = index + 1;
              return IconButton(
                onPressed: () => setState(() => _selectedRating = starValue),
                icon: Icon(
                  starValue <= _selectedRating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                ),
              );
            }),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () async {
            final success = await widget.onSubmit(_selectedRating);
            if (success && context.mounted) {
              Navigator.pop(context);
            }
          },
          child: const Text('Konfirmasi'),
        ),
      ],
    );
  }
}