import 'dart:developer';

import 'package:agora/utils/color_constant.dart';
import 'package:flutter/material.dart';

class ButtonComponent extends StatelessWidget {
  const ButtonComponent({
    super.key,
    required this.text,
    required this.onPressed,
    this.buttonColor = Colors.lightBlue,
    this.fontSize,
    this.borderRadius,
    this.boxShadow,
    this.prefixWidget,
    this.suffixIcon,
    this.iconColor = Colors.white,
    this.textColor = Colors.white,
    this.isDisabled = false,
    this.isLoading = false,
    this.buttonLoadingColor,
    this.height,
    this.width,
    this.fontWeight,
    this.side,
    this.padding,
    this.autoWidth = true,
  });

  final String text;
  final void Function()? onPressed;
  final Color buttonColor;
  final double? fontSize;
  final double? borderRadius;
  final BoxShadow? boxShadow;
  final Widget? prefixWidget;
  final IconData? suffixIcon;
  final Color iconColor;
  final Color? textColor;
  final bool isDisabled;
  final bool isLoading;
  final Color? buttonLoadingColor;
  final double? height;
  final double? width;
  final FontWeight? fontWeight;
  final BorderSide? side;
  final EdgeInsetsGeometry? padding;

  ///if its disable auto width based on button content
  final bool autoWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 49,
      width: width ?? (autoWidth ? MediaQuery.sizeOf(context).width : null),
      child: TextButton(
        onPressed:
            isDisabled
                ? () {
                  log('here');
                }
                : isLoading
                ? null
                : onPressed,
        style: TextButton.styleFrom(
          side: side,
          padding: padding,
          backgroundColor:
              isDisabled ? Colors.grey.shade400 : ColorConstant.primaryColor,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 15),
          ),
        ),
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            Visibility(
              visible: !isLoading,
              maintainSize: true,
              maintainState: true,
              maintainAnimation: true,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (prefixWidget != null) ...[
                    prefixWidget!,
                    const SizedBox(width: 5),
                  ],
                  Text(text),
                  if (suffixIcon != null) ...[
                    const SizedBox(width: 5),
                    Icon(suffixIcon),
                  ],
                ],
              ),
            ),
            if (isLoading) CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
