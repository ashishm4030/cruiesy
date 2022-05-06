import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();

String? gName;
String? gEmail;
String? gProfilePic;
String? googleAuth;

Future<String> signInWithGoogle() async {
  await Firebase.initializeApp();

  final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
  final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount!.authentication;

  final AuthCredential credential = GoogleAuthProvider.credential(
    accessToken: googleSignInAuthentication.accessToken,
    idToken: googleSignInAuthentication.idToken,
  );

  final UserCredential authResult = await _auth.signInWithCredential(credential);
  final User? user = authResult.user;

  if (user != null) {
    assert(user.email != null);
    assert(user.displayName != null);
    assert(user.photoURL != null);
    assert(user.uid.isEmpty || user.uid != null);

    gName = user.displayName;
    gEmail = user.email;
    gProfilePic = user.photoURL;
    googleAuth = user.uid;

    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final User? currentUser = _auth.currentUser;
    assert(user.uid == currentUser!.uid);

    print('Sign In With Google Succeeded: $user');
    print('Sign In With Google AuthToken: ${googleSignInAuthentication.accessToken}');
    return '$user';
  }
  return '';
}

Future<void> signOutGoogle() async {
  await googleSignIn.signOut();
}
