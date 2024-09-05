// ignore_for_file: file_names, must_be_immutable

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommonButton extends StatelessWidget {
  Border? border;
  Color? bgColor;
  String? image;
  TextStyle? textStyle;
  Function()? onTap;
  String? text;
  CommonButton({Key? key, this.text, this.onTap, this.image, this.bgColor, this.border, this.textStyle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(left: 10, right: 10),
        height: Get.height * 0.06,
        width: Get.width,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(5),
          border: border,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            image != null
                ? Image.asset(
                    image!,
                    height: 22,
                  )
                : const SizedBox(),
            image != null
                ? const SizedBox(
                    width: 10,
                  )
                : const SizedBox(),
            Text(text!, style: textStyle),
          ],
        ),
      ),
    );
  }
}

class CommonPopUpButton extends StatelessWidget {
  TextStyle? style;
  Decoration? decoration;
  Color? color;

  String? text;
  CommonPopUpButton({Key? key, required this.text, this.style, this.color, this.decoration}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 37,
      width: Get.width,
      decoration: decoration,
      // BoxDecoration(color: AppColor.white_Color,borderRadius: BorderRadius.circular(5)
      child: Center(
          child: Text(text!, style: style
              // TextStyle(
              //     overflow: TextOverflow.clip,
              //     decoration: TextDecoration.none,
              //     fontSize: 14,
              //     color: AppColor.dark_grey,
              //     fontFamily: "Roboto")
              )),
    );
  }
}
