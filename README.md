# Electricity Consumption Monitor (ECM)
---
The Electricity Consumption Monitor is a service for creating a energy
consumption history and is called *ECM* in the further course of the document.

The *ECM* acts as a MQTT subscriber to collect the meter data from a Smart Meter.
Therefore a MQTT broker and MQTT publisher are needed
in order to user the *ECM*.

For instance we run the *ECM* in our setup with the *mosquitto* MQTT broker and the
*Tasmota ESP01S Smart Meter reader* as MQTT publisher.
See also [End to End tests](./e2e_tests/), [bayha-electronics](https://bayha-electronics.de/wiki/tasmota-smartmeter/)
and [youtube](https://www.youtube.com/watch?v=pYC3AiunNLA).

The maturity level of the *ECM* are visible via the release notes which are
embedded in the Git tags.
---

## Example Usage

The easiest, to use the ECM is via the *ecm_sdk*.
All dependencies are included in the *bank_account_monitor_sdk*.
See also [Dockerfile](./docker/Dockerfile).
All commands below have been tested only in an Ubuntu 22.04 environment
with Docker installed.

### Building the *ecm_sdk*

Enter the project root directory and execute the following command,
this will build the SDK.

        ./build_sdk.sh

### Starting the *ecm_sdk*

Enter the project root directory and execute the following command.
This will start the SDK and mount the project root directory in the SDK.

        ./run_sdk.sh

### Building the *ECM*

Is possible to build the *ECM* for ARMv7 and x64 Target architecture.
The following commands are available for building/cleaning the project:

        ./run_build.sh x64      // build for x64 target architecture
        ./run_build.sh armv7    // build for ARMv7 target architecture
        ./run_build.sh clean    // clean the project

### Staring the *ECM* service

The syntax for starting the *ECM* is as follows:

        ecm <meter data path> <url mqtt broker> <topic>

After starting the *ECM* is connecting to the MQTT broker and subscribe to the passed topic. The received meter data are stored in a flat file in JSON format.

## Dependencies

All dependencies of the project are listed in the Docker file. See also into the [Dockerfile](./docker/Dockerfile).

## License

The *ECM* is publish under this [License](./LICENSE). When you use the *ECM* in the way descried in the example above, you also shall consider the licenses of the [dependencies](#dependencies)