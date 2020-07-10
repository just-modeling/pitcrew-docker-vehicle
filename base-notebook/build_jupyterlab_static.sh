#!/bin/bash
# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.

git clone https://github.com/ksmc/jupyterlab.git
cd jupyterlab
git checkout v1.0.4.1
sudo pip install -e .
sudo jlpm install
sudo jlpm run build
