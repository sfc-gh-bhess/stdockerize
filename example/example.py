import streamlit as st
import json

st.markdown("## Just an Example")

st.markdown("---")
with st.expander("Here are your secrets"):
    with open("/tmp/secrets.json", "r") as inf:
        secrets = json.load(inf)
    st.json(secrets)
