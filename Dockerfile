FROM node:18-slim

# تثبيت. المتطلبات الأساسية + أدوات الرسوميات + Chrome
RUN apt update && apt install -y \
    wget gnupg2 curl ca-certificates fonts-liberation \
    libappindicator3-1 libasound2 libatk-bridge2.0-0 libatk1.0-0 libcups2 \
    libdbus-1-3 libgdk-pixbuf2.0-0 libnspr4 libnss3 libx11-xcb1 libxcomposite1 \
    libxdamage1 libxrandr2 xdg-utils unzip chromium chromium-driver \
    xvfb x11vnc fluxbox git

# تثبيت noVNC
WORKDIR /opt
RUN git clone https://github.com/novnc/noVNC.git && \
    git clone https://github.com/novnc/websockify noVNC/utils/websockify

# إعداد السكربت الذي يشغل البيئة الرسومية
RUN echo '#!/bin/bash\n\
Xvfb :1 -screen 0 1280x800x24 &\n\
export DISPLAY=:1\n\
fluxbox &\n\
x11vnc -display :1 -forever -nopw -shared -bg -rfbport 5901\n\
/opt/noVNC/utils/launch.sh --vnc localhost:5901 --listen 8080\n' > /start.sh && \
    chmod +x /start.sh

# فتح المنفذ
EXPOSE 8080

# تشغيل كل شيء
CMD ["/start.sh"]
