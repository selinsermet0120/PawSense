import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseDatasource {
  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: 'https://wthlmfjxtcnqweokbdot.supabase.co',
      anonKey: 'sb_publishable_EjU_bIvxOkErrRqz1DV40g_pIOinhNB',
    );
  }
}
