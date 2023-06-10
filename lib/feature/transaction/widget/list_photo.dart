import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:monsey/app/widget_support.dart';
import 'package:monsey/common/constant/colors.dart';
import 'package:monsey/common/constant/images.dart';
import 'package:monsey/common/constant/styles.dart';
import 'package:monsey/common/widget/animation_click.dart';
import 'package:monsey/translations/export_lang.dart';
import 'package:photo_manager/photo_manager.dart';

const ThumbnailOption option = ThumbnailOption(
    size: ThumbnailSize.square(200), format: ThumbnailFormat.png);
const int _sizePerPage = 50;
const int _sizePerPageAll = 1000;

class ListPhoto extends StatefulWidget {
  const ListPhoto({Key? key}) : super(key: key);

  @override
  State<ListPhoto> createState() => _ListPhotoState();
}

class _ListPhotoState extends State<ListPhoto>
    with SingleTickerProviderStateMixin {
  late TabController _controller;
  List<AssetEntity> _recentPhoto = [];
  List<AssetEntity> _allPhotos = [];
  List<String> tabs = [LocaleKeys.recentPhotos.tr(), LocaleKeys.allPhotos.tr()];
  XFile? imageFile;

  Future<void> getPhotoRecent() async {
    final PermissionState result = await PhotoManager.requestPermissionExtend();
    if (result.isAuth) {
      if (result.hasAccess) {
        final List<AssetPathEntity> listRecent =
            await PhotoManager.getAssetPathList(type: RequestType.image);
        final assetListRecent =
            await listRecent[0].getAssetListPaged(page: 0, size: _sizePerPage);
        final List<AssetPathEntity> listAll =
            await PhotoManager.getAssetPathList(
                type: RequestType.image, hasAll: true, onlyAll: true);
        final assetListAll =
            await listAll[0].getAssetListPaged(page: 0, size: _sizePerPageAll);

        setState(() {
          _recentPhoto = assetListRecent;
          _allPhotos = assetListAll;
        });
      }
    }
  }

  Future<void> takeAPhoto() async {
    imageFile = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 90);
    if (imageFile != null) {
      final File file = File(imageFile!.path);
      final Uint8List bytes = file.readAsBytesSync();
      if (bytes.lengthInBytes / (1024 * 1024) >= 5) {
        ScaffoldMessenger.of(context).showSnackBar(
          AppWidget.customSnackBar(
              content: 'Please choose photo has size less than 5 MB',
              milliseconds: 1000),
        );
        Navigator.of(context).pop();
      } else {
        Navigator.of(context).pop(bytes);
      }
    }
  }

  Widget itemView(List<AssetEntity> photos) {
    return GridView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      itemCount: photos.isNotEmpty ? photos.length + 1 : 1,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: 1,
          crossAxisCount: 4,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8),
      itemBuilder: (context, index) {
        return index == 0
            ? AnimationClick(
                function: takeAPhoto,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: grey4, borderRadius: BorderRadius.circular(8)),
                  child: Image.asset(icCamera),
                ),
              )
            : photos.isNotEmpty
                ? GestureDetector(
                    onTap: () async {
                      final File? imageFile = await photos[index - 1].file;
                      final Uint8List bytes = imageFile!.readAsBytesSync();
                      Navigator.of(context).pop(bytes);
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: AssetEntityImage(
                        photos[index - 1],
                        isOriginal: false,
                        thumbnailSize: option.size,
                        thumbnailFormat: option.format,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                : const SizedBox();
      },
    );
  }

  @override
  void initState() {
    _controller = TabController(length: 2, vsync: this, initialIndex: 0);
    getPhotoRecent();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
            padding: const EdgeInsets.only(top: 24),
            child: TabBar(
                controller: _controller,
                onTap: (value) {},
                labelStyle: headline(color: purplePlum),
                unselectedLabelStyle: body(color: grey4),
                labelColor: purplePlum,
                unselectedLabelColor: grey4,
                indicatorColor: white,
                indicatorWeight: 2,
                tabs: List.generate(
                  tabs.length,
                  (index) => Align(
                    alignment: index == 0
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    child: Tab(
                      text: tabs[index],
                    ),
                  ),
                ))),
        Expanded(
          child: TabBarView(
              controller: _controller,
              children: [itemView(_recentPhoto), itemView(_allPhotos)]),
        )
      ],
    );
  }
}
