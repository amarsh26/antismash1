FROM kbase/sdkbase2:python
MAINTAINER KBase Developer
# -----------------------------------------
# In this section, you can install any system dependencies required
# to run your App.  For instance, you could place an apt-get update or
# install line here, a git checkout to download code, or run any other
# installation scripts.

RUN apt-get update && apt-get -y upgrade \
  && apt-get install -y --no-install-recommends \
    git \
    wget \
    g++ \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*



RUN rm /bin/sh && ln -s /bin/bash /bin/sh
RUN conda create -n py39 python=3.9 \
    && source activate py39 \
    && conda install nose jinja2 \
    && pip3 install jsonrpcbase numpy biopython \
    && pip3 install coverage

#RUN apt-get install -y apt-transport-https
#COPY ./ca-certificates.conf /etc/ca-certificates.conf
#RUN update-ca-certificates
RUN sudo wget https://dl.secondarymetabolites.org/antismash-stretch.list -O /etc/apt/sources.list.d/antismash.list
RUN sudo wget -q -O- https://dl.secondarymetabolites.org/antismash.asc | sudo apt-key add -
RUN sudo apt-get update
RUN apt-get install -y  hmmer2 hmmer diamond-aligner fasttree prodigal ncbi-blast+ muscle glimmerhmm

WORKDIR /tmp
RUN wget https://dl.secondarymetabolites.org/releases/6.0.0/antismash-6.0.0.tar.gz && tar -zxf antismash-6.0.0.tar.gz 

RUN sed -i 's/biopython >=1.78/biopython==1.76/' antismash-6.0.0/setup.py
RUN sed -i 's/jinja2/jinja2==3.0.0/' antismash-6.0.0/setup.py

RUN source activate py39 && pip install ./antismash-6.0.0
RUN source activate py39 && download-antismash-databases


#===========


COPY . /kb/module
RUN cp /kb/module/InsdcIO.py /miniconda/envs/py39/lib/python3.9/site-packages/Bio/SeqIO/InsdcIO.py


RUN mkdir -p /kb/module/work
RUN chmod -R a+rw /kb/module

WORKDIR /kb/module

RUN make all

ENTRYPOINT [ "./scripts/entrypoint.sh" ]

CMD [ ]
