echo "Welcome to flutter utilities:"
echo
echo "[1] build runner"
echo "[2] build runner --delete-conflicting-outputs"
read -p "Run: " selection

case $selection in
    1)
    echo "build_runner"
    dart run build_runner build
    ;;

    2)
    echo "build_runner"
    dart run build_runner build --delete-conflicting-outputs
    ;;

    *)
    echo "Unknown command!!"
    ;;
esac
