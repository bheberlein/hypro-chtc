# Introduction to HTCondor

## References

- [CHTC Guides](...)
- [HTCondor Manual](https://htcondor.readthedocs.io/en/latest/index.html)
- [HTCondor Introduction](https://htcondor.readthedocs.io/en/latest/apis/python-bindings/tutorials/HTCondor-Introduction.html)
- [HTCondor Developer Technical Overview](https://htcondor-wiki.cs.wisc.edu/index.cgi/wiki?p=DeveloperTechnicalOverview)

> ### 3 levels of complexity
>
> 1. HTCondor is software that manages networks of computers to efficiently perform computational tasks
> 2. Submit node, worker nodes, ...
> 3. Central manager, daemons, ...

HTCondor is a distributed computing framework that enables job scheduling and execution across a networked cluster of machines.

HTCondor can manage thousands of jobs and nodes, making it suitable for both small clusters and large grids.

A mix of different hardware and operating systems may be integrated in a single pool.

> HTCondor is a specialized batch system for managing compute-intensive jobs. HTCondor provides a queuing mechanism, scheduling policy, priority scheme, and resource classifications. Users submit their compute jobs to HTCondor, HTCondor puts the jobs in a queue, runs them, and then informs the user as to the result.

## ClassAds

**ClassAds** are HTCondor's system for rigorously describing availability & capability of computing resources.

Both a job's runtime requirements and a worker machine's capabilities are expressed as ClassAds, allowing flexible matchmaking.

## Cluster Structure

- **Central Manager**: The heart of the cluster, responsible for coordinating and matchmaking between jobs and resources.
- **Submit Nodes**: Machines where users submit jobs. These are often the access points for end users.
- **Worker Nodes**: Machines that execute jobs. These can be desktops, servers, or other computational resources.

Each machine runs one or more HTCondor daemons depending on its role.

## HTCondor Daemons

A **daemon** is a long-running background process that attends to some task.

All machines in the cluster are running some kind of HTCondor daemon.

### Central Manager Daemons

The Central Manager node runs the Collector & Negotiator daemons, which provide the functional backbone of the computing system.

#### Collector

The **Collector** maintains a central inventory of all the pieces of the HTCondor pool.

- Tracks the state of all machines in the pool.
- Gathers resource advertisements from worker nodes and job availability from submit nodes.
- Acts as a directory service, enabling communication across the cluster.

The Collector gathers descriptions of the states of all the daemons in your HTCondor pool. It provides both **service discovery** and **monitoring** for these daemons.

For example, each machine that can run jobs will advertise a ClassAd describing its resources and state. In this module, we'll learn the basics of querying the collector for information and displaying results.

The Schedd maintains a queue of jobs and is responsible for managing their execution. We'll learn the basics of querying the schedd.

#### Negotiator

The **Negotiator** is responsible for matching jobs to worker nodes.

- Matches jobs to available resources using policies and priorities.
- Negotiates between job requests and resource offers to assign tasks to worker nodes.

### Submit Node Daemons

#### Schedd

The **Schedd** (scheduler) daemon is responsible for submitting jobs to the pool.

- Manages user job queues on the submit node.
- Handles job submission, monitoring, and result retrieval.
- Communicates with the Central Manager to find suitable worker nodes.
- Can queue jobs locally if the cluster is busy, ensuring eventual execution.

#### Shadow

Additional **Shadow** daemons are spawned for each running job

> Every machine in the pool has certain properties: its architecture, operating system, amount of memory, the speed of its CPU, amount of free swap and disk space, and other characteristics. Similarly, every job has certain requirements and preferences. ... The owner of a job specifies the requirements and preferences of the job when it is submitted. The properties of the computing resources are reported to the central manager by the startd on each machine in the pool. The negotiator's task is not only to find idle machines, but machines with properties that match the requirements of the jobs, and if possible, the job preferences.

<!-- -->
> When a match is made between a job and a machine, the HTCondor daemons on each machine are sent a message by the central manager. The schedd on the submitting machine starts up another daemon, called the "shadow". This acts as the connection to the submitting machine for the remote job, the shadow of the remote job on the local submitting machine. The startd on the executing machine also creates another daemon, the "starter". The starter actually starts the HTCondor job, which involves transferring the binary from the submitting machine. (See figure 2). The starter is also responsible for monitoring the job, maintaining statistics about it, making sure there is space for the checkpoint file, and sending the checkpoint file back to the submitting machine (or the checkpoint server, if one exists). In the event that a machine is reclaimed by its owner, it is the starter that vacates the job from that machine.

### Worker Node Daemons

#### Startd

The **Startd** daemon

- Advertises the machine's availability and resources (CPU, memory, etc.) to the Central Manager.

- Accepts and runs jobs sent by the Schedd.

Starter:

- A helper process spawned by Startd to execute the job on the worker node.
- Manages the job's lifecycle (e.g., starting, suspending, terminating).

Shared Utility Daemons

- Master:
  - Oversees the other daemons on a machine, ensuring they are running and restarting them if they fail.
  - Runs on every machine in the cluster.
- Shadow:
  - Manages a job's execution on the submit node side.
  - Handles tasks like transferring files to/from the worker node.

Workflow Overview

- Job Submission:
  - A user writes a submit file defining the job's requirements (e.g., executable, arguments, resources).
  - The job is submitted via condor_submit to the Schedd daemon on the submit node.
- Resource Advertisement:
  - Worker nodes, via Startd, advertise their availability and resource specifications to the Collector.
- Matchmaking:
  - The Negotiator daemon queries the Collector for available jobs and resources.
  - Matches jobs to resources based on user-defined policies (e.g., resource requirements, priorities).
- Job Execution:
  - Once matched, the Schedd contacts the matched Startd to send the job.
  - The Startd spawns a Starter process to execute the job.
  - The Shadow process on the submit node handles file transfers and monitors job progress.
- Completion and Cleanup:
  - After execution, results are sent back to the submit node.
  - The job's status is updated in the queue, and any remaining cleanup is handled by the Starter and Shadow.

Communication and Configuration

- Communication: HTCondor daemons communicate using TCP/IP. All daemons rely on the Collector for discovery and use well-defined protocols to interact.
- Configuration:
  Each machine has a configuration file (condor_config) specifying roles, policies, and parameters.
  Policies control job priorities, resource allocation, preemption, and scheduling behavior.
  Key Features
  ClassAds:

Your Access Point
As a user:

- You submit jobs to a Schedd daemon on an access point (submit node).
- Schedd communicates with the Central Manager to find resources.

## Implementation Details

### Submit Files

- [Sample submit description files](#...)
- [Submitting many similar jobs with one queue command](#...)
- [Variables in the Submit Description File](#...)
- [Including Submit Commands Defined Elsewhere](#...)
- [Using Conditionals in the Submit Description File](#...)
- [Function Macros in the Submit Description File](#...)

### File Transfer Mechanism

- [File Transfer Mechanism](https://htcondor.readthedocs.io/en/latest/users-manual/file-transfer.html)

#### Input Files

- the executable, as defined with the `executable` command
- the input, as defined with the `input` command
- any other files, directories etc that HTCondor is to transfer to the remote scratch directory, to set up the execution environment for the job before it is run. This should be given as a comma-separated ist to the `transfer_input_files` command.  
- (for the java universe) any jar files, as defined with the `jar_files` command

### Output Files

- If only a subset of the output sandbox is to be transferred, use `transfer_output_files` command in the submit file
