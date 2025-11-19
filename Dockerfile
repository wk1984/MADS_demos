FROM julia:1.9.3-bookworm

# RUN cat /etc/passwd

RUN export DEBIAN_FRONTEND=noninteractive \
    export DEBCONF_NONINTERACTIVE_SEEN=true \
	&& apt-get update -y \
    && apt-get install -y --no-install-recommends python3 python3-pip python3-full
 
RUN pip3 install jupyterlab

RUN jupyterlab --version

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

RUN which julia \
    && julia -e 'using Pkg; Pkg.status(); Pkg.add("IJulia");'

