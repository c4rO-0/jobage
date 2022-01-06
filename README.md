# jobage 

a job-management tool for cluster scheduling systems.
remember only one set of commands for all the systems.


author : C4r-bs

---

## progress 

|       | bash | zsh  |
| ----- | ---- | ---- |
| lsf   | o    | o    |
| slurm | o    | o    |


## install

```bash
source main.sh
```
or

add `source main.sh` to `~/.bashrc`

## usage

1. all commands start with jbg.XXX
2. run jbg.help to get a summary help information
3. run jbg.XXX -h get a help information for the command XXX.

## custom 

1. on setting: copy setting file to jobage working directory:

``` bash
mkdir -p "$_jobage_wPath";
cp "$_jobage_default_setting" "$_jobage_setting";
source main.sh
```

2. edit setting file:
  
``` shell
vi "$_jobage_setting";
```

3. off setting (if wanted):
  
``` shell
rm "$_jobage_setting";
```



