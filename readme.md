# BMHM - Baremetal hashmap implementation

## Introduction

A ~6 day adventure of implementing a linear-probing based hashmap on baremetal AMD64 with nothing but UEFI. UEFI was an extremely useful tool as it allowed me to easily output text to the screen, easily take user input, and allocate some memory.

## Features

Linear probing with tombstones
Growth when load-factor reacher 75%
Fully generic: callbacks for equality, hashing, pretty-printing, freeing
Microsoft x64 ABI throghout the program
UTF-16 strings
A simple user interface to test the implementation
No external libraries used (except UEFI of course)
