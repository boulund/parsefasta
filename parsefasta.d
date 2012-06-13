#!/usr/bin/env rdmd
/* 
Programmed in the D language
Fredrik Boulund 2012-05-30
 Simple attempt at stupid FASTA parser without
any form of sanity checks or such. Just the simplest
possible object oriented approach to a data structure
with FASTA objects.
 It can retrieve records using regexp parsing of 
header lines.
*/

import std.getopt; // Parse command line arguments
import std.regex; // regexp retrieval of records
import std.string; // chomp
//import std.file; // File handling
//import std.stream; // Stream handling
import std.stdio; // writeln, writefln etc.


/* FastaStruct with two string fields */
struct FastaStruct
{
	string header = "";
	string sequence = "";
}

/*
  Implementation using io.stream to read file line by line instead.
  Hope is to be able to read files larger than available memory
  efficiently.
*/
FastaStruct[] parseFasta(string filename)
{
	int recordcounter = 0;
	string currentLine;
	FastaStruct[] recordsFromFile; // Stores all fasta records

	/* Open fastaFile for reading */
	File fastaFile = File(filename, "r"); 
	/* Read one line at a time */
	currentLine = fastaFile.readln();
	while (!fastaFile.eof())
	{
		if (currentLine[0] == '>')
		{
			recordsFromFile ~= FastaStruct("",""); // Append new record to array
			recordcounter = cast(int)recordsFromFile.length;
			recordsFromFile[recordcounter-1].header = cast(string) chomp(currentLine);
		}
		else
		{
			recordsFromFile[recordcounter-1].sequence = recordsFromFile[recordcounter-1].sequence ~ cast(string) chomp(currentLine);
		}
		currentLine = fastaFile.readln();
	}

	return recordsFromFile;
}




void writeToFile(string fileOut, FastaStruct[] FastaRecords, string searchReg)
{
	/* Write all matched records to file */
	auto headerReg = regex(searchReg);
	File outFile = File(fileOut);
	foreach (FastaStruct record; FastaRecords)
	{
		auto m = match(record.header, headerReg);
		if (m)
		{
			outFile.writeln(record.header);
			outFile.writeln(record.sequence);
		}
	}
}

void printOut(FastaStruct[] FastaRecords, string searchReg)
{
	/* Print all matched records to stdout */
	auto headerReg = regex(searchReg);
	foreach (FastaStruct record; FastaRecords)
	{
		auto m = match(record.header, headerReg);
		if (m)
		{
			writeln(record.header);
			writeln(record.sequence);
		}
	}
}

void printHelp()
{
	writeln("Simple FASTA parser in D, Fredrik Boulund (c) 2012");
	writeln("  usage: parsefasta [options] file.fasta");
	writeln("Available options:\n"
	  "  -o, --output FILENAME  write output to filename instead of stdout\n"
	  "  -r, --retrieve REGEXP   use REGEXP to retrieve only matching records\n"
	  "  -h, --help              show this friendly and helpful message\n"
	  );
}

int main(string[] args)
{
	// Init variables
	bool help;
	string fileOut = "";
	string searchReg = "";
	FastaStruct[] FastaRecords;

	/* Parse command line options and arguments */
	if (args.length < 2)
	{
		printHelp();
		return 0;
	}
	try
	{
		getopt(args, 
			"o", &fileOut,
			"output", &fileOut,
			"r", &searchReg,
			"retrieve", &searchReg,
			"h", &help,
			"help", &help);

		if (help) 
		{
			printHelp();
			return 0;
		}
	}
	catch (Exception e)
	{
		writefln("%s\nType -h or --help for help", e.msg);
		return 1;
	}

	/+
	writefln("args array is: %s", args);
	writefln("fileout option is: %s", fileOut);
	writefln("print option is: %s", print);
	writefln("Input regexp is: \n%s", searchReg);
	+/

	/* Parse FASTA file */
	FastaRecords = parseFasta(args[1]);

	/* Print or write output */
	if (fileOut == "")
		printOut(FastaRecords, searchReg);
	else
		writeToFile(fileOut, FastaRecords, searchReg);

	return 0;
}
