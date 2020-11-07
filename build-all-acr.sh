# Login novncacr
az login 
ACR_NAME=ddapracr
az acr login -n $ACR_NAME

cd base-notebook
docker build -t $ACR_NAME.azurecr.io/base-notebook:latest .
docker push $ACR_NAME.azurecr.io/base-notebook:latest
cd ..

# drived from base-notebook
cd scipy-notebook
docker build -t $ACR_NAME.azurecr.io/scipy-notebook:latest --build-arg BASE_CONTAINER=$ACR_NAME.azurecr.io/base-notebook:latest .
docker push $ACR_NAME.azurecr.io/scipy-notebook:latest
cd ..

# drived from scipy-notebook
cd datascience-notebook
docker build -t $ACR_NAME.azurecr.io/datascience-notebook:latest --build-arg BASE_CONTAINER=$ACR_NAME.azurecr.io/scipy-notebook:latest .
docker push $ACR_NAME.azurecr.io/datascience-notebook:latest
cd ..

# cd tensorflow-notebook
# docker build -t $ACR_NAME.azurecr.io/tensorflow-notebook:latest --build-arg BASE_CONTAINER=$ACR_NAME.azurecr.io/scipy-notebook:latest .
# docker push $ACR_NAME.azurecr.io/tensorflow-notebook:latest
# cd ..

cd pyspark-notebook
# build spark-py image
docker build \
	--build-arg VCS_REF=$(git rev-parse --short HEAD) \
    --build-arg BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ") \
    --build-arg VERSION=0.1 \
	-t $ACR_NAME.azurecr.io/spark-py:v2.4.5 \
	-f spark-2.4.5-bin-hadoop3.2/Dockerfile .
docker push $ACR_NAME.azurecr.io/spark-py:v2.4.5

docker build -t $ACR_NAME.azurecr.io/pyspark-notebook:v2.4.5 --build-arg BASE_CONTAINER=$ACR_NAME.azurecr.io/scipy-notebook:latest .
docker push $ACR_NAME.azurecr.io/pyspark-notebook:v2.4.5
cd ..

# cd arcgis-notebook
# docker build -t $ACR_NAME.azurecr.io/gis-notebook:latest --build-arg BASE_CONTAINER=$ACR_NAME.azurecr.io/scipy-notebook:latest .
# docker push $ACR_NAME.azurecr.io/gis-notebook:latest
# cd ..

# # drived from pyspark-notebook
# cd all-spark-notebook
# docker build -t $ACR_NAME.azurecr.io/all-spark-notebook:latest --build-arg BASE_CONTAINER=$ACR_NAME.azurecr.io/pyspark-notebook:latest .
# docker push $ACR_NAME.azurecr.io/all-spark-notebook:latest
# cd ..

# vscode image
cd theia-vscode/theia-apps/theia-docker
docker build -t $ACR_NAME.azurecr.io/theia-vscode:latest .
docker push $ACR_NAME.azurecr.io/theia-vscode:latest
cd .. && cd ..

# pgadmin image
cd pgadmin4
docker build -t $ACR_NAME.azurecr.io/pgadmin4:latest .
docker push $ACR_NAME.azurecr.io/pgadmin4:latest
cd ..

# rstudio image
cd rstudio
docker build -t $ACR_NAME.azurecr.io/rstudio:latest .
docker push $ACR_NAME.azurecr.io/rstudio:latest
cd ..








