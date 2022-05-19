import 'dart:async';
import 'package:flutter/material.dart';
import 'support/database.dart';
import 'support/routes.dart';
import 'scanner/current_bill.dart';
import 'package:share/share.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';
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
	ItemList				itemList     = ItemList();
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

class MainSaveBillDataEvent extends MainEvent
{

}

class MainBloc
{
	Future<String> get _localPath async {
		final directory = await getApplicationDocumentsDirectory();

		return directory.path;
	}

	Future<File> get _localFile async {
		final path = await _localPath;
		print('path ${path}');
		return File('$path/bills.csv');
	}

	Future<int> deleteFile() async {
		try {
			final file = await _localFile;

			await file.delete();
		} catch (e) {
			return 0;
		}
		return 0;
	}

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
		if(event is MainSaveBillDataEvent)
		{
			await _mainSaveBillData(event);
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
		mainProperties.itemList =  mainProperties.currentBill!.findItems();

		Navigator.pushNamed
		(
			mainProperties.context!,
			'BillView',
			arguments: MainBlocArgument(this),
		);
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
		db.debugPrintTable('Shop');
		db.debugPrintTable('Bills');
		db.debugPrintTable('Items');
		return true;
	}

	Future<bool> _mainExport(MainExportEvent event) async
	{
		await deleteFile(); // not happy about the literal
		// by now just a test
		String denormalized =
		'''
		SELECT Items.ItemID, Items.ItemDeciptor, Items.ItemValue,
			Bills.BillID, Bills.DateOfPurchase,
			Shop.ShopID, Shop.Name, Shop.Street, Shop.City, Shop.Zip
			FROM Items 
			INNER JOIN Bills ON Items.BillID = Bills.BillID
			INNER JOIN Shop ON Bills.ShopID = Shop.ShopID;
		''';
		List<List<dynamic>> rows = [];
		var denormalizedList = await db.read(denormalized);
		await db.debugPrintSqlQuery("SELECT ItemID FROM Items" );


//row refer to each column of a row in csv file and rows refer to each row in a file
		List<dynamic> row = [];

		row.add('ItemID');
		row.add('ItemDeciptor');
		row.add('ItemValue');
		row.add('BillID');
		row.add('DateOfPurchase');
		row.add('Name');
		row.add('Street,');
		row.add('City');
		row.add('Zip');

		rows.add(row);

		for (int i = 0; i < denormalizedList.length; i++)
		{
			List<dynamic> row = [];
			row.add(denormalizedList[i]["ItemID"]);
			row.add(denormalizedList[i]['ItemDeciptor']);
			row.add(denormalizedList[i]['ItemValue']);
			row.add(denormalizedList[i]['BillID']);
			row.add(denormalizedList[i]['DateOfPurchase']);
			row.add(denormalizedList[i]['Name']);
			row.add(denormalizedList[i]['Street,']);
			row.add(denormalizedList[i]['City']);
			row.add(denormalizedList[i]['Zip']);
			rows.add(row);
		}

		String dir = (await getExternalStorageDirectory())!.absolute.path + "/documents";
		String file = "$dir";
		print(" FILE " + file);
		File f =File(file+"bills.csv");

		String csv = const ListToCsvConverter(textDelimiter: "\"").convert(rows);

		f.writeAsString(csv);
		List<String> paths= [];
		paths.add(file+"bills.csv");
		Share.shareFiles(paths, subject: "The bills from BiDoO");

		print("Export called");
		return true;
	}

	Future<bool> _mainClearData(MainClearDataEvent event) async
	{
		db.execute
		(
			'''
			DELETE FROM Bills;
			'''
		);
		db.execute(
				'''
			DELETE FROM Items;
			'''
		);
		print("Clear data called");
		return true;
	}

	Future<bool> _mainSaveBillData(MainSaveBillDataEvent event) async
	{

		String lookForExistingStore =
		'''
			SELECT ShopID FROM Shop WHERE 
			Name LIKE '${db.secure(mainProperties.itemList.store.name)}'
			AND Street LIKE '${db.secure(mainProperties.itemList.store.name)}'
		''';
		List<Map> ExistingStoreID = await db.read(lookForExistingStore);
		if(ExistingStoreID.isNotEmpty)
		{
			ExistingStoreID.forEach
			(
				(char)
				{
					mainProperties.itemList.store.id = char['ShopID'];
				}
			);
		}
		else
		{
			String saveFirstTimeStoreData =
			'''
			INSERT INTO Shop
			(ShopID, Name, Street, City, Zip)
			VALUES
			(
				'${db.secure(mainProperties.itemList.store.id)}',
				'${db.secure(mainProperties.itemList.store.name)}',
				'${db.secure(mainProperties.itemList.store.street)}',
				'${db.secure(mainProperties.itemList.store.city)}',
				'${db.secure(mainProperties.itemList.store.zip)}'
			)
			''';
			await db.execute(saveFirstTimeStoreData);

			db.debugPrintTable('Shop');
		}

		double sum = .0;
		for(Item item in mainProperties.itemList.product)
		{
			sum += item.value;
		}

		bool billIsAlreadyExisting = false;

		String lookForExistingBill =
		'''
			SELECT 
			Summed.BillID, Summed.ShopID, Summed.DateOfPurchase, Summed.TheValue FROM 
(SELECT Bills.BillID AS BillID, Bills.ShopID, Bills.DateOfPurchase, 
Sum([Items].ItemValue) AS TheValue
FROM Bills INNER JOIN [Items] ON [Items].BillID = Bills.BillID
GROUP BY Bills.BillID, Bills.ShopID, Bills.DateOfPurchase) Summed
WHERE 
BillID = '${db.secure(mainProperties.itemList.id)}' 
AND ShopID = '${db.secure(mainProperties.itemList.store.id)}' 
AND DateOfPurchase = '${mainProperties.itemList.date.toIso8601String()}'
AND TheValue = $sum 
		''';
		List<Map> ExistingBillID = await db.read(lookForExistingStore);
		if(ExistingBillID.isNotEmpty)
		{
			ExistingBillID.forEach
			(
				(char)
				{
					mainProperties.itemList.id = char['BillID'];
				}
			);
			billIsAlreadyExisting = true;
		}
		else
		{
			String saveFirstTimeBillData =
			'''
			INSERT INTO Bills
			(BillID, ShopID, DateOfPurchase)
			VALUES
			(
				'${db.secure(mainProperties.itemList.id)}',
				'${db.secure(mainProperties.itemList.store.id)}',
				'${mainProperties.itemList.date.toIso8601String()}'
			);
			''';
			await db.execute(saveFirstTimeBillData);
		}

		if(!billIsAlreadyExisting)
		{
			for(Item item in mainProperties.itemList.product)
			{
				String sqlInsertItem =
				'''
				INSERT INTO Items (ItemID, BillID, ItemDeciptor, ItemValue)
				VALUES 
				(
					'${db.secure(item.id)}',
					'${db.secure(mainProperties.itemList.id)}',
					'${db.secure(item.name)}',
					${item.value}
				);
				''';
				await db.execute(sqlInsertItem);
			}
		}
		db.debugPrintTable('Items');
		Navigator.pushNamed
		(
				mainProperties.context!,
				'/'
		);
		return true;
	}
}