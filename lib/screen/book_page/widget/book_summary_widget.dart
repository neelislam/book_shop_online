import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller_from_firebase/book_summary_controller.dart';
import '../../../model/book_summary_model.dart';

class BookSummaryWidget extends StatefulWidget {
  final String bookId;
  final String bookName;
  final String author;
  final String? genre;

  const BookSummaryWidget({
    super.key,
    required this.bookId,
    required this.bookName,
    required this.author,
    this.genre,
  });

  @override
  State<BookSummaryWidget> createState() => _BookSummaryWidgetState();
}

class _BookSummaryWidgetState extends State<BookSummaryWidget> {
  final BookSummaryController _controller = Get.put(BookSummaryController());
  bool _showSpoilers = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.loadSummary(
        bookId: widget.bookId,
        bookName: widget.bookName,
        author: widget.author,
        genre: widget.genre,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_controller.isLoading.value) {
        return _buildLoadingState();
      }

      if (_controller.error.value.isNotEmpty) {
        return _buildErrorState(_controller.error.value);
      }

      if (_controller.currentSummary.value == null) {
        return const SizedBox.shrink();
      }

      return _buildSummaryContent(_controller.currentSummary.value!);
    });
  }

  Widget _buildLoadingState() {
    return Card(
      margin: const EdgeInsets.all(20),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'generating_ai_summary'.tr,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome, size: 12, color: Colors.green.shade700),
                      const SizedBox(width: 4),
                      Text(
                        'free'.tr,
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String errorMsg) {
    return Card(
      margin: const EdgeInsets.all(20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 8),
            Text('failed_to_generate_summary'.tr,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryContent(BookSummaryModel summary) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green.shade400, Colors.blue.shade400],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.auto_awesome, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'ai_powered'.tr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'book_summary'.tr,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Text(
                    'free'.tr,
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Text(summary.shortSummary, style: const TextStyle(fontSize: 15, height: 1.5)),
            const SizedBox(height: 16),

            _buildThemesSection(summary.themes),
            const SizedBox(height: 16),

            _buildMoodSection(summary.mood),
            const SizedBox(height: 16),

            _buildSpoilerToggle(),

            if (_showSpoilers) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),

              Text('detailed_summary'.tr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(summary.detailedSummary, style: const TextStyle(fontSize: 14, height: 1.5)),
              const SizedBox(height: 16),

              Text('key_takeaways'.tr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...summary.keyTakeaways.map((takeaway) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ', style: TextStyle(fontSize: 18, color: Colors.blue.shade700)),
                    Expanded(child: Text(takeaway, style: const TextStyle(fontSize: 14, height: 1.4))),
                  ],
                ),
              )),
            ],

            const SizedBox(height: 16),
            Text(
              '${'generated'.tr} ${_formatDate(summary.generatedAt)} • ${'powered_by_gemini'.tr}',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemesSection(List<String> themes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('main_themes'.tr, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: themes.map((theme) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(theme, style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w600, fontSize: 13)),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildMoodSection(String mood) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Icon(Icons.mood, color: Colors.orange.shade700, size: 20),
            const SizedBox(width: 4),
            Text(
              '${'mood'.tr}: ',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Text(
              mood,
              style: const TextStyle(fontSize: 14),
              overflow: TextOverflow.visible,
            ),
          ],
        ),
      ),
    );

  }

  Widget _buildSpoilerToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: SwitchListTile(
        title: Text('show_detailed_summary'.tr),
        subtitle: Text('may_contain_spoilers'.tr),
        value: _showSpoilers,
        onChanged: (value) => setState(() => _showSpoilers = value),
        secondary: Icon(_showSpoilers ? Icons.visibility : Icons.visibility_off, color: Colors.red.shade700),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'today'.tr;
    if (diff.inDays == 1) return 'yesterday'.tr;
    if (diff.inDays < 7) return '${diff.inDays} ${'days_ago'.tr}';
    return '${date.day}/${date.month}/${date.year}';
  }
}