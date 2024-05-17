import 'package:get/get.dart';

class FormController extends GetxController {
  String? phone;
  String? password;

  void setPhone(String value) {
    phone = value;
    update();
  }
  void setPassword(String value) {
    password = value;
    update();
  }
}
