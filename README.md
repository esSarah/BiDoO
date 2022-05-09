# BiDoO
Filobask Bill or Document OCR

##Project Structure
| Fixed Point in Time | Stardate | Status |
| ------------------- | -------- | ------ |
| Kickoff | 20220509 | (Done)
| Elevator Pitch | 20220511 |  |
| Final Presentation | 20220520 |  |

# Assignment

Free Project that applies the knowledge inspired by the Ironhack Data Analytics bootcamp

# Idea

For my long term software project Filobask I was looking for a specialiced OCR for
supermarket bills. As target for OCR they are very special for quite some reasons.

- the heart, the product and price list, is not isolated or in a data format.
- the bill can be way longer than any usual scanning solution supports.
- Matrix printed fonts create problems for existing training sets.

My idea is to adress as many of those problems as possible.

# Organisation

I'm organizing the project with a [Kanban board on trello](https://trello.com/b/RyxosgRC/filobask-bill-or-document-ocr)

# Research

Since we used it so much in the course and it is basically the standard for data science prototyping, the first
impulse was to use python with opencv. thanks to the length of bills I want to test to catch data in real time from a video stream.

## Already tested frameworks

- python with webserver - stream works, but does not play nice with opencv
- python with Jupyter Notebook. Out of the book it stalls, there are complex solutions, but all in all not worth it.
- python with Qt UI - could work, but connection to Android notebook and its cam is flaky.

## current status

- test USB connected android notebook with Python QT on desktop / notebook
- test flutter application directly on the phone.
