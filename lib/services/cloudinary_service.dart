import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class CloudinaryService {
  static const String cloudName = "dkmowzhgf";
  static const String uploadPreset = "profile_upload";

  static Future<String?> uploadProfileImage(
      File imageFile, String userId) async {
    final uri = Uri.parse(
      "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
    );

    final request = http.MultipartRequest("POST", uri)
      ..fields['upload_preset'] = uploadPreset
      ..fields['folder'] = "users/$userId/profile"
      ..files.add(await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
      ));

    final response = await request.send();
    final resBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final data = json.decode(resBody);
      return data['secure_url'];
    }
    return null;
  }
}
