# fi_ss
Miscellaneous spike sorting datasets to be used with MountainLab

You should place the raw data in the fi_ss/raw directory.
The file names and directory nestings don't matter as the system will identify the correct files by their SHA-1 sums.

You must add fi_ss/raw to your prv search path. To set this up, use

```
mlconfig
```

The datasets are found in fi_ss/datasets. However the actual data files are not found there. Instead, the raw.mda.prv text files are SHA-1 pointers to the files in fi_ss/raw 

You can determine if a particular raw.mda.prv file is found by using

```
cd datasets/name/of/directory
prv-locate raw.mda.prv
```

If the raw data is found, it will display the full path to that dataset. Otherwise you will need to either copy the data to the raw folder or configure mountainlab using mlconfig as described above.

The fi_nufft/analyses folder contain a variety of analysis projects. Read the instructions.txt in each folder.

