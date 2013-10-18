Process Queue
===============

Process queue for single-thread high cpu usage processes.

It control the number of running processes to avoid a large number (> number of CPU threads number) of processes running concurrently, which is inefficient due to processes switch.

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