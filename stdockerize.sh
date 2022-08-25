#!/bin/bash

read -r -d '' USAGE << EOM
Usage: $0 -d <output dockerfile> -m <output makefile>  -n <dockername> [-s <secrets file .json>] <streamlit app .py>

This program will produce a Docker file and a make file that can be used to create a Docker 
container for your Streamlit app. You can run the 'docker' target in the produced make file 
to create the Docker image. Feel free to modify the generated Docker or make files as appropriate.

This program is intended to be run inside the directory that has the source code for the Streamlit 
app. The directory should have the Python files, but also a requirements.txt file for the 
prerequisites.

The inputs are
  -f <output dockerfile>  : The name of the Docker file to create
  -m <output makefile>    : The name of the make file to create
  -n <dockername>         : The name of the Docker image to create
  -s <secrets file .json> : (Optional) A json file of secrets to be included into the Docker image. 
                              If specified, this file will be accessible in the Docker image 
                              at /tmp/secrets.json.
  -p <port>               : Port to use for the app (default is 80)
  -u <baseUrlPath>        : Base URL path to add to URL
  <streamlit app .py>     : The filename of the Streamlit app Python file 
                              (e.g. the argument you would provide to 'streamlit run')
EOM

# Parse args
# stdockerize.sh <output dockerfile> <output makefile> <streamlit app .py> <dockername> <secrets file .json>

dockerfile=""
makefile=""
dockername=""
app_py=""
secrets=""
port="80"
baseUrlPath=""

while [ $# -gt 1 ]
do
    case "$1" in
        -d) dockerfile="$2"
            shift;;
        -m) makefile="$2"
            shift;;
        -n) dockername="$2"
            shift;;
        -s) secrets="$2"
            shift;;
        -p) port="$2"
            shift;;
        -u) baseUrlPath="$2"
            shift;;
        *) echo "Error: $1 is not an option."
            echo "$USAGE"
            exit 1;;
    esac
    shift
done
app_py=$1

if [ -z "$app_py" ]; then
    echo "Error: need application file name (last argument)."
    echo "$USAGE"
    exit 1
fi

if [ -z "$dockerfile" ]; then
    echo "Error: need Docker file name (-d option)."
    echo "$USAGE"
    exit 1
fi
if [ -z "$makefile" ]; then
    echo "Error: need Makefile name (-m option)."
    echo "$USAGE"
    exit 1
fi
if [ -z "$dockername" ]; then
    echo "Error: need Docker image name (-n option)."
    echo "$USAGE"
    exit 1
fi
if [ -z "$app_py" ]; then
    echo "Error: need Streamlit app file name."
    echo "$USAGE"
    exit 1
fi

##############
### Dockerfile
##############

cat > $dockerfile << EOM
FROM python:3.9-slim

EXPOSE $port

WORKDIR /app

COPY . .

RUN apt-get update && apt-get install -y --no-install-recommends gcc python3-dev g++

RUN pip3 install -r requirements.txt

EOM

## Optionally add secrets
if [ -n "$secrets" ]; then
echo "Adding secrets file"
cat >> $dockerfile << EOM
RUN  --mount=type=secret,id=secrets,dst=/tmp/secrets.json.in cp /tmp/secrets.json.in /tmp/secrets.json

EOM
fi

## Optionally add baseUrlPath
if [ -n "$baseUrlPath" ]; then
cat >> $dockerfile << EOM
ENTRYPOINT [ "python3", "-m", "streamlit", "run", "$app_py", "--server.port=$port", "--server.address=0.0.0.0" "--server.baseUrlPath=$baseUrlPath" ]
EOM
else
cat >> $dockerfile << EOM
ENTRYPOINT [ "python3", "-m", "streamlit", "run", "$app_py", "--server.port=$port", "--server.address=0.0.0.0" ]
EOM
fi


############
### Makefile
############
TAB="$(printf '\t')"
cat > $makefile << EOM
DOCKERIMAGENAME=$dockername

run:
${TAB}docker run -p $port:$port \$(DOCKERIMAGENAME)

EOM

## Optionally add secrets
if [ -n "$secrets" ]; then
cat >> $makefile << EOM
docker:
${TAB}DOCKER_BUILDKIT=1 docker build -f $dockerfile --no-cache --progress=plain --secret id=secrets,src=$secrets -t \$(DOCKERIMAGENAME) .
EOM
else
cat >> $makefile << EOM
docker:
${TAB}DOCKER_BUILDKIT=1 docker build -f $dockerfile --no-cache --progress=plain -t \$(DOCKERIMAGENAME) .
EOM
fi

echo "Docker file ($dockerfile) created. Makefile ($makefile) created. Feel free to edit or customize as needed."
echo "To make the Docker image run: make -f $makefile docker"
echo "Then you can run the image with: make -f $makefile run"
