FROM alpine:latest AS prepare

RUN apk add --update --no-cache wget xz 
RUN wget -O pandoc-crossref-Linux.tar.xz https://github.com/lierdakil/pandoc-crossref/releases/latest/download/pandoc-crossref-Linux.tar.xz\
	&& tar --xz -xf pandoc-crossref-Linux.tar.xz

FROM pandoc/latex:latest
COPY --from=prepare pandoc-crossref /opt/pandoc/
RUN apk add --update --no-cache make python3
RUN python3 -m ensurepip
RUN python3 -m pip install --no-cache-dir pandoc-acro pandoc-include
ENV PATH="$PATH:/opt/texlive/texdir/bin/x86_64-linux"
RUN tlmgr install koma-script acro translations

WORKDIR /data
ENTRYPOINT ["pandoc", "--filter", "pandoc-include", "--filter", "pandoc-acro", "--filter", "/opt/pandoc/pandoc-crossref", "--citeproc"]
