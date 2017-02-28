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
	cd ${QBDIR}; dpkg-buildpackage -b -us -uc


download:
	rm -rf libqb-${QBVERSION} libqb-${QBVERSION}.orig.tar.gz
	git clone git://github.com/ClusterLabs/libqb.git libqb-${QBVERSION}
	cd libqb-${QBVERSION}; git checkout v${QBVERSION}
	tar czf libqb-${QBVERSION}.orig.tar.gz libqb-${QBVERSION}/

.PHONY: upload
upload: ${DEBS}
	tar cf - ${DEBS} | ssh repoman@repo.proxmox.com upload

.PHONY: clean
clean:
	rm -rf *~ debian/*~ *_${ARCH}.deb *.changes *.dsc ${QBDIR} libqb_${QBVERSION}.orig.tar.gz

.PHONY: dinstall
dinstall: ${DEBS}
	dpkg -i ${DEBS}
