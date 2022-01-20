import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

const Color colorBar = Color(0xFF23272A);
const Color colorBg = Color(0xFF2C2F33);
const Color colorText = Color(0xFF99AAB5);
const Color colorText2 = Color(0xFF5865F2);
const Color colorLoadImg = Color(0xFF404EED);

void main() {
  runApp(
    Phoenix(
      child: MyApp(),
    ),
  );
}

//Homepage: Folders

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Album>? _albums;
  bool loading= false;

  @override
  void initState() {
    super.initState();
    loading = true;
    initAsync();
  }

  Future<void> initAsync() async {
    if (await _promptPermissionSetting()) {
      List<Album> albums =
      await PhotoGallery.listAlbums(mediumType: MediumType.image);
      setState(() {
        _albums = albums;
        loading = false;
      });
    }
    setState(() {
      loading = false;
    });
  }

  Future<bool> _promptPermissionSetting() async {
    if (Platform.isIOS &&
      await Permission.storage.request().isGranted &&
      await Permission.photos.request().isGranted ||
      Platform.isAndroid && await Permission.storage.request().isGranted) {
        return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gallery App',
      home: Scaffold(
        backgroundColor: colorBg,
        appBar: AppBar(
          backgroundColor: colorBar,
          title: const Text(
              'Gallery',
              style: TextStyle(
                  fontSize: 24.0,
                  color: colorText
              ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => Phoenix.rebirth(context),
              tooltip: 'Refresh',
              //color: colorText2
            ),
          ]
        ),
        body: loading ? const Center(
          child: CircularProgressIndicator(),
        ) :
        LayoutBuilder(
          builder: (context, constraints) {
            double gridW = (constraints.maxWidth) / 2;
            double gridH = gridW;
            return Container(
              padding: EdgeInsets.all(0),
              child: GridView.count(
                crossAxisCount: 2,
                children: <Widget>[
                  ...?_albums?.map(
                    (album) => GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => AlbumPage(album)
                        )
                      ),
                      child: Column(
                        children: <Widget>[
                          ClipRRect(
                            child: Container(
                              height: gridH - 40,
                              width: gridW,
                              child: FadeInImage(
                                fit: BoxFit.cover,
                                placeholder: MemoryImage(kTransparentImage),
                                image: AlbumThumbnailProvider(
                                  albumId: album.id,
                                  mediumType: album.mediumType,
                                  highQuality: true,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            alignment: Alignment.topLeft,
                            padding: EdgeInsets.only(left: 3.0),
                            child: Text(
                              album.name ?? "Unnamed Album",
                              textAlign: TextAlign.start,
                              maxLines: 1,
                              style: const TextStyle(
                                height: 1.25,
                                fontSize: 16.0,
                                color: colorText
                              ),
                            ),
                          ),
                          Container(
                            alignment: Alignment.topLeft,
                            padding: EdgeInsets.only(left: 3.0),
                            child: Text(
                              album.count.toString(),
                              textAlign: TextAlign.start,
                              maxLines: 1,
                              style: const TextStyle(
                                height: 1.2,
                                fontSize: 16.0,
                                color: colorText2
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

//Folder: Images

class AlbumPage extends StatefulWidget {
  final Album album;

  AlbumPage(Album album) : album = album;

  @override
  State<StatefulWidget> createState() => AlbumPageState();
}

class AlbumPageState extends State<AlbumPage> {
  List<Medium>? media;

  @override
  void initState() {
    super.initState();
    initAsync();
  }

  void initAsync() async {
    MediaPage imagePage = await widget.album.listMedia();
    setState(() {
      media = imagePage.items;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gallery App',
      home: Scaffold(
        backgroundColor: colorBg,
        appBar: AppBar(
          backgroundColor: colorBar,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_outlined),
            onPressed: () => Navigator.of(context).pop(),
            //onPressed: () => Phoenix.rebirth(context),
            tooltip: 'Back',
          ),
          title: Text(
            widget.album.name ?? "Untitled",
            style: const TextStyle(
              fontSize: 22.0,
              color: colorText
            ),
          ),
        ),
        body: GridView.count(
          crossAxisCount: 2,
          children: <Widget>[
            ...?media?.map(
                  (medium) => GestureDetector(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ViewerPage(medium))),
                child: Container(
                  color: colorLoadImg,
                  child: FadeInImage(
                    fit: BoxFit.cover,
                    placeholder: MemoryImage(kTransparentImage),
                    image: ThumbnailProvider(
                      mediumId: medium.id,
                      mediumType: medium.mediumType,
                      highQuality: true,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//Viewing Image

class ViewerPage extends StatelessWidget {
  final Medium medium;

  ViewerPage(Medium medium) : medium = medium;

  @override
  Widget build(BuildContext context) {
    DateTime? date = medium.creationDate ?? medium.modifiedDate;
    String? name = medium.filename;

    return MaterialApp(
      home: Scaffold(
        backgroundColor: colorBg,
        appBar: AppBar(
          backgroundColor: colorBar,
          leading: Row(
            children: <Widget>[
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_outlined),
                tooltip: 'Back',
              ),
            ]
          ),
          actions: [
            Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  FittedBox(
                    fit: BoxFit.contain,
                    child: Text(
                      name.toString(),
                      style: const TextStyle(
                          fontSize: 20.0,
                          color: colorText
                      ),
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.contain,
                    child: Text(
                      date!.toLocal().toString(),
                      style: const TextStyle(
                          fontSize: 15.0,
                          color: colorText2
                      ),
                    ),
                  ),
                ]
            ),
            Padding(padding: EdgeInsets.fromLTRB(0, 0, 20, 0))
          ]
        ),
        body: Container(
          alignment: Alignment.center,
          child: InteractiveViewer(
            scaleEnabled: true,
            panEnabled: true,
            minScale: 0.5,
            maxScale: 4.0,
            child: FadeInImage(
              fit: BoxFit.cover,
              placeholder: MemoryImage(kTransparentImage),
              image: PhotoProvider(mediumId: medium.id),
            )
          )
        ),
      ),
    );
  }
}