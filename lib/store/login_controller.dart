import 'package:get/get.dart';

class FormController extends GetxController {
  String? phone = '';
  String? password = '';
  late Map<String, dynamic> session = {
    'session': false,
  };

  void setPhone(String value) {
    phone = value;
    update();
  }
  void setPassword(String value) {
    password = value;
    update();
  }

  void setSession(dynamic value) {
    session = value;
    update();
  }

  void reset() {
    phone = '';
    password = '';
    session = {
      'session' : false
    };
  }
}
