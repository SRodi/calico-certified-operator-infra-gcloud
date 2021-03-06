#!/bin/bash

: '
Create a gcloud VM for Calico Certified Operator Level 1 course.

This script satisfy the requirements specified for the course
https://courses.academy.tigera.io/courses/course-v1:tigera+CCO-L1+CCO-L1-2020/courseware/34335c1507344450bbda775dd4460119/bf1560778a764aeaada7bb423860bcce/2?activate_block_id=block-v1%3Atigera%2BCCO-L1%2BCCO-L1-2020%2Btype%40vertical%2Bblock%4047286ffb436843c0838ef22449d50568

Google Cloud docs to set up VM instance with nested virtualization enabled:
https://cloud.google.com/compute/docs/instances/enable-nested-virtualization-vm-instances

' 

source values

config(){

    gcloud config set project $GCP_PROJECT
    gcloud config set compute/region $GCP_REGION
    gcloud config set compute/zone $GCP_ZONE

}

authenticate(){

    # authenticate to gcloud
    gcloud auth login --no-launch-browser

    # create project (might already exist)
    gcloud projects create $GCP_PROJECT

    config
}

create(){

    # enable compute API
    gcloud services enable compute.googleapis.com

    # Create a disk from the debian-9 image family with 200GB pd storage
    # you can ignore the warning ".. You might need to resize the root repartition manually .."
    # as the operating system supports automatic resizing
    gcloud compute disks create $NAME-disk \
            --image-project debian-cloud \
            --image-family debian-9 \
            --zone $GCP_ZONE \
            --size 200 \
            --type pd-standard

    # create custom image with special licence key for nested virtualiztion
    gcloud compute images create $NAME-nested-vm-image \
            --source-disk $NAME-disk \
            --source-disk-zone $GCP_ZONE \
            --licenses "https://www.googleapis.com/compute/v1/projects/vm-options/global/licenses/enable-vmx"
    
    # Create a VM instance using the new custom image with the license.
    gcloud compute instances create $NAME-nested-vm \
            --zone $GCP_ZONE \
            --min-cpu-platform "Intel Haswell" \
            --image $NAME-nested-vm-image \
            --machine-type=$MACHINE_TYPE \
            --metadata-from-file startup-script=$START_UP_SCRIPT_REL_PATH

}

ssh(){

echo "
        Check that nested virtualization is enabled by running the following 
        command. A nonzero response confirms that nested virtualization is enabled.
        
        grep -cw vmx /proc/cpuinfo

        On first boot give it a couple of minutes to run the startup script.


        $(tput bold)$(tput setab 1)!! Change permissions for multipass socket !!$(tput sgr 0)

        Enter the following:
        $(tput setaf 0)$(tput setab 6)sudo chown $USER:$USER /var/snap/multipass/common/multipass_socket$(tput sgr 0)

"

    # Connect to the VM instance
    gcloud compute ssh $NAME-nested-vm \
            --zone $GCP_ZONE

}

destroy(){

    gcloud compute instances delete $NAME-nested-vm \
            --zone $GCP_ZONE -q
    
    gcloud compute images delete $NAME-nested-vm-image -q

    gcloud compute disks delete $NAME-disk \
            --zone $GCP_ZONE -q

    gcloud services disable compute.googleapis.com
    
}

stop(){

  gcloud compute instances stop $NAME-nested-vm \
            --zone $GCP_ZONE -q
}

start(){

  gcloud compute instances start $NAME-nested-vm \
            --zone $GCP_ZONE -q
}

case "$1" in

  authenticate)
    authenticate
    exit;;

  create)
    create
    exit;;

  ssh)
    ssh
    exit;;

  destroy)
    destroy
    exit;;

  start)
    start
    exit;;

  stop)
    stop
    exit;;

  *)
    echo "

    ------------------------------------------

    Prerequisites:

      1. Update $(tput setaf 0)$(tput setab 6)values$(tput sgr 0) file with constant values for the project

      2. Create a gcloud account

    ------------------------------------------

    Usage Options:

    authenticate      [ Authenticate to gcloud, create project and configure defaults ]
    create            [ Create disk, image and VM with nested virtualization enabled ]
    ssh               [ ssh into VM ]
    start             [ (re-)Start VM ]
    stop              [ Stops VM ]
    destroy           [ Destroy VM, image and disk ]

    
    "
    exit;
    ;;
esac
