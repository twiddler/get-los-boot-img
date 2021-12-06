FROM fedora:34

RUN dnf update -y && dnf install python3.9 python3.9-pip python3.9-devel git unzip wget findutils gcc -y
COPY get-latest-boot-img.sh /root/
ENTRYPOINT ["bash", "/root/get-latest-boot-img.sh"]
