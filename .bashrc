#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '

alias ll="ls -la --color=auto"

eval "$(oh-my-posh init bash --config ~/.config/oh-my-posh/hanselman.omp.json)"
alias config='/usr/bin/git --git-dir=/home/rafl/.cfg/ --work-tree=/home/rafl'
alias discord='discord --no-sandbox --enable-accelerated-mjpeg-decode --enable-accelerated-video --ignore-gpu-blacklist --enable-native-gpu-memory-buffers --enable-gpu-rasterization --enable-features=VaapiVideoEncoder,VaapiVideoDecoder,CanvasOopRasterization --use-gl=desktop --enable-zero-copy --enable-accelerated-video-decode --disable-features=UseChromeOSDirectVideoDecoder --disable-gpu-sandbox'
alias brave='brave --enable-accelerated-mjpeg-decode --enable-accelerated-video --ignore-gpu-blacklist --enable-native-gpu-memory-buffers --enable-gpu-rasterization --enable-features=VaapiVideoEncoder,VaapiVideoDecoder,CanvasOopRasterization --use-gl=desktop --enable-zero-copy --enable-accelerated-video-decode --disable-features=UseChromeOSDirectVideoDecoder --disable-gpu-sandbox'
