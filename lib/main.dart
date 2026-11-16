import 'package:flutter/material.dart';
// import 'data/fake_book_repository.dart';
import 'data/local_book_repository.dart';
import 'domain/book_repository.dart';
import 'presentation/viewmodels/reading_view_model.dart';
import 'presentation/views/reading_tracker_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final BookRepository repository = LocalBookRepository();
  // final BookRepository repository = FakeBookRepository();

  final viewModel = ReadingViewModel(repository);

  runApp(ReadingTrackerApp(viewModel: viewModel));
}

class ReadingTrackerApp extends StatelessWidget {
  final ReadingViewModel viewModel;

  const ReadingTrackerApp({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reading Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: ReadingTrackerScreen(viewModel: viewModel),
    );
  }
}