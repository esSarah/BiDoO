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


  List<List<Block>> iteration = [[]];

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
        /*
        bool isFresh = true;
        for(final foundBlock in foundBlocks)
        {
          if(foundBlock.soundex == soundex.encode(textBlock.text).toString())
          {
            isFresh = false;
          }
        }
        if(isFresh)
        {
          PhoneticEncoding? soundexBlock = soundex.encode(textBlock.text);

          // print(textBlock.text);
        }*/
        foundBlocks.add
        (
          Block
          (
            textBlock,
            soundex.encode
            (
              textBlock.text
            ).toString()
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
    int finder = 0;
    int lengthOfIteration = iteration.length;
    int lengthOfFoundBlocks = foundBlocks.length;

    if (lengthOfIteration == 1)
    {
      iteration.add(foundBlocks);
    }
    /*
    else

    {
      while (breakMeIfYouCan)
      {
        print("Endlosschleife?");
        if
        (
          // look if you can find three blocks with similar text in a row
          // on the existing data.
          !leggo &&
          foundBlocks[finder].soundex ==
              iteration[iterator].first.soundex &&
          foundBlocks[finder + 1].soundex ==
              iteration[iterator + 1].first.soundex &&
          foundBlocks[finder + 2].soundex ==
              iteration[iterator + 2].first.soundex
        )
        {
          // If so, we have found a starting point

          // now the difference to the end of the old data
          // should be added to the finder as well to
          // only add new found data

          finder += 3 + lengthOfIteration - interator

          leggo = true;

          finder += 3;

          // now that we found the start, find the end

          // temporary, I want to see if it findeth the place
          print("Found start at Position: " + iterator.toString());
          breakMeIfYouCan = false;
        }
        if(leggo)
        {

          if(finder>lengthOfFoundBlocks)
          {
            break;
          }
          else
          {
            iteration.add[foundBlocks[finder]
          }

        }
        iterator++;

        breakMeIfYouCan = false; // :P
      }
      iteration.add(foundBlocks);
      return false;

     */
    return true;
  }

}