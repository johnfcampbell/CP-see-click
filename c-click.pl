#!/usr/bin/perl -w

use strict;
use LWP::Simple;

my $ticker;
#my %companies = getConfig();


open (MMP, '>seeclick.txt');
open (PCD, '>pcdclick.txt');
open (QXP, '>quarkscf.txt');

print QXP '<v6.50><e0>';
print QXP "\r";

print MMP '[STYL]pu,seefix ';
#print PCD '#SOM##metro,c-click,c-click,c-click#[,pu,seefix ';
print PCD '#SOM##seeclickfix,c-click,c-click,c-click#[,pu,seefix ';


#print %companies;

#foreach $ticker (sort keys %companies)
{

  my $searchURL = 'http://www.seeclickfix.com/issues.xml?above_map=issue_report&below_map=big_map_std&lat=39.93975130761637&left_map=issues_feeds_list&lng=-74.97482299804688&top_frame=advanced_search&zoom=11';
	$searchURL = 'http://www.seeclickfix.com/issues.xml?lat=39.93975130761637&lng=-74.97482299804688&zoom=11&sort=issues.rating&start=168&end=0&num_results=400';
	#$searchURL .= $ticker;
	my $content = get($searchURL) or die "could not get $searchURL";
	
	#my $content = jbbGet($searchURL) or die "could not get $searchURL";	
		
	$content =~ s/.*?(\<record\>.*)/$1/gs;
	$content =~ s/(\<\/record\>).{0,3}(\<record\>)/$1_IRP_$2/gs;
	
	
	my @records = split /_IRP_/,$content;
	
	
	my $record;
	
	foreach $record (@records)
	{
		if (notPA($record))
		{
			
			printMMP($record);
			printPCD($record);
			printQuark($record);
		
		}
	}
	
	#die "a natural death.";
	
	my $change;
	my $price = $content;

		


	#$change =~ s/...big..b.//;
	
	if (0 == 1) {
	print QXP $change;	
	print QXP "\n";
	
	print MMP $change;
	print MMP '[TR][TE]';
	print MMP "\n";
		
	print PCD $change;
	print PCD '[TR';
	print PCD "\n";
	

	print $content;
	print "\n===\n\n\n"
	}
}

print PCD '#EOM# ';

close PCD;
close MMP;
close QXP;

	die "a natural death.";




# ---------------------getConfig: Read the pop55 config file -----------------

sub getConfig

{


my %configlist;
my @configitems= (0,0,0,0,0,0);

open (CONFIG,"4S029list.dat") or die "No 4S029 company list";

while (<CONFIG>)
	{
			chomp;
			(my $stockName, my $ticker) = split '=',$_;
			$configlist{$ticker}= $stockName;
	}

close (CONFIG);

return %configlist;

}

# ---------------------printMMP: Markup map format -----------------

sub printMMP

{

	my $record = $_[0];
	print MMP "[STYL]gs1 ";
	print MMP summary($record);
	print MMP " [STYL]gs2 ";
	print MMP rating($record);
	print MMP " [STYL]gs3 ";
	print MMP address($record);
	print MMP " [STYL]gs4 ";
	print MMP description($record);
	print MMP '[PARA]';

	return;

}


# ---------------------printPCD: PCDump format -----------------

sub printPCD

{

	my $record = $_[0];
	print PCD "[,gs1 ";
	print PCD summary($record);
	print PCD " [,gs2 ";
	print PCD rating($record);
	print PCD " [,gs3 ";
	print PCD address($record);
	print PCD " [,gs4 ";
	print PCD description($record);
	print PCD '[EP';


	return;

}


# ---------------------printQuark: Xpress Tags -----------------

sub printQuark

