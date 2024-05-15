import 'package:firebase_auth/firebase_auth.dart';

class AuthenticationService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();

  Future<String?> signIn({required String email,required String password})async{
    try{
      await firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      return "Signed In Successfully";
    } on FirebaseAuthException catch(e){
      return e.message;
    }
  }

  Future<String?> signUp({required String email, required String password}) async {
    try{
      await firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      return "Signed Up Successfully";
    }on FirebaseAuthException catch(e){
      return e.message;
    }
  }
}