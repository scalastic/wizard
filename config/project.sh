#!/usr/bin/env bash

declare -Ax project
declare -Ax project_language
declare -Ax project_build
declare -Ax project_architecture
declare -Ax project_architecture_layers=()

declare -x name=0
declare -x version=1
declare -x description=2
declare -x path=3

project[$name]="Project 1"

project_language[$name]="Java"
project_language[$version]="1_8"
project_build[$name]="Maven"
project_build[$version]="3_3_9"

project_architecture[$name]="3-tier"
project_architecture[$description]="Presentation, Business+Data tiers"

project_architecture_layers[0,$name]="Presentation"
project_architecture_layers[0,$path]="front/"
project_architecture_layers[0,$description]="User interface"

project_architecture_layers[1,$name]="Business"
project_architecture_layers[1,$path]="service/"
project_architecture_layers[1,$description]="Business logic"
