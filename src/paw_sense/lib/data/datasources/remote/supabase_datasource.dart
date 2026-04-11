<<<<<<< HEAD
=======
import 'package:flutter_dotenv/flutter_dotenv.dart';
>>>>>>> 184ff44f924bd06e13a586a090c5eb8a61f31d0c
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseDatasource {
  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
<<<<<<< HEAD
    await Supabase.initialize(
      url: 'https://wthlmfjxtcnqweokbdot.supabase.co',
      anonKey: 'sb_publishable_EjU_bIvxOkErrRqz1DV40g_pIOinhNB',
=======
    await dotenv.load(fileName: '.env');
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
>>>>>>> 184ff44f924bd06e13a586a090c5eb8a61f31d0c
    );
  }
}
