import 'package:flutter/material.dart';
import '../../domain/book.dart';

class BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback onStartReading;
  final VoidCallback onComplete;
  final VoidCallback onDelete;

  const BookCard({
    super.key,
    required this.book,
    required this.onStartReading,
    required this.onComplete,
    required this.onDelete,
  });

  String get _statusLabel {
    switch (book.status) {
      case ReadingStatus.wishlist:
        return 'Wishlist';
      case ReadingStatus.reading:
        return 'Sedang Dibaca';
      case ReadingStatus.completed:
        return 'Selesai Dibaca';
    }
  }

  Color get _statusColor {
    switch (book.status) {
      case ReadingStatus.wishlist:
        return Colors.orange;
      case ReadingStatus.reading:
        return Colors.blue;
      case ReadingStatus.completed:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    book.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Chip(
                  label: Text(
                    _statusLabel,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  backgroundColor: _statusColor,
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Penulis: ${book.author}',
              style: TextStyle(color: Colors.grey[700]),
            ),
            if (book.status == ReadingStatus.completed && book.rating != null) ...[
              const SizedBox(height: 6),
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    index < book.rating! ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 20,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (book.status == ReadingStatus.wishlist)
                  ElevatedButton.icon(
                    onPressed: onStartReading,
                    icon: const Icon(Icons.menu_book, size: 18),
                    label: const Text('Mulai Baca'),
                  ),
                if (book.status == ReadingStatus.reading)
                  ElevatedButton.icon(
                    onPressed: onComplete,
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text('Selesaikan'),
                  ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  tooltip: 'Hapus buku',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}