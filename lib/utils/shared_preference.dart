import 'package:driver_please_flutter/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  Future<bool> saveUser(User user) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString('id_con', user.id);
    prefs.setString('name', user.name);
    prefs.setString('lastName', user.lastName);
    prefs.setString('email', user.email);
    prefs.setString('mobile', user.mobile);
    prefs.setString('country', user.country);
    prefs.setString('state', user.state);
    prefs.setString('city', user.city);
    prefs.setString('status', user.status);
    prefs.setString('comission', user.comission);
    prefs.setString('ratekm', user.rateKm);
    prefs.setString('rateM', user.rateM);
    prefs.reload();
    return true;
  }

  Future<User> getUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String userId = prefs.getString("id_con").toString();
    String name = prefs.getString("name").toString();
    String lastName = prefs.getString("lastName").toString();
    String email = prefs.getString("email").toString();
    String mobile = prefs.getString("mobile").toString();
    String country = prefs.getString("country").toString();
    String state = prefs.getString("state").toString();
    String city = prefs.getString("city").toString();
    String status = prefs.getString("status").toString();
    String comission = prefs.getString("comission").toString();
    String ratekm = prefs.getString("ratekm").toString();
    String rateM = prefs.getString("rateM").toString();

    var agent = User(
        id: userId,
        name: name,
        lastName: lastName,
        email: email,
        mobile: mobile,
        country: country,
        state: state,
        city: city,
        status: status,
        comission: comission,
        rateKm: ratekm,
        rateM: rateM);
    return agent;
  }

  void removeUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<bool> saveValueUser(var key, var value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, "");
    prefs.reload();
    return true;
  }
}
