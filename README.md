#  HEIFU Docker

HEIFU Docker repository

## Initial Setup

Download your `config.bext` file from beXStream and replace `ControlDocker/config.bext` with it.

That's it!

## Usage

```bash
./runDockers.sh
```

##  Configuration

Some docker configuration can be done by editing the file:

* **SimulationDocker/rosCatkinEntrypoint.sh**
	* Vehicle type: 
		* `SimpleSim` for low memory docker usage
		* `heifu` to have the HEIFU dynamics
	* Location:
		* Position of simulated drone in LLA
	* Heading:
		* Initial `yaw` rotation in radians
* **ControlDocker/rosCatkinEntrypoint.sh**
	* Endpoint: 
		* Use one of follow `qa`, `preprod`, `prod`, `local`, `graca`, `newpreprod` for online usage
		* Or `localdocker` for offline usage with beXStream docker
