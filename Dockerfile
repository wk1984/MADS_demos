FROM ubuntu:20.04

RUN export DEBIAN_FRONTEND=noninteractive \
    export DEBCONF_NONINTERACTIVE_SEEN=true \
	&& apt-get update -y \
    && apt-get install -y --no-install-recommends python3 python3-pip wget \
	&& pip3 install jupyterlab

RUN jupyter-lab --version

RUN useradd -m -s /bin/bash user && echo "user:111" | chpasswd
RUN usermod -aG sudo user

# 必须要修改权限，否则JUPYTER停止后不能够重新启动
USER root
RUN chown -R user:user $HOME/
RUN chmod -R u+rwx $HOME/

RUN mkdir -p $HOME/.julia
RUN chown -R user:user $HOME/.julia
RUN chmod -R u+rwx $HOME/.julia

RUN mkdir -p /workdir
RUN chown -R user:user /workdir
RUN chmod -R u+rwx /workdir

USER user

# 配置JULIA环境
ENV HOME=/home/user
ENV JUPYTER=/usr/local/bin/jupyter
ENV PYTHON=/usr/local/bin/python3
ENV JULIA_PKG_SERVER="https://mirrors.ustc.edu.cn/julia"
ENV PATH=$HOME/julia-1.9.3/bin:$PATH

RUN cd $HOME \
    && wget -q https://julialang-s3.julialang.org/bin/linux/x64/1.9/julia-1.9.3-linux-x86_64.tar.gz \
#    && wget https://mirrors.tuna.tsinghua.edu.cn/julia-releases/bin/linux/x64/1.7/julia-1.7.3-linux-x86_64.tar.gz \
    && tar -xzf julia-1.9.3-linux-x86_64.tar.gz \
    && rm julia-1.9.3-linux-x86_64.tar.gz

RUN which julia 

# Then install julia packages on a per-user basis...

RUN echo 'using Pkg; Pkg.add("Conda");Pkg.build("Conda")' | julia
RUN echo 'using Pkg; Pkg.add("PyCall");Pkg.build("PyCall")' | julia

RUN echo 'using Pkg; Pkg.add(name="Mads", version="1.3.10", io=devnull)' | julia
RUN echo 'using Pkg; Pkg.add("PyCall", io=devnull)' | julia
RUN echo 'using Pkg; Pkg.add("DataFrames", io=devnull)' | julia
RUN echo 'using Pkg; Pkg.add("DataStructures", io=devnull)' | julia
RUN echo 'using Pkg; Pkg.add("CSV", io=devnull)' | julia
RUN echo 'using Pkg; Pkg.add("YAML", io=devnull)' | julia
RUN echo 'using Pkg; Pkg.add("IJulia", io=devnull)' | julia

RUN echo 'using Pkg; Pkg.gc()' | julia

USER user
WORKDIR /work

CMD ["jupyter-lab" ,  "--ip=0.0.0.0"  , "--no-browser"]