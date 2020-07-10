# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
ARG BASE_CONTAINER
FROM $BASE_CONTAINER

LABEL maintainer="Jupyter Project <jupyter@googlegroups.com>"

# Install Tensorflow
RUN conda install --quiet --yes \
    'tensorflow=1.13*' \
    'keras=2.2*' && \
    conda install pytorch torchvision cudatoolkit=10.0 -c pytorch && \
    conda clean --all -f -y && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

RUN pip install --pre jupyter-tensorboard && \
	jupyter serverextension enable jupyter_tensorboard --py --sys-prefix && \
	jupyter nbextension enable jupyter_tensorboard --py --sys-prefix && \
    jupyter labextension install jupyterlab_tensorboard --no-build && \
    jupyter lab build && \
    conda clean --all -f -y && \
    npm cache clean --force && \
    rm -rf $CONDA_DIR/share/jupyter/lab/staging && \
    rm -rf /home/$NB_USER/.cache/yarn && \
    rm -rf /home/$NB_USER/.node-gyp && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER