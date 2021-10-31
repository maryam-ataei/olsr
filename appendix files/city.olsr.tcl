#=================================================
#                     Init.
#=================================================

set scriptStart [clock seconds]         ;# start time of the simulation
# ====================================================================== 
# Define options
# ======================================================================
set val(chan)   Channel/WirelessChannel		      ;# channel type
set val(prop)   Propagation/TwoRayGround		      ;# radio-propagation model
set val(netif)  Phy/WirelessPhy		      ;# network interface type
set val(mac)    Mac/802_11		      ;# MAC type
set val(ifq)    Queue/DropTail/PriQueue		      ;# interface queue type
set val(ll)     LL		      ;# link layer type
set val(ant)    Antenna/OmniAntenna		      ;# antenna model
set val(ifqlen) 50		      ;# max packet in ifq
set val(rp)      OLSR
set opt(nn) 182;# how many nodes are simulated
set opt(tracedir)   olsr_out_files/
set opt(outdir)     olsr_out_files/

set opt(filename)   $opt(tracedir)out           ;# base filename for traces
#set opt(vnfilen)    $opt(filename)-highway_10.tr     ;# vanet tracelog

set opt(x)     852			      ;# x coordinate of topology
set opt(y)     1252			     ;# y coordinate of topology
set opt(stop)      1000.999   ;# simulation end time
remove-packet-header PGM PGM_SPM PGM_NAK Pushback NV LDP MPLS rtProtoLS Ping
remove-packet-header TFRC TFRC_ACK Diffusion RAP TORA IMEP MIP
remove-packet-header IPinIP Encap HttpInval MFTP SRMEXT SRM aSRM
remove-packet-header  CtrMcast rtProtoDV GAF Snoop TCPA TCP IVS
remove-packet-header Resv UMP Src_rt
global defaultRNG
$defaultRNG seed 1

#=================================================
#                      MAC
#=================================================

# this should be more or less 802.11a
Mac/802_11 set dataRate_            6.0e6
Mac/802_11 set basicRate_           6.0e6
Mac/802_11 set CCATime              0.000004
Mac/802_11 set CWMax_               1023
Mac/802_11 set CWMin_               15
Mac/802_11 set PLCPDataRate_        6.0e6
Mac/802_11 set PLCPHeaderLength_    50
Mac/802_11 set PreambleLength_      16
Mac/802_11 set SIFS_                0.000016
Mac/802_11 set SlotTime_            0.000009

# 300m, default power, freq, etc... These can be calculated with
# the tool in ns-allinone-2.29/ns-2.29/indep-utils/propagation/
Phy/WirelessPhy set RXThresh_   15.154867e-11     ;# 200m at 5.15e9 GHz
Phy/WirelessPhy set freq_       5.15e9
Phy/WirelessPhy set Pt_         0.281838        ;# value for the 300m case..
if {$argc !=1} {
puts stderr "Error! ns called with wrong number of arguments!($argc)"
exit 1
} else {
set f [lindex $argv 0]
} 
#set default-RNG 19
# seed the default RNG
global defaultRNG
$defaultRNG seed $f
set num 0
set num [expr ($f*10)+100]
puts " num: $num and f:$f"
set opt(sc)         scenario/scenario5/180/city$num.tcl
#set opt(sc)         scenario/velocity5/scenario5/180/city$num.tcl

#=================================================
# define a 'finish' procedure
#=================================================
proc eval1 {s i} {
	global zof zofx zofX xpos node_ ns_ null_ udp_ p
	set zof [$node_($s) set X_]
        set xpos [$node_($i) set X_]
#set zofx [expr $zof+9500]
#set zofX [expr $zof+10000]
set zofx 7000
set zofX 8000
if (($xpos<=$zofX)&&($xpos>$zofx)) {
puts " it is test node :$i,position:$xpos "
  set udp_($i) [new  Agent/UDP]
    $ns_ attach-agent  $node_($i)  $udp_($i)
set null_($i) [new Agent/Null]
$ns_ attach-agent $node_($i) $null_($i)

}
}

