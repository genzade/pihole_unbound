# Pihole Unbound Docker (Raspberry Pi)

## Prerequisites

First and foremost you need to [setup your raspberry pi](https://projects.raspberrypi.org/en/projects/raspberry-pi-setting-up/2).

Once that is setup you will need remote access and [here is a detailed guide](https://www.raspberrypi.com/documentation/computers/remote-access.html)
on how you can achieve this.

Make sure the above steps were done correctly before continuing. Once you have
established a ssh connection to the pi you will need to install docker and docker
compose.

Before coninuing

```bash
$ sudo apt-get update
$ sudo apt-get upgrade
```

`docker`

```bash
$ curl -sSL https://get.docker.com | sh
$ sudo usermod -aG docker $USER
```

See [this article](https://raspberrytips.com/docker-on-raspberry-pi/) for detailed
explanation.

`docker compose`

```bash
$ sudo apt-get update
$ sudo apt-get install docker-compose-plugin
```

First create a `.env` file to substitute variables for your deployment.

### Pi-hole environment variables

> Vars and descriptions replicated from the [official pihole container](https://github.com/pi-hole/docker-pi-hole/#environment-variables):

| Variable             | Default         | Value                                                                          | Description                                                                                                                                              |
| -------------------- | --------------- | ------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `TZ`                 | UTC             | `<Timezone>`                                                                   | Set your [timezone](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) to make sure logs rotate at local midnight instead of at UTC midnight. |
| `WEBPASSWORD`        | random          | `<Admin password>`                                                             | http://pi.hole/admin password. Run `docker logs pihole \| grep random` to find your random pass.                                                         |
| `FTLCONF_LOCAL_IPV4` | unset           | `<Host's IP>`                                                                  | Set to your server's LAN IP, used by web block modes and lighttpd bind address.                                                                          |
| `REV_SERVER`         | `false`         | `<"true"\|"false">`                                                            | Enable DNS conditional forwarding for device name resolution                                                                                             |
| `REV_SERVER_DOMAIN`  | unset           | Network Domain                                                                 | If conditional forwarding is enabled, set the domain of the local network router                                                                         |
| `REV_SERVER_TARGET`  | unset           | Router's IP                                                                    | If conditional forwarding is enabled, set the IP of the local network router                                                                             |
| `REV_SERVER_CIDR`    | unset           | Reverse DNS                                                                    | If conditional forwarding is enabled, set the reverse DNS zone (e.g. `192.168.0.0/24`)                                                                   |
| `WEBTHEME`           | `default-light` | `<"default-dark"\|"default-darker"\|"default-light"\|"default-auto"\|"lcars">` | User interface theme to use.                                                                                                                             |

Example `.env` file in the same directory as your `docker-compose.yaml` file:

```bash
FTLCONF_LOCAL_IPV4=192.168.1.10
TZ=America/Los_Angeles
WEBPASSWORD=QWERTY123456asdfASDF
REV_SERVER=true
REV_SERVER_DOMAIN=local
REV_SERVER_TARGET=192.168.1.1
REV_SERVER_CIDR=192.168.0.0/16
HOSTNAME=pihole
DOMAIN_NAME=pihole.local
PIHOLE_WEBPORT=80
WEBTHEME=default-light
```

Copy the example file to a file called `.env`, do this with;

```bash
$ cp .env.sample .env
```

Change the values as nesessary.

## Run it

You run it with the following command.

```bash
$ docker compose up -d
```

## Test it

From inside your raspberry pi start a bash session in the docker container.

```bash
$ docker exec -it pihole bash
```

And run the following;

```bash
$ dig fail01.dnssec.works @127.0.0.1 -p 5335 # this should fail (no response)
$ dig dnssec.works @127.0.0.1 -p 5335        # this should work and return an IP address
```

Read [this article](https://docs.pi-hole.net/guides/dns/unbound/) for a detailed
explanation of what is going on here.

If all is well update your router log into your router's configuration page and
find the DHCP/DNS settings and set it so that your router is pointing to your
raspberry pi's IP address. Note: make sure you adjust this setting under your
LAN settings and not the WAN.

Log into the admin dashboard of you pihole in a browser and you should start
seeing queries being blocked.
