import 'package:safe_zone/app/app.dart';
import 'package:safe_zone/bootstrap.dart';

void main() {
  bootstrap((sharedPreferences) => App(sharedPreferences: sharedPreferences));
}
