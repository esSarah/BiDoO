# BiDoO

## Where to go now?
- Prepare "Lidl" and "Kaufland" parsing, where currently only "Rewe" works.
- Take some time to find and squish bugs.
- <p>Experimentation with slightly different concepts.<br>
Klassification to determin Store and select parsing rules accordingly?</p>
- Look for paid advertisment options via google
- publish mvp iteration II (hopefully with ads) on Playstore.

# First sprint done, MVP Prototyping:

Filobask Bill or Document OCR

## Project Structure

| Fixed Point in Time | Stardate | Status |
| ------------------- | -------- | ------ |
| Kickoff | 20220509 | (Done)
| Elevator Pitch | 20220511 | (Done) |
| Final Presentation | 20220520 | (Done) |

[Elevator Pitch Presentation](https://docs.google.com/presentation/d/1qFfitMDrd6ocsBSLyW3meEdjbTlGeKAU87XEDCRloGQ/edit?usp=sharing)

[Final Presentation](https://docs.google.com/presentation/d/15u0AsOKawuic-fKLVZcp7sxOaunpFYmzl4_W0Y_0J7c/edit?usp=sharing)

# Assignment

Free Project that applies the knowledge inspired by the [Ironhack Data Analytics bootcamp](https://www.ironhack.com/de/data-analytics).

# Idea

For my long term software project Filobask I was looking for a specialiced OCR for
supermarket bills. As target for OCR they are very special for quite some reasons.

- the heart, the product and price list, is not isolated or in a data format.
- the bill can be way longer than any usual scanning solution supports.
- Matrix printed fonts create problems for existing training sets.

My idea is to adress as many of those problems as possible.

# Organisation

I'm organizing the project with a [Kanban board on trello](https://trello.com/b/RyxosgRC/filobask-bill-or-document-ocr).


## Current Activities (Success)

- Creating the MVP as phone app (Flutter) with Google ML - no cleaning of the pictures neccessary, it is just brilliant.<br>
  *Making it myself would have been fun as well, but for something published I'd have to drop it anyway. I can't compete with most of the recent solutions*
  
# Current Status

- all is ready for the final presentation

## Completed Activities

- Complex Navigation and BloC Management added, Scan Results are shown in List. 
- Creation of a line object with relative placement in the bill and multible Blocks per line.
- Save Products list, Shop and Date info in local SQLite database
- Enable android export as denormalized CSV 
-
# Research

Since we used it so much in the course and it is basically the standard for data science prototyping, the first
impulse was to use python with opencv. thanks to the length of bills I want to test to catch data in real time from a video stream.

## Already Tested Frameworks

- python with webserver - stream works, but does not play nice with opencv
- python with Jupyter Notebook. Out of the book it stalls, there are complex solutions, but all in all not worth it.
- python with Qt UI - could work, but connection to Android notebook and its cam is flaky.
- Using Python directly on the phone.
- flutter application directly on the phone.

## Tested OCR

- Google Lens (became Plan B)
- Self made; Classification Random Forrest, ml assisted pre cleaning of the scan
- OpenCV
- Tessseract (Klassik)
- Google ML

## Plan B (discarded)
*in case everything else falls until 20220516*

- At least shorter bills can be converted to DOCX filetype by google lense. A nice mix of classifiers can look for the relevant data in there
