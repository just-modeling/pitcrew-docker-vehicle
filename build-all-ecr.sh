# Login mphjphk8sacr
ACR_NAME=446516249306.dkr.ecr.us-east-1.amazonaws.com
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $ACR_NAME
aws ecr create-repository --repository-name k8s-hub --image-scanning-configuration scanOnPush=true --region us-east-1
aws ecr create-repository --repository-name novnc-notebook --image-scanning-configuration scanOnPush=true --region us-east-1
aws ecr create-repository --repository-name base-notebook --image-scanning-configuration scanOnPush=true --region us-east-1
aws ecr create-repository --repository-name scipy-notebook --image-scanning-configuration scanOnPush=true --region us-east-1
aws ecr create-repository --repository-name datascience-notebook --image-scanning-configuration scanOnPush=true --region us-east-1
aws ecr create-repository --repository-name theia-vscode --image-scanning-configuration scanOnPush=true --region us-east-1
aws ecr create-repository --repository-name pgadmin4 --image-scanning-configuration scanOnPush=true --region us-east-1
aws ecr create-repository --repository-name unifi --image-scanning-configuration scanOnPush=true --region us-east-1
aws ecr create-repository --repository-name rstudio --image-scanning-configuration scanOnPush=true --region us-east-1

# build jupyter-k8s-hub
cd jupyter-k8s-hub
docker build -t $ACR_NAME/k8s-hub:latest .
docker push $ACR_NAME/k8s-hub:latest
cd ..

# build the novnc-desktop
cd docker-ubuntu-vnc-desktop
docker build -t $ACR_NAME/novnc-notebook:latest .
docker push $ACR_NAME/novnc-notebook:latest
cd ..

# build the base-notebook
cd base-notebook
docker build -t $ACR_NAME/base-notebook:latest .
docker push $ACR_NAME/base-notebook:latest
cd ..

# drived from base-notebook
cd scipy-notebook
docker build -t $ACR_NAME/scipy-notebook:latest --build-arg BASE_CONTAINER=$ACR_NAME/base-notebook:latest .
docker push $ACR_NAME/scipy-notebook:latest
cd ..

# drived from scipy-notebook
cd datascience-notebook
docker build -t $ACR_NAME/datascience-notebook:latest --build-arg BASE_CONTAINER=$ACR_NAME/scipy-notebook:latest .
docker push $ACR_NAME/datascience-notebook:latest
cd ..

# vscode image
cd theia-vscode
docker build -t $ACR_NAME/theia-vscode:latest .
docker push $ACR_NAME/theia-vscode:latest
cd ..

# pgadmin image
cd pgadmin4
docker build -t $ACR_NAME/pgadmin4:latest .
docker push $ACR_NAME/pgadmin4:latest
cd ..

# rstudio image
cd rstudio
docker build -t $ACR_NAME/rstudio:latest .
docker push $ACR_NAME/rstudio:latest
cd ..