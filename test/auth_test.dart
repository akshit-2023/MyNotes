// ignore_for_file: non_constant_identifier_names

import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/auth_user.dart';
import 'package:test/test.dart';

void main(){
  group('Mock Authentication',(){
    final provider=MockAuthProvider();
    test('should not be initialized to begin with', (){
      expect(provider.isInitialized, false);
    });


    test("cannot logout if not initialized", (){
      expect(
        provider.logOut(),
        throwsA(const TypeMatcher<NotInitializedException>())//checks that NotInitializedException is thrown
      );
    });

    test('Should be able to be initialozed', () async {
      await provider.Initialize();
      expect(provider.isInitialized, true);
    });

    test('user should be null after initialization', (){
      expect(provider.currentUser, null);
    });

    test('should be able to initialize in less than 2 seconds', ()async{
      await provider.Initialize();
      expect(provider.isInitialized, true);

    },timeout: const Timeout(Duration(seconds: 2)));

    test('create user should delegate to logIn fucntion', () async {
      final badEmailUser = provider.createUser(email: 'foo@bar.com', password: 'sadasd');

      expect(badEmailUser, throwsA(const TypeMatcher<UserNotFoundAuthException>()));

      final badPasswordUser=provider.createUser(email: 'someone@bar.com', password: 'foobar');
      
      expect(badPasswordUser, throwsA(TypeMatcher<WrongPasswordAuthException>()));

      final user = await provider.createUser(email: 'foo', password: 'bar');

      expect(provider.currentUser, user);

      expect(user.isEmailVerified, false);
    });

    test('Logged in user should be able to get verified', (){
      provider.sendEmailVerification();
      final user=provider.currentUser;
      expect(user,isNotNull);//isNotNull is a matcher
      expect(user!.isEmailVerified,true);
    });

    test('should be able to log out and log in again',() async {
      await provider.logOut();
      await provider.logIn(email: 'email', password: 'password');

      final user=provider.currentUser;
      expect(user,isNotNull);
    });
  });    
}

class NotInitializedException implements Exception{

}
class MockAuthProvider implements AuthProvider{
  AuthUser? _user;
  var _isInitialized=false;
    bool get isInitialized => _isInitialized;
  
  @override
  Future<void> Initialize() async{
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized=true;
  }

  @override
  Future<AuthUser> createUser({required String email, required String password}) async {
    if(!isInitialized) throw NotInitializedException();
    Future.delayed(const Duration(seconds: 1));
    return logIn(email: email, password: password);
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<AuthUser> logIn({required String email, required String password}) {
    if(!isInitialized) throw NotInitializedException();
    if(email=='foo@bar.com') throw UserNotFoundAuthException();
    if(password=='foobar') throw WrongPasswordAuthException();
    const user=AuthUser(isEmailVerified: false);
    _user=user;
    return Future.value(user);
  }

  @override
  Future<void> logOut() async {
    if(!isInitialized) throw NotInitializedException();
    if(_user==null) throw UserNotFoundAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user=null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if(!isInitialized) throw NotInitializedException();
    final user=_user;
    if(user==null) throw UserNotFoundAuthException();
    const newUser=AuthUser(isEmailVerified: true);
    _user=newUser;
  }

}