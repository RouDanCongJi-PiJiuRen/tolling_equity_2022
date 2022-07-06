FROM continuumio/miniconda3
RUN conda install jupyterlab
# need latest jupyterlab to use altair
RUN conda update jupyterlab
RUN conda install geopandas
RUN pip install gpdvega
RUN conda install seaborn
RUN conda install scikit-learn
RUN conda install -c anaconda xlrd
RUN conda install -c conda-forge altair vega_datasets
RUN apt-get update && apt-get -y upgrade 
# unfortunately apt version of libsqlcipher-dev from debian-stretch apt in miniconda is too old (v3.4.x), you need sqlcipher v4.0.0+ (internally reports as v3.28)
# building it from scratch from source code below:
# (1/4) install compile tools, and openssl headers for sqlcipher compile
RUN apt-get -y install build-essential libssl-dev libreadline-dev
# (2/4) download and untar the latest release of sqlcipher source code (v4.2.0 at this time), into $HOME (which is /root/)
RUN cd $HOME && curl -L https://github.com/sqlcipher/sqlcipher/archive/v4.2.0.tar.gz | tar -zx
# (3/4) run the configure script, with dynamic linking (this is the suggested setup in sqlcipher's README)
RUN cd $HOME/sqlcipher-4.2.0 && ./configure --enable-tempstore=yes CFLAGS="-DSQLITE_HAS_CODEC" LDFLAGS="-lcrypto"
# (4/4) compile, install the compiled executable and library, and have OS rescan dynamic libraries to acknowledge the new library
# note that without more flags, "make install" installs into /usr/local/bin, which is not in $PATH of this miniconda image
RUN cd $HOME/sqlcipher-4.2.0 && make && make install && ldconfig
# install pysqlcipher3 (which builds and links against libsqlcipher)
RUN pip install pysqlcipher3
CMD jupyter lab --notebook-dir=/opt/dssg-hot --ip='0.0.0.0' --port=8877 --no-browser --allow-root
