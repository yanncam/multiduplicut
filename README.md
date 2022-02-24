# multiduplicut

**MultiDuplicut** is a bash wrapper that use the fantastic [Duplicut](https://github.com/nil0x42/duplicut) project, but works with **multi-huge-wordlists files** without re-ordering their content !

_From [Duplicut](https://github.com/nil0x42/duplicut) project:_
> Modern password wordlist creation usually implies concatenating multiple data sources.
> Ideally, most probable passwords should stand at start of the wordlist, so most common passwords are cracked instantly.
> With existing dedupe tools you are forced to choose if you prefer to preserve the order OR handle massive wordlists.
> Unfortunately, wordlist creation requires both

When you work with password's cracking attacks, it's very powerfull to :
- Use optimized wordlists of common passwords, common leaks (like the traditionnal `darkc0de.txt` or `rockyou.txt` wordlists);
- Use others wordlists from huge leaks (HaveIBeenPwned, uniqpass, etc.);
- Use contextualized wordlists for hashs set (computed via `cewl`, dedicated wordlist from Dehashed, pwndb, etc.).
- Through tools like `hashcat`, each wordlist can be derived to generate new candidate via rules (like traditionnal `best64.rule` of hashcat, or `OneRuleToRuleThemAll.rule`, etc.).

An optimized wordlist is a simple text file, with one word on each line without alphabetical ordering. Indeed, to optimize the cracking of passwords, a wordlist must place the most probable words upstream of the dictionary, so they are ordered statistically and not alphabetically.

But when you chain many password cracking wordlists-based attacks, several wordlists can share the same word-candidate, like `p@ssw0rd`. From an efficient point of view, it's not optimized :

- Each wordlist (whatever its size, which can be very huge) needs to be deduplicated itself, and the [Duplicut](https://github.com/nil0x42/duplicut) project if perfect for that (dedup one, and only one wordlist itself) ;
- Each word-candidate needs to appear only one time in a unique wordlist, so we have to deduplicate words cross-wordlists (we reach the limits of the Duplicut project...).

So the **multiduplicut** wrapper was born !

## How it works ?

- **multiduplicut** identify wordlists in the current directory and sort each file (not their content) from the smallest size to the biggest (the smallest wordlist is also the fastest and most relevant for common words).
- **multiduplicut** concatenate all content of all worlists ordered-by-size in one unique temp file (needs disk space !) and add some random strings as marker to seperate in this unique file each wordlist content. Content/words order ISN'T changed !
- **multiduplicut** call the [Duplicut](https://github.com/nil0x42/duplicut) binary, to deduplicate this huge-temp-unique-wordlist.
- Then, **multiduplicut** splits this huge-temp-unique-wordlist from each marker (random string) to re-create initial wordlist's file (with the `*.multiduplicut` suffix).
- Finally, **multiduplicut** displays some statistics about optimization done.

## Installation

```
# First, deploy duplicut tool
git clone https://github.com/nil0x42/duplicut
cd duplicut
make
make install # require root privileges to add this binary to $PATH
cd ..
git clone https://github.com/yanncam/multiduplicut/
```

## Demonstration / Example / How to use ?

```

```
