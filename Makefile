RELEASE=4.1

QBVERSION=1.0.1
QBRELEASE=1
QBDIR=libqb-${QBVERSION}
QBSRC=libqb-${QBVERSION}.orig.tar.gz

ARCH:=$(shell dpkg-architecture -qDEB_BUILD_ARCH)

DEBS=									\
	libqb0_${QBVERSION}-${QBRELEASE}_${ARCH}.deb			\
	libqb0-dbg_${QBVERSION}-${QBRELEASE}_${ARCH}.deb		\
	libqb-dev_${QBVERSION}-${QBRELEASE}_${ARCH}.deb

all: ${DEBS}
	echo ${DEBS}

${DEBS}: ${QBSRC}
	rm -rf ${QBDIR}
	tar xf ${QBSRC} 
	cp -a debian ${QBDIR}/debian
	cd ${QBDIR}; dpkg-buildpackage -rfakeroot -b -us -uc


download:
	rm -rf libqb-${QBVERSION} libqb-${QBVERSION}.orig.tar.gz
	git clone git://github.com/ClusterLabs/libqb.git libqb-${QBVERSION}
	cd libqb-${QBVERSION}; git checkout v${QBVERSION}
	cd libqb-${QBVERSION}; ./autogen.sh
	tar czf libqb-${QBVERSION}.orig.tar.gz libqb-${QBVERSION}/

.PHONY: upload
upload: ${DEBS}
	umount /pve/${RELEASE}; mount /pve/${RELEASE} -o rw 
	mkdir -p /pve/${RELEASE}/extra
	rm -f /pve/${RELEASE}/extra/libqb*.deb
	rm -f /pve/${RELEASE}/extra/Packages*
	cp ${DEBS} /pve/${RELEASE}/extra
	cd /pve/${RELEASE}/extra; dpkg-scanpackages . /dev/null > Packages; gzip -9c Packages > Packages.gz
	umount /pve/${RELEASE}; mount /pve/${RELEASE} -o ro

.PHONY: clean
clean:
	rm -rf *~ debian/*~ *_${ARCH}.deb *.changes *.dsc ${QBDIR} libqb_${QBVERSION}.orig.tar.gz

.PHONY: dinstall
dinstall: ${DEBS}
	dpkg -i ${DEBS}
