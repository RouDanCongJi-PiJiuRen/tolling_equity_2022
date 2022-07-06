FROM alpine:latest

RUN apk --no-cache add \
	python3 \
	&& pip3 install flask requests

COPY webhook.py /root/webhook.py

CMD python3 /root/webhook.py
