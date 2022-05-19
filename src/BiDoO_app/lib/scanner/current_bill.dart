import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:dart_phonetics/dart_phonetics.dart';
import 'package:uuid/uuid.dart';


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
  var uuid = Uuid();

  List<Item> product = [];
  double sum = .0;
  Store store = Store();
  String id = "";
  DateTime date = DateTime.now();

  bool isValid()
  {
    double currentSum = .0;
    for(Item item in product)
    {
      currentSum += item.value;
    }

    return (currentSum == sum);
  }

  ItemList()
  {
    id = uuid.v1();
  }
}

class Item
{
  String id="";
  var uuid = const Uuid();
  String name = "";
  double value = .0;

  Item()
  {
    id = uuid.v1();
  }
}

class Store
{
  var uuid = Uuid();
  String id = "";
  String name = "";
  String street = "";
  String zip = "";
  String city = "";

  Store()
  {
    id = uuid.v1();
  }
}

// make one ScanIteration per image
class CurrentBill
{

  bool isBill = false;

  Store store = Store();


  final soundex = Soundex.genealogyEncoder;

  Iterable<String> shops =
  [
    "kaufland",
    "lidl",
    "lodl", // they really use a hard to read logo
    "rewe"
  ];

  //
  Iterable<String> sumLabels =
  [
    'summe',
    'gesamt'
    'bruttoumsatz',
    'endsumme',
    'summen',
    'summe eur'
  ];

  //breaks
  Iterable<String> currencyTitle =
  [
    'eur',
    '€',
    'betrag'
  ];

  String onlyDigits(String stringToExtractDigitsFrom)
  {
    String cleaned = "";
    final RegExp onlyDigits = RegExp
    (
      r'\d+'
    );
    Iterable<RegExpMatch> digits
    = onlyDigits.allMatches(stringToExtractDigitsFrom);
    if(digits.isNotEmpty)
    {
      String? extract = "";
      extract = digits.first.group(0);
      if(extract!=null){cleaned=extract;}
    }
    return cleaned;
  }

  String onlyNumberParts(String toClean)
  {
    String cleaned = "";
    final RegExp onlyDigits = RegExp
    (
      r'-?[\d]*[,|.]*[\d]*'
    );

    Iterable<RegExpMatch> digits
    = onlyDigits.allMatches(toClean);
    if(digits.isNotEmpty)
    {
      for(RegExpMatch match in digits)
      {
        String? extract = "";

        extract = match.group(0);
        if (extract != null)
        {
          cleaned += extract;
        }
      }
    }
    return cleaned.replaceAll(" ", "");
  }

  String cleanPrice(String priceToClean)
  {
    // remove empty spaces
    String cleanStep = onlyNumberParts(priceToClean);
    // split along the commas.
    List<String> parts = cleanStep.split(",");

    cleanStep = onlyDigits(parts.first) + "." + onlyDigits(parts.last);
    return cleanStep;
  }

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


