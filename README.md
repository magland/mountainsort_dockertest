# mountainsort_dockertest
Basic docker test of mountainsort -- includes downloading and running a synthetic dataset

## Instructions

Be sure to have docker installed. Then do the following:

```
docker build -t mstest1 .
docker run -t mstest1
```

The first line builds the docker image, including compilation of mountainlab.

The second line runs a test by downloading a dataset and running spike sorting on it.