import 'package:flutter_snaptag_kiosk/domain/models/photo/front_photo.dart';

abstract interface class IFrontPhotoService {
  Future<FrontPhoto> getRandomPhoto();
}
