import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'support/routes.dart' as router;
import 'main_bloc.dart';

List<CameraDescription> cameras = [];

Future<void> main() async
{
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget
{
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) 
  {
    final MainBloc mainBloc = MainBloc();
    return MaterialApp
    (
      title: 'Flutter Demo',
      theme: ThemeData
      (
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      onGenerateRoute: router.generateRoute,
      initialRoute: '/',
      home: MyHomePage(mainBloc: mainBloc),
    );
  }
}

class MyHomePage extends StatefulWidget 
{
  MyHomePage
  (
    {
      Key? key, required this.mainBloc
    }
  ) : super(key: key);

  MainBloc mainBloc;
  
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
{
  MainBloc mainBloc = MainBloc();

  @override
  Widget build(BuildContext context)
  {
    mainBloc = widget.mainBloc;
    return StreamBuilder
    (
        stream: mainBloc.master,
      builder:
      (
      BuildContext  context,
          AsyncSnapshot state,
      )
      {
        if
        (
        state.data == null ||
            state.data.status == MainStates.isInitializing
        )
        {
          if (state.data == null) {
            mainBloc.poke(context);
          }
          return Text('');
        }
        else
        {
          return Scaffold
          (
            appBar: AppBar
            (
              title: Text('BiDoO'),
            ),
            body: Center
            (
              child: Column
              (
                mainAxisAlignment: MainAxisAlignment.center,
                children: const <Widget>
                [
                  Text
                    (
                    'Use the back button after you filmed the bill:',
                  ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton
            (
              onPressed: ()
              {
                // Navigate to the second screen using a named route.
                Navigator.pushNamed(context, 'Camera');
              },
              tooltip: 'Increment',
              child: const Icon(Icons.add),
            ),
          );
        }
      }
    );
  }
}