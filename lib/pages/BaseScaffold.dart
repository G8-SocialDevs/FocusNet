import 'package:flutter/material.dart';
import 'package:focusnet/pages/CustomAppBar.dart'; // Ajusta la ruta del archivo

class BaseScaffold extends StatelessWidget {
  final Widget titleWidget; 
  final Widget body; 

  const BaseScaffold({
    Key? key,
    required this.titleWidget,
    required this.body,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(titleWidget: titleWidget),
      body: body, 
    );
  }
}
