import 'package:flutter/material.dart';
import '../main.dart';
import '../scanner/text_detector_view.dart';

Route<dynamic> generateRoute(RouteSettings settings)
{
  switch (settings.name)
  {
    case '/':
      return MaterialPageRoute(builder: (context) => MyApp());
    case 'Camera':
      return MaterialPageRoute(builder: (context) => TextRecognizerView());
    default:
      return MaterialPageRoute(builder: (context) => MyApp());
  }
}