{

	#print "record = ";
	#print $_[0];
	print "\n";
	print "summary = ";
	print summary($_[0]);
	print "\n";
	print "description = ";
	print description($_[0]);
	print "\n";
	print "rating = ";
	print rating($_[0]);
	print "\n";
	print "address = ";
	print address($_[0]);
	print "\n\n";

	my $record = $_[0];
	
	print QXP "\@fix-sum:";
	print QXP summary($record);
	print QXP "\<\\n\>\<\@fix-rate>";
	print QXP rating($record);
	print QXP "\<\\n\>\<\@fix-addr>";
	print QXP address($record);
	print QXP "\<\\n\>\<\@fix-desc>";
	print QXP description($record);
	print QXP "\n";


#@fix-sum:Pot holes
#@:<@fix-rate><a$$>50 people want this fixed. <\n><@fix-addr>24 Overbrook Dr  Cherry Hill<@><Is$t$h$z$k$b$c$f$><\n><@fix-desc><>Overbrook Dr in the Colwick section of Cherry Hill looks like the roads leading into Baghdad; a complete disaster area where many roadside bombs went off! The temporary fixes that you’ve been repairing them with for years  aren’t the answer, repave it with some of the high taxes you charge us with and do it right before someone gets killed...


	return;

}

# ---------------------jbbGet: Fetch Web page -----------------

# This will be the equivalent of get under LWP::Simple.
# But  we might not have LWP::SImple on cpoc or the Mac mini.
#
sub jbbGet
{
	my $browser = LWP::UserAgent->new();
	$browser->agent("Johns Bargain Browser");
	my $webdoc = $browser->request(HTTP::Request->new(GET => $_[0]));
	if ($webdoc->is_success)
		{
			return $webdoc->content;
		}
	else
		{
			return "";
		}

}

# ---------------------notPA: Filter results -----------------
# used to filter out results from Phila. and other parts of Pa.
# the URL defines radius from Cherry Hill.
# A slice of that radius would be from Pennsylvania locations,
# but that's not our coverage area.

sub notPA
{
	my $testString = $_[0];
	$testString =~ s/.*\x3caddress\x3e(.*)\x20*\x3c\x2faddress\x3e.*/$1_END_/igs;
	#	print "teststring = $testString \n";
	$testString =~ s/\x2c/\x20/g;
	#	print "string = $testString\n";
	$testString =~ s/\x20*USA\x20*_END_/_END_/g;
	#	print "string = $testString \n";
	$testString =~ s/\x20*19[01]\d\d\x20*_END_/_END_/g;
	#	print "string = $testString \n";
	$testString =~ s/\x20*_END_/_END_/g;
	#	print "string = $testString \n";		
		
	$_ = $testString;
	return (1 - (m/PA_END_/i));

}


# ---------------------summary: extract summary -----------------

sub summary
{
	my $record = $_[0];
	$record =~ s/.*\x3csummary.(.*)/$1/sgi;
	$record =~ s/\x3c\x2fsummary.*//sgi;

	if ($record eq $_[0])
		{ return "";}
	else
		{return $record;} 

}


# ---------------------extract description -----------------

sub description
{
	my $record = $_[0];
	$record =~ s/.*\x3cdescription.(.*)/$1/sgi;
	$record =~ s/\x3c\x2fdescription.*//sgi;

	if ($record eq $_[0])
		{ return "";}
	else
		{return $record;} 

}

# ------------rating: extract, turn into words -----------------

sub rating
{
	my $record = $_[0];
	$record =~ s/.*\x3crating.type..integer..(.*)/$1/sgi;
	$record =~ s/\x3c\x2frating.*//sgi;

	if ($record eq $_[0])
		{ return "";}
	else
		{
		if ($record eq '1')
			{return "1 person wants this fixed. ";}
		else
		{
		$record = $record . " people want this fixed. ";		
		return $record;
		} 
		}
}

# ---------------------extract, trim address -----------------

sub address
{
	my $record = $_[0];
	$record =~ s/.*\x3caddress.(.*)/$1/sgi;
	$record =~ s/\x3c\x2faddress.*//sgi;


	$record =~ s/USA$//gi;
	$record =~ s/08[0-9]{3}\x20*$//gi;
	$record =~ s/08[0-9]{3}\,*$//gi;
	$record =~ s/\,*\x20*NJ\,*\x20*//gi;

	if ($record eq $_[0])
		{ return "";}
	else
		{return $record;} 

}

