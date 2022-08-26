# A tool to Dockerize a Streamlit app
This tool will help Dockerize your Streamlit app.

## Details
This tool will output a Docker file for your Streamlit app
as well as a Makefile to simplify building the Docker container.

Run the command from the main directory of your app.
The Docker container will contain all of the files in the
directory as well as all subdirectories below it. The Docker
container will start the specified app on port 80 using `python3`. 
The Docker container will use `pip3` to install all prerequisites
listed in `requirements.txt`.

A best practice is not to include credentials (or other secrets)
in the repository itself. To support adding credentials (or other
secrets) to your container, you can specify a file outside the 
app directory that will be copied to the Docker container to 
`/tmp/secrets.json`. 

The tool will output a Dockerfile and Makefile so that you can
additionally modify the Dockerfile and Makefile to customize 
your app to suit your specific needs.

After running the command, you can:
* build the Docker container with `make -f <output makefile> docker`
* run the Docker container/app with `make -f <output makefile> run` 

## Command Arguments
The command takes the following required arguments:
* the output Dockerfile filename (`-d` arguemnt)
* the output Makefile filename (`-m` argument)
* the tag to use for the Docker container (`-n` argument)
* the filename of the Streamlit Python app to start (last argument, no switch)

It also takes the following optional arguments:
* the path/filename of the secrets file to copy into the Docker container (`-s` argument)
* the port to use for the app (`-p` argument, default is port 80)
* the path to add to the base URL for the app (`-u` argument)

```
Usage: ../stdockerize.sh -d <output dockerfile> -m <output makefile>  -n <dockername> [-s <secrets file .json> -p <port> -u <baseUrlPath> -k <platform>] <streamlit app .py>

This program will produce a Docker file and a make file that can be used to create a Docker 
container for your Streamlit app. You can run the 'docker' target in the produced make file 
to create the Docker image. Feel free to modify the generated Docker or make files as appropriate.

This program is intended to be run inside the directory that has the source code for the Streamlit 
app. The directory should have the Python files, but also a requirements.txt file for the 
prerequisites.

The inputs are
  -d <output dockerfile>  : The name of the Docker file to create
  -m <output makefile>    : The name of the make file to create
  -n <dockername>         : The name of the Docker image to create
  -s <secrets file .json> : (Optional) A json file of secrets to be included into the Docker image. 
                              If specified, this file will be accessible in the Docker image 
                              at /tmp/secrets.json.
  -p <port>               : Port to use for the app (default is 80)
  -u <baseUrlPath>        : Base URL path to add to URL
  -k <platform>           : Platform to build image for (default is to build for local architecture)
                              (if set, Makefile will contain an additional target (docker_native) 
                               to build the image for the local architecture)
  <streamlit app .py>     : The filename of the Streamlit app Python file 
                              (e.g. the argument you would provide to 'streamlit run')
```

## Example
Change directory into the `example` directory. From there, run:

```
../stdockerize.sh -d dfile -m mfile -n st_example -s ../secrets.json example.py
```

The output you see should be:
```
Adding secrets file
Docker file (dfile) created. Makefile (mfile) created. Feel free to edit or customize as needed.
To make the Docker image run: make -f mfile docker
Then you can run the image with: make -f mfile run
```

Then you can build the Docker image with:

```
make -f mfile docker
```

And then run the Docker image with 

```
make -f mfile run
```

And visit your Streamlit app at `http://localhost`.
