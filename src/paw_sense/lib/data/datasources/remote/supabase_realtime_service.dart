import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase Realtime kanallarını merkezi olarak yöneten servis.
/// Her abone için benzersiz kanal oluşturur.
class SupabaseRealtimeService {
  final SupabaseClient _client;
  final List<RealtimeChannel> _channels = [];

  SupabaseRealtimeService(this._client);

  /// Belirtilen tabloda değişiklik olduğunda callback çağır.
  /// [subscriberName]: kanal adını benzersiz yapmak için kullanılır.
  void subscribe({
    required String subscriberName,
    required String table,
    void Function(PostgresChangePayload payload)? onInsert,
    void Function(PostgresChangePayload payload)? onUpdate,
    void Function(PostgresChangePayload payload)? onDelete,
  }) {
    final channelName = 'rt_${subscriberName}_$table';
    var channel = _client.channel(channelName);

    if (onInsert != null) {
      channel = channel.onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: table,
        callback: onInsert,
      );
    }

    if (onUpdate != null) {
      channel = channel.onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: table,
        callback: onUpdate,
      );
    }

    if (onDelete != null) {
      channel = channel.onPostgresChanges(
        event: PostgresChangeEvent.delete,
        schema: 'public',
        table: table,
        callback: onDelete,
      );
    }

    channel.subscribe((status, [error]) {
      debugPrint('Realtime [$channelName] durumu: $status');
      if (error != null) {
        debugPrint('Realtime [$channelName] hata: $error');
      }
    });

    _channels.add(channel);
  }

  /// Tüm kanalları kapat
  void dispose() {
    for (final channel in _channels) {
      _client.removeChannel(channel);
    }
    _channels.clear();
  }
}
