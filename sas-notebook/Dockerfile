# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
ARG BASE_CONTAINER
FROM $BASE_CONTAINER

LABEL maintainer="Jupyter Project <jupyter@googlegroups.com>"

# Set when building on Travis so that certain long-running build steps can
# be skipped to shorten build time.

USER $NB_USER

# Install IJulia as jovyan and then move the kernelspec out
# to the system share location. Avoids problems with runtime UID change not
# taking effect properly on the .local folder in the jovyan home dir.
RUN conda install -c anaconda sas_kernel && \
	#pip install sas_kernel && \
	#mv $HOME/.local/share/jupyter/kernels/sas* $CONDA_DIR/share/jupyter/kernels/ && \
    chmod -R go+rx $CONDA_DIR/share/jupyter && \
    fix-permissions $CONDA_DIR && \
    fix-permissions $CONDA_DIR/share/jupyter

RUN jupyter nbextension install --py sas_kernel.showSASLog --sys-prefix && \
	jupyter nbextension enable sas_kernel.showSASLog --py --sys-prefix && \
	jupyter nbextension install --py sas_kernel.theme --sys-prefix && \
	jupyter nbextension enable sas_kernel.theme --py --sys-prefix