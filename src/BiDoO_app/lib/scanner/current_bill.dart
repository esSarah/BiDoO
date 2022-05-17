import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:dart_phonetics/dart_phonetics.dart';

class Line
{
  Line();
}

class Block
{
  //var uuid = const Uuid();
  String id= "";
  String soundex = "";
  String fulltext = "";

  double relativeRelationToLastBlockY = .0;
  double relativeRelationToLastBlockX = .0;

  int absolutePositionLeftTopX     = 0;
  int absolutePositionLeftTopY     = 0;
  int absolutePositionRightBottomX = 0;
  int absolutePositionRightBottomY = 0;


  Block(TextBlock textBlock, String soundexBlock)
  {
    soundex = soundexBlock;
    fulltext = textBlock.text;
    // coordinates at times of first call

    // if this shall be painted on screen it must be
    // translated... and it is only correct in this frame

    absolutePositionLeftTopX      = textBlock.boundingBox.left.floor();
    absolutePositionLeftTopY      = textBlock.boundingBox.top.floor();
    absolutePositionRightBottomX  = textBlock.boundingBox.right.floor();
    absolutePositionRightBottomY  = textBlock.boundingBox.bottom.floor();

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

  final soundex = Soundex.genealogyEncoder;

  Iterable<String> shops =
  [
    "kaufland",
    "liedl",
    "rewe"
  ];


  List<Block> iteration = [];

  CurrentBill()
  {
    ;
  }

  bool isProperBill(RecognizedText current_fulltext)
  {
    List<Block> foundBlocks = [];
    for (TextBlock textBlock in current_fulltext.blocks)
    {
      if (isBill)
      {
        foundBlocks.add
        (
          Block
          (
            textBlock,
            soundex.encode
            (textBlock.text).toString()
          )
        );
      }
      else
      {
        bool isFound = false;
        for (final textLine in textBlock.lines)
        {
          for (final textWord in textLine.elements)
          {
            if (shops.contains(textWord.text.toLowerCase()))
            {
              print("found " + textWord.text);
              isBill = true;
              PhoneticEncoding? soundexBlock = soundex.encode(textBlock.text);
              foundBlocks.add(Block(textBlock, soundexBlock.toString()));
              isFound = true;
              //break;
            }
          }
          //if(isFound){break;}
        }
      }
    }
    foundBlocks.sort
    (
      (a, b) =>
      a.absolutePositionLeftTopX.compareTo
      (
          b.absolutePositionLeftTopX
      )
    );
    foundBlocks.sort
    (
      (a, b) =>
      a.absolutePositionLeftTopY.compareTo
      (
        b.absolutePositionLeftTopY
      )
    );

    bool breakMeIfYouCan = true;
    bool leggo = false;
    int iterator = 5;
    int finder = 5;
    int lengthOfIteration = iteration.length;
    int lengthOfFoundBlocks = foundBlocks.length;

    if (iteration.isEmpty)
    {
      iteration = foundBlocks.toList();
    }
    else
    {
      while (breakMeIfYouCan)
      {
        lengthOfIteration = iteration.length;
        print("Endlosschleife?");
        if (!leggo)
        {
          if(((iterator+3)>lengthOfIteration))
          {
            print("Found no match");
            breakMeIfYouCan = false;
          }
          else
          {
            print("looking at: foundBlocks[" + finder.toString() + "] = \"" + foundBlocks[finder].soundex + "\" and: iteration[" + iterator.toString() +"] = \""+ iteration[iterator].soundex + "\"");
            print("\"" + foundBlocks[finder].fulltext + "\" vs. \"" + iteration[iterator].fulltext + "\"");
            print("looking at: foundBlocks[" + (finder+1).toString() + "] = \"" + foundBlocks[finder+1].soundex + "\" and: iteration[" + (iterator+1).toString() +"] = \""+ iteration[iterator + 1].soundex + "\"");
            print("\"" + foundBlocks[finder+1].fulltext + "\" vs. \"" + iteration[iterator + 1].fulltext + "\"");
            print("looking at: foundBlocks[" + (finder+2).toString() + "] = \"" + foundBlocks[finder+2].soundex + "\" and: iteration[" + (iterator+2).toString() +"] = \""+ iteration[iterator + 2].soundex + "\"");
            print("\"" + foundBlocks[finder+2].fulltext + "\" vs. \"" + iteration[iterator + 2].fulltext + "\"");

            if
            (
              // look if you can find three blocks with similar text in a row
              // on the existing data.
              foundBlocks[finder].soundex ==
               iteration[iterator].soundex &&
              foundBlocks[finder + 1].soundex ==
                iteration[iterator + 1].soundex &&
              foundBlocks[finder + 2].soundex ==
                iteration[iterator + 2].soundex
            )
            {
              // If so, we have found a starting point

              // now the difference to the end of the old data
              // should be added to the finder as well to
              // only add new found data

              // jumo the positions three steps forward,

              leggo = true;

              // temporary, I want to see if it findeth though place
              print("Found start at Position: " + iterator.toString());
            }
          }
          iterator++;
          if (iterator > lengthOfIteration)
          {
            breakMeIfYouCan = false;
          }
        }
        else
        {
          if(breakMeIfYouCan)
          {
            if (finder + 1 > lengthOfFoundBlocks)
            {
              breakMeIfYouCan = false;
            }
            else
            {
              print("Finder tries to add " + finder.toString());
              iteration.add(foundBlocks[finder]);
              // else add to multiple options, not yet implemented;
            }
            finder++;
            iterator++;
          }// not used now, but keeps track of existing entries
        }
      }
    }
    return true;
  }
}