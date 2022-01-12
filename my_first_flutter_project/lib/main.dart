//import 'dart:ffi';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'mynextscreen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final urlImages = [
    'https://images.unsplash.com/photo-1456926631375-92c8ce872def?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8NHx8bGVvcGFyZHN8ZW58MHx8MHx8&w=1000&q=80',
    'https://images.unsplash.com/photo-1561731216-c3a4d99437d5?ixlib=rb-1.2.1'
  ];

  bool empty = true;
  late XFile? _Ximage;
  late File _image;

  Future getImageFromCamera() async {
    var image = await ImagePicker().pickImage(source: ImageSource.camera);

    setState(() {
      empty = false;
      _Ximage = image;
      _image = File(_Ximage!.path);
    });
  }

  Future getImageFromGallery() async {
    var image = await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      empty = false;
      _Ximage = image;
      _image = File(_Ximage!.path);
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Center(
          child: Text(
            "Image Picker",
            style: TextStyle(fontSize: 30),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 200.0,
            child: Center(
              child: empty == true ? Text('No image') : Image.file(_image),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            FloatingActionButton(
              onPressed: getImageFromCamera,
              tooltip: "Pick Image form gallery",
              child: Icon(Icons.add_a_photo),
            ),
            FloatingActionButton(
              onPressed: getImageFromGallery,
              tooltip: "Pick Image from camera",
              child: Icon(Icons.camera_alt),
            )
          ],
        ),
        Center(
          child: InkWell(
            child: Ink.image(
              image: NetworkImage(urlImages[0]),
              height: 300,
              fit: BoxFit.cover,
            ),
            onTap: openGallery,
          ),
        ),
      ],
    ),
  );

  void openGallery() => Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => GalleryWidget(
        urlImages: urlImages,
        index: 0,
      ),
  ));
}

class GalleryWidget extends StatefulWidget {
  final PageController pageController;
  final List<String> urlImages;
  final int index;

  GalleryWidget({
    required this.urlImages,
    this.index = 0,
  }) : pageController = PageController(initialPage: index);

  @override
  State<StatefulWidget> createState() => _GalleryWidgetState();
}

class _GalleryWidgetState extends State<GalleryWidget> {
  late int index = widget.index;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(
      alignment: Alignment.bottomLeft,
      children: [
        PhotoViewGallery.builder(
          pageController: widget.pageController,
          itemCount: widget.urlImages.length,
          builder: (context, index) {
            final urlImage = widget.urlImages[index];

            return PhotoViewGalleryPageOptions(
              imageProvider: NetworkImage(urlImage),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.contained * 4,
            );
          },
          onPageChanged: (index) => setState(() => this.index = index),
        ),
        Container(
          padding: EdgeInsets.all(16),
          child: Text(
            'Image ${index + 1}/${widget.urlImages.length}',
            style: TextStyle(color: Colors.white, fontSize: 1)
          ),
        ),
      ],
    ),
  );
}