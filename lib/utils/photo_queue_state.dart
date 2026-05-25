import '../models/photo.dart';
import 'status.dart';

bool shouldAdvancePhotoIndex(int index, int total, int change) {
  if (total <= 0) {
    return false;
  }
  if (change > 0 && index >= total - 1) {
    return false;
  }
  return true;
}

bool allPhotosProcessed(Iterable<Photo> photos) {
  return photos.isNotEmpty &&
      photos.every((photo) => photo.status != Status.none);
}
