echo "Welcome to flutter utilities:"
echo
echo "[1] build runner"
echo "[2] build runner --delete-conflicting-outputs"
echo "[3] generate localization files"
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

    *)
    echo "Unknown command!!"
    ;;
esac
