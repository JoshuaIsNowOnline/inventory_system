// 部署配置檔
// 將此檔案重命名為 config.dart 並替換 api_service.dart 中的 URL 配置

class AppConfig {
  // 🏠 本地開發環境
  static const String LOCAL_BASE_URL = 'http://127.0.0.1:7000';
  
  // 🏪 店內網路環境 (替換為店內電腦的實際 IP)
  static const String STORE_BASE_URL = 'http://192.168.1.100:7000';
  
  // ☁️ 雲端部署環境 (替換為實際的雲端 URL)
  static const String CLOUD_BASE_URL = 'https://your-app.railway.app';
  
  // 🔧 當前使用的環境
  static const Environment CURRENT_ENV = Environment.STORE;
}

enum Environment {
  LOCAL,    // 開發測試
  STORE,    // 店內網路  
  CLOUD,    // 雲端部署
}

// 在 ApiService 中使用：
// String get baseUrl {
//   switch (AppConfig.CURRENT_ENV) {
//     case Environment.LOCAL:
//       return AppConfig.LOCAL_BASE_URL;
//     case Environment.STORE:  
//       return AppConfig.STORE_BASE_URL;
//     case Environment.CLOUD:
//       return AppConfig.CLOUD_BASE_URL;
//   }
// }