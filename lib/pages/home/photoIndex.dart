import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../providers/photos.dart';

part 'photoIndex.g.dart';

@Riverpod(keepAlive: true)
class PhotoIndex extends _$PhotoIndex{
  int _maxLenght = 0;

  @override
  int build() {
    _maxLenght = ref.watch(photosProvider.select((value) => value.length));
    return 0;
  }

  void update(int Function(int state) update) {
    state = (update(state) + _maxLenght) % _maxLenght;
  }

}
