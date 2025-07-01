FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# 安裝必要套件：zsh、git、curl、wget、vim、字型等
RUN apt-get update && apt-get install -y \
		zsh \
		git \
		curl \
		wget \
		vim \
		fonts-powerline \
		fonts-noto-color-emoji \
		fonts-font-awesome \
		locales \
		libglib2.0-0 \
		libx11-xcb1 \
		libxcomposite1 \
		libxcursor1 \
		libxdamage1 \
		libxrandr2 \
		libasound2 \
		libatk1.0-0 \
		libatk-bridge2.0-0 \
		libcups2 \
		libdrm2 \
		libgbm1 \
		libgtk-3-0 \
		libpango-1.0-0 \
		libpangocairo-1.0-0 \
		libxkbfile1 \
		libsecret-1-0 \
		libxss1 \
		libnss3 \
		libxshmfence1 \
		flex \
		bison \
		gperf \
		python3 \
		python3-pip \
		python3-venv \
		cmake \
		ninja-build \
		ccache \
		libffi-dev \
		libssl-dev \
		dfu-util \
		libusb-1.0-0 \
		&& apt-get clean && rm -rf /var/lib/apt/lists/*

# 設定語系（避免 locale 警告）
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# 建立非 root 使用者 myuser，並設定 zsh 為預設 shell
RUN useradd -ms /bin/zsh myuser
USER myuser
WORKDIR /home/myuser

# 安裝 oh-my-zsh（非互動式）
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# 安裝 Powerlevel10k 主題
RUN git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /home/myuser/.oh-my-zsh/custom/themes/powerlevel10k

# 設定 oh-my-zsh 預設主題為 powerlevel10k
RUN sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' /home/myuser/.zshrc

#安裝oh-my-zsh 插件
RUN git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
RUN git clone https://github.com/zsh-users/zsh-completions.git   ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-completions


# 複製簡單的 powerlevel10k 設定檔，避免首次啟動時互動設定
		RUN echo '[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh' >> /home/myuser/.zshrc

# 下載簡單的 powerlevel10k 設定檔（可選）
		RUN curl -fsSL https://raw.githubusercontent.com/romkatv/powerlevel10k/refs/heads/master/config/p10k-rainbow.zsh -o /home/myuser/.p10k.zsh

# 下載 zshrc 
                    RUN curl -fsSL https://raw.githubusercontent.com/ChangMK/zshrc/refs/heads/main/.zshrc -o /home/myuser/.zshrc

# 安裝 VSCode Server
		RUN mkdir -p /home/myuser/.vscode-server && \
			curl -fsSL https://update.code.visualstudio.com/latest/server-linux-x64/stable -o vscode-server.tar.gz && \
			tar -xzf vscode-server.tar.gz -C /home/myuser/.vscode-server --strip-components=1 && \
			rm vscode-server.tar.gz

# 設定權限
			RUN chown -R myuser:myuser /home/myuser/.vscode-server

			CMD ["zsh"]
# 安裝 ESP-IDF v5.2
			RUN git clone --branch v5.2 --recursive https://github.com/espressif/esp-idf.git /home/myuser/esp-idf

# 安裝 ESP-IDF 依賴工具（esp-idf 安裝腳本）
			RUN /bin/bash -c "cd /home/myuser/esp-idf && ./install.sh"

# 設定環境變數，讓 ESP-IDF 工具鏈可用
#			RUN echo 'source /home/myuser/esp-idf/export.sh' >> /home/myuser/.zshrc

# 設定權限
			RUN chown -R myuser:myuser /home/myuser/esp-idf

# 新增目錄給宿主機對應
			RUN mkdir -p /home/myuser/playground/homekit
#			USER root

#			EXPOSE 22
