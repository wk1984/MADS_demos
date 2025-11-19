FROM julia:1.9.3-bookworm

# RUN cat /etc/passwd

RUN which jupyter

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

