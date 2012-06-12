#!/usr/bin/env rdmd
/* 
Programmed in the D language
Fredrik Boulund 2012-05-30
 Simple attempt at stupid FASTA parser without
any form of sanity checks or such. Just the simplest
possible object oriented approach to a data structure
with FASTA objects.
 It can now retrieve records using regexp parsing of 
header lines.
*/

import std.getopt; // Parse command line arguments
import std.regex; // regexp retrieval of records
import std.string; // chomp
import std.file; // File handling
import std.stdio; // writeln, writefln etc.

/*
  FastaStruct with two string fields
*/
struct FastaStruct
{
	string header = "";
	string sequence = "";
}


/*
  Simplest possible FASTA parser taking a filename,
  returning an array of FastaStructs.
  It is very stupid and performs no sanity checks
*/
FastaStruct[] parseFasta(string filename)
{
	int recordcounter = 0;
	FastaStruct[] recordsFromFile; // Stores all fasta records

	/* Open fastaFile for reading */
	File fastaFile = File(filename, "r"); 
	/* Read one line at a time */
	foreach (string line; lines(fastaFile))
	{
		if (line[0] == '>')
		{
			recordsFromFile ~= FastaStruct("",""); // Append new record to array
			recordcounter = cast(int)recordsFromFile.length;
			recordsFromFile[recordcounter-1].header = chomp(line);
		}
		else
		{
			recordsFromFile[recordcounter-1].sequence = recordsFromFile[recordcounter-1].sequence ~ chomp(line);
		}
	}

	return recordsFromFile;
}

void writeToFile(string fileOut, FastaStruct[] FastaRecords, string searchReg)
{
	/* Write all matched records to file */
	auto headerReg = regex(searchReg);
	File outFile = File(fileOut, "w");
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
	string searchReg ="";
	File outFile;
	File fastaFile;	
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
