import 'package:flutter/material.dart';
import '../main.dart';
import '../bill_view.dart';
import '../main_bloc.dart';
import '../scanner/text_detector_view.dart';

class MainBlocArgument
{
  MainBloc? mainBloc;
  MainBlocArgument(MainBloc bloc)
  {
    mainBloc = bloc;
  }
}

Route<dynamic> generateRoute(RouteSettings settings)
{
  switch (settings.name)
  {
    case '/':
      return MaterialPageRoute(builder: (context) => MyApp());
    case 'Camera':
      final args = settings.arguments as MainBlocArgument;
      return MaterialPageRoute
      (
        builder:(context){return TextRecognizerView(mainBloc: args.mainBloc,);},
      );
    case 'BillView':
      final args = settings.arguments as MainBlocArgument;
      return MaterialPageRoute
      (
        builder:(context){return BillView(mainBloc: args.mainBloc,);},
      );
    default:
      return MaterialPageRoute(builder: (context) => MyApp());
  }
}