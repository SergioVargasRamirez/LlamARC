#prep env
source /opt/intel/oneapi/setvars.sh
export USE_XETLA=OFF
export SYCL_PI_LEVEL_ZERO_USE_IMMEDIATE_COMMANDLISTS=1
export SYCL_CACHE_PERSISTENT=1
export ZES_ENABLE_SYSMAN=1

#llama
/llama.cpp/server -m /models/Meta-Llama-3-8B-Instruct/Meta-Llama-3-8B_q4_K_M.gguf -c 4096 -ngl 99 -sm none -mg 0 --host 0.0.0.0 --port 8081

#code llama
#/llama.cpp/server -m /models/CodeLlama-13b-Instruct-hf/CodeLlama-13b-Instruct-hf-13B-Q4_K_M.gguf -c 4096 -ngl 99 -sm none -mg 0 --host 0.0.0.0 --port 8081
