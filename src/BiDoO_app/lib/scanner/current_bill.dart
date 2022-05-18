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


  Block(TextLine textBlock, String soundexBlock)
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

class ItemList
{
  List<Item> product = [];
  double sum = .0;

  bool isValid()
  {
    double currentSum = .0;
    for(Item item in product)
    {
      currentSum += item.value;
    }

    return (currentSum == sum);
  }

  ItemList();
}
class Item
{
  String name = "";
  double value = .0;

  Item();
}

// make one ScanIteration per image
class CurrentBill
{
  bool isBill = false;

  String shopName = "";
  String shopStreet = "";
  String shopZip = "";
  String shopCity = "";

  DateTime timeOfTransaction = DateTime.now();




  final soundex = Soundex.genealogyEncoder;

  Iterable<String> shops =
  [
    "kaufland",
    "lidl",
    "lodl", // they really use a hard to read logo
    "rewe"
  ];

  Iterable<String> sumLabels =
  [
    'summe',
    'gesamt'
    'bruttoumsatz',
    'endsumme',
    'summen',
    'summe eur'
  ];



  int addLines(TextBlock textBlock, List<Block> listToAddLinesTo)
  {
    int numberOfLines = 0;

    for(TextLine line in textBlock.lines)
    {
      numberOfLines++;
      listToAddLinesTo.add
      (
        Block
        (
          line,
          soundex.encode(line.text).toString()
        )
      );
    }

    return numberOfLines;
  }

  int addSortedLines(List<Block> cleanedBlocks)
  {
    List<Line> newLines = [];
    int numberOfLines = 0;

    for(Block block in cleanedBlocks)
    {
      numberOfLines++;
      int yTop = block.absolutePositionLeftTopY;
      int yBottom = block.absolutePositionRightBottomY;
      int yCenter = ((yBottom - yTop) / 2).ceil();

      var existingLine = newLines.where
      (
        (element) =>
        (
          element.absolutePositionRightBottomY < yBottom + yCenter &&
          element.absolutePositionLeftTopY > yTop - yCenter
        )
      );

      if (existingLine.isEmpty)
      {
        Line toAdd = Line();
        toAdd.addBlock(block);
        newLines.add(toAdd);
      }
      else
      {
        // print("Versuche neuen Block ab bestehende Line anzufuegen");
        newLines[newLines.indexOf(existingLine.first)].addBlock(block);
      }
    }

    lines += newLines;
    print("added " + numberOfLines.toString() + " new lines");
    return numberOfLines;
  }

  List<Block> uniqueBlocks = [];

  List<Line> lines = [];
  ItemList itemList = ItemList();

  CurrentBill()
  {
    ;
  }



  bool findItems()
  {
    print("findItems was called");

    // searched for a number of multiplications (signaled by * or x)
    RegExp multiples  = RegExp
    (
      r'^[\d]+[ ]+[x|*]$'
    );

    // searches for a typical price / sum at the end of a line
    RegExp price      = RegExp
    (
      r'^-?[ ]*([\d]+[,|.]\d\d[ ]+[A|B|K|Eur|Euro|€]$)|(^-?[ ]*[\d]+[,|.]\d\d$)'
    );

    // used to extract exact price
    RegExp exactPrice = RegExp
    (
      r'^-?[ ]*[\d]+[,|.]\d\d'
    );
    int  LineNumberOfSum        = 0;
    bool theCounteningHathBegun = false;
    bool theCounteningIsOver    = false;

    for(Line line in lines.reversed.toList())
    {
      for (String currentSearchTerm in sumLabels)
      {
        if
        (
          !theCounteningHathBegun &&
          line.parts.first.soundex ==
          soundex.encode(currentSearchTerm).toString()
        )
        {
          // one of the labels signifying the sum total
          // was found
          theCounteningHathBegun = true;

          bool sumNotFound = true;
          double sum = .0;
          print("Found a sum");
          for(Block block in line.parts)
          {
            print("-" + block.fulltext + "-");
            if(block.fulltext.contains(price))
            {
              print("Found something out here");
              sumNotFound = false;
              Iterable<RegExpMatch> exactPriceList = exactPrice.allMatches(line.parts.last.fulltext);
              if(exactPriceList.isNotEmpty)
              {
                String? extract = "";
                extract = exactPriceList.first.group(0);
                if(extract != null)
                {
                  sum = double.parse(extract.replaceAll(',', '.'));
                }
                print("The Sum of all articles is " + sum.toString());
                bool sumNotFound = false;
              }
            }
          }
          if(sumNotFound)
          {
            print("but no money");
          }

        }
      }
      LineNumberOfSum++;
    }


    return itemList.isValid();
  }

  bool isProperBill(RecognizedText currentFulltext)
  {

    List<Block> foundBlocks = [];
    for (TextBlock textBlock in currentFulltext.blocks)
    {
      int counter = 0;

      if (isBill)
      {
        addLines(textBlock, foundBlocks);
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
              //PhoneticEncoding? soundexBlock = soundex.encode(textBlock.text);
              addLines(textBlock, foundBlocks);
              // foundBlocks.add(Block(textLine, soundexBlock.toString()));
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
      addSortedLines(uniqueBlocks);
    }
    else
    {
      List<Block> newEntries = [];
      while (isStillGoing)
      {
        lengthOfIteration = uniqueBlocks.length;

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
              isAdding = true;
              // only add new found data
              finder = lengthOfIteration - iterator -5;
              // the five was added earlier as a starting point
              // after the potentially redundant address

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
              newEntries.add(foundBlocks[finder]);
              // else add to multiple options, not yet implemented;
            }
            finder++;
            iterator++;
          }// not used now, but keeps track of existing entries
        }
      }
      addSortedLines(newEntries);
      uniqueBlocks += newEntries;
    }
    return true;
  }
}