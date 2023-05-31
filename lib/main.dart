import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

// ignore: implementation_imports
import 'package:rive/src/runtime_nested_artboard.dart';
// ignore: implementation_imports
import 'package:rive/src/rive_core/animation/nested_state_machine.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SimpleAssetAnimation(),
    );
  }
}

class SimpleAssetAnimation extends StatefulWidget {
  const SimpleAssetAnimation({Key? key}) : super(key: key);

  @override
  State<SimpleAssetAnimation> createState() => _SimpleAssetAnimationState();
}

class _SimpleAssetAnimationState extends State<SimpleAssetAnimation> {
  void _onRiveInit(Artboard artboard) {
    final controller = StateMachineController.fromArtboard(
      artboard,
      'State Machine 1',
      onStateChange: _onStateChange,
    );
    artboard.addController(controller!);

    // WARNING: This is all internal rive stuff & liable to change without
    // a change in major rive-flutter version
    for (var element in artboard.activeNestedArtboards) {
      for (var element in (element as RuntimeNestedArtboard).animations) {
        void callback(String stateMachineName, String stateName) =>
            _onNestedStateChange(element.nestedArtboard?.name ?? '',
                stateMachineName, stateName);
        if (element is NestedStateMachine) {
          if (element.stateMachineInstance
              is RuntimeNestedStateMachineInstance) {
            final cache = (element.stateMachineInstance
                as RuntimeNestedStateMachineInstance);
            element.stateMachineInstance = RuntimeNestedStateMachineInstance(
              cache.stateMachineController.artboard as RuntimeArtboard,
              StateMachineController(cache.stateMachineController.stateMachine,
                  onStateChange: callback),
            );
          }
        }
      }
    }
  }

  void _onStateChange(
    String stateMachineName,
    String stateName,
  ) {
    print('StateMachine: $stateMachineName, State: $stateName');
  }

  void _onNestedStateChange(
    String nestedArtboardName,
    String stateMachineName,
    String stateName,
  ) {
    print('NestedArtboardName: $nestedArtboardName, '
        'StateMachine: $stateMachineName, '
        'State: $stateName');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: RiveAnimation.asset(
          'assets/switch.riv',
          fit: BoxFit.cover,
          onInit: _onRiveInit,
        ),
      ),
    );
  }
}
