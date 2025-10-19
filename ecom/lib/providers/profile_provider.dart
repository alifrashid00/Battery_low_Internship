import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_provider.dart';

// Profile data model
class UserProfile {
  final String? id;
  final String? name;
  final String? address;
  final String? phoneNumber;
  final String? avatarUrl;

  UserProfile({
    this.id,
    this.name,
    this.address,
    this.phoneNumber,
    this.avatarUrl,
  });

  UserProfile copyWith({
    String? id,
    String? name,
    String? address,
    String? phoneNumber,
    String? avatarUrl,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone_number': phoneNumber,
      'avatar_url': avatarUrl,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      phoneNumber: json['phone_number'],
      avatarUrl: json['avatar_url'],
    );
  }
}

// Profile service provider
final profileServiceProvider = Provider<ProfileService>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return ProfileService(supabase);
});

// Current user profile provider
final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  final profileService = ref.watch(profileServiceProvider);
  return await profileService.getUserProfile(user.id);
});

class ProfileService {
  final SupabaseClient _supabase;

  ProfileService(this._supabase);

  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return null;
      return UserProfile.fromJson(response);
    } catch (e) {
      throw Exception('Failed to load profile: $e');
    }
  }

  Future<void> updateProfile(UserProfile profile) async {
    try {
      await _supabase.from('profiles').upsert(profile.toJson());
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  Future<String?> uploadAvatar(XFile file, String userId) async {
    try {
      // Validate file first
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) {
        throw Exception('Selected file is empty');
      }

      final fileExt = file.name.split('.').last.toLowerCase();
      final allowedExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];

      if (!allowedExtensions.contains(fileExt)) {
        throw Exception(
          'Invalid file type. Allowed: ${allowedExtensions.join(', ')}',
        );
      }

      final fileName = '$userId.$fileExt';
      final filePath = fileName; // Just the filename, not avatars/filename

      print('Uploading avatar: $filePath (${bytes.length} bytes)');

      await _supabase.storage
          .from('avatars')
          .uploadBinary(
            filePath,
            bytes,
            fileOptions: const FileOptions(upsert: true),
          );

      final publicUrl = _supabase.storage
          .from('avatars')
          .getPublicUrl(filePath);

      print('Avatar uploaded successfully: $publicUrl');
      return publicUrl;
    } catch (e) {
      print('Avatar upload error: $e');
      throw Exception('Failed to upload avatar: $e');
    }
  }
}
