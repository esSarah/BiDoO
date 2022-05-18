import 'dart:async';
import 'package:meta/meta.dart';
import 'package:flutter/material.dart';
import 'support/database.dart';
import 'support/routes.dart';
import 'scanner/current_bill.dart';
import 'package:uuid/uuid.dart';

/* rather generic bloc
	 to have all the building blocks
	 of a block ready when it gets
	 more complex
 */
enum MainStates
{
	isInitializing,
	isIdle,
	isWaiting,
	isReading,
//	isProcessing,
	isShowing
}

class MainProperties
{
	MainStates      status       = MainStates.isInitializing;
	BuildContext?   context;
	CurrentBill?    currentBill;
	bool            isReading    = false;
	DatabaseManager db           = DatabaseManager();
}

abstract class MainEvent
{
	MainEvent([List props = const[]]);
}

class MainInitializeEvent extends MainEvent
{


}

class MainStartReadingEvent extends MainEvent
{

}

class MainStartRecordingEvent extends MainEvent
{

}

class MainStartProcessingEvent extends MainEvent
{
	final List<Block> foundBlocks;

	MainStartProcessingEvent
	(
		{
			required this.foundBlocks
		}
	) : super([foundBlocks]);
}


class MainStartShowingResultEvent extends MainEvent
{

}

class MainTestDatabaseEvent extends MainEvent
{

}

class MainExportEvent extends MainEvent
{

}

class MainClearDataEvent extends MainEvent
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
		db.initDB();
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
		if(event is MainStartShowingResultEvent)
		{
			await _mainStartShowingResult(event);
		}
		if(event is MainStartReadingEvent)
		{
			await _mainStartReading(event);
		}
		if(event is MainStartRecordingEvent)
		{
			await _mainStartRecording(event);
		}
		if(event is MainTestDatabaseEvent)
		{
			await _mainTestDatabase(event);
		}
		if(event is MainExportEvent)
		{
			await _mainExport(event);
		}
		if(event is MainClearDataEvent)
		{
			await _mainClearData(event);
		}

		print(event.toString() + " --- " + mainProperties.status.toString());
		return true;
	}

	Future<bool> _mainInitialize(MainInitializeEvent event) async
	{
		mainProperties.status = MainStates.isIdle;
		_mainController.add(mainProperties);
		return true;
	}

	Future<bool> _mainStartShowingResult(MainStartShowingResultEvent event) async
	{
		mainProperties.isReading = false;
		mainProperties.status = MainStates.isShowing;
		mainProperties.currentBill?.findItems();
		print("Push comes to shove");
		Navigator.pushNamed
		(
			mainProperties.context!,
			'BillView',
			arguments: MainBlocArgument(this),
		);
		return true;
		return true;
	}

	Future<bool> _mainStartReading(MainStartReadingEvent event) async
	{
		mainProperties.isReading = false;
		mainProperties.status = MainStates.isWaiting;

		Navigator.pushNamed
		(
			mainProperties.context!,
			'Camera',
			arguments: MainBlocArgument(this),
		);
		return true;
	}

	Future<bool> _mainStartRecording(MainStartRecordingEvent event) async
	{
		mainProperties.status = MainStates.isReading;
		mainProperties.isReading = true;
		return true;

	}

	Future<bool> _mainTestDatabase(MainTestDatabaseEvent event) async
	{
		print("Database test called");
		var billID = Uuid();
		var shopID = Uuid();
		String fakeBillID = billID.v1();
		String fakeShopID = shopID.v1();
		DateTime today = DateTime.now();
		String stringToday = today.toIso8601String();

		db.execute
		(
				'''
				INSERT INTO Bills ('BillID','ShopID', 'DateOfPurchase')
				VALUES ('$fakeBillID','$fakeShopID ', '$stringToday')
				'''
		);
		db.debugPrintTable('Bills');
		return true;
	}

	Future<bool> _mainExport(MainExportEvent event) async
	{
		// by now just a test

		print("Export called");
		return true;
	}

	Future<bool> _mainClearData(MainClearDataEvent event) async
	{
		db.execute
		(
			'''
			TRUNCATE TABLE Bills;
			'''
		);
		db.execute
		(
				'''
			TRUNCATE TABLE Shop;
			'''
		);
		db.execute(
				'''
			TRUNCATE TABLE Items;
			'''
		)
		print("Clear data called");
		return true;
	}
}