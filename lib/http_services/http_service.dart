import 'dart:convert';

import 'package:http/http.dart' as http;

import 'dialysis_statistic_data_model.dart';

Future<DialysisStatisticDataModel> fetchData() async {
  final response = await http.get(Uri.parse(
      'https://dialysis.gandakidata.com/api/getDialysisStatisticData'));

  if (response.statusCode == 200) {
    return DialysisStatisticDataModel.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load data');
  }
}

// Future<T> fetchData<T>(
//     String url, T Function(Map<String, dynamic>) fromJson) async {
//   final response = await http.get(Uri.parse(url));

//   if (response.statusCode == 200) {
//     return fromJson(jsonDecode(response.body));
//   } else {
//     throw Exception('Failed to load data');
//   }
// }
