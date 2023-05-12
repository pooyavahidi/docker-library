ARG BASE_IMAGE
# Pass anaconda as the Base image.
FROM ${BASE_IMAGE}


# Installing additional conda packages for DataScience related activities.
RUN conda install -y -c conda-forge ipympl \
    && conda clean -afy
