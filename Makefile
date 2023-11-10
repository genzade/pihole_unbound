build:
	wget -O ./unbound/iana.d/root.zone https://www.internic.net/domain/root.zone
	sudo chown -R root:1000 ./unbound/
