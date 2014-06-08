/*
   (C) 2014 Florian Huemer

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>
*/

%option noyywrap 

%{
#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <getopt.h>


char lowercase = 0;
char uppercase = 0;
char use_spaces = 0;
int spaces = 0;


%}


%%

(?i:abs|access|after|and|alias|all|architecture|array|assert|attribute|begin|block|body|buffer|bus|case|component|configuration|constant|disconnect|downto|else|elsif|end|entity|exit|file|for|function|generate|generic|guarded|if|impure|inout|in|inertial|is|label|library|linkage|loop|map|mod|nand|new|next|nor|not|null|of|on|open|or|others|out|package|port|postponed|procedure|process|pure|range|record|register|reject|rem|report|return|reverse_range|rol|ror|select|severity|shared|signal|sla|sll|sra|srl|subtype|then|to|transport|type|units|until|use|variable|wait|when|while|with|xnor|xor)  {

	int i = 0;

	if (lowercase )
	{
		while(yytext[i])
		{
			putchar (tolower(yytext[i]));
			i++;
		}
	}
	else if (uppercase)
	{
		while(yytext[i])
		{
			putchar (toupper(yytext[i]));
			i++;
		}
	}
	else
	{
		printf("%s",yytext);
	}
}

[A-Za-z\_](_?[0-9A-Za-z\_])* { printf( "%s", yytext ); }


\t          { 
	if(use_spaces)
	{
		int i = 0;
		while(i<spaces)
		{
			putchar(' ');
			i++;
		}
	}
	else
	{
		putchar('\t');
	}
}

\-\-.*$    {printf("%s", yytext);/* comment */}

.           printf( "%s", yytext );


%%


void help()
{
	printf("snippetformatter \n\n");
	printf("Usage example:\n");
	printf("snippetformatter [(-h|--help)] [(-l|--lowercase)] [(-u|--uppercase)] [(-s|--spaces) integer]\n\n");
	printf("Options:\n");
	printf("-h or --help: Displays this information.\n");
	printf("-l or --lowercase: print lower case keywords.\n");
	printf("-u or --uppercase: print upper case keywords.\n");
	printf("-s or --spaces integer: convert tabs to spaces.\n");
	exit(1);
}

int main(int argc, char **argv)
{
	// GetOpt option definition
	char *opt_spaces=0;

	int next_option;
	const char* const short_options = "hlus:";
	const struct option long_options[] =
		{
			{ "help", 0, NULL, 'h' },
			{ "lowercase", 0, NULL, 'l' },
			{ "uppercase", 0, NULL, 'u' },
			{ "spaces", 1, NULL, 's' },
			{ NULL, 0, NULL, 0 }
		};

	// Parse options
	while (1)
	{
		// Obtain a option
		next_option = getopt_long (argc, argv, short_options, long_options, NULL);

		if (next_option == -1)
			break; // No more options. Break loop.

		switch (next_option){

			case 'h' : // -h or --help 
				help();
				break;

			case 'l' : // -l or --lowercase
				lowercase=1;
				break;

			case 'u' : // -u or --uppercase
				uppercase=1;
				break;

			case 's' : // -s or --spaces
				use_spaces = 1;
				opt_spaces=optarg;
				spaces=atoi(opt_spaces);
				break;

			case '?' : // Invalid option
				help(); // Return help

			case -1 : // No more options
				break;

			default : // Something unexpected? Aborting
				return(1);
		}
	}
		 
	// Iterate over rest arguments called argv[optind]
	yyin = stdin;
	while (optind < argc)
	{
		yyin = fopen( argv[optind], "r" );
		optind++;
	}
	
	yylex();

	return 0;
}