  ItemList findItems()
  {
    ItemList items = ItemList();

    print("findItems was called");

    // searched for a number of multiplications (signaled by * or x)
    final RegExp multiples  = RegExp
    (
      r'^[\d]+.*[x|X|*]$'
    );

    // searches for a typical price / sum at the end of a line
    final RegExp price      = RegExp
    (
      r'^-?[ ]*[\d]*[,|.][ ]?\d\d.*$'
    );

    // used to extract exact price
    final RegExp exactPrice = RegExp
    (
      r'^-?[ ]*[\d]+[,|.]\d\d'
    );

    final RegExp onlyDigits = RegExp
    (
      r'\d+'
    );
    
    final RegExp germanDate = RegExp
    (
      r'(0[1-9]|[12][0-9]|3[01])[.](0[1-9]|1[012])[.](19|20)[0-9]{2}'
    );

    bool theCounteningHathBegun = false;
    bool theCounteningHathEnded = false;

    double sum = .0;
    bool sumNotFound = true;

    String currentLabel  = "";
    int    NumberOfItems =  0;
    double pricePerItem  = .0;
    double interSum      = .0;

    bool   foundAnInterSum        = false;
    bool   foundAMultiplyer       = false;
    bool   foundIndividualPrice   = false;
    bool   foundTheLabel          = false;
    bool   lookForLabelInNextLine = false;
    bool   lookForPriceNextRow    = false;

    List<Line> aboveSum = [];


    for(Line line in lines.toList())
    {
      if(!theCounteningHathBegun)
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
            print("Found a sum");
            for (Block block in line.parts)
            {
              print("-" + onlyNumberParts(block.fulltext) + "-");
              if (onlyNumberParts(block.fulltext).contains(price))
              {
                print("Found the sum here");
                sumNotFound = false;
                sum = double.parse(cleanPrice(block.fulltext));
                items.sum = sum;
                print("The sum of all sums = " + sum.toString());
                theCounteningHathBegun = true;
              }
            }
            if (sumNotFound) {
              print("but no money");
            }
          }
        }
          // this is after the inner four loop
      }
      if(!theCounteningHathBegun)
      {
        aboveSum.add(line);
      }
    }
    // a clear seperation between finding the sum and the items
    for(Line line in aboveSum.reversed)
    {
      if(!theCounteningHathEnded)
      {
        print("* looking at new line *");

        String breakingPoint = "";
        // first, look for the breaks
        List<String> wordsInLastLine = line.parts.last.fulltext.split(" ");
        if(wordsInLastLine.isNotEmpty)
        {
          breakingPoint = wordsInLastLine.last.toLowerCase();
        }
        for(String Safetyword in currencyTitle)
        {
          if(breakingPoint.contains(Safetyword))
          {
            theCounteningHathEnded = true;
          }
        }

        for(Block block in line.parts.reversed)
        {
          if(!foundAnInterSum){
          print("looking for price");
          print("-" + block.fulltext + "-, ");
          print("at -" + onlyNumberParts(block.fulltext) + "-");}
          // look for price
          if
          (
            !foundAnInterSum &&
              onlyNumberParts(block.fulltext).contains(price)
          )
          {
            print("found a price");
            print(cleanPrice(block.fulltext));
            interSum = double.parse(cleanPrice(block.fulltext));
            print("The interim sum of this articles " + interSum.toString());
            foundAnInterSum = true;
          }
        }
        // look for multiples
        for(Block block in line.parts)
        {
          print("lookForLabelInNextLine " + lookForLabelInNextLine.toString());
          print("foundAMultiplyer " + foundAMultiplyer.toString());

          if
          (
           !lookForLabelInNextLine &&
            !foundAMultiplyer
          )
          {
            print("Testing for Multiplyer - "+ block.fulltext + "-");
          }

          if
          (
            !lookForLabelInNextLine &&
            !foundAMultiplyer &&
            block.fulltext.contains(multiples)
          )
          {
            print("I found a multiplyer");
            // find multiplyerfinal

            Iterable<RegExpMatch> timesOfItem
            = onlyDigits.allMatches(block.fulltext);
            if(timesOfItem.isNotEmpty)
            {
              String? extract = "";
              extract = timesOfItem.first.group(0);
              if(extract != null)
              {
                NumberOfItems = int.parse(extract);
              }
              print("there are  " + NumberOfItems.toString() + " items");
              foundAMultiplyer = true;
            }
            lookForLabelInNextLine = true;
            lookForPriceNextRow = true;
          }
          if
          (
             !lookForPriceNextRow &&
             !foundIndividualPrice &&
              foundAMultiplyer
          )
          {
            print("Testing for individual price after Multiplyer was found -" +
                onlyNumberParts(block.fulltext) + "-");
          }
          if
          (
            !lookForPriceNextRow &&
            !foundIndividualPrice &&
            foundAMultiplyer &&
              onlyNumberParts(block.fulltext).contains(price)
          )
          {
            //this price has to be the
            //individual items price

            print("Parsing individual price");


            pricePerItem = double.parse(cleanPrice(block.fulltext));
            foundIndividualPrice = true;
            print("The price per item is supposed to be " + pricePerItem.toString());

            if(pricePerItem == interSum)
            {
              // the sum we found earlier is just the price per item
              // still need to look for that sum.
              // And yes, some bills have the sum first, than the parts.
              foundAnInterSum = false;

            }
          }
          lookForPriceNextRow = false;
        }
        if(lookForLabelInNextLine)
        {
          lookForLabelInNextLine = false;
        }
        else
        {
          print("supposed to look for the label under following conditions");
          print("foundTheLabel "+foundTheLabel.toString()+" foundAnInterSum = " +foundAnInterSum.toString());
          if
          (
            !foundTheLabel&&foundAnInterSum
          )
          {
            // all other stuff is found,
            // than this can only be the last missing peace
            foundTheLabel = true;
            currentLabel = line.parts.first.fulltext;

            print("It is named -" + currentLabel + "- ");

            if(NumberOfItems==0)
            {
              NumberOfItems==1;
            }

            for (int i = 0; i < NumberOfItems; i++)
            {
              Item currentPart = Item();
              currentPart.name = currentLabel;
              currentPart.value = pricePerItem;
              items.product.add(currentPart);
              print(currentLabel + "  " + pricePerItem.toString());
            }

            foundAnInterSum      = false;
            foundTheLabel        = false;
            foundAMultiplyer     = false;
            foundIndividualPrice = false;
          }
        }
      }
    }

    double endsumCalculated = .0;
    for(Item product in items.product.reversed)
    {
      endsumCalculated += product.value;
      print(product.name + ", " + product.value.toString() + " Eur");
    }
    print("------------");
    print(endsumCalculated.toString() + " Eur");

    bool isStillLookingForNames = true;
    bool finishedCity = false;
    bool finishedDate = false;

    String storeName = "";
    // now for the rest of inormations
    for(Line line in lines.toList())
    {


      if(isStillLookingForNames)
      {
        List<String> parts = line.parts.first.fulltext.split(" ");
        if(!parts.isEmpty)
        {
          print("parts.first -" + parts.first +
            '- parts.last -' + parts.last + '-');
          if(onlyNumberParts(parts.first).isEmpty
              &&
              parts.last == onlyNumberParts(parts.last))
          {
            items.store.street = line.parts.first.fulltext;

            storeName = storeName.substring(0, storeName.length - 1);
            items.store.name = storeName;
            isStillLookingForNames = false;
          }
          storeName += line.parts.first.fulltext + "\n";
        }
      }
      if(!finishedCity)
      {
        List<String> parts = line.parts.first.fulltext.split(" ");
        if
        (
          parts.isNotEmpty &&
          onlyNumberParts(parts.first).length==5
        )
        {
          items.store.zip = onlyNumberParts(parts.first);
          items.store.city = parts.last;
          finishedCity = true;
        }
      }
      if(!finishedDate)
      {

        for(Block block in line.parts)
        {
          Iterable<RegExpMatch> DateInItem
          = germanDate.allMatches(block.fulltext);
          if (DateInItem.isNotEmpty)
          {
            String? extract = "";
            extract = DateInItem.first.group(0);
            if(extract != null)
            {
              print("Ein Date? = -" + extract + "-");
              if(extract.length>9)
              {
                String dateFormat =
                  extract.substring(6,10) + "-" +
                  extract.substring(3,5)  + "-" +
                  extract.substring(0,2)   ;
                print("-" + dateFormat + "-");
                items.date = DateTime.parse(dateFormat);
              }

            }
          }

        }

      }
    }

    return items;
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