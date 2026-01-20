import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/event_provider.dart';
import '../../widgets/event_card.dart';
import 'package:go_router/go_router.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search events...',
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchResults.clear());
                    },
                  )
                : null,
          ),
          onChanged: (value) async {
            setState(() => _isSearching = true);
            if (value.isEmpty) {
              setState(() {
                _searchResults.clear();
                _isSearching = false;
              });
            } else {
              final results = await context.read<EventProvider>().searchEvents(
                value,
              );
              setState(() {
                _searchResults = results;
                _isSearching = false;
              });
            }
          },
        ),
      ),
      body: _isSearching
          ? const Center(child: CircularProgressIndicator())
          : _searchResults.isEmpty
          ? Center(
              child: Text(
                _searchController.text.isEmpty
                    ? 'Start typing to search events'
                    : 'No results found',
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _searchResults.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: EventCard(
                  event: _searchResults[index],
                  onTap: () {
                    context.go('/events/${_searchResults[index].id}');
                  },
                ),
              ),
            ),
    );
  }
}
