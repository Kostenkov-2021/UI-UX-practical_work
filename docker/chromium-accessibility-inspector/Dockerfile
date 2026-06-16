FROM debian:trixie-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get -o Acquire::Retries=5 update \
    && apt-get -o Acquire::Retries=5 install -y --no-install-recommends \
        ca-certificates \
        chromium \
        chromium-l10n \
        dbus-x11 \
        fluxbox \
        fonts-liberation \
        fonts-noto \
        fonts-noto-color-emoji \
        novnc \
        procps \
        supervisor \
        websockify \
        x11vnc \
        xauth \
        xvfb \
    && rm -rf /var/lib/apt/lists/*

RUN useradd --create-home --shell /bin/bash browser \
    && mkdir -p /tmp/.X11-unix /profile \
    && chmod 1777 /tmp/.X11-unix

COPY accessibility-inspector /opt/accessibility-inspector
COPY docker/chromium-accessibility-inspector/entrypoint.sh /usr/local/bin/start-chromium

RUN chmod +x /usr/local/bin/start-chromium \
    && chown -R browser:browser /opt/accessibility-inspector /home/browser

WORKDIR /root

ENV DISPLAY=:99
ENV DISPLAY_WIDTH=1440
ENV DISPLAY_HEIGHT=900
ENV DISPLAY_DEPTH=24
ENV START_URL=about:blank
ENV EXTENSION_PATH=/opt/accessibility-inspector
ENV CHROMIUM_USER_DATA_DIR=/profile

EXPOSE 6080 9222

CMD ["/usr/local/bin/start-chromium"]
