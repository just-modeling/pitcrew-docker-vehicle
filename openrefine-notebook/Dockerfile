# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
ARG BASE_CONTAINER
FROM $BASE_CONTAINER

USER root
RUN apt-get update && apt-get install -y supervisor openjdk-8-jre && apt-get clean

USER $NB_USER
ARG REFINEVERSION=3.0
ENV REFINEVERSION=$REFINEVERSION

RUN wget -q -O openrefine-$REFINEVERSION.tar.gz https://github.com/OpenRefine/OpenRefine/releases/download/$REFINEVERSION/openrefine-linux-$REFINEVERSION.tar.gz && \
	mkdir -p $HOME/.openrefine && \
	tar xzf openrefine-$REFINEVERSION.tar.gz -C $HOME/.openrefine && \
	rm openrefine-$REFINEVERSION.tar.gz

#RUN wget -q -O rdf-extension-1.1.5-orefine-3.2.zip https://github.com/stkenny/grefine-rdf-extension/releases/download/v1.1.5-orefine-3.2/rdf-extension-1.1.5-orefine-3.2.zip && \
#	unzip rdf-extension-1.1.5-orefine-3.2.zip -d $HOME/.openrefine/openrefine-3.2/webapp/extensions && \
#	rm rdf-extension-1.1.5-orefine-3.2.zip

USER root
COPY jupyter-openrefine-proxy /opt/conda/openrefine/jupyter-openrefine-proxy
RUN chown -R jovyan:users /opt/conda/openrefine && \
	fix-permissions $CONDA_DIR && \
	fix-permissions /home/$NB_USER

USER $NB_USER 	
#RUN conda install -yq jupyter-server-proxy -c conda-forge && \
#    conda clean -tipsy

#RUN mkdir /opt/conda/openrefine && \
#	git clone https://github.com/betatim/openrefineder.git && \
#	cd openrefineder && \
#	pip install . && \
#	fix-permissions $CONDA_DIR && \
#	fix-permissions /home/$NB_USER
	
RUN cd /opt/conda/openrefine/jupyter-openrefine-proxy && \
	pip install . && \
	#jupyter serverextension enable jupyter_openrefine_proxy --py --sys-prefix && \
	#jupyter nbextension  install  --sys-prefix --py jupyter_openrefine_proxy && \
	#jupyter nbextension  enable  --sys-prefix --py jupyter_openrefine_proxy && \
	fix-permissions $CONDA_DIR && \
	fix-permissions /home/$NB_USER

## CKAN extension expired
#RUN cd /home/jovyan/.openrefine/openrefine-3.2/webapp/extensions && \
#	git clone https://github.com/Ontodia/grefine-ckan-storage-extension.git
	
USER $NB_USER
