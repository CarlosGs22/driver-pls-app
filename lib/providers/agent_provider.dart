import 'package:driver_please_flutter/models/user.dart';
import 'package:flutter/cupertino.dart';

class UserProvider extends ChangeNotifier {
  User _user = User.agent();

  User get user => _user;

  void setUser(User user) async {
    _user = user;
    notifyListeners();
  }
}
