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
