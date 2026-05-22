import 'dart:convert';
import 'dart:io';
import 'lib/utils/constants.dart';

void main() async {
  print('Initializing HTTP request to Supabase REST API...');
  
  final client = HttpClient();
  try {
    final uri = Uri.parse('$supabaseUrl/rest/v1/$itemsTable?select=*&limit=1');
    final request = await client.getUrl(uri);
    
    // Set headers
    request.headers.add('apikey', supabaseAnonKey);
    request.headers.add('Authorization', 'Bearer $supabaseAnonKey');
    
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    print('Response status: ${response.statusCode}');
    print('Response body: $responseBody');
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(responseBody);
      if (data.isNotEmpty) {
        print('Columns in items table: ${data.first.keys}');
      } else {
        print('Items table is empty. Trying to insert a test item to check schema...');
        await testInsert(client);
      }
    }
  } catch (e) {
    print('Error: $e');
  } finally {
    client.close();
  }
}

Future<void> testInsert(HttpClient client) async {
  try {
    final uri = Uri.parse('$supabaseUrl/rest/v1/$itemsTable');
    final request = await client.postUrl(uri);
    
    request.headers.add('apikey', supabaseAnonKey);
    request.headers.add('Authorization', 'Bearer $supabaseAnonKey');
    request.headers.add('Content-Type', 'application/json');
    request.headers.add('Prefer', 'return=representation');
    
    final body = jsonEncode({
      'name': 'Test Item Schema',
      'description': 'Schema test',
    });
    
    request.write(body);
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    print('Insert status: ${response.statusCode}');
    print('Insert body: $responseBody');
    
    if (response.statusCode == 201) {
      final List<dynamic> data = jsonDecode(responseBody);
      if (data.isNotEmpty) {
        print('Successfully inserted test item. Columns: ${data.first.keys}');
        final id = data.first['id'];
        
        // Clean up
        final deleteUri = Uri.parse('$supabaseUrl/rest/v1/$itemsTable?id=eq.$id');
        final deleteReq = await client.deleteUrl(deleteUri);
        deleteReq.headers.add('apikey', supabaseAnonKey);
        deleteReq.headers.add('Authorization', 'Bearer $supabaseAnonKey');
        final deleteRes = await deleteReq.close();
        print('Cleaned up test item. Status: ${deleteRes.statusCode}');
      }
    }
  } catch (e) {
    print('Insert test failed: $e');
  }
}
