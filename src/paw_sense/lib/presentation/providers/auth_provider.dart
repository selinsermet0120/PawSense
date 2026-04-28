import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseClient _client;

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider(this._client) {
    _user = _client.auth.currentUser;
    _client.auth.onAuthStateChange.listen((data) {
      _user = data.session?.user;
      notifyListeners();
    });
  }

  User? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _client.auth.signInWithPassword(email: email, password: password);
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = _turkishError(e.message);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Beklenmeyen bir hata oluştu.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp(String name, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _client.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = _turkishError(e.message);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Beklenmeyen bir hata oluştu.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signOut() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _client.auth.signOut();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('socket') ||
          msg.contains('network') ||
          msg.contains('failed host lookup') ||
          msg.contains('timeout')) {
        _errorMessage = 'Çıkış yapılamadı: internet bağlantınızı kontrol edin.';
      } else {
        _errorMessage = 'Çıkış yapılamadı: ${e.toString()}';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String _turkishError(String message) {
    final m = message.toLowerCase();
    if (m.contains('invalid login credentials') || m.contains('invalid_credentials')) {
      return 'E-posta veya şifre hatalı.';
    }
    if (m.contains('email already registered') || m.contains('already been registered')) {
      return 'Bu e-posta zaten kayıtlı.';
    }
    if (m.contains('password should be at least')) {
      return 'Şifre en az 6 karakter olmalıdır.';
    }
    if (m.contains('unable to validate email')) {
      return 'Geçersiz e-posta adresi.';
    }
    return message;
  }
}
