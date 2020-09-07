#!/usr/bin/perl 

# ok i want an 8MB video file for output on discord.  so this is just another ffmpeg wrapper


use Getopt::Long; 
use v5.10; 
use DDP; sub pp { p @_ };
use strict;use warnings;



=head1 SYNOPSIS

8mbwebm.pl [opts] [-o outfile] infile

 Options:
   -h, -help            brief help message
   -p			set prefix. "8MB_" is the default.
   -ss 			start time
   -to 			end time
   -s			new size like: 640x480
   -o 			not working
   -m 			change size in megabytes for output file
   -264, -2 		output in mp4 (aac + H.264) 
  			     ( libx264 + libfdk_aac in ffmpeg) 
   -d 			specify output directory instead of dir of file
default -codec is opus + vp9  ( libvpx-vp9, libopus in ffmpeg) 



=cut


my $progname = '8mbwebm.pl';
use Getopt::Long;
my $help;
my $outname;
my $prefix='8MB_';
my @realtime = ( '-deadline','realtime', '-cpu-used','4');  # 5 is 3x more quicker than 4, but hey it's working
my $realtime;
my $size ;
my $megabytes=8;
my $h264; 
my $outdir; 

my ($ss, $to);
GetOptions ('d=s',\$outdir,'h264',\$h264,'x264',\$h264,  '2',\$h264, '264', \$h264, 'm=f', \$megabytes, 'ss=s', \$ss, 'to=s',\$to, 's=s', \$size,  'r',\$realtime, 'p=s',\$prefix, 'o=s',\$outname, 'h', \$help,'help', \$help) || do { print STDERR "$0 found invalid option\n";exit 1};

say("$progname. Convert any video file to an 8MB .webm"),  Getopt::Long::HelpMessage if $help;
sub check_exists_command { 
	my $check = `sh -c 'command -v $_[0]'`; 
	return $check;
}
check_exists_command 'ffmpeg' or die "$0 requires ffmpeg";
check_exists_command 'mediainfo' or die "$0 requires mediainfo";

@realtime = () if !$realtime;
my $multi_pass = !scalar@realtime;

my @size = ( '-s', $size); @size = () unless $size;
my @ss  =  ('-ss', $ss); @ss = () unless $ss;
my @to =   ('-to', $to); @to = () unless $to; 

die 'not a directory' if $outdir and ! -d $outdir;
die 'directory not writable' if $outdir and ! -w $outdir;

sub count_lines_in_string { 
	$_ = shift;
	return 0 if( !defined $_ or $_ eq "");
	my $lastchar = substr $_, -1,1;
	my $numlines = () = /\n/g;
	return $numlines + ($lastchar ne "\n") # was last line wasn't a whole line with a "\n";
}
#:enew
#:r !mediainfo --Info-Parameters
sub callmediainfov2   {  # uh prototypes suck
	my $file  = shift; 
	my $group  = shift; # like General
	my $field  = shift;
	if ($field) {
		$_ = `mediainfo   --Inform="$group;%$field%"  "$file" `;
	} else {
		$_ = `mediainfo   --Inform="$group;"  "$file" `;
	}
	my $numlines = count_lines_in_string $_; 
	die 'too many lines mediainfo'. "$file $group $field"  if $numlines> 1 ; 

	chomp;$_}
sub callmediainfov :prototype($$)  {  # uh prototypes suck
	$a=shift;
	$b=shift;
	$_ = `mediainfo   --Inform="Video;%$b%"  "$a" `;chomp;$_}
sub mb () { 2 ** 20}
my $eight = int $megabytes *mb /1.027; # .4% container overhead webm
$eight *= 8; 
my $k = 1000;  # ffmpeg kbps is 1000, not 1024

sub to_seconds{
	my $has_ms = scalar $_[0] =~ /\.\d+/;

        my @components = split /[;:\.]/, $_[0];
	push @components, 0 if not $has_ms ; 

	@components = reverse @components;

	push @components, 0 if $#components < 3 ; # hours are opt.
	push @components, 0 if $#components < 3 ; # minutes are opt. 

# now we should have an array of ms, s, min, h. 

     	return (($components[3] * 60 + $components[2]) * 60 + $components[1])        + ".$components[0]";
#     	return (($components[3] * 60 + $components[2]) * 60 + $components[1]) * 1000 + ".$components[0]" * 1000;
}
sub to_seconds_conditional {
	$_ = shift;
	return to_seconds $_ if /[;:]/; # handle either case if time string  is 12.9 or 33:00.23
	return $_;
}

