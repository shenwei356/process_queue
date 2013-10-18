
#!/usr/bin/env perl
use strict;
die "Usage: $0 int\n" unless @ARGV == 1;
my $m = shift @ARGV;
my $p = 2;
for (1..$m) {
	for (1..$m) {
		for (1..$m) {
   			$p = $p + (sqrt $p) / $p;
   		}
   	}
}
print "$p\n";

