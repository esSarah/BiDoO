import 'dart:async';
import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseManager
{
	late  Database databaseInstance;
	final bool     isDebug = false;

	Future<Database> get fetchDatabase async
	{
		databaseInstance = await initDB();
		return databaseInstance;
	}

	Future<List<Map>> read(String sql) async
	{
		var databaseConnection = await fetchDatabase;
		if (isDebug) print('db: SQL (supposedly) read: ' + sql);

		return await databaseConnection.rawQuery(sql);
	}

	Future<bool> execute(String sql) async
	{
		var databaseConnection = await fetchDatabase;
		if (isDebug) print('db: SQL (supposedly) executed: ' + sql);
		await databaseConnection.execute(sql);
		return true;
	}

	Future<bool> delete(String sql) async
	{
		var databaseConnection = await fetchDatabase;
		if (isDebug) print('db: SQL (supposedly) delete: ' + sql);
		await databaseConnection.delete(sql);
		return true;
	}

	Future<int> newID(String tablename) async
	{
		int lastID = await executeIntScalar
		(
			'SELECT MAX(ID) FROM ${secure(tablename)}'
		);
		return lastID + 1;
	}

	Future<int> executeIntScalar(String sql) async
	{
		int result = 0;
		var databaseConnection = await fetchDatabase;

		List<Map> resultMap;
		bool isFirstLine = true;
		resultMap = await read(sql);
		try
		{
			// if the result is a Map with more than
			// one result wie really just want
			// the first column of the first row

			// the break statement doesn't work in
			// the Lists forEach function though.
			resultMap.forEach
			(
				(line)
				{
					if (isFirstLine) {
						result = line[line.keys.first];
						isFirstLine = false;
					}
				}
			);
		}
		catch (e) {
			print("Result of \'" + sql + "\' was not an Integer");
			print("Trying to parse the result");
			resultMap.forEach
			(
				(line)
				{
					result = int.parse(line[line.keys.first].toString());
				}
			);
		}

		return result;
	}

	Future<bool> debugPrintTable(String tablename) async
	{
		await debugPrintSqlQuery('SELECT * FROM ${secure(tablename)}');
		return true;
	}

	Future<bool> debugPrintSqlQuery(String sql) async
	{
		bool isFirstLine = true;
		List<Map> resultMap;
		resultMap = await read(sql);
		resultMap.forEach
		(
			(line)
			{
				if (isFirstLine)
				{
					String columns = '';
					line.keys.forEach
					(
						(currentKey)
						{
							columns += currentKey.toString() + ', ';
						}
					);
					print('Headers: ' + columns);
					print('-----------');
					isFirstLine = false;
				}
				String values = '';
				line.keys.forEach
				(
					(currentKey)
					{
						values += line[currentKey].toString() + ', ';
					}
				);
				print(values);
			}
		);
		return true;
	}

	initDB() async
	{
		io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
		String path = join(documentsDirectory.path, 'BiDoO.db');
		var db = await openDatabase(path, version: 2, onCreate: onCreateFunc);
		return db;
	}

	String secure(String sql)
	{
		return sql.replaceAll(RegExp('[\']'), '\'\'');
	}

	Future<int> getIntValue(String label, int characterId) async
	{
		String sql = '''
			SELECT 
			ValueInteger AS ValueInteger
			FROM [Value] WHERE
			CharacterID = $characterId AND
	
			Label = '${secure(label)}'
    ''';
		return await executeIntScalar(sql);
	}

	Future<String> getStringValue(String label, int characterId) async
	{
		String returnValue = '';
		String sql = '''
    SELECT 
		ValueString AS ValueString
		FROM [Value] WHERE
		CharacterID = $characterId AND
		Label = '${secure(label)}'
    ''';
		List<Map> valueData = await read(sql);
		valueData.forEach
		(
			(result)
			{
				returnValue = result[ 'ValueString' ];
			}
		);
		return returnValue;
	}

	Future<bool> setIntValue(String label, int characterId, int intValue) async
	{
		int numberOfExistingEntries = await executeIntScalar
		(
			'''
			SELECT
			Count(characterId)
			FROM [Value] WHERE
			CharacterID = $characterId AND
			Label = '${secure(label)}'
			'''
		);
		if (numberOfExistingEntries > 0) {
			await execute
			(
				'''
				UPDATE [Value]
				SET ValueInteger = $intValue
				WHERE
					CharacterID = $characterId AND
					Label = '${secure(label)}'
				'''
			);
		}
		else {
			int newValueID = await newID('Value');
			await execute
			(
				'''
				INSERT INTO [Value]
				(
					ID,
					CharacterID,
					Label,
					ValueInteger,
					Timestamp
				)
				VALUES
				(
					$newValueID,
					$characterId,
					'${secure(label)}',
					$intValue,
					'${DateTime.now().toIso8601String()}'
				) 
      	'''
			);
		}

		return true;
	}

	Future<bool> setStringValue
	(
		String label, int characterId,
		String stringValue) async
		{
			int numberOfExistingEntries = await executeIntScalar
			(
				'''
				SELECT
				Count(characterId)
				FROM [Value] WHERE
				CharacterID = $characterId AND
				Label = '${secure(label)}'
				'''
			);
			if (numberOfExistingEntries > 0)
			{
				await execute
				(
					'''
					UPDATE [Value]
					SET ValueString = '${secure(stringValue)}'
					WHERE
						CharacterID = $characterId AND
						Label = '${secure(label)}'
					'''
				);
		}
		else
		{
			int newValueID = await newID('Value');
			await execute
			(
				'''
				INSERT INTO [Value]
				(
					ID,
					CharacterID,
					Label,
					ValueString,
					Timestamp
				)
				VALUES
				(
					$newValueID,
					$characterId,
					'${secure(label)}',
					'${secure(stringValue)}',
					'${DateTime.now().toIso8601String()}'
				) 
				'''
			);
		}

		return true;
	}

	void onCreateFunc(Database db, int version) async
	{
		String databaseStructur = '''

-- Table: Shop
CREATE TABLE Shop ( 
    ShopID CHAR( 38 )      PRIMARY KEY
                           NOT NULL
                           UNIQUE,
    Name   VARCHAR( 255 )  NOT NULL,
    Street VARCHAR( 255 ),
    City   VARCHAR( 255 ),
    Zip    VARCHAR 
);


-- Table: Bills
CREATE TABLE Bills ( 
    BillID         CHAR( 38 )  PRIMARY KEY
                               NOT NULL,
    ShopID         CHAR( 38 )  NOT NULL,
    DateOfPurchase DATE        NOT NULL 
);


-- Table: Items
CREATE TABLE Items ( 
    ItemID       CHAR( 38 )      PRIMARY KEY
                                 NOT NULL
                                 UNIQUE,
    BillID       CHAR( 38 )      NOT NULL,
    ItemDeciptor VARCHAR( 255 )  NOT NULL,
    ItemValue    REAL            NOT NULL 
);
    ''';
		List<String> commands = databaseStructur.split(";");
		commands.forEach((command)
		{
			if(command.isNotEmpty )
			{
				//print(command.trim());
				db.rawQuery(command);
			}
		});
	}
}
