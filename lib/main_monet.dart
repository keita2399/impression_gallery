import 'config/app_config.dart';
import 'config/monet_config.dart';
import 'services/art_api.dart';
import 'services/monet_api.dart';
import 'main.dart';

void main() {
  appConfig = monetConfig;
  artApi = MonetApi();
  startApp();
}
