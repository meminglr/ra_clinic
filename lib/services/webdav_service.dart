import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:webdav_client/webdav_client.dart' as webdav;

class WebDavService {
  final String _url = dotenv.env['WEBDAV_URL'] ?? "";
  final String _user = dotenv.env['WEBDAV_USER'] ?? "";
  final String _password = dotenv.env['WEBDAV_PASSWORD'] ?? "";
  late webdav.Client _client;

  WebDavService() {
    // Basic Auth is not provided, assuming no auth or handling it if requested
    _client = webdav.newClient(
      _url,
      user: _user,
      password: _password,
      debug: true,
    );
  }

  Future<void> init() async {
    try {
      await _client.ping();
    } catch (e) {
      print("WebDav Ping Failed: $e");
    }
  }

  Future<void> ensureFolder(String path) async {
    path = _normalizePath(path);
    try {
      await _client.mkdir(path);
    } catch (e) {
      // Ignore if exists or handle specific error code
      print("Ensure Folder Error (might exist): $e");
    }
  }

  Future<List<dynamic>> listFiles(String folderPath) async {
    folderPath = _normalizePath(folderPath);
    try {
      return await _client.readDir(folderPath);
    } catch (e) {
      print("List Files Error: $e");
      return [];
    }
  }

  Future<void> uploadFile(
    String folderPath,
    String fileName,
    Uint8List data,
  ) async {
    folderPath = _normalizePath(folderPath);
    await ensureFolder(folderPath);
    String fullPath = "$folderPath/$fileName";
    // Correct API use for write
    await _client.write(fullPath, data);
  }

  Future<void> deleteFile(String path) async {
    path = _normalizePath(path);
    await _client.remove(path);
  }

  String getFileUrl(String path) {
    path = _normalizePath(path);
    // Construct public URL if possible, or use ID.
    // Assuming simple concatenation
    if (_url.endsWith("/")) {
      return "$_url$path";
    }
    return "$_url/$path";
  }

  String _normalizePath(String path) {
    if (path.startsWith("/")) return path.substring(1);
    return path;
  }

  Map<String, String> getAuthHeaders() {
    String credentials = "$_user:$_password";
    String encoded = base64Encode(utf8.encode(credentials));
    return {"Authorization": "Basic $encoded"};
  }
}
