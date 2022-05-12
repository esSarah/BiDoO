

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:uuid/uuid.dart';

class Block
{
  var uuid = const Uuid();
  String id= "";

  String fulltext = "";


  Block(TextBlock textBlock)
  {
    fulltext = textBlock.text;
    id =  uuid.v4();
  }

}

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
        for(final foundblock in foundBlocks)
        {
          if(foundblock.fulltext.toLowerCase() == textBlock.text.toLowerCase())
          {
            isFresh = true;
          }
        }
        if(isFresh)
        {
          foundBlocks.add(Block(textBlock));
          print(textBlock.text);
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
    }
    return false;
  }
}