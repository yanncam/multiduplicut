# :bulb: multiduplicut : optimize wordlists-based password cracking methods chaining

**MultiDuplicut** is a bash wrapper that use the fantastic [Duplicut](https://github.com/nil0x42/duplicut) project, but works with **multi-huge-wordlists files** without re-ordering their content, and quickly !

_From [Duplicut](https://github.com/nil0x42/duplicut) project:_
> Modern password wordlist creation usually implies concatenating multiple data sources.
> Ideally, most probable passwords should stand at start of the wordlist, so most common passwords are cracked instantly.
> With existing dedupe tools you are forced to choose if you prefer to preserve the order OR handle massive wordlists.
> Unfortunately, wordlist creation requires both

When you work with password's cracking attacks, it's very powerfull to :
- Use optimized wordlists of common passwords, common leaks (like the traditionnal `darkc0de.txt` or `rockyou.txt` wordlists);
- Use others wordlists from huge leaks (HaveIBeenPwned, uniqpass, etc.);
- Use contextualized wordlists for hashs set (computed via [cewl](https://www.kali.org/tools/cewl/), dedicated wordlist from [Dehashed](https://www.dehashed.com/), [pwndb](https://github.com/davidtavarez/pwndb), etc.).
- Through tools like `hashcat`, each wordlist can be derived to generate new candidate via rules (like traditionnal `best64.rule` of [hashcat](https://hashcat.net/), or [OneRuleToRuleThemAll](https://github.com/NotSoSecure/password_cracking_rules), etc.).

An optimized wordlist is a simple text file, with one word on each line without alphabetical ordering. Indeed, to optimize the cracking of passwords, a wordlist must place the most probable words upstream of the dictionary, so they are ordered statistically and not alphabetically.

But when you chain many password cracking wordlists-based attacks, several wordlists can share the same word-candidate, like `p@ssw0rd`. From an efficient point of view, it's not optimized :

- Each wordlist (whatever its size, which can be very huge) needs to be deduplicated itself, and the [Duplicut](https://github.com/nil0x42/duplicut) project if perfect for that (dedup one, and only one wordlist itself) ;
- Each word-candidate needs to appear only one time in a unique wordlist, so we have to deduplicate words cross-wordlists (we reach the limits of the Duplicut project...).
- It's possible to concatenate all your wordlist into only-one-very-huge-file (several thousands of GB), but I recommand to keep wordlists seperated for statistics, tracking, efficience, etc.

So the **multiduplicut** wrapper was born!

## :mag: How it works?

- **multiduplicut** identifies wordlists in the current directory and sort each file (not their content) from the smallest size to the biggest (the smallest wordlist is also the fastest and most relevant for common words).
- **multiduplicut** concatenates all content of all worlists ordered-by-size in one unique temp file (needs disk space!) and add some random strings as marker to seperate in this unique file each wordlist content. Content/words order ISN'T changed!
- **multiduplicut** calls the [Duplicut](https://github.com/nil0x42/duplicut) binary, to deduplicate this huge-temp-unique-wordlist.
- Then, **multiduplicut** splits this huge-temp-unique-wordlist from each marker (random string) to re-create initial wordlist's file (with the `*.multiduplicut` suffix).
- Finally, **multiduplicut** displays some statistics about optimization done.

## :hammer: Installation

```
# First, deploy duplicut tool:
git clone https://github.com/nil0x42/duplicut
cd duplicut
make
make install # require root privileges to add this binary to $PATH
cd ..
# Then deploy multiduplicut:
git clone https://github.com/yanncam/multiduplicut/
```

## :fire: Demonstration / Example / How to use?

_The following **multiduplicut** output was done on a simple Kali laptop, with 8GB of RAM and Intel(R) Core(TM) i7-4500U CPU @ 1.80GHz._

5 wordlists to process :

| Wordlist                            | InitSize (bytes)  | InitSize (human readable)   | Init#Words  | Order by size |
| -------------                       |-------------      | -----                       | ------      | ------        |
| darkc0de.txt                        | 15073803          | 15M                         | 1471063     | 1             |
| rockyou.txt                         | 139921524         | 134M                        | 14344395    | 3             |
| facebook-firstnames.txt             | 38352882          | 37M                         | 4347667     | 2             |
| uniqpassv14.txt                     | 2638722220        | 2,5G                        | 241584732   | 4             |
| 515_have-i-been-pwned-v2_found.txt  | 5396405697        | 5,1G                        | 496692948   | 5             |

**Place all wordlists with the `*.txt` extension in the same directory, with the `multiDuplicutOrder.sh` script ([Duplicut](https://github.com/nil0x42/duplicut) already installed and available through $PATH environment variable) :**

```
root@x:~/work$ ls -la
total 8035660
drwxr-xr-x 2 root root       4096 24 févr. 13:03 .
drwxr-xr-x 5 root root       4096 24 févr. 12:06 ..
-rwxr-xr-x 1 root root 5396405697 24 févr. 11:43 515_have-i-been-pwned-v2_found.txt
-rwxr-xr-x 1 root root   15073803 24 févr. 11:43 darkc0de.txt
-rwxr-xr-x 1 root root   38352882 24 févr. 11:43 facebook-firstnames.txt
-rwxr-xr-x 1 root root       4229 24 févr. 13:03 multiDuplicutOrder.sh
-rwxr-xr-x 1 root root  139921524 24 févr. 11:43 rockyou.txt
-rwxr-xr-x 1 root root 2638722220 24 févr. 11:44 uniqpassv14.txt
```

Then, simply launch the `./multiDuplicutOrder.sh` script :

```
root@x:~/work$ ./multiDuplicutOrder.sh
[*] 5 wordlists identified !
[*] Each wordlist will be cleaned in the following order (only first word appearence in the first wordlist will be kept).
        [+] [darkc0de.txt] (15073803 B | 1471063 words)
        [+] [facebook-firstnames.txt] (38352882 B | 4347667 words)
        [+] [rockyou.txt] (139921524 B | 14344395 words)
        [+] [uniqpassv14.txt] (2638722220 B | 241584732 words)
        [+] [515_have-i-been-pwned-v2_found.txt] (5396405697 B | 496692948 words)
[*] 4 temp-files will be created.
[*] Full-concatenation of wordlists with separators started into FULL.CSyXKgg.tmp.
[*] Run full-duplicut over full-concatened-wordlist FULL.CSyXKgg.tmp.
[*] Regenerate initial wordlists multiduplicuted.
        [*] Value [TKb4WIimns50BxEyW8WuQljmR6nPwJsVVKi5XtELSJgkIRrehSLlwCXhxEYTKGaPMQLJnrYrdgDzmYy8bunSrUR9nTZRumbCdpTH] found at line 1471061 !
        [*] Value [Wvd4jMqfrvdHxTSepMxheNl0d5Pfw7TrqwbKmus6hT80dc9d04Cbk5UQVl3zHt0ShT9eRhEYKducxnxZWXKfEvYb8vaRBTRdWuzd] found at line 5656119 !
        [*] Value [BKFpmVIJqbxWYTz3nEPfJmA0VAk8DP4rB9MB6wYYPdUxQfKWe6jSKJVgqOezMjY8au5hEnAzN1rrngNOMQXjxroHZ9xyslohZXIL] found at line 19230958 !
        [*] Value [uYIlON52A6sEmoNJ19ksi5leYMNyo2BKOSQR2FT0sK0Z8UNBXVdjz1kZfuMZXqDvN3Q2VBL2xZ7lY4rC9kWE1mMNhJRMMaCYYCd6] found at line 245248807 !
[*] Rename final wordlists multiduplicuted.
        [+] [darkc0de.txt] (15073803 B | 1471063 words) => [darkc0de.txt.multiduplict] (15073771 B | 1471060 words) 3 words deleted, 32 bytes reducted, optimization : 1%
        [+] [facebook-firstnames.txt] (38352882 B | 4347667 words) => [facebook-firstnames.txt.multiduplict] (37152637 B | 4185057 words) 162610 words deleted, 1200245 bytes reducted, optimization : 4%
        [+] [rockyou.txt] (139921524 B | 14344395 words) => [rockyou.txt.multiduplict] (133740731 B | 13574838 words) 769557 words deleted, 6180793 bytes reducted, optimization : 5%
        [+] [uniqpassv14.txt] (2638722220 B | 241584732 words) => [uniqpassv14.txt.multiduplict] (2488302004 B | 226017848 words) 15566884 words deleted, 150420216 bytes reducted, optimization : 6%
        [+] [515_have-i-been-pwned-v2_found.txt] (5396405697 B | 496692948 words) => [515_have-i-been-pwned-v2_found.txt.multiduplict] (4825785541 B | 436865572 words) 59827376 words deleted, 570620156 bytes reducted, optimization : 11%
[*] Global : Wordlists size 8228476126 (7847MB) reduce to 7500054684 (-728421442 (-694MB)) (Optimization 9%)
[*] Global : Wordlists line 758440805 reduce to 682114375 (-76326430) (Optimization 11%)
[*] All done in 2653 seconds (0 hour 44 min 13 sec) !
```

The work on these 5 wordlists, for a total of 7847MB (7,8GB) take only 44 min and 13 sec! Not hours nor days. And the statistical order of each word-candidate is kept!

| Wordlist                            | InitSize (bytes)  | InitSize (human readable)   | Init#Words  | Order by size | NewSize (bytes)    | New#Words  | %Optim  |
| -------------                       |-------------      | -----                       | ------      | ------        | ------      | ------      | ------  |
| darkc0de.txt                        | 15073803          | 15M                         | 1471063     | 1             | 15073771    | 1471060     | 1%      |
| rockyou.txt                         | 139921524         | 134M                        | 14344395    | 3             | 133740731   | 13574838    | 5%      |
| facebook-firstnames.txt             | 38352882          | 37M                         | 4347667     | 2             | 37152637    | 4185057     | 4%      |
| uniqpassv14.txt                     | 2638722220        | 2,5G                        | 241584732   | 4             | 2488302004  | 226017848   | 6%      |
| 515_have-i-been-pwned-v2_found.txt  | 5396405697        | 5,1G                        | 496692948   | 5             | 4825785541  | 436865572   | 11%     |

**Global:**
- **5 wordlists for a total of 8228476126 B (7847MB, 7,8GB) reduce to 7500054684 B => -694MB => Optimization 9%**.
- **758440805 words initially reduce to 682114375 (-76326430) => Optimization 11%**
- **Full process on 44 min 13 sec on a standard laptop!**

## :toolbox: To go deeper...

Deduplicate files between them is a common issue. There is several technics already identified (see this [StackOverflow](https://stackoverflow.com/questions/4366533/how-to-remove-the-lines-which-appear-on-file-b-from-another-file-a) topic as example).

But, depending of the context, the deduplicate process can be very long (several hours / days), generate OOM errors, force to sort the content of the files before, etc.

There are multiple tools, POSIX command and binaries that _appear_ doing the job, command like `diff`, `awk`, `grep`, `sed`, `sort`, `comm`, `python`...
But in most cases, these technics produce an Out-of-memory error on very huge files, or require the files to be sorted. My initial tests based on these kind of tools/commands worked, but over several hours or even days...

It's why the [Duplicut](https://github.com/nil0x42/duplicut) exists, in highly optimized C to address this very specific need !
But the Duplicut tool work on one, and only one file at a time.
**multiduplicut** is a simple bash-wrapper to use the Duplicut tool on several files and do the same job cross-wordlists.

## :beers: Credits

- Thanks to @nil0x42 for very optimized tool [Duplicut](https://github.com/nil0x42/duplicut).
- Thanks to lmalle, my duck debugger for this wrapper.
- GreetZ to all the Le££e team :)

