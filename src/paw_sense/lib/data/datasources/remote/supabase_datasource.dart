import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseDatasource {
  static const String _expectedUrl = 'https://wthlmfjxtcnqweokbdot.supabase.co';

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    try {
      _log('🔄 .env dosyası yükleniyor...');
      await dotenv.load(fileName: '.env');
      _log('✅ .env dosyası yüklendi.');
    } catch (e, st) {
      _logError(
        '.env dosyası yüklenemedi. pubspec.yaml assets bölümünde tanımlı mı '
        've dosya src/paw_sense/.env yolunda var mı kontrol edin.',
        e,
        st,
      );
      rethrow;
    }

    final url = dotenv.env['SUPABASE_URL'];
    final anonKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (url == null || url.isEmpty) {
      final err = StateError(
        'SUPABASE_URL .env dosyasında bulunamadı. Beklenen değer: $_expectedUrl',
      );
      _logError('SUPABASE_URL eksik.', err, StackTrace.current);
      throw err;
    }
    if (anonKey == null || anonKey.isEmpty) {
      final err = StateError('SUPABASE_ANON_KEY .env dosyasında bulunamadı.');
      _logError('SUPABASE_ANON_KEY eksik.', err, StackTrace.current);
      throw err;
    }

    if (url != _expectedUrl) {
      _log(
        '⚠️ UYARI: SUPABASE_URL beklenen değerle eşleşmiyor.\n'
        '   Beklenen: $_expectedUrl\n'
        '   Mevcut  : $url',
      );
    } else {
      _log('✅ SUPABASE_URL doğru: $url');
    }

    _log('🔑 Anon key uzunluğu: ${anonKey.length} karakter '
        '(önizleme: ${_maskKey(anonKey)})');

    try {
      _log('🔄 Supabase başlatılıyor...');
      await Supabase.initialize(
        url: url,
        anonKey: anonKey,
        debug: kDebugMode,
      );
      _log('✅ Supabase başarıyla başlatıldı.');
    } on AuthException catch (e, st) {
      _logError(
        'Supabase AuthException: ${e.message} (statusCode: ${e.statusCode}). '
        'Anon key geçerliliğini kontrol edin.',
        e,
        st,
      );
      rethrow;
    } on PostgrestException catch (e, st) {
      _logError(
        'Supabase PostgrestException: ${e.message} '
        '(code: ${e.code}, details: ${e.details}, hint: ${e.hint})',
        e,
        st,
      );
      rethrow;
    } catch (e, st) {
      _logError(
        'Supabase başlatılamadı. URL/anon key veya ağ bağlantısını kontrol edin. '
        'Hata tipi: ${e.runtimeType}',
        e,
        st,
      );
      rethrow;
    }
  }

  static String _maskKey(String key) {
    if (key.length <= 8) return '***';
    return '${key.substring(0, 4)}...${key.substring(key.length - 4)}';
  }

  static void _log(String message) {
    developer.log(message, name: 'SupabaseDatasource');
    if (kDebugMode) {
      debugPrint('[SupabaseDatasource] $message');
    }
  }

  static void _logError(String message, Object error, StackTrace stackTrace) {
    developer.log(
      '❌ $message',
      name: 'SupabaseDatasource',
      error: error,
      stackTrace: stackTrace,
      level: 1000,
    );
    if (kDebugMode) {
      debugPrint('[SupabaseDatasource][ERROR] $message');
      debugPrint('  → $error');
      debugPrint(stackTrace.toString());
    }
  }
}
