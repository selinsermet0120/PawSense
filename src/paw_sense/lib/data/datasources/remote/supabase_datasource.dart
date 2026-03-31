import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseDatasource {
  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: 'REDACTED_URL',
      anonKey: 'REDACTED_KEY',
    );
  }
}
