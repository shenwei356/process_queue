#!/usr/bin/perl
# Copyright 2013 Wei Shen (shenwei356#gmail.com). All rights reserved.
# Use of this source code is governed by a MIT-license
# that can be found in the LICENSE file.

# Name    : Process queue for high CPU/RAM/time usage processes.
#           It control the number of running processes to avoid a
# 			large number (> number of CPU threads number) of processes
#			running concurrently, which is inefficient due to processes switch.
# Author  : Wei Shen
# Contact : shenwei356#gmail.com  
# Site    : http://shenwei.me, https://github.com/shenwei356
# Date    : 2013-10-18
# Update  : 2013-10-18

use strict;
use threads;

my $default_queue_file = "queue.txt";
my $usage              = <<"USAGE";
===============================================================================
Name   : Process queue for high CPU/RAM/time usage processes.
Contact: Wei Shen <shenwei356#gmail.com>
Usage  : $0 queue_file
a sample queue file "$default_queue_file" are given. 
===============================================================================

USAGE

my $queue_file;

if ( @ARGV == 0 ) {
    $queue_file = $default_queue_file;
    unless ( -e $queue_file ) {
        print $usage;
        &create_sample_queue_file();
    }
}
else {
    $queue_file = $ARGV[0];
}

# read jobs
my ( $para, $jobs ) = &read_jobs($queue_file);
die "MAX_THREADS_NUM should be given as an integer!\n"
  unless $$para{MAX_THREADS_NUM} > 0;
my $MAX_THREADS_NUM = int $$para{MAX_THREADS_NUM};

print "MAX_THREADS_NUM = $MAX_THREADS_NUM\n";

&run_jobs( $MAX_THREADS_NUM, $jobs );

sub run_jobs {
    my ( $MAX_THREADS_NUM, $jobs ) = @_;
    my ( %threads, $N_threads, $is_thread_joined, $job_id );
    for my $job (@$jobs) {
        $N_threads = keys %threads;

        # control threads ammount.
        if ( $N_threads >= $MAX_THREADS_NUM ) {
            while (1) {
                $is_thread_joined = 0;
                for ( keys %threads ) {
                    if ( $threads{$_}->is_joinable() ) {
                        $threads{$_}->join();
                        print "Job $_ finished.\n";
                        delete $threads{$_};    # join a thread
                        $is_thread_joined = 1;
                    }
                }
                last if $is_thread_joined;
                sleep 2;
            }
        }

        # run a new job
        $job_id++;
        $threads{$job_id} = threads->create( sub { `$job`; } );
        print "Job $job_id started: $job\n";
    }

    # wait all jobs
    while (1) {
        for ( keys %threads ) {
            if ( $threads{$_}->is_joinable() ) {
                $threads{$_}->join();
                print "job $_ finished.\n";
                delete $threads{$_};
            }
        }
        last if keys %threads == 0;
        sleep 1;
    }
    print "All jobs finished.\n";
}

sub read_jobs ($) {
    my ($file) = @_;
    my $para   = {};
    my $jobs   = [];
    open IN, $file or die "File $file failed to open.\n";
    while (<IN>) {
        s/^\s+//g;
        s/\s+$//g;
        next if $_ eq ''    # blank line
          or /^#/;          # annotation
        s/\#.*//g;          # delete annotation
        if (/([\w\_]+)\s*=\s*(.+)/) {
            warn "$1 was defined more than once\n" if defined $$para{$1};
            $$para{$1} = $2;
            warn "value of $1 undefined!\n" if $2 eq '';
        }
        else {
            s/\r?\n//;
            push @$jobs, $_;
        }
    }
    close IN;
    return ( $para, $jobs );
}

# Create sample queue file
sub create_sample_queue_file {
    my $sample_job_file = "sample_job.pl";
    &create_sample_job_file($sample_job_file);

    my $content = <<"QUEUE";
# max number of threads running concurrently
MAX_THREADS_NUM = 4

# jobs
perl $sample_job_file 1000
perl $sample_job_file 800
perl $sample_job_file 400
perl $sample_job_file 300
perl $sample_job_file 600
perl $sample_job_file 300

QUEUE
    open OUT, ">", "queue.txt"
      or die "Failed to create default queue file\n";
    print OUT $content;
    close OUT;

}

# The sample job file. It's a perl script which accept a integer and do some
# high cpu usage math work.
sub create_sample_job_file {
    my ($filename) = @_;
    my $content = q(
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

);
    open OUT, ">", $filename
      or die "Failed to create default queue file\n";
    print OUT $content;
    close OUT;
}
