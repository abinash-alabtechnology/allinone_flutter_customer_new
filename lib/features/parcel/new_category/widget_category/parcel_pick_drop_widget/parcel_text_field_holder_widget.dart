import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:handy_allinone/util/app_constants.dart';
import 'package:handy_allinone/util/images.dart';

class TextfiledHolder extends StatelessWidget {
  final String hintText;
  final IconData iconData;
  final TextEditingController textEditingController;
  final bool wantMargin;
  final bool isPhone;
  final List<TextInputFormatter>? textInputFormatter;
  const TextfiledHolder(
      {super.key,
      required this.hintText,
      required this.iconData,
      required this.textEditingController,
      this.wantMargin = true,this.isPhone = false,this.textInputFormatter,});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: wantMargin ? const EdgeInsets.symmetric(horizontal: 12) : null,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        // border: Border.all(color: Colors.black54, width: 0.8),
      ),
      child: Row(
        children: [

          Flexible(
            child: TextField(
              onTapUpOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              controller: textEditingController,
              inputFormatters: textInputFormatter,
              decoration: InputDecoration(
                hintText: hintText,
                floatingLabelAlignment: FloatingLabelAlignment.start,
                floatingLabelStyle: const TextStyle(
                  fontFamily: AppConstants.fontFamily,
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  height: 1,
                ),
                labelStyle: const TextStyle(
                  fontFamily: AppConstants.fontFamily,
                  fontSize: 16,
                  color: Colors.black38,
                  fontWeight: FontWeight.w500,
                  height: 1,
                ),
                label: Text(
                  hintText,
                  maxLines: 2,
                ),
                prefixIcon: isPhone ? _leadingIcon() : Icon(
    iconData,
    color: Colors.pink,
    ),
                contentPadding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                disabledBorder: _inputBorder(),
                border: _inputBorder(),
                focusedBorder: _inputfocusBorder(context),
                enabledBorder: _inputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _leadingIcon() => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 10),
          Image.asset(
            Images.indian,
            height: 25,
            width: 25,
          ),
          const SizedBox(width: 4),
          const Text(
            "+91",
            style: TextStyle(color: Colors.black87),
          ),
          const SizedBox(
            height: 20,
            child: VerticalDivider(
              thickness: 1.5,
              color: Colors.grey,
            ),
          ),
        ],
      );

  OutlineInputBorder _inputBorder() => OutlineInputBorder(
        gapPadding: 10,
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colors.grey.shade200,
          width: 0.5,
          style: BorderStyle.solid,
        ),
      );

  OutlineInputBorder _inputfocusBorder(context) => OutlineInputBorder(
        gapPadding: 10,
        borderRadius: BorderRadius.circular(11.3),
        borderSide: BorderSide(
          color: Theme.of(context).primaryColor,
          width: 1.1,
          style: BorderStyle.solid,
        ),
      );
}
