import 'config/app_config.dart';
import 'config/cleveland_config.dart';
import 'services/art_api.dart';
import 'services/cleveland_api.dart';
import 'main.dart';

void main() {
  appConfig = clevelandConfig;
  artApi = ClevelandApi();
  startApp();
}
