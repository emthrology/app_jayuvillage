import 'package:dio/dio.dart';
import 'package:flutter/material.dart';


class AddressSearchComponent extends StatefulWidget {
  const AddressSearchComponent({super.key});

  @override
  State<AddressSearchComponent> createState() => _AddressSearchComponentState();
}

class _AddressSearchComponentState extends State<AddressSearchComponent> {
  final Dio _dio = Dio();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // body: Center(
      //   child:Text('물품현황 총괄팀장 화면')
      // ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: searchAddress('월계동 556'),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final addresses = snapshot.data!['documents'];
            return ListView.builder(
              itemCount: addresses.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(addresses[index]['address_name']),
                  subtitle: Text(addresses[index]['road_address']['address_name']),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }
          return CircularProgressIndicator();
        },
      ) ,
    );
  }

  Future<Map<String, dynamic>> searchAddress(String query) async {
    final String apiKey = '24ddb5988f2a2fb66657e02ead084598';
    final String url = 'https://dapi.kakao.com/v2/local/search/address.json?query=$query&analyze_type=similar';
    final response = await _dio.get(
        url,
        options: Options(
          headers: {'Authorization': 'KakaoAK $apiKey'},
        )
    );
    if (response.statusCode == 200) {
      debugPrint('searchAddress_response:${response}');
      return response.data;
    } else {
      throw Exception('Failed to load address');
    }
  }
}
