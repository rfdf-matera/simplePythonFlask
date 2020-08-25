FROM alpine:latest

WORKDIR simplePythonApplication/

ADD . /simplePythonApplication/

RUN apk add py3-pip py3-mysqlclient

RUN pip install -r requirements.txt

EXPOSE 5000

CMD python3 app.py
