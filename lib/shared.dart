import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceHelper{

  static String userIdKey = "USERKEY";
  static String userNameKey = "USERNAMEKEY";
  static String displayNamekey  = "USERDISPLAYNAMEKEY";
  static String useremailKey = "USEREMAILKEY";
  static String userProfileKey = "USERPROFILEKEY";

  Future<bool> saveUserName(String getUserName) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userNameKey, getUserName);
  }

  Future<bool> saveUserEmail(String getUseremail) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(useremailKey, getUseremail);
  }

  Future<bool> saveUserId(String getUserId) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userIdKey, getUserId);
  }

  Future<bool> saveDisplayName (String getDisplayName) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(displayNamekey, getDisplayName);
  }

  Future<bool> saveUserProfileUrl (String getUserProfile) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userProfileKey,getUserProfile);
  }

  //get data
  Future<String> getUserName() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userNameKey);
  }

  Future<String> getUserEmail() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(useremailKey);
  }

  Future<String> getUserId() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userIdKey);
  }

  Future<String> getDisplaName() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(displayNamekey);
  }

  Future<String> getUserProfileUrl() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userProfileKey);
  }
}