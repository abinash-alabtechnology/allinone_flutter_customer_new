import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:handy_allinone/features/favourite/controllers/favourite_controller.dart';
import 'package:handy_allinone/features/item/domain/models/item_model.dart';
import 'package:handy_allinone/helper/auth_helper.dart';
import 'package:handy_allinone/common/widgets/custom_snackbar.dart';


class AddFavouriteView extends StatefulWidget {
  final Item? item;
  final double? top, right;
  final double? left;
  final int? storeId;
  const AddFavouriteView({super.key, required this.item, this.top = 15, this.right = 15, this.left, this.storeId});

  @override
  State<AddFavouriteView> createState() => _AddFavouriteViewState();
}

class _AddFavouriteViewState extends State<AddFavouriteView> with SingleTickerProviderStateMixin {

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.top, right: widget.right, left: widget.left,
      child: GetBuilder<FavouriteController>(builder: (favouriteController) {
        bool isWished;
        if(widget.storeId != null) {
          isWished = favouriteController.wishStoreIdList.contains(widget.storeId);
        } else {
          isWished = favouriteController.wishItemIdList.contains(widget.item!.id);
        }
        return InkWell(
          onTap: favouriteController.isRemoving ? null : () {
            if(AuthHelper.isLoggedIn()) {
              if(widget.storeId != null) {
                isWished ? favouriteController.removeFromFavouriteList(widget.storeId, true) : favouriteController.addToFavouriteList(null, widget.storeId, true);
              } else {
                isWished ? favouriteController.removeFromFavouriteList(widget.item!.id, false) : favouriteController.addToFavouriteList(widget.item, null, false);
              }
            }else {
              showCustomSnackBar('you_are_not_logged_in'.tr);
            }
            _controller.reverse().then((value) => _controller.forward());
          },
          child: ScaleTransition(
            scale: Tween(begin: 0.7, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut)),
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                isWished ? CupertinoIcons.heart_solid : CupertinoIcons.heart,
                color: isWished ? Theme.of(context).primaryColor : Theme.of(context).primaryColor.withValues(alpha: 0.6),
                size: 18,
              ),
            ),
          ),
        );
      }),
    );
  }
}


class AddFavouriteView1 extends StatefulWidget {
  final Item? item;
  final double? top, right;
  final double? left;
  final int? storeId;
  const AddFavouriteView1({super.key, required this.item, this.top = 15, this.right = 15, this.left, this.storeId});

  @override
  State<AddFavouriteView1> createState() => _AddFavouriteView1State();
}

class _AddFavouriteView1State extends State<AddFavouriteView1> with SingleTickerProviderStateMixin {

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.top, right: widget.right, left: widget.left,
      child: GetBuilder<FavouriteController>(builder: (favouriteController) {
        bool isWished;
        if(widget.storeId != null) {
          isWished = favouriteController.wishStoreIdList.contains(widget.storeId);
        } else {
          isWished = favouriteController.wishItemIdList.contains(widget.item!.id);
        }
        return InkWell(
          onTap: favouriteController.isRemoving ? null : () {
            if(AuthHelper.isLoggedIn()) {
              if(widget.storeId != null) {
                isWished ? favouriteController.removeFromFavouriteList(widget.storeId, true) : favouriteController.addToFavouriteList(null, widget.storeId, true);
              } else {
                isWished ? favouriteController.removeFromFavouriteList(widget.item!.id, false) : favouriteController.addToFavouriteList(widget.item, null, false);
              }
            }else {
              showCustomSnackBar('you_are_not_logged_in'.tr);
            }
            _controller.reverse().then((value) => _controller.forward());
          },
          child: ScaleTransition(
            scale: Tween(begin: 0.7, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut)),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background heart (filled with cardColor)
                Icon(
                  CupertinoIcons.heart_solid,
                  color: Theme.of(context).cardColor,
                  size: 25,
                ),
                // Foreground heart (outline with primary color)
                Icon(
                  isWished ? CupertinoIcons.heart_solid : CupertinoIcons.heart,
                  color: Theme.of(context).primaryColor,
                  size: 25,
                ),
              ],
            ),
            // child: Icon(isWished ? CupertinoIcons.heart_solid : CupertinoIcons.heart, color: isWished ? Theme.of(context).primaryColor : Theme.of(context).primaryColor.withValues(alpha: 0.3), size: 25),
          ),
        );
      }),
    );
  }
}
class AddFavouriteView3 extends StatefulWidget {
  final Item? item;
  final double? top, right;
  final double? left;
  final int? storeId;
  const AddFavouriteView3({super.key, required this.item, this.top = 15, this.right = 15, this.left, this.storeId});

