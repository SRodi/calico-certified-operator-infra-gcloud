## Infrastructure for Calico Certified Operator Level 1

The script `infra.sh` allows to manage the lifecycle of the VM used for the completion of **Calico Certified Operator Level 1**. It provisions a Google Cloud compute instance with support for nested virtualization.

Please note the default machine type and zone are as follows:
`n1-standard-4` (this machine satisfies the requirements for the course -  https://cloud.google.com/compute/docs/machine-types)
and zone `europe-west1-b`. These values can be updated in `values` file.

### Prerequisites

The following are the requirements for the successful execution of the script

1. Create a Google Cloud account
2. Install Google Cloud SDK [following this instructions](https://cloud.google.com/sdk/docs/install)
2. Execute from Unix based OS (MacOS or Linux)

### Quick start

To execute the script run:

```bash
./infra.sh <OPTION>
```

Available Options:

 *   **authenticate**       [ Authenticate to gcloud, create project and configure defaults ]
 *   **create**             [ Create disk, image and VM with nested virtualization enabled ]
 *   **ssh**                [ ssh into VM ]
 *   **start**              [ (re-)Start VM ]
 *   **stop**               [ Stops VM ]
 *   **destroy**            [ Destroy VM, image and disk ]

```bash
./infra.sh authenticate
```

### Working with the VM

Once the instance is created you can access it with `./infra.sh ssh`. You will have to update the permission in order to run Multipass commands. You can do so by running `sudo chown $USER:$USER /var/snap/multipass/common/multipass_socket`.

To check that nested virtualization is enabled run `grep -cw vmx /proc/cpuinfo`. A nonzero response confirms that nested virtualization is enabled.

From this point onwards you can [continue with week 1 Calico Certified Operator L1](https://courses.academy.tigera.io/courses/course-v1:tigera+CCO-L1+CCO-L1-2020/courseware/34335c1507344450bbda775dd4460119/bf1560778a764aeaada7bb423860bcce/3?activate_block_id=block-v1%3Atigera%2BCCO-L1%2BCCO-L1-2020%2Btype%40vertical%2Bblock%404268c3adc81943c4a970a91432689321) course and proceed with step `Validating the Lab Orchestrator Installation`

### Disclaimer

No error handling was implemented. This is a very simple `happy path` script that leverages `gcloud cli` and helps handling the infrastructure to complete the course. No guarantees are given on the correct functioning or future support in case of updates to the course content/material.

### Issues and possible solutions

Any prompted errors come directly from gcloud cli. Some common errors you might come across:
1. You are trying to create a resource that already exist (mitigate by changing the name in `value` file or ignore if you need to use that resource such as project/disk/image )
2. You authenticated to wrong google account (mitigate by running again `./infra.sh authenticate` and authenticate to the right account)
3. You are trying to re-enable compute api but the api is still on process to be disabled (mitigate by waiting for a few min more)
