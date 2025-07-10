import 'package:permission_handler/permission_handler.dart';

Future<void> requestImagePermissions() async {
  // perr android 13+
  if (await Permission.photos.request().isDenied ||
      await Permission.camera.request().isDenied) {
    print('Permessi negati');
  }

  // dispositivi piu vecchi
  await Permission.storage.request();
}
