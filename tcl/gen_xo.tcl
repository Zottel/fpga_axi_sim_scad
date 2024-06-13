#
# Copyright (C) 2019-2021 Xilinx, Inc
#
# Licensed under the Apache License, Version 2.0 (the "License"). You may
# not use this file except in compliance with the License. A copy of the
# License is located at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#

if { $::argc != 3 } {
    puts "ERROR: Program \"$::argv0\" requires 3 arguments!\n"
    puts "Usage: $::argv0 <xoname> <target> <device>\n"
    exit
}

set xoname  [lindex $::argv 0]
set target    [lindex $::argv 1]
set device    [lindex $::argv 2]

set suffix "scad_${target}_${device}"

#source -notrace ./tcl/package_kernel.tcl
source ./tcl/package_kernel.tcl

if {[file exists "${xoname}"]} {
    file delete -force "${xoname}"
}

set ctrl_protocol "ap_ctrl_hs"
package_xo -xo_path ${xoname} -kernel_name krnl_scad -ctrl_protocol ${ctrl_protocol} -ip_directory ./build/packaged_kernel_${suffix} -output_kernel_xml ./build/scad.xml
# -kernel_files cpp/scad_cmodel.cpp

