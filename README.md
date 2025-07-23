# LlamARC - Local, dockerized RAG and Coding Assistant with Intel ARC770 support

This repository provides a local, dockerized RAG and Coding Assistant I have been using to experiment with my ARC770 GPU. 

After many experiments, I settled on this solution. It uses [Llama.cpp](https://github.com/ggml-org/llama.cpp.git) to serve LLMs locally on an Intel ARC 770 GPU, which substatially accelerates the interaction with the LLMs.

I think my (several) tests led to an elegant using a general purpose Ubuntu Jammy container with all the necessary dependencies to interact with my
ARC 770 GPU installed in it. In this container nothing else is installed, which is nice, because it makes it multipurpose; hopefully.

Why not installing all the dependencies directly on my OpenSuse? Well... Intel supports Ubuntu, period. Trying to get the GPU to work on OpenSuse was... frustrating. 

The main disadvantage of this solution is that the folder containing `llama.cpp` needs to mounted in the container and compiled using the container libraries once. Also, if you need to quantize the LLM you intend to use, you will need to enter the container, attach the folder with the LLMs and with `llama.cpp`, install requirements for the quantize to work and run the programs manually.

At least for now, I implemented a `setup.sh` script that takes care of a number of things, like:

 1. Building/pulling the required `docker` images.
 2. Downloading the specific `commit` of `llama.cpp` that worked for me. And,
 3. Compiling `llama.cpp` with ARC770 support.
 
 I will try to include a `quantize` script as soon as I need one.

This repository is my LLM playground and the basis for some other projects using GPU support for Deep Learning. I hope it is useful for someone else.

## Before you start: prepare the environment

I assume you cloned this repository and work in it.

1. To pull/build the necessary docker containers, get `llama.cpp` and compile it, prepare `Open-WebUI` data folder, simply run `setup.sh`. Make sure your user can execute the scripts in the folder `llama.cpp.scripts` otherwise the compile phase will fail.

```sh

bash setup.sh

```

If all worked you should now have the following containers:
    1. an Ubuntu Jammy docker image (jammy_arc770) with all necessary dependencies to use Intel's ARC770 GPU
    2. an open-webui image
    3. a docling image

You can check if the images are there using the following command on the terminal:

```sh

#check containers
docker image ls

```

You should also have a `llama.cpp` folder. Inside this folder you should have a folder `build/bin` with `llama.cpp` executables inside. It is a good practice to `chown` all folders and files to make your user the owner; I would not leave `root` as the owner or run anything as `root` but you know this.

`llama.cpp` expects the LLMs to be located inside LlamARC in a folder named `models`. I created have a symbolic link to a larger HD where I actually keep the LLMs. In my case: `ln -s /mnt/scratch/LLModels/ models` works. 

2. To launch all the services, i.e. the `llama.cpp` server, dockling, and open-webui, on a terminal run:

```sh
docker-compose up
```

Check the three containers run. 

3. Once the tests finished, type the following on a different terminal.

```sh
docker-compose down
``` 

---


### Configure Open WebUI

After creating an Admin user, go to Setting->Connections, add a new connection and use the url of your llama.cpp server. In my case `http://minimuc:8081/v1`. Verify your connection is
working and check whether your local LLM can be selected from the dropdown.


### Configure Docling from Open WebUI

Go to the Admin Panel -> Documents. There, select `Docling` as the `Content Extraction Engine`. Edit the address, in my case the address is `http://minimuc:5001`. In my case, the OCR engine is
`easyocr` and the languages `en,es,fr,de`; this is different from the default. I have not played with the settings yet.

## Extras

### Clone and compile llama.cpp

I have been using `commit 24ecb581`, which seems to work with my ARC 770 without much trouble.

### Quantize the model

In case you need to quatize the model, inside the jammy_arc770 container run:

```sh
#install the required packages for convert.py to run
python3 -m pip install -r requirements.txt
#run convert.py to get a gguf f32 model
python3 convert.py /models/CodeLlama-13b-Instruct-hf/
#run quantize with the desired option, below using Q4_K_M
./build/bin/quantize /models/CodeLlama-13b-Instruct-hf/CodeLlama-13b-Instruct-hf-13B-F32.gguf /models/CodeLlama-13b-Instruct-hf/CodeLlama-13b-Instruct-hf-13B-Q4_K_M.gguf Q4_K_M

```

### Setup VS Codium

1. Install `Continue - open-source AI code assistant` and configure it to use your local `llama.cpp` server; you will need to know the ip and port of your local `llama.cpp` server


