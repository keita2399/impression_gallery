/// ビルド時に --dart-define=BOT_BASE_URL=https://... で上書き可能
const String kBotBaseUrl = String.fromEnvironment(
  'BOT_BASE_URL',
  defaultValue: 'https://sanpo-bot.vercel.app',
);
