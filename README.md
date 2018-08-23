# tcltk-deploy
[![Build Status](https://ci.sagrid.ac.za/buildStatus/icon?job=tcltk-deploy)](https://ci.sagrid.ac.za/job/tcltk-deploy) [![DOI](https://zenodo.org/badge/48986476.svg)](https://zenodo.org/badge/latestdoi/48986476)

Build, test and deploy scripts for [Tcl/Tk](https://tcl.tk/) from CODE-RADE

## Dependencies

This project has no dependencies

## Versions

Versions built are:

  1. 8.6.8

## Configuration

It seems there is no easy way to turn off building against X, so what the hell, we keep that in the standard location.

The builds are configured with :

### TK configuration

```
--enable-64bit \
--enable-shared \
--enable-threads \
```

### TCL configuration

```
--with-tcl=${WORKSPACE}/tcl${VERSION}/unix/build-${BUILD_NUMBER} \
--enable-threads  \
--enable-shared \
--enable-64bit \
--enable-xft
```
## Citing

Cite as
Bruce Becker. (2017). SouthAfricaDigitalScience/tcltk-deploy: CODE-RADE Foundation Release 3 - Tcl/Tk [Data set]. Zenodo. http://doi.org/10.5281/zenodo.571827
