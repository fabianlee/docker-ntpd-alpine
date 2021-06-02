# docker-ntpd-alpine

openntpd takes about 5 minutes to finally get the "clock is now synced" message.  The peers can all be healthy, yet the it is not ready.  Calls from ntpdate will say "no server suitable for synchronization found"

Because of this, I instead used a chrony daemon with Alpine, and that is ready within 10 seconds.  See my description here: https://fabianlee.org/2021/06/02/docker-building-an-ntp-server-image-with-alpine-and-chrony/

