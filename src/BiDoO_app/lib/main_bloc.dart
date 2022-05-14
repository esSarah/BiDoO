import 'dart:async';
import 'package:meta/meta.dart';
import 'package:flutter/material.dart';
import 'support/database.dart';
import 'support/routes.dart';
import 'scanner/current_bill.dart';

/* rather generic bloc
	 to have all the building blocks
	 of a block ready when it gets
	 more complex
 */
enum MainStates
{
	isInitializing,
	isIdle,
	/*
	isReading,
	isProcessing,
	isShowing
	*/
}

class MainProperties
{
	MainStates  status          = MainStates.isInitializing;
	BuildContext? context;
	// DatabaseManager     db                  = new DatabaseManager();
}

abstract class MainEvent
{
	MainEvent([List props = const[]]);
}

class MainInitializeEvent extends MainEvent
{


}

class MainStartReading extends MainEvent
{

}

class MainStartProcessing extends MainEvent
{
	final List<Block> foundBlocks;

	MainStartProcessing
	(
		{
			required this.foundBlocks
		}
	) : super([foundBlocks]);
}

class MainStartShowingResult extends MainEvent
{

}

class MainBloc
{

	MainProperties mainProperties = MainProperties();

	final DatabaseManager  db     = DatabaseManager();

	final _mainController = StreamController<MainProperties>.broadcast();
	Stream<MainProperties> get master => _mainController.stream;

	final _mainEventController = StreamController<MainEvent>();
	// in dieses Sammelbecken kommen die Events
	Sink<MainEvent> get mainEvents =>
	_mainEventController.sink;

	MainBloc()
	{
		mainProperties = MainProperties();
		mainProperties.status = MainStates.isInitializing;
		_mainEventController.stream.listen(_mapEventToState);
	}

	void poke(BuildContext context)
	{
		mainProperties.context = context;

		// any more complex initialization
		// should go here

		mainProperties.status = MainStates.isIdle;
		_mainController.add(mainProperties);
	}

	Future<bool> _mapEventToState(MainEvent event) async
	{
		if(event is MainInitializeEvent)
		{
			await _mainInitialize(event);
		}
		print(mainProperties.status.toString());
		return true;
	}

	Future<bool> _mainInitialize(MainInitializeEvent event) async
	{
		mainProperties.status = MainStates.isIdle;
		_mainController.add(mainProperties);
		return true;
	}
}