# (executed at the end of the simulation to parse results, etc).
proc finish {} {
    global ns_ tracefd
    global ns_ vanettracefd
    global opt
    global scriptStart

$ns_ flush-trace
    close $tracefd
 set scriptEnd [clock seconds]           ;# end-time of the simulation

        seconds (End: [clock format $scriptEnd -format {%d.%m.%y %H:%M:%S}])"
  puts "Finishing ns.."
    exit 0                                  ;# ... and we're done
}
# ======================================================================
# Main Program
# ======================================================================
# 
# Initialize Global Variables
# 
set ns_ [new Simulator]
set tracefd [open $opt(filename).tr w]
$ns_ use-newtrace
$ns_ trace-all $tracefd

Agent/OLSR set use_mac_    true
Agent/OLSR set debug_      true
Agent/OLSR set willingness 3
Agent/OLSR set ack_ival_   1

# set up log-trace file (where the agents will dump their tables, etc)
#set vanettracefd [open $opt(vnfilen) w]
#set VanetTrace [new Trace/Generic]
#$VanetTrace attach $vanettracefd

# set up topography object
set topo    [new Topography]
$topo load_flatgrid $opt(x) $opt(y)
proc log-movement {} {
  global logtimer ns_ ns
  set ns $ns_
  source /home/maryam/ns-allinone-2.35/ns-2.35/tcl/mobility/timer.tcl
  Class LogTimer -superclass Timer
  LogTimer instproc timeout {} {
      global opt node_;
      for {set i 0} {$i < $opt(nn)} {incr i} {
          $node_($i) log-movement
      }
      $self sched 1
  }
  set logtimer [new LogTimer]
  $logtimer sched  1
}

# 
# Create God
# 
create-god $opt(nn)

# Configure node

set chan_1_ [new $val(chan)]
$ns_ node-config  -adhocRouting $val(rp) \
 		 -llType $val(ll) \
 		 -macType $val(mac) \
 		 -ifqType $val(ifq) \
 		 -ifqLen $val(ifqlen) \
 		 -antType $val(ant) \
 		 -propType $val(prop) \
 		 -phyType $val(netif) \
 		 -topoInstance $topo \
 		 -agentTrace ON \
 		 -routerTrace ON \
 		 -macTrace ON \
 		 -movementTrace ON \
 		 -channel $chan_1_  

Agent set debug_ true       ;# to get displayed the debug()-messages... if you
                            ;# make a batch of simulations, comment this out!


for {set i 0} {$i < $opt(nn)} {incr i} {
  set node_($i) [$ns_ node $i]
  $node_($i) random-motion 0 ;# disable random motion
# create some agents and attach them to the nodes
}
for {set i 0} {$i < $opt(nn)} {incr i} {
 set udp_($i) [new  Agent/UDP]
   $ns_ attach-agent  $node_($i)  $udp_($i)
set null_($i) [new Agent/Null]
$ns_ attach-agent $node_($i) $null_($i)}
for {set i 0} {$i < $opt(nn)} {incr i} {
for {set j 0} {$j < $opt(nn)} {incr j} {
$ns_ connect $udp_($i) $null_($j)
}
}


for {set q 0} {$q < 1000} {incr q} {
$ns_ at [expr ($q+100)] "$udp_(181) loadfile"
}

$udp_(181) set dst_addr_ 0xE000000
set cbr_(1) [new Application/Traffic/CBR]
$cbr_(1) set packetSize_ 512
$cbr_(1) set interval_ 1
$cbr_(1) set random_ 1
$cbr_(1) set maxpkts_ 10000
$cbr_(1) set dst_ 0xE000000
$node_(181) set X_ 510.0                                                     #450
$node_(181) set Y_ 880.0                                                   #300
$node_(181) set Z_ 0.0
$node_(180) set X_ 720     #for destination region between 700 to 900
$node_(180) set Y_ 70.0
$node_(180) set Z_ 0.0  


source $opt(sc)
for {set i 0} {$i < $opt(nn)} {incr i} {
$ns_ at 100 "eval1 1 $i"
}
$ns_ at 900 "$cbr_(1) stop"
source $opt(sc)
$ns_ at $opt(stop) "finish"
for {set i 0} {$i < $opt(nn) } {incr i} {
    $ns_ at 1000 "$node_($i) reset";
}

# run the simulation
$ns_ run

# Tell nodes when the simulation ends
#

