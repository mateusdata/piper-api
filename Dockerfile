# Use a imagem oficial do Ubuntu (22.04 LTS, por exemplo)
FROM ubuntu:22.04

# Impede perguntas interativas durante a instalação
ENV DEBIAN_FRONTEND=noninteractive

# Atualiza os pacotes e instala o Python, pip, sudo e outras dependências necessárias
RUN apt-get update && apt-get install -y \
    sudo \
    python3 \
    python3-pip \
    git \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Atualiza o pip para a versão mais recente
RUN pip3 install --upgrade pip

# Clona o repositório do Piper
RUN git clone https://github.com/rhasspy/piper.git 

# Instala as dependências do Piper
RUN cd piper && cd src && cd python_run/ && pip install -e . && pip install -r requirements_http.txt

# Cria o diretório de modelos e baixa o modelo ONNX
RUN mkdir /models
RUN cd /models && wget https://huggingface.co/rhasspy/piper-voices/resolve/v1.0.0/pt/pt_BR/faber/medium/pt_BR-faber-medium.onnx?download=true
RUN cd /models && mv pt_BR-faber-medium.onnx?download=true faber.onnx
RUN cd /models && wget https://huggingface.co/rhasspy/piper-voices/resolve/v1.0.0/pt/pt_BR/faber/medium/pt_BR-faber-medium.onnx.json?download=true.json
RUN cd /models && mv pt_BR-faber-medium.onnx.json?download=true.json faber.onnx.json

# Expõe a porta 5000 (onde o servidor HTTP do Piper estará ouvindo)
EXPOSE 5000

# Inicia o servidor Piper
CMD ["python3", "-m", "piper.http_server", "--model", "/models/faber.onnx", "--host=0.0.0.0"]