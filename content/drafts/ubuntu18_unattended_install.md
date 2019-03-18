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