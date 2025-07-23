FROM ubuntu:jammy AS jammy_arc770

SHELL ["/bin/bash", "-l", "-c"]

#prep the system
RUN apt-get update
RUN apt-get install -y gpg-agent wget hwinfo gawk dkms libc6-dev udev cmake python3-pip

#get drivers
RUN wget -qO - https://repositories.intel.com/gpu/intel-graphics.key | gpg --yes --dearmor --output /usr/share/keyrings/intel-graphics.gpg
RUN echo "deb [arch=amd64 signed-by=/usr/share/keyrings/intel-graphics.gpg] https://repositories.intel.com/gpu/ubuntu jammy client" | tee /etc/apt/sources.list.d/intel-gpu-jammy.list

RUN apt-get update

RUN apt-get install -y intel-opencl-icd \
intel-level-zero-gpu \
level-zero \
intel-media-va-driver-non-free \
libmfx1 \
libmfxgen1 \
libvpl2 \
libegl-mesa0 \
libegl1-mesa \
libegl1-mesa-dev \
libgbm1 \
libgl1-mesa-dev \
libgl1-mesa-dri \
libglapi-mesa \
libgles2-mesa-dev \
libglx-mesa0 \
libigdgmm12 \
libxatracker2 \
mesa-va-drivers \
mesa-vdpau-drivers \
mesa-vulkan-drivers \
va-driver-all \
vainfo \
clinfo

#get the oneapi env
RUN wget -O- https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB | gpg --dearmor | tee /usr/share/keyrings/oneapi-archive-keyring.gpg > /dev/null

RUN echo "deb [signed-by=/usr/share/keyrings/oneapi-archive-keyring.gpg] https://apt.repos.intel.com/oneapi all main" | tee /etc/apt/sources.list.d/oneAPI.list

RUN apt-get update
RUN apt-get install -y intel-oneapi-common-vars=2024.0.0-49406 \
intel-oneapi-compiler-cpp-eclipse-cfg=2024.0.2-49895 \
intel-oneapi-compiler-dpcpp-eclipse-cfg=2024.0.2-49895 \
intel-oneapi-diagnostics-utility=2024.0.0-49093 \
intel-oneapi-compiler-dpcpp-cpp=2024.0.2-49895 \
intel-oneapi-mkl=2024.0.0-49656 \
intel-oneapi-mkl-devel=2024.0.0-49656 \
intel-oneapi-mpi=2021.11.0-49493 \
intel-oneapi-mpi-devel=2021.11.0-49493 \
intel-oneapi-tbb=2021.11.0-49513  \
intel-oneapi-tbb-devel=2021.11.0-49513 \
intel-oneapi-ccl=2021.11.2-5  \
intel-oneapi-ccl-devel=2021.11.2-5 \
intel-oneapi-dnnl-devel=2024.0.0-49521 \
intel-oneapi-dnnl=2024.0.0-49521 \
intel-oneapi-tcm-1.0=1.0.0-435

#get .bashrc ready to set the environment before running llama.cpp
#RUN echo "source /opt/intel/oneapi/setvars.sh" >>/root/.bashrc
#RUN echo "export USE_XETLA=OFF" >>/root/.bashrc
#RUN echo "export SYCL_PI_LEVEL_ZERO_USE_IMMEDIATE_COMMANDLISTS=1" >>/root/.bashrc
#RUN echo "export SYCL_CACHE_PERSISTENT=1" >>/root/.bashrc
#RUN echo "export ZES_ENABLE_SYSMAN=1" >>/root/.bashrc

#EXPOSE 8081

#ENTRYPOINT [ "/bin/bash" ]
#CMD bash /llama.cpp.scripts/run_server_llama.sh
