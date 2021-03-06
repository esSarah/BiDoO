import 'main_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'scanner/current_bill.dart';
import 'support/routes.dart' as router;

enum ScreenMode { liveFeed, gallery }

class BillView extends StatefulWidget {
	BillView
	(
		{
			Key? key,
			this.mainBloc,
		}
			)
			: super(key: key);


	final MainBloc? mainBloc;
	@override
	_BillViewState createState() => _BillViewState();
}

class _BillViewState extends State<BillView> {

	MainBloc? _mainBloc;

	@override
	void initState()
	{
		super.initState();
		_mainBloc = widget.mainBloc;
	}

	@override
	void dispose()
	{
		super.dispose();
	}

	@override
	Widget build(BuildContext context)
	{
		return StreamBuilder
		(
			stream: _mainBloc!.master,
			builder:
			(
			BuildContext  context,
					AsyncSnapshot state,
			)
			{
				// build page as list
				List<Widget> widgets = [];

				CurrentBill bill = _mainBloc!.mainProperties.currentBill!;
				ItemList itemList = _mainBloc!.mainProperties.itemList;

				List<Line> billOfLines = bill.lines;


				Column newColumn = Column
				(
					children:
					[
						Row
						(
							children:
							[
								Text(itemList.store.name),
							]
						),
						Row
						(
							children:
							[
								Text(itemList.store.street),
							]
						),
						Row
						(
							children:
							[
								Text(itemList.store.zip + " " + itemList.store.city),
							]
						),
						Row
						(
							children:
							[
								Text(itemList.date.toString()),
							]
						),

						for(Item item in itemList.product)
							Text(item.name + ": " + item.value.toString() + " EUR")

					]
				);

				widgets.add(newColumn);


				return Scaffold
				(
					body: ListView.builder
					(
						itemCount: widgets.length,
						itemBuilder: (context, index)
						{
							return widgets[index];
						},
					),

					floatingActionButton: Stack
					(
						fit: StackFit.expand,
						children:
						[
							Positioned
							(
								left: 40,
								bottom: 40,
								child: FloatingActionButton
								(
									heroTag: null,
									child: const Icon
									(
										Icons.cancel,
										color: Color.fromRGBO(255, 0, 0, 50),
										size: 40,
									),
									onPressed: ()
									{
									// Navigate to the first screen using a named route.
										Navigator.pushNamed
										(
											context, '/'
										);
									}
								),
							),
							Positioned
							(
								bottom: 40,
								right: 40,
								child: FloatingActionButton
								(
									heroTag: null,
									child: const Icon
									(
										Icons.ballot,
										size: 40,
									),
									onPressed: ()
									{
										// Navigate to the first screen using a named route.
										_mainBloc!.mainEvents.add(MainSaveBillDataEvent());
									}
								),
							),
						],
					),
				);
			}
		);
	}
}