  @override
  State<AddFavouriteView3> createState() => _AddFavouriteView3State();
}

class _AddFavouriteView3State extends State<AddFavouriteView3> with SingleTickerProviderStateMixin {

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.top, right: widget.right, left: widget.left,
      child: GetBuilder<FavouriteController>(builder: (favouriteController) {
        bool isWished;
        if(widget.storeId != null) {
          isWished = favouriteController.wishStoreIdList.contains(widget.storeId);
        } else {
          isWished = favouriteController.wishItemIdList.contains(widget.item!.id);
        }
        return InkWell(
          onTap: favouriteController.isRemoving ? null : () {
            if(AuthHelper.isLoggedIn()) {
              if(widget.storeId != null) {
                isWished ? favouriteController.removeFromFavouriteList(widget.storeId, true) : favouriteController.addToFavouriteList(null, widget.storeId, true);
              } else {
                isWished ? favouriteController.removeFromFavouriteList(widget.item!.id, false) : favouriteController.addToFavouriteList(widget.item, null, false);
              }
            }else {
              showCustomSnackBar('you_are_not_logged_in'.tr);
            }
            _controller.reverse().then((value) => _controller.forward());
          },
          child: SvgPicture.asset(
              isWished?"assets/image/Frame1.svg":"assets/image/Frame.svg",
            height: 20,
            width: 20,
            // color:Colors.black
            // color: isWished? Theme.of(context).cardColor:Theme.of(context).primaryColor,
          ),
        );
      }),
    );
  }
}
class AddFavouriteView2 extends StatefulWidget {
  final Item? item;
  final double? top, right, left;
  final int? storeId;

  const AddFavouriteView2({
    super.key,
    required this.item,
    this.top = 15,
    this.right = 15,
    this.left,
    this.storeId,
  });

  @override
  State<AddFavouriteView2> createState() => _AddFavouriteView2State();
}

