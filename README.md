# olsr
General Information
This repository contains the authors' C++ implementation of the paper An OLSR-based Geocast Routing Protocol for Vehicular Ad Hoc Networks (Springer 2021).
The code was developed on NS2 simulation tool and runs on Linux (Ubuntu, Mint).
Requirement
Install NS2 on Linux
Install SUMO and MOVE package to simulate traffic model and create a mobility trace file
Patch OLSR protocol to NS2
Performance Evaluation
Comparing the performance of the proposed OLSR-based method (Tuned version) to the AODV-based protocol (Multi-path AODV) and CALAR-DD protocol and the effects of destination region resizing, packet resizing, and the vehicles’ speed on the performance of these protocols.
Dependencies
Included:
NS2
SUMO
MOVE
AWK
Python
How to run
To simulate, we need the city.olsr.tcl file contained in the appendix files. The below commands are given to simulate the scenario (For instance: 180 nodes) defined in 3 different situations. The output results are stored in an olsr_out_files. Because the size of the output result file is so large, we also store the necessary output information in the file folder for ease of evaluation.
ns city.olsr.tcl 0
ns city.olsr.tcl 10
ns city.olsr.tcl 20
More Information
Because the execution of this code was very time-consuming, some files were used to store data used by the network nodes. However, its cost was also considered in evaluating the performance of the protocols.
Also, one of the Mobility trace files (180 nodes) is included in the appendix files as an example for simulation.
Contact
For any questions regarding the paper or the implementation, please contact Maryam Ataei. If you find a bug, please let us know.
