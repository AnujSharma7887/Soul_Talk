import 'package:flutter/material.dart';

class MyInputAlertBox extends StatelessWidget {
  final TextEditingController textController;
  final String hintText;
  final void Function()? onPressed;
  final String onPressedText;

  const MyInputAlertBox({
    super.key,
    required this.textController,
    required this.hintText,
    required this.onPressed,
    required this.onPressedText,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      content: SizedBox(
        width: 270,
        child: TextField(
          controller: textController,
          maxLength: 200,
          maxLines: 5,
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Theme.of(context).colorScheme.tertiary),
                borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.onPrimary),
              borderRadius: BorderRadius.circular(12),
            ),
            hintText: hintText,
            hintStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
            fillColor: Theme.of(context).colorScheme.secondary,
            filled: true,
            counterStyle: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 15,
            ),
          ),
        ),
      ),

      //button
      actions: [
        //cancel button
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            textController.clear();
          },
          child: const Text("Cancel"),
        ),
        //save button
        TextButton(
            onPressed: () {
              //clear box
              Navigator.pop(context);
              //execute function
              onPressed!();

              //clear controller
              textController.clear();
            },
            child: Text(
              onPressedText,
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            )),
      ],
    );
  }
}