class _AddFavouriteView2State extends State<AddFavouriteView2>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: widget.top ?? 0,
        right: widget.right ?? 0,
        left: widget.left ?? 0,
      ),
      child: GetBuilder<FavouriteController>(
        builder: (favouriteController) {
          bool isWished;
          if (widget.storeId != null) {
            isWished =
                favouriteController.wishStoreIdList.contains(widget.storeId);
          } else {
            isWished =
                favouriteController.wishItemIdList.contains(widget.item!.id);
          }

          return InkWell(
            onTap: favouriteController.isRemoving
                ? null
                : () {
              if (AuthHelper.isLoggedIn()) {
                if (widget.storeId != null) {
                  isWished
                      ? favouriteController.removeFromFavouriteList(
                      widget.storeId, true)
                      : favouriteController.addToFavouriteList(
                      null, widget.storeId, true);
                } else {
                  isWished
                      ? favouriteController.removeFromFavouriteList(
                      widget.item!.id, false)
                      : favouriteController.addToFavouriteList(
                      widget.item, null, false);
                }
              } else {
                showCustomSnackBar('you_are_not_logged_in'.tr);
              }

              _controller.reverse().then((value) => _controller.forward());
            },
            child: ScaleTransition(
              scale: Tween(begin: 0.7, end: 1.0).animate(
                CurvedAnimation(
                  parent: _controller,
                  curve: Curves.easeOut,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background heart (card color)
                  Icon(
                    CupertinoIcons.heart_solid,
                    color: Theme.of(context).cardColor,
                    size: 25,
                  ),
                  // Foreground heart (primary color or outlined)
                  Icon(
                    isWished ? CupertinoIcons.heart_solid : CupertinoIcons.heart,
                    color: Theme.of(context).primaryColor,
                    size: 25,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class AddFavouriteView4 extends StatefulWidget {
  final Item? item;
  final double? top, right;
  final double? left;
  final int? storeId;
  const AddFavouriteView4({super.key, required this.item, this.top = 15, this.right = 15, this.left, this.storeId});

  @override
  State<AddFavouriteView4> createState() => _AddFavouriteView4State();
}

class _AddFavouriteView4State extends State<AddFavouriteView4> with SingleTickerProviderStateMixin {

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FavouriteController>(builder: (favouriteController) {
      bool isWished;
      if(widget.storeId != null) {
        isWished = favouriteController.wishStoreIdList.contains(widget.storeId);
      } else {
        isWished = favouriteController.wishItemIdList.contains(widget.item!.id);
      }
      return InkWell(
        onTap: favouriteController.isRemoving ? null : () {
          if(AuthHelper.isLoggedIn()) {
            if(widget.storeId != null) {
              isWished ? favouriteController.removeFromFavouriteList(widget.storeId, true) : favouriteController.addToFavouriteList(null, widget.storeId, true);
            } else {
              isWished ? favouriteController.removeFromFavouriteList(widget.item!.id, false) : favouriteController.addToFavouriteList(widget.item, null, false);
            }
          }else {
            showCustomSnackBar('you_are_not_logged_in'.tr);
          }
          _controller.reverse().then((value) => _controller.forward());
        },
        child: ScaleTransition(
          scale: Tween(begin: 0.7, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut)),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background heart (filled with cardColor)
              Icon(
                CupertinoIcons.heart_solid,
                color: Theme.of(context).cardColor,
                size: 25,
              ),
              // Foreground heart (outline with primary color)
              Icon(
                isWished ? CupertinoIcons.heart_solid : CupertinoIcons.heart,
                color: Theme.of(context).primaryColor,
                size: 25,
              ),
            ],
          ),
          // child: Icon(isWished ? CupertinoIcons.heart_solid : CupertinoIcons.heart, color: isWished ? Theme.of(context).primaryColor : Theme.of(context).primaryColor.withValues(alpha: 0.3), size: 25),
        ),
      );
    });
  }
}



class AddFavouriteViewCom extends StatefulWidget {
  final Item? item;
  final int? storeId;
  const AddFavouriteViewCom({super.key, required this.item, this.storeId});

  @override
  State<AddFavouriteViewCom> createState() => _AddFavouriteViewComState();
}

class _AddFavouriteViewComState extends State<AddFavouriteViewCom> with SingleTickerProviderStateMixin {

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FavouriteController>(builder: (favouriteController) {
      bool isWished;
      if(widget.storeId != null) {
        isWished = favouriteController.wishStoreIdList.contains(widget.storeId);
      } else {
        isWished = favouriteController.wishItemIdList.contains(widget.item!.id);
      }
      return InkWell(
        onTap: favouriteController.isRemoving ? null : () {
          if(AuthHelper.isLoggedIn()) {
            if(widget.storeId != null) {
              isWished ? favouriteController.removeFromFavouriteList(widget.storeId, true) : favouriteController.addToFavouriteList(null, widget.storeId, true);
            } else {
              isWished ? favouriteController.removeFromFavouriteList(widget.item!.id, false) : favouriteController.addToFavouriteList(widget.item, null, false);
            }
          }else {
            showCustomSnackBar('you_are_not_logged_in'.tr);
          }
          _controller.reverse().then((value) => _controller.forward());
        },
        child: ScaleTransition(
          scale: Tween(begin: 0.7, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut)),
          child: Icon(isWished ? CupertinoIcons.heart_solid : CupertinoIcons.heart, color: isWished ? Theme.of(context).primaryColor : Colors.grey, size: 20),
        ),
      );
    });
  }
}




class AddFavouriteViewItemDetails extends StatefulWidget {
  final Item? item;
  final int? storeId;
  const AddFavouriteViewItemDetails({super.key, required this.item, this.storeId});

  @override
  State<AddFavouriteViewItemDetails> createState() => _AddFavouriteViewItemDetailsState();
}

class _AddFavouriteViewItemDetailsState extends State<AddFavouriteViewItemDetails> with SingleTickerProviderStateMixin {

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FavouriteController>(builder: (favouriteController) {
      bool isWished;
      if(widget.storeId != null) {
        isWished = favouriteController.wishStoreIdList.contains(widget.storeId);
      } else {
        isWished = favouriteController.wishItemIdList.contains(widget.item!.id);
      }
      return InkWell(
        onTap: favouriteController.isRemoving ? null : () {
          if(AuthHelper.isLoggedIn()) {
            if(widget.storeId != null) {
              isWished ? favouriteController.removeFromFavouriteList(widget.storeId, true) : favouriteController.addToFavouriteList(null, widget.storeId, true);
            } else {
              isWished ? favouriteController.removeFromFavouriteList(widget.item!.id, false) : favouriteController.addToFavouriteList(widget.item, null, false);
            }
          }else {
            showCustomSnackBar('you_are_not_logged_in'.tr);
          }
          _controller.reverse().then((value) => _controller.forward());
        },
        child: ScaleTransition(
          scale: Tween(begin: 0.7, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut)),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: isWished ? Theme.of(context).primaryColor : Colors.grey.shade300,
            ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(isWished ? CupertinoIcons.heart_solid : CupertinoIcons.heart, color: isWished ? Theme.of(context).cardColor : Colors.grey, size: 20),
              )),
        ),
      );
    });
  }
}
