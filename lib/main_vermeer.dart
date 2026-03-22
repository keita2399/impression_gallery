import 'config/app_config.dart';
import 'config/vermeer_config.dart';
import 'services/art_api.dart';
import 'services/vermeer_api.dart';
import 'main.dart';

void main() {
  appConfig = vermeerConfig;
  artApi = VermeerApi();
  startApp();
}
