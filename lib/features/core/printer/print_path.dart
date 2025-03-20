class PrintPath {
  String? frontPath;
  String? backPath;

  PrintPath({this.frontPath, this.backPath});

  Map<String, dynamic> toMap() {
    return {
      'frontPath': frontPath,
      'backPath': backPath,
    };
  }

  // ✅ `Map<String, dynamic>`을 다시 `PrintPath` 객체로 변환
  factory PrintPath.fromMap(Map<String, dynamic> map) {
    return PrintPath(
      frontPath: map['frontPath'],
      backPath: map['backPath'],
    );
  }
}

class PrintParam {
  String? frontPath;
  String? backPhotoImageUrl;

  PrintParam({this.frontPath, this.backPhotoImageUrl});
}
