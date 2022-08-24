FROM alpine:latest AS prepare

RUN apk add --update --no-cache wget xz git
RUN wget -O pandoc-crossref-Linux.tar.xz https://github.com/lierdakil/pandoc-crossref/releases/latest/download/pandoc-crossref-Linux.tar.xz\
	&& tar --xz -xf pandoc-crossref-Linux.tar.xz
RUN git clone https://github.com/01mf02/pandocfilters.git 01mf02-pandocfilters\
	&& chmod ugo+x 01mf02-pandocfilters/*.py

FROM pandoc/latex:latest
COPY --from=prepare pandoc-crossref /opt/pandoc/
COPY --from=prepare 01mf02-pandocfilters/*.py /opt/pandoc/01mf02-pandocfilters/
RUN ln -sT /opt/pandoc/01mf02-pandocfilters/linkindex.py /usr/local/bin/pandoc-linkindex\
	&& ln -sT /opt/pandoc/01mf02-pandocfilters/linkref.py /usr/local/bin/pandoc-linkref\
	&& ln -sT /opt/pandoc/01mf02-pandocfilters/divenv.py /usr/local/bin/pandoc-divenv\
	&& ln -sT /opt/pandoc/01mf02-pandocfilters/listing.py /usr/local/bin/pandoc-float-listings
RUN apk add --update --no-cache make python3\
	&& ln -sT /usr/bin/python3 /usr/local/bin/python
RUN python3 -m ensurepip
RUN python3 -m pip install --no-cache-dir pandoc-acro pandoc-include pandocfilters
ENV PATH="$PATH:/opt/texlive/texdir/bin/x86_64-linux"
RUN tlmgr install koma-script acro translations hyphenat

WORKDIR /data
ENTRYPOINT ["pandoc", "--filter", "pandoc-include", "--filter", "pandoc-linkindex", "--filter", "pandoc-float-listings", "--filter", "pandoc-acro", "--filter", "pandoc-crossref", "--citeproc"]
