import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:uuid/uuid.dart';
import 'painters/coordinates_translator.dart';
import 'dart:io';
import 'dart:ui';

class Line
{
  Line();
}

class Block
{
  //var uuid = const Uuid();
  String id= "";

  String fulltext = "";

  double relativeRelationToLastBlockY = .0;
  double relativeRelationToLastBlockX = .0;

  double absolutePositionLeftTopX     = .0;
  double absolutePositionLeftTopY     = .0;
  double absolutePositionRightBottomX = .0;
  double absolutePositionRightBottomY = .0;


  Block(TextBlock textBlock)
  {
    fulltext = textBlock.text;
    // coordinates at times of first call

    // if this shall be painted on screen it must be
    // translated... and it is only correct in this frame

    absolutePositionLeftTopX      = textBlock.boundingBox.left;
    absolutePositionLeftTopY      = textBlock.boundingBox.top;
    absolutePositionRightBottomX  = textBlock.boundingBox.right;
    absolutePositionRightBottomY  = textBlock.boundingBox.bottom;

    //id =  uuid.v4();
  }
}
class ScanIteration
{
  List<Line> lines = [];

  ScanIteration();
}

// make one ScanIteration per image
class CurrentBill
{
  bool isBill = false;
  Iterable<String> shops =
  [
    "kaufland",
    "liedl",
    "rewe"
  ];

  List<Block> foundBlocks = [];

  CurrentBill()
  {
    ;
  }

  bool isProperBill(RecognizedText current_fulltext)
  {
    for (final textBlock in current_fulltext.blocks)
    {
      if(isBill)
      {
        bool isFresh = true;
        for(final foundBlock in foundBlocks)
        {
          if(foundBlock.fulltext.toLowerCase() == textBlock.text.toLowerCase())
          {
            isFresh = false;
          }
        }
        if(isFresh)
        {
          foundBlocks.add(Block(textBlock));
          // print(textBlock.text);
        }
      }
      else
      {
        for (final textLine in textBlock.lines)
        {
          for (final textWord in textLine.elements)
          {
            if (shops.contains(textWord.text.toLowerCase()))
            {
              print("found " + textWord.text);
              isBill = true;
              foundBlocks.add(Block(textBlock));
            }
          }
        }
      }
      foundBlocks.sort
      (
        (a, b) =>
        a.absolutePositionLeftTopY.compareTo
        (
            b.absolutePositionLeftTopY
        )
      );
    }
    return false;
  }
}