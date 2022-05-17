import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:dart_phonetics/dart_phonetics.dart';

class Line
{
  List<Block> parts = [];

  int absolutePositionLeftTopX     = 0;
  int absolutePositionLeftTopY     = 0;
  int absolutePositionRightBottomX = 0;
  int absolutePositionRightBottomY = 0;

  void addBlock(Block newBlockOnTheKid)
  {
    if
    (
      absolutePositionLeftTopX <
        newBlockOnTheKid.absolutePositionLeftTopX
    )
    {
      absolutePositionLeftTopX =
        newBlockOnTheKid.absolutePositionLeftTopX;
    }
    if
    (
      absolutePositionLeftTopY <
        newBlockOnTheKid.absolutePositionLeftTopY
    )
    {
      absolutePositionLeftTopY =
        newBlockOnTheKid.absolutePositionLeftTopY;
    }
    if
    (
      absolutePositionRightBottomX <
        newBlockOnTheKid.absolutePositionRightBottomX
    )
    {
      absolutePositionRightBottomX =
        newBlockOnTheKid.absolutePositionRightBottomX;
    }
    if
    (
      absolutePositionRightBottomY <
        newBlockOnTheKid.absolutePositionRightBottomY
    )
    {
      absolutePositionRightBottomY =
        newBlockOnTheKid.absolutePositionRightBottomY;
    }
    parts.add(newBlockOnTheKid);
    //sort them again along the X axis.
    parts.sort
    (
      (a, b) =>
      a.absolutePositionLeftTopX.compareTo(b.absolutePositionLeftTopX)
    );

  }
  Line();
}

class Block
{
  //var uuid = const Uuid();
  String id= "";
  String soundex = "";
  String fulltext = "";


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

  Iterable<String> sumLabels =
  [
    'summe',
    'gesamt'
    'bruttoumsatz',
    'endsumme',
    'summen'
  ];


  List<Block> uniqueBlocks = [];

  List<Line> lines = [];

  CurrentBill()
  {
    ;
  }

  bool isProperBill(RecognizedText current_fulltext)
  {

    List<Block> foundBlocks = [];
    for (TextBlock textBlock in current_fulltext.blocks)
    {
      int counter = 0;

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



    bool isStillGoing = true;
    bool isAdding     = false;
    // jump the queue for what is most likely the header
    // with the address, that might repeat itself later
    int iterator = 5;
    int finder   = 5;
    int lengthOfIteration   = uniqueBlocks.length;
    int lengthOfFoundBlocks = foundBlocks.length;

    if (uniqueBlocks.isEmpty)
    {
      // after sorting but before later iterations are processed
      // create the first lists
      uniqueBlocks = foundBlocks.toList();

      for(Block block in uniqueBlocks)
      {
        int yTop = block.absolutePositionLeftTopY;
        int yBottom = block.absolutePositionRightBottomY;
        int yCenter = ((yBottom - yTop) / 2).ceil();

        var existingLine = lines.where
          (
                (element) =>
            element.absolutePositionRightBottomY<yBottom+yCenter &&
                element.absolutePositionLeftTopY>yTop-yCenter
        );


        if (existingLine.isEmpty)
        {
          Line toAdd = Line();
          toAdd.addBlock(block);
          lines.add(toAdd);
        }
        else
        {
          // print("Versuche neuen Block ab bestehende Line anzufuegen");
          lines[lines.indexOf(existingLine.first)].addBlock(block);
        }
      }

    }
    else
    {
      while (isStillGoing)
      {
        lengthOfIteration = uniqueBlocks.length;
        print("Endlosschleife?");
        if (!isAdding)
        {
          if(((iterator+3)>lengthOfIteration))
          {
            print("Found no match");
            isStillGoing = false;
          }
          else
          {
            if
            (
              // look if you can find three blocks with similar text in a row
              // on the existing data.
              foundBlocks[finder].soundex ==
               uniqueBlocks[iterator].soundex &&
              foundBlocks[finder + 1].soundex ==
                uniqueBlocks[iterator + 1].soundex &&
              foundBlocks[finder + 2].soundex ==
                uniqueBlocks[iterator + 2].soundex
            )
            {
              // If so, we have found a starting point

              // now the difference to the end of the old data
              // should be added to the finder as well to
              // only add new found data

              isAdding = true;

            }
          }
          iterator++;
          if (iterator > lengthOfIteration)
          {
            isStillGoing = false;
          }
        }
        else
        {
          if(isStillGoing)
          {
            if (finder + 1 > lengthOfFoundBlocks)
            {
              isStillGoing = false;
            }
            else
            {
              print("Finder tries to add " + finder.toString());
              uniqueBlocks.add(foundBlocks[finder]);
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