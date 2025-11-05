# 庫存管理系統 - 應用打包工具
cd "$(dirname "$0")/frontend/inventory_app"

echo "庫存管理系統 - 應用打包工具"
echo "================================"
echo ""
echo "選擇打包類型:"
echo "1. Android APK (所有 Android 手機適用)"  
echo "2. 網頁版 (iPhone Safari 適用)"
echo "3. macOS 桌面版"
echo ""

read -p "請輸入選項 (1-3): " choice

case $choice in
  1)
    echo ""
    echo "正在構建 Android APK..."
    flutter clean
    flutter pub get
    flutter build apk --release
    echo ""
    echo "✅ APK 已生成: build/app/outputs/flutter-apk/app-release.apk"
    echo "📱 請將此檔案傳送到 Android 手機並安裝"
    ;;
  2)  
    echo ""
    echo "正在構建網頁版..."
    flutter clean
    flutter pub get
    flutter build web --release
    echo ""
    echo "✅ 網頁版已生成: build/web/"
    echo "🌐 將此資料夾上傳到網頁伺服器"
    echo "📱 iPhone 用戶可透過 Safari 訪問"
    ;;
  3)
    echo ""
    echo "正在構建 macOS 桌面版..."
    flutter clean
    flutter pub get
    flutter build macos --release
    echo ""
    echo "✅ macOS 應用已生成: build/macos/Build/Products/Release/"
    echo "💻 可直接在 macOS 電腦上運行"
    ;;
  *)
    echo "無效選項"
    ;;
esac

echo ""
read -p "按任意鍵繼續..."