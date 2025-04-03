import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final dialysisStatsProvider =
    StateNotifierProvider<DialysisStatsNotifier, Map<String, dynamic>>((ref) {
  return DialysisStatsNotifier();
});

class DialysisStatsNotifier extends StateNotifier<Map<String, dynamic>> {
  DialysisStatsNotifier() : super({}) {
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse(
          'https://dialysis.gandakidata.com/api/getDialysisStatisticData'));

      if (response.statusCode == 200) {
        state = json.decode(response.body);
      } else {
        log('Failed to fetch data');
      }
    } catch (e) {
      log('Error: $e');
    }
  }
}

final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredDialysisStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final data = ref.watch(dialysisStatsProvider);

  if (query.isEmpty) return data;

  return Map.fromEntries(
      data.entries.where((entry) => entry.key.toLowerCase().contains(query)));
});

class MySearchPage extends ConsumerWidget {
  static const routeName = '/MySearchPage';
  const MySearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(filteredDialysisStatsProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: TextField(
            onChanged: (value) =>
                ref.read(searchQueryProvider.notifier).state = value,
            decoration: InputDecoration(
              labelText: 'Search Statistic',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Expanded(
          child: stats.isEmpty
              ? Center(child: Text('No data found'))
              : ListView(
                  children: stats.entries.map((entry) {
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        title:
                            Text(entry.key.replaceAll('_', ' ').toUpperCase()),
                        subtitle: Text(entry.value.toString()),
                      ),
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }
}
