Process Queue
=============

**Please use [crun](https://github.com/shenwei356/crun)**.

Process queue for high CPU/RAM/time usage processes.

If you want to run a list of jobs which use high CPU/RAM or cost long time, a process queue is a good choice to run those jobs.

Process Queue control the number of running processes to avoid a large number (> number of CPU threads number) of processes running concurrently, which is inefficient due to processes switch.

HOW
---
Process Queue is a perl script. It create a Perl thread for every job and control the threads number.

Usage
-----
The first time you running process_queue.pl, a sample queue file "queue.txt" will be created.

You can edit the max number of threads running concurrently, and add a list of single-thread high cpu usage jobs. 

queue.txt:

    # max number of threads running concurrently
    MAX_THREADS_NUM = 4
    
    # jobs
    perl sample_job.pl 1000
    perl sample_job.pl 800
    perl sample_job.pl 400
    perl sample_job.pl 300
    perl sample_job.pl 600
    perl sample_job.pl 300

-----  
Copyright (c) 2013, Wei Shen (shenwei356@gmail.com)

[MIT License](https://github.com/shenwei356/process_queue/blob/master/LICENSE)