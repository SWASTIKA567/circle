import 'package:flutter/material.dart';

class NotesTab extends StatefulWidget {
  const NotesTab({super.key});

  @override
  State<NotesTab> createState() => _NotesTabState();
}

class _NotesTabState extends State<NotesTab> {
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'All',
    'Computer Science',
    'Data Structures',
    'OS',
    'Networks',
    'Mathematics',
  ];

  final List<Map<String, String>> _notes = [
    {
      'title': 'Data Structures & Algorithms Handnotes',
      'subject': 'Data Structures',
      'author': 'Prof. Sharma',
      'semester': 'Sem 3',
      'pages': '48 pages',
      'rating': '4.9',
    },
    {
      'title': 'Operating Systems Process Management',
      'subject': 'OS',
      'author': 'Rahul V. (Topper)',
      'semester': 'Sem 4',
      'pages': '32 pages',
      'rating': '4.8',
    },
    {
      'title': 'Computer Networks OSI & TCP/IP Model',
      'subject': 'Networks',
      'author': 'Dr. K. Verma',
      'semester': 'Sem 5',
      'pages': '56 pages',
      'rating': '4.7',
    },
    {
      'title': 'Discrete Mathematics & Graph Theory',
      'subject': 'Mathematics',
      'author': 'Dept. Faculty',
      'semester': 'Sem 3',
      'pages': '64 pages',
      'rating': '4.9',
    },
    {
      'title': 'DBMS Normalization & SQL Queries',
      'subject': 'Computer Science',
      'author': 'Ananya P.',
      'semester': 'Sem 4',
      'pages': '40 pages',
      'rating': '4.6',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryIndigo = Colors.indigo;

    final filteredNotes = _notes.where((note) {
      final matchesCategory = _selectedCategory == 'All' ||
          note['subject'] == _selectedCategory;
      final query = _searchController.text.trim().toLowerCase();
      final matchesQuery = query.isEmpty ||
          note['title']!.toLowerCase().contains(query) ||
          note['subject']!.toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Search & Filters Header
          Container(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.indigo.shade50)),
            ),
            child: Column(
              children: [
                // Search Input
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search college notes, subjects...',
                    hintStyle: TextStyle(color: Colors.indigo.shade200, fontSize: 14),
                    prefixIcon: const Icon(Icons.search_rounded, color: primaryIndigo),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.indigo.shade50.withValues(alpha: 0.35),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.indigo.shade100),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.indigo.shade100),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: primaryIndigo, width: 1.8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Category Chips
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final cat = _categories[index];
                      final isSelected = _selectedCategory == cat;
                      return ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : primaryIndigo,
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                        selectedColor: primaryIndigo,
                        backgroundColor: Colors.indigo.shade50.withValues(alpha: 0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected ? primaryIndigo : Colors.indigo.shade100,
                          ),
                        ),
                        showCheckmark: false,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedCategory = cat);
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Notes List
          Expanded(
            child: filteredNotes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.menu_book_outlined, size: 56, color: Colors.indigo.shade200),
                        const SizedBox(height: 12),
                        Text(
                          'No notes found for "$_selectedCategory"',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    itemCount: filteredNotes.length,
                    itemBuilder: (context, index) {
                      final item = filteredNotes[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.indigo.shade100),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.indigo.withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.indigo.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.picture_as_pdf_rounded,
                                      color: primaryIndigo,
                                      size: 26,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['title']!,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'By ${item['author']} • ${item['pages']}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.indigo.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      item['subject']!,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: primaryIndigo,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      item['semester']!,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade800,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: primaryIndigo,
                                      side: const BorderSide(color: primaryIndigo),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    icon: const Icon(Icons.download_rounded, size: 16),
                                    label: const Text('Download', style: TextStyle(fontSize: 12)),
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Downloading "${item['title']}"...'),
                                          behavior: SnackBarBehavior.floating,
                                          backgroundColor: primaryIndigo,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryIndigo,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Upload Note', style: TextStyle(fontWeight: FontWeight.w600)),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Upload Note feature coming up!'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: primaryIndigo,
            ),
          );
        },
      ),
    );
  }
}
