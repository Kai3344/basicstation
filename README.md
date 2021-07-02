# LoRa Basics™ Station for sx1301 and sx1302 LoRa concentrators

This project deploys a LoRaWAN gateway with Basic™ Station Packet Forward protocol using docker. It runs on a Raspberry Pi (3/4) or balenaFin with sx1301 and sx1302 LoRa concentrators (e.g. RAK833, RAK2245, RAK2247, RAK2287 and IMST iC880a among others).


## Introduction

Deploy a The Things Stack (TTS v3) LoRaWAN gateway running the Basics™ Station Semtech Packet Forward protocol in a docker container inside your Raspberry Pi or compatible SBC. 

The Basics™ Station protocol enables the LoRa gateways with a reliable and secure communication between the gateways and the cloud and it is becoming the standard Packet Forward protocol used by most of the LoRaWAN operators.

This project has been tested with The Things Network (TTN v2) and The Things Stack Community Edition (TTSCE or TTNv3).


## Requirements


### Hardware

* Raspberry Pi 3/4 or [balenaFin](https://www.balena.io/fin/)
* SD card in case of the RPi 3/4

Any of these LoRa concentrators:

* SX1301 
> * [IMST iC880a](https://shop.imst.de/wireless-modules/lora-products/8/ic880a-spi-lorawan-concentrator-868-mhz)
> * [RAK 833 Concentrator](https://store.rakwireless.com/products/rak833-gateway-module)*
> * [RAK 2245 Pi Hat](https://store.rakwireless.com/products/rak2245-pi-hat)
> * [RAK 2247 Concentrator](https://store.rakwireless.com/products/rak2247-lpwan-gateway-concentrator-module)*

* SX1302
> * [RAK 2287 Concentrator](https://store.rakwireless.com/products/rak2287-lpwan-gateway-concentrator-module)* with [RAK 2287 Pi Hat](https://store.rakwireless.com/products/rak2287-pi-hat)

Other concentrators might also work. Please note that only SPI versions are supported at the moment.

### Software

If you are going to use docker to deploy the project, you will need:

* An OS image for your board (Raspberry Pi OS, Ubuntu OS for ARM,...)
* Docker (and optionally docker-compose) on the machine (see below for instal·lation instructions)

If you are going to use this image with Balena, you will need:

* A balenaCloud account ([sign up here](https://dashboard.balena-cloud.com/))

On both cases you will also need:

* A The Things Stack V3 account [here](https://ttc.eu1.cloud.thethings.industries/console/)
* [balenaEtcher](https://balena.io/etcher) to burn the image on the SD or the BalenaFin


Once all of this is ready, you are able to deploy this repository following instructions below.


## Installing docker & docker-compose on the OS

If you are going to run this project directly using docker (not using Balena) then you will need to install docker on the OS first. This is pretty staring forward, just follow these instructions:

```
sudo apt-get update && sudo apt-get upgrade -y
curl -sSL https://get.docker.com | sh
sudo usermod -aG docker ${USER}
newgrp docker
sudo apt install -y python3 python3-dev python3-pip libffi-dev libssl-dev
sudo pip3 install docker-compose
sudo systemctl enable docker
```

Once done, you should be able to check the instalation is alright by testing:

```
docker --version
docker-compose --version
```


## Deploy the code


### Via docker-compose

You can use the next `docker-compose.yml` file to configure and run your instance of Basics™ Station. 

```
version: '3.7'

services:

  basicstation:
    image: xoseperez/basicstation:aarch64-latest
    container_name: basicstation
    restart: unless-stopped
    privileged: true
    network_mode: host      # required to read main interface MAC instead of virtual one
    environment:
      MODEL: "SX1301"
      GW_GPS: "false"
      GW_RESET_GPIO: 17
      GW_ENABLE_GPIO: 0
      TTN_STACK_VERSION: 3
      TTN_REGION: "eu1"
      #TC_URI:              # uses TTN server by default, based on the TTN_STACK_VERSION and TTN_REGION variables
      #TC_TRUST:            # uses TTN certificates by default
      TC_KEY: "..."
```

Modify the environment variables to match your setup. You will need a gateway key (`TC_KEY` variable above) to connect it to your LoRaWAN Network Server (LNS). If you want to do it beforehand you will need the Gateway EUI. Check the `Gate the EUI of the LoRa Gateway` section below to know how. Otherwise, check the logs messages when the service starts to know the Gateway EUI to use.


### Via [Balena Deploy](https://www.balena.io/docs/learn/deploy/deploy-with-balena-button/)

Running this project is as simple as deploying it to a balenaCloud application. You can do it in just one click by using the button below:

[![](https://www.balena.io/deploy.png)](https://dashboard.balena-cloud.com/deploy?repoUrl=https://github.com/balenalabs/basicstation)

Follow instructions, click Add a Device and flash an SD card with that OS image dowloaded from balenaCloud. Enjoy the magic 🌟Over-The-Air🌟!


### Via [Balena-CLI](https://www.balena.io/docs/reference/balena-cli/)

If you are a balena CLI expert, feel free to use balena CLI.

- Sign up on [balena.io](https://dashboard.balena.io/signup)
- Create a new application on balenaCloud.
- Clone this repository to your local workspace.
- Using [Balena CLI](https://www.balena.io/docs/reference/cli/), push the code with `balena push <application-name>`
- See the magic happening, your device is getting updated 🌟Over-The-Air🌟!


## Configure the Gateway


### Define your MODEL

The model is defined depending on the version of the concentrator: ```SX1301``` or ```SX1302```. 

In case that your LoRa concentrator is a ```RAK2287``` it is using ```SX1302```. If the concentrator is the ```RAK2245``` or ```iC880a``` it uses the ```SX1301```. The default model is the ```SX1301```.

You can change the model on the `docker-compose.yml` file if running it directly on the OS or using the BalenaCloud Dashboard:

1. Go to balenaCloud dashboard and get into your LoRa gateway device site.
2. Click "Device Variables" button on the left menu and change the ```MODEL``` variable to ```SX1302``` if needed.

That enables a fleet of LoRa gateways with both (e.g.) ```RAK2245``` and ```RAK2287``` together under the same app.


### Define your REGION and TTN STACK VERSION

From now it's important to facilitate the ```TTN_STACK_VERSION``` that you are going to use: ```3``` (The Things Stack v3) or ```2``` (The Things Network or TTN V2). The default variable is set into ```3```(V3).

Before starting, also check the ```TTN_REGION```. It needs to be changed if your region is not Europe. In case you use version 3, the European version is ```eu1```. Check [here](https://www.thethingsnetwork.org/docs/lorawan/frequencies-by-country.html) the LoRa frequencies by country.

With these variables ```TTN_REGION``` and ```TTN_STACK_VERSION``` the ```TC_URI``` will be generated automatically. In case that you want to point to another specific ```TC_URI```, feel free to add this Device Variable on the balenaCloud.


### Get the EUI of the LoRa Gateway

The LoRa gateways are manufactured with a unique 64 bits (8 bytes) identifier, called EUI, which can be used to register the gateway on The Things Network and The Things Stack. To get the EUI from your board it’s important to know the Ethernet MAC address of it (this is not going to work if your device does not have Ethernet port). 

The ```EUI``` will be the Ethernet mac address (6 bytes), which is unique, expanded with 2 more bytes (FFFE). This is a standard way to increment the MAC address from 6 to 8 bytes.

To get the ```EUI```, copy the TAG of the device which will be generated automatically when the device gets provisioned on balenaCloud for first time. Be careful when you copy the tag, as other characters will be copied.

If that does not work, open a terminal to the host OS and type:

```
GATEWAY_EUI=$(cat /sys/class/net/eth0/address | sed -r 's/[:]+//g' | sed -e 's#\(.\{6\}\)\(.*\)#\1fffe\2#g')
GATEWAY_EUI=${GATEWAY_EUI^^}
echo $GATEWAY_EUI
```

Copy the result and you are ready to register your gateway with this EUI.


### Configure your The Things Stack gateway (V3)

1. Sign up at [The Things Stack console](https://ttc.eu1.cloud.thethings.industries/console/).
2. Click "Go to Gateways" icon.
3. Click the "Add gateway" button.
4. Introduce the data for the gateway.
5. Paste the EUI from the balenaCloud tags.
6. Complete the form and click Register gateway.
7. Once the gateway is created, click "API keys" link.
8. Click "Add API key" button.
9. Select "Grant individual rights" and then "Link as Gateway to a Gateway Server for traffic exchange ..." and then click "Create API key".
10. Copy the API key generated. and bring it to balenaCloud as ```TC_KEY```.


### Configure your The Things Network gateway (V2)

1. Sign up at [The Things Network console](https://console.thethingsnetwork.org/).
2. Click Gateways button.
3. Click the "Register gateway" link.
4. Check “I’m using the legacy packet forwarder” checkbox.
5. Paste the EUI from the balenaCloud tag or the Ethernet mac address of the board (calculated above)
6. Complete the form and click Register gateway.
7. Copy the Key generated on the gateway page.


### Basics Station Service Variables

These variables you can set them under the `environment` tag in the `docker-compose.yml` file or using an environment file (with the `env_file` tag). If you are using Balena you can also set them in the `Device Variables` tab for the device (or globally for the whole application).

Variable Name | Value | Description | Default
------------ | ------------- | ------------- | -------------
**`MODEL`** | `STRING` | ```SX1301``` or ```SX1302``` | ```SX1301```
**`GW_GPS`** | `STRING` | Enables GPS | true or false
**`GW_RESET_PIN`** | `INT` | Pin number that resets (Raspberry Pi header number) | 11
**`GW_RESET_GPIO`** | `INT` | GPIO number that resets (Broadcom pin number, if not defined, it's calculated based on the GW_RESET_PIN) | 17
**`GW_ENABLE_GPIO`** | `INT` | GPIO number that enables power (by pulling HIGH) to the concentrator (Broadcom pin number) | 0
**`GW_ID`** | `STRING` | TTN Gateway EUI | (EUI)
**`TTN_STACK_VERSION`** | `INT` | If using TTN, version of the stack. It can be either 2 (TTNv2) or 3 (TTS Community Edition) | 3
**`TTN_REGION`** | `STRING` | Region of the TTN server to use | ```eu1``` (```eu``` when using TTN v2)
**`TC_TRUST`** | `STRING` | Certificate for the server | Automatically retrieved from LetsEncryt based on the `TTN_STACK_VERSION` value
**`TC_URI`** | `STRING` | Basics Station TC URI to get connected.  | 
**`TC_KEY`** | `STRING` | Unique TTN Gateway Key used for TTS Community Edition | (Key pasted from TTN console)
**`GW_KEY`** | `STRING` | Unique TTN Gateway Key used for TTNv2 | (Key pasted from TTN console)

Whe using The Things Stack Community Edition (`TTN_STACK_VERSION` to 3) the `TC_URI` and `TC_TRUST` values are automatically populated to use ```wss://eu1.cloud.thethings.network:8887```. If your region is not EU you can set it using ```TTN_REGION```. At the moment there is only one server avalable is ```eu1```. If you are still using the old TTN server (`TTN_STACK_VERSION` to 2) `TC_URI` and `TC_TRUST` values are automatically populated to use ```wss://lns.eu.thethings.network:443```. If your region is not EU you can set it using ```TTN_REGION```, Possible values are ```eu```, ```us```, ```in``` and ```au```.


## Troubleshoothing

It's possible that on the TTN Console the gateway appears as Not connected if it's not receiving any LoRa message. Sometimes the websockets connection among the LoRa Gateway and the server can get broken. However a new LoRa package will re-open the websocket between the Gateway and TTN or TTI. This issue should be solved with the TTN v3.

Feel free to introduce issues on this repo and contribute with solutions.


## Attribution

- This is an adaptation of the [Semtech Basics Station repository](https://github.com/lorabasics/basicstation). Documentation [here](https://doc.sm.tc/station).
- This is in part working thanks of the work of Jose Marcelino from RAK Wireless, Xose Pérez from Allwize and Marc Pous from balena.io.
- This is in part based on excellent work done by Rahul Thakoor from the Balena.io Hardware Hackers team.
