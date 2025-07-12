FROM node:18-slim

# تثبيت جميع المتطلبات مع حل مشكلة vncserver
RUN apt update && apt install -y \
    wget gnupg2 curl ca-certificates fonts-liberation \
    libappindicator3-1 libasound2 libatk-bridge2.0-0 libatk1.0-0 libcups2 \
    libdbus-1-3 libgdk-pixbuf2.0-0 libnspr4 libnss3 libx11-xcb1 libxcomposite1 \
    libxdamage1 libxrandr2 xdg-utils unzip chromium chromium-driver \
    xvfb x11vnc fluxbox git \
    tigervnc-standalone-server tigervnc-common  # استبدال tightvncserver بحزمة أخرى

WORKDIR /opt
RUN git clone https://github.com/novnc/noVNC.git && \
    git clone https://github.com/novnc/websockify noVNC/utils/websockify

# سكريبت تشغيل معدل يعمل في جميع البيئات
RUN echo '#!/bin/bash\n\
if command -v vncserver &> /dev/null; then\n\
  vncserver :1 -geometry 1280x800 -depth 24\n\
else\n\
  Xvfb :1 -screen 0 1280x800x24 &\n\
  export DISPLAY=:1\n\
  fluxbox &\n\
  x11vnc -display :1 -forever -nopw -shared -bg -rfbport 5901\n\
fi\n\
/opt/noVNC/utils/launch.sh --vnc localhost:5901 --listen 8080 &\n\
tail -f /dev/null' > /start.sh && \
    chmod +x /start.sh

EXPOSE 8080

CMD ["/start.sh"]
