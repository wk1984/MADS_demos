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

RUN mkdir -p /workdir
RUN chown -R user:user /workdir
RUN chmod -R u+rwx /workdir

USER user

# 配置JULIA环境
ENV HOME=/home/user
ENV JUPYTER=/usr/local/bin/jupyter
ENV JULIA_PKG_SERVER="https://mirrors.ustc.edu.cn/julia"
ENV PATH=$HOME/julia-1.7.3/bin:$PATH

RUN cd $HOME \
    && wget https://julialang-s3.julialang.org/bin/linux/x64/1.7/julia-1.7.3-linux-x86_64.tar.gz \
#    && wget https://mirrors.tuna.tsinghua.edu.cn/julia-releases/bin/linux/x64/1.7/julia-1.7.3-linux-x86_64.tar.gz \
    && tar -xzf julia-1.7.3-linux-x86_64.tar.gz \
    && rm julia-1.7.3-linux-x86_64.tar.gz

RUN which julia 

# Then install julia packages on a per-user basis...

RUN echo 'using Pkg; Pkg.add(name="Mads", version="1.3.10")' | julia
RUN echo 'using Pkg; Pkg.add("PyCall")' | julia
RUN echo 'using Pkg; Pkg.add("DataFrames")' | julia
RUN echo 'using Pkg; Pkg.add("DataStructures")' | julia
RUN echo 'using Pkg; Pkg.add("CSV")' | julia
RUN echo 'using Pkg; Pkg.add("YAML")' | julia
RUN echo 'using Pkg; Pkg.add("IJulia")' | julia

RUN echo 'using Pkg; Pkg.gc()' | julia

WORKDIR /work

CMD ["jupyter-lab" ,  "--ip=0.0.0.0"  , "--no-browser"]