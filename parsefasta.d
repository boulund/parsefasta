#!/usr/bin/env rdmd
/* 
Programmed in the D language
Fredrik Boulund 2012-05-30
 Simple attempt at stupid FASTA parser without
any form of sanity checks or such. Just the simplest
possible object oriented approach to a data structure
with FASTA objects.
*/

import std.getopt; // Parse command line arguments
import std.regex; // TODO: future implementation of grep-like regexp fetching of records
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


int main(string[] args)
{
	// Init variables
	string fileOut = "";
	File outFile;
	File fastaFile;	
	FastaStruct[] FastaRecords;

	/* Parse command line options and arguments */
	if (args.length < 2)
	{
		writeln("usage: parsefasta [options] file.fasta");
		writeln("Available options:\n  "
		  "--fileout FILENAME  output filename\n  ");
		return 0;
	}
	getopt(args, 
		"fileout", &fileOut);
	
	/+
	writefln("args array is: %s", args);
	writefln("fileout option is: %s", fileOut);
	writefln("print option is: %s", print);
	+/

	/* Parse FASTA file */
	FastaRecords = parseFasta(args[1]);
	
	if (fileOut == "")
	{
		/* Print all parsed records */
		foreach (FastaStruct record; FastaRecords)
		{
			writeln(record.header);
			writeln(record.sequence);
		}
	}
	else
	{
		/* Write all parsed records to file */
		outFile = File(fileOut, "w");
		foreach (FastaStruct record; FastaRecords)
		{
			writeln(record.header);
			writeln(record.sequence);
		}
	}
	return 0;
}
