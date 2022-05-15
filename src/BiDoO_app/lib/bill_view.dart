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

				CurrentBill? bill = _mainBloc?.mainProperties.currentBill;

				for (Block block in bill!.foundBlocks)
				{
					widgets.add(Text(block.fulltext));
				}


				return Scaffold
				(
					body: ListView.builder
					(
						itemCount: widgets.length,
						itemBuilder: (context, index) {
							return widgets[index];
						},
					),
				floatingActionButton: FloatingActionButton
					(
						onPressed: ()
						{
							// Navigate to the second screen using a named route.
							Navigator.pushNamed
								(
								context, '/'
							);
						},
						tooltip: 'Scan',
						child: const Icon(Icons.arrow_back_ios_rounded),
					),
				);
			}
		);
	}
}