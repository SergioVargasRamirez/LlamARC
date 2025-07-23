 #!/usr/bin/env bash

#Sergio Vargas R. 2025
#License here.

#Setting up all the environment for my localLLM installation using llama.cpp and ARC 770
#Requires git and docker installed on the system
#Also requires the LLModels available in the right format, i.e. gguf and quantized if wanted/needed

#expected paths
DOCKERFILES_DIR="./dockerfiles"
LLAMACPP="./llama.cpp-b2906"
OPENWEBUI="./open-webui"

#The script will:
#1. get or build the necessary docker images.
#2. if needed, download llama.cpp commit 24ecb581, the one I tested and know works with Intel's ARC770.
#3. compile llama.cpp with ARC770 GPU support
#4. if not available, it will create an open-webui folder for Open-WebUI data persistence


###########################
#   PREP DOCKER IMAGES    #
###############################################################################################
#the commands to build/pull the images are:                                                   #
#build a ubuntu:jammy-based image with all the dependencies to interact with Intel's ARC 770  #
#docker build -f ./dockerfiles/jammy_arc770.dockerfile -t jammy_arc770 .                      #
#                                                                                             #
#build docling image                                                                          #
#docker pull ghcr.io/docling-project/docling-serve:v0.16.1                                    # 
#                                                                                             # 
#pull open-webui image                                                                        #
#docker pull ghcr.io/open-webui/open-webui:main                                               # 
###############################################################################################

declare -a IMAGE_NAMES=("jammy_arc770" "ghcr.io/open-webui/open-webui:main" "ghcr.io/docling-project/docling-serve:v0.16.1")
declare -a DOCKER_CMD=("build" "pull" "pull")
declare -a DOCKER_FILE=("./dockerfiles/jammy_arc770.dockerfile" "" "")

# get number of images
N_IMAGES=${#IMAGE_NAMES[@]}

#loop through the images
for (( i=0; i<${N_IMAGES}; i++ ));
do
    if [ -z "$(docker images -q ${IMAGE_NAMES[$i]} 2> /dev/null)" ]; then
        echo "Image: ${IMAGE_NAMES[$i]} does not exist."
        if [ ${DOCKER_CMD[$i]} = "build" ]; then
            echo "  Proceeding to build the image using: docker build -f $DOCKERFILES_DIR/${IMAGE_NAMES[$i]}.dockerfile -t ${IMAGE_NAMES[$i]} ."
            docker build -f $DOCKERFILES_DIR/${IMAGE_NAMES[$i]}.dockerfile -t ${IMAGE_NAMES[$i]} .
            if [ $? != "0" ]; then
                echo "docker build was not successful, please check if the image was properly built."
            else
                echo "docker build was successful."
            fi
        fi
        if [ ${DOCKER_CMD[$i]} = "pull" ]; then
            echo "  Proceeding to pull the image using: docker pull ${IMAGE_NAMES[$i]}"
            docker pull ${IMAGE_NAMES[$i]}
            if [ $? != "0" ]; then
                echo "docker pull was not successful, please check if the image was properly pulled."
            else
                echo "docker pull was successful."
            fi
        fi
    else
        echo "Image ${IMAGE_NAMES[$i]} exists."
    fi
done

##################################
#  CLONE AND COMPILE llama.cpp   # 
##################################

LLAMA_URL="https://github.com/ggml-org/llama.cpp.git"
LLAMACPP_RELEASE="https://github.com/ggml-org/llama.cpp/archive/refs/tags/b2906.tar.gz"
#LLAMACPP_COMMIT="24ecb58168dce81646c2ed425690a106591c8c6d"

if [ ! -d "$LLAMACPP" ]; then
    echo "$LLAMACPP does not exist. Downloading llama.cpp release b2906"

    #download possible working release
    wget $LLAMACPP_RELEASE
    tar -xvzf b2906.tar.gz
    
    # compile llama.cpp with the jammy_arc770 container
    
    docker-compose -f docker-compose.compile.yml up

    rm b2906.tar.gz

else
    echo "$LLAMACPP exists."
fi


##################################
#  CHECK OPEN-WEBUI DATA FOLDER  # 
##################################

if [ ! -d "$OPENWEBUI" ]; then
    echo "$OPENWEBUI does not exist. Creating folder..."
    mkdir $OPENWEBUI
else
    echo "$OPENWEBUI exists."
fi

