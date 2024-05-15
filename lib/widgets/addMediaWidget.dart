import 'package:flutter/material.dart';

class AddMediaWidget extends StatefulWidget {
  const AddMediaWidget(
      {Key? key,
      this.child,
      this.onTap,
      this.onTapCancel,
      this.isEmpty,
      this.docId,
      this.index,
      this.array})
      : super(key: key);

  final Widget? child;
  final Function()? onTap;
  final Function()? onTapCancel;
  final bool? isEmpty;
  final String? docId;
  final int? index;
  final List<dynamic>? array;

  @override
  _AddMediaWidgetState createState() => _AddMediaWidgetState();
}

class _AddMediaWidgetState extends State<AddMediaWidget> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 190,
            width: 120,
            color: Colors.black12,
            child: widget.child,
          ),
        ),
        Visibility(
          visible: widget.isEmpty!,
          child: Positioned(
            top: 0,
            left: 0,
            child: InkWell(
                onTap: widget.onTapCancel,
                child: const Icon(
                  Icons.highlight_remove_sharp,
                  color: Colors.black,
                )),
          ),
        ),
        Positioned(
          bottom: 5,
          right: 5,
          child: InkWell(
            onTap: widget.onTap,
            child: Image.asset(
              "assets/3x/Icon feather-plus-circle@3x.png",
              height: 25,
              width: 25,
            ),
          ),
        ),
      ],
    );
  }
}
