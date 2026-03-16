import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // current User
  User? get currentUser => _auth.currentUser;

  // 인증 상태 변경 스트림
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // 회원가입
  Future<String?>? signUp({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty) {
      return "이메일을 입력해주세요.";
    } else if (password.isEmpty) {
      return "비밀번호를 입력해주세요.";
    }

    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; // 성공시 null 리턴
    } on FirebaseAuthException catch (e) {
      return e.message ?? "회원가입에 실패했습니다."; // 실패시 error message 리턴
    } catch (e) {
      return e.toString();
    }
  }

  // 로그인
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty) {
      return "이메일을 입력해주세요.";
    } else if (password.isEmpty) {
      return "비밀번호를 입력해주세요.";
    }

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // 성공 시 null 리턴
    } on FirebaseAuthException catch (e) {
      // 사용자에게 보여줄 에러 메시지 처리 (예: 비밀번호 불일치, 존재하지 않는 사용자)
      return e.message ?? "로그인에 실패했습니다.";
    } catch (e) {
      return e.toString();
    }
  }

  // 로그아웃
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
