import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:http/http.dart' as http;

void main(List<String> args) async {
  // Create the request handler
  Handler handler = const Pipeline()
      .addMiddleware(corsHeaders())
      .addMiddleware(logRequests())
      .addHandler(_handleRequest);

  // Start the server
  final port = int.tryParse(args.isNotEmpty ? args[0] : '8080') ?? 8080;
  final server = await serve(handler, InternetAddress.anyIPv4, port);

  print('CORS Proxy Server listening on port ${server.port}');
  print('Forward requests to: http://localhost:${server.port}/proxy');
  print('Target LM Studio server: http://127.0.0.1:1234');
}

Future<Response> _handleRequest(Request request) async {
  // Handle preflight OPTIONS requests
  if (request.method == 'OPTIONS') {
    return Response.ok('', headers: {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
      'Access-Control-Allow-Headers':
          'Origin, Content-Type, Accept, Authorization, X-Requested-With',
    });
  }

  // Only handle proxy requests
  if (!request.url.path.startsWith('proxy')) {
    return Response.notFound('Use /proxy path to proxy requests to LM Studio');
  }

  try {
    // Extract the target path (remove 'proxy' prefix)
    final targetPath = request.url.path.substring(5); // Remove 'proxy'
    final targetUrl = 'http://127.0.0.1:1234$targetPath';

    // Forward query parameters
    final queryParams =
        request.url.query.isNotEmpty ? '?${request.url.query}' : '';
    final fullTargetUrl = '$targetUrl$queryParams';

    print('Proxying ${request.method} request to: $fullTargetUrl');

    // Read the request body
    final body = await request.readAsString();

    // Create headers for the proxied request
    final headers = Map<String, String>.from(request.headers);
    headers.remove('host'); // Remove host header to avoid conflicts

    // Make the proxied request
    late http.Response response;

    switch (request.method) {
      case 'GET':
        response = await http.get(Uri.parse(fullTargetUrl), headers: headers);
        break;
      case 'POST':
        response = await http.post(
          Uri.parse(fullTargetUrl),
          headers: headers,
          body: body,
        );
        break;
      case 'PUT':
        response = await http.put(
          Uri.parse(fullTargetUrl),
          headers: headers,
          body: body,
        );
        break;
      case 'DELETE':
        response =
            await http.delete(Uri.parse(fullTargetUrl), headers: headers);
        break;
      default:
        return Response(405, body: 'Method not allowed');
    }

    // Return the response with CORS headers
    return Response(
      response.statusCode,
      body: response.body,
      headers: {
        'Content-Type': response.headers['content-type'] ?? 'application/json',
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers':
            'Origin, Content-Type, Accept, Authorization, X-Requested-With',
        ...response.headers,
      },
    );
  } catch (e) {
    print('Proxy error: $e');
    return Response.internalServerError(
      body: jsonEncode({'error': 'Proxy error: ${e.toString()}'}),
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
    );
  }
}
