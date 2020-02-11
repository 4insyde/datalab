FROM jupyter/datascience-notebook:414b5d749704

USER root

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update \
    && apt-get install -y apt-transport-https curl iputils-ping gnupg
RUN curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg \
    | sudo apt-key add -
RUN echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" \
    | sudo tee -a /etc/apt/sources.list.d/kubernetes.list

RUN apt-get update \
    && apt-get install -y kubectl git gcc mono-mcs musl-dev octave vim figlet \
    && rm -rf /var/lib/apt/lists/*

# kubefwd for local development and testing
RUN apt-get clean && apt-get autoremove --purge
RUN wget https://github.com/txn2/kubefwd/releases/download/v1.9.0/kubefwd_amd64.deb \
    && dpkg -i kubefwd_amd64.deb \
    && rm kubefwd_amd64.deb

RUN curl -L https://github.com/nuclio/nuclio/releases/download/1.1.13/nuctl-1.1.13-linux-amd64 -o /bin/nuctl \
    && chmod 775 /bin/nuctl

USER $NB_UID

# Installs data science, machine learning, blockchaine and iot python packages
RUN pip install --upgrade --no-cache \
    nuclio-jupyter \
    pylantern \
    ipywidgets \
    elasticsearch \
    pandasticsearch \
    kafka-python \
    kubernetes \
    nbgitpuller \
    rubix \
    python-gitlab \
    scipy \
    numpy \
    pandas \
    scikit-learn \
    matplotlib \
    tensorflow \
    torch \
    torchvision \
    fastai \
    octave_kernel \
    jupyterlab-git \
    paho-mqtt \
    web3 \
    py-solc \
    nteract_on_jupyter

# Jupyter lab and server enstensions
RUN jupyter labextension install @jupyterlab/git
RUN jupyter labextension install @jupyterlab/plotly-extension
RUN jupyter serverextension enable --py jupyterlab_git
RUN jupyter serverextension enable nteract_on_jupyter
RUN jupyter labextension install @jupyter-widgets/jupyterlab-manager 
RUN jupyter labextension install plotlywidget 
RUN jupyter labextension install @jupyterlab/plotly-extension 
RUN jupyter labextension install jupyterlab_bokeh 
RUN jupyter labextension install qgrid 
RUN jupyter labextension install ipysheet 
RUN jupyter labextension install lineup_widget

# see https://github.com/timkpaine/lantern

RUN mkdir -p ./.jupyter/lab/user-settings/@jupyterlab/apputils-extension
COPY ./user-settings/themes.jupyterlab-settings ./.jupyter/lab/user-settings/@jupyterlab/apputils-extension

COPY ./bash/bash_profile ./.bash_profile

ENV DATALAB_DIST "DataLab"
ENV DATALAB_VERSION "v0.0.1"
ENV JUPYTER_ENABLE_LAB "yes"
ENV GRANT_SUDO "yes"
ENV RESTARTABLE "yes"
