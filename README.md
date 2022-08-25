# A tool to Dockerize a Streamlit app




## Example
Change directory into the `example` directory. From there, run:

```
../stdockerize.sh -d dfile -m mfile -n st_example -s ../secrets.json example.py
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
