# Preseeding Ubuntu 18.04

## Introduction


## Partitioning

## Snippet

```
### Partitioning
d-i partman-auto/method string lvm
d-i partman-lvm/device_remove_lvm boolean true
d-i partman-lvm/confirm boolean true
d-i partman-lvm/confirm_nooverwrite boolean true
d-i partman-auto-lvm/guided_size string max
d-i partman-basicfilesystems/no_swap boolean false
d-i partman-auto-lvm/new_vg_name string system

d-i partman-auto/expert_recipe string       \
  multi-cnx ::                              \
    4000 8000 8000  $default_filesystem     \
    $defaultignore{ }                       \
    $lvmok{ }                               \
    method{ format }                        \
    format{ }                               \
    use_filesystem{ }                       \
    $default_filesystem{ }                  \
    mountpoint{ / }                         \
    .                                       \
    1000 4000 4000 $default_filesystem      \
    $lvmok{ }                               \
    method{ format }                        \
    format{ }                               \
    use_filesystem{ }                       \
    $default_filesystem{ }                  \
    mountpoint{ /home }                     \
    .                                       \
    1000 2000 2000 $default_filesystem      \
    $lvmok{ }                               \
    method{ format }                        \
    format{ }                               \
    use_filesystem{ }                       \
    $default_filesystem{ }                  \
    mountpoint{ /tmp }                      \
    .                                       \
    2000 4000 4000 $default_filesystem      \
    $lvmok{ }                               \
    method{ format }                        \
    format{ }                               \
    use_filesystem{ }                       \
    $default_filesystem{ }                  \
    mountpoint{ /var }                      \
    .                                       \
    250 250 250 $default_filesystem         \
    $lvmok{ }                               \
    method{ format }                        \
    format{ }                               \
    use_filesystem{ }                       \
    $default_filesystem{ }                  \
    mountpoint{ /var/log/audit }            \
    .                                              


# override default filesystem format (ext3)
d-i partman/default_filesystem string ext4

# This makes partman automatically partition without confirmation, provided
# that you told it what to do using one of the methods above.
d-i partman/confirm_write_new_label boolean true
d-i partman/choose_partition select finish
d-i partman/confirm boolean true
d-i partman/confirm_nooverwrite boolean true
```

## Conclusion

























preseeding

so this is a mess. Very little documentation. Got it semi sorted though using bento, which is a collection of base images

so far will need a:
- builder
- profisioner
- post processor

Will use bento as a template and reverse engineer the shit out of things

apparently there's two different server images? the `live` version uses a different installer interface: Subiquity
This could have potentially been causing me grief. Will need to test and confirm though



of note:
```
<priority> is some size usually between <minimal size> and <maximal
size>.  It determines the priority of this partition in the contest
with the other partitions for size.  Notice that if <priority> is too
small (relative to the priority of the other partitions) then this
partition will have size close to <minimal size>.  That's why it is
recommended to give small partitions a <priority> larger than their
<maximal size>.
```










https://serverfault.com/questions/449395/unix-server-partitioning-filesystem-layout

https://secopsmonkey.com/custom-partioning-using-preseed.html












redhat knowledgebase. Seems decent
https://access.redhat.com/search/#/

https://www.cisecurity.org/cis-benchmarks/