for my $file (@ARGV) { 
	my $ms = callmediainfov2 $file, 'General', 'Duration';
	 say("$progname fatal error: couldn't get duration of $file"), exit  unless $ms ;
	if ( $ss and $to ) { # try and adjust bitrate from "times" given.
		$ms =  to_seconds_conditional($to) *1000 - to_seconds_conditional($ss) *1000; 
	} elsif ($ss) {  
		$ms = $ms - to_seconds_conditional($ss) *1000; 
	}
	my $b_opus = 80;  $b_opus = 95 if $h264; 
	my $bits_remainder = $eight - ($b_opus * $k * $ms /1000);
	my $b_vp9  = $bits_remainder / ( $ms /1000) ;
	my @e = 'commandline.pl'; @e = (); 
	use File::Spec::Functions "splitpath";
	my          $newfile  =  "$outdir/". $prefix. (splitpath $file)[2] if $outdir;
	$newfile  =  ( splitpath $file)[1] . $prefix. (splitpath $file)[2] unless $outdir;
	 
	my @extensions = qw( 3gp$ ogm$ divx$ rmvb$ wmv$ mov$ mpeg$ mpg$ avi$ mkv$ mp4$ m4v$ mkv$ webm$ );
	for my $ext (@extensions) {
		my $reach;
		eval { $reach=qr/$ext/;$newfile =~ s/$reach//;}; 
	}
	$newfile .= $h264 ? 'mp4':'webm';
	say("$progname: error outfile already exists. $newfile") , exit 1 if -e $newfile; 

if ($multi_pass and !$h264) {
my $comment = "	 For two-pass targeting an average bitrate, the target bitrate is specified with the -b:v switch:
ffmpeg -i input.mp4 -c:v libvpx-vp9 -b:v 2M -pass 1 -an -f null /dev/null && \
ffmpeg -i input.mp4 -c:v libvpx-vp9 -b:v 2M -pass 2 -c:a libopus output.webm";
	$" = ' '; 
	my $ret; $ret = system ( @e ,"ffmpeg","-hide_banner", "-i", $file, split " ", "-c:v libvpx-vp9 @size @ss @to -b:v $b_vp9 -pass 1 -an -f null /dev/null");
	($ret >> 8) or 
	do { $ret=system(@e, "ffmpeg","-hide_banner",  "-i", $file, "-c:v","libvpx-vp9",@realtime, @size, @ss, @to, "-b:v",$b_vp9,"-pass","2","-c:a","libopus","-b:a","${\($b_opus * $k)}", $newfile); $ret>>=8;}; 
	print( "$progname failed on ffmpeg\n"),exit if $ret;
} elsif(1) {

	print(".\n.\n.\nwarning:  x264 tends to crash on durations less than 2.5s\n continue?"),getc  if $ms < 2600;
my $comment = "You can add -movflags +faststart as an output option if your videos are going to be viewed in a browser. This will move some information to the beginning of your file and allow the video to begin playing before it is completely downloaded by the
-preset slow
ffmpeg -y -i input -c:v libx264 -b:v 2600k -pass 1 -an -f null /dev/null && \
ffmpeg -i input -c:v libx264 -b:v 2600k -pass 2 -c:a aac -b:a 128k output.mp4";

	$" = ' '; 
	my $ret; $ret = system ( @e ,"ffmpeg","-hide_banner", "-i", $file, split " ", "-c:v libx264 -preset slow @size @ss @to -b:v $b_vp9 -pass 1 -an -f null /dev/null");
	($ret >> 8) or 
	do { $ret=system(@e, "ffmpeg","-hide_banner",  "-i", $file, "-c:v","libx264","-movflags", "+faststart", "-preset","slow", @size, @ss, @to, "-b:v",$b_vp9,"-pass","2","-c:a","libfdk_aac","-b:a","${\($b_opus * $k)}", $newfile); $ret>>=8;}; 
	print( "$progname failed on ffmpeg\n"),exit if $ret;
	}
elsif (0) {  # this was never useful on files that had bursts of high-bitrates.
# fix
	$b_vp9 *= .814; # the cpu-time parameter kind of defeats the whole intention of this program, honestly, since it makes the vp9 not care so much for bitrate param.  
	system @e, "ffmpeg","-hide_banner",  "-i", $file, "-c:v","libvpx-vp9",@realtime,"-b:v",$b_vp9,"-c:a","libopus","-b:a","${\($b_opus * $k)}", $newfile=~s/\.mp4$/\.webm/r;
}
	say "---- Completed OK ----";
	say "output file $newfile\nhas a size of ${\( (-s $newfile)/mb)} MB";
	$b_vp9 = int $b_vp9/1000;
	say $h264 ? "target bitrate was x264:$b_vp9 Kbps aac:$b_opus Kbps":"target bitrate was vp9:$b_vp9 Kbps opus:$b_opus Kbps";
	`bep` if check_exists_command 'bep';
}
