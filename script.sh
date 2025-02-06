echo "Welcome to flutter utilities:"
echo
echo "[1] build runner"
echo "[2] build runner --delete-conflicting-outputs"
echo "[3] generate localization files"
echo "[4] flutter build windows --debug"
echo "[5] flutter build windows --release"
echo "[6] flutter create . --platforms windows"
read -p "Run: " selection

case $selection in
    1)
    echo "Running build_runner"
    dart run build_runner build
    ;;

    2)
    echo "Running build_runner with --delete-conflicting-outputs"
    dart run build_runner build --delete-conflicting-outputs
    ;;

    3)
    echo "Generating localization files"
    dart run easy_localization:generate -S assets/lang -O lib/localization -f keys -o locale_keys.g.dart
    ;;

    4)
    echo "Building Flutter for Windows in debug mode"
    flutter build windows --debug
    ;;

  
    5)
    echo "Building Flutter for Windows in release mode"
    flutter build windows --release
    ;;
    6)
    echo "Creating Flutter project for Windows platform"
    flutter create . --platforms windows
    ;;

    *)
    echo "Unknown command!!"
    ;;
esac

# Windows에서 스크립트 실행 방법
# PowerShell 명령어를 사용하여 스크립트에 실행 권한 부여
# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
# 스크립트 실행
#.\script.sh

# macOS에서 스크립트 실행 방법
# 터미널 명령어를 사용하여 스크립트에 실행 권한 부여
# chmod +x script.sh
# 스크립트 실행
# ./script.sh
