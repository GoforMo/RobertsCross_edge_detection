# Introduction

This project runs through an FPGA implementation of the [Roberts Cross](https://en.wikipedia.org/wiki/Roberts_cross "RC") (RC) operation for Edge Detection on an image. It is a discrete differential operator that approximates the gradient of an image. Two images, a blackbuck and junkyard boeing plane are used to show the simulation results of a synthesizable rtl RC module.  

The goal of this exercise is to visualize the RC Operator in action with a real image using simulation first. It is untested in hardware due to time limitations. <!--TODO : maybe try to test in hardware, time permitting--> Vivado 2023.2 is used for simulation. 

# Contents

    1. images folder
        a. blackbuck_grayscale
        b. boeing_grayscale
        
