# 💾 lifecap

Cache and summarize your life.

## 🧱 Structure

* There's some shell scripts in ./src
* There's some tests in ./test
* There's some data collectors in ./collectors

None of it is finished

## 📝 Plan

Pull data from various sources:

```sh
# if you didn't install
export PATH="$(pwd)/src:$PATH"

lifecap service start -d

# now let's add some sources
lifecap source add email/imap        gaz@bitplane.net
lifecap source add code/repo/github  bitplane
lifecap source add code/repo/local   ~
lifecap source add code/commits      --email="gaz@bitplane.net"
lifecap source add local/files       ~/Documents
lifecap source add os/x11            :0

# let it run for a while...
sleep 600

# see what we've got
lifecap topic messages email/gaz@bitplane.net/inbox --from=2001 --to=2003
```

* Commands are actually things like `lifecap-source-add` so anything can be
  overridden; by default `lifecap-topic-write some/path ...` calls
  `lifecap-topic-write some path ...` which uses the filesystem, but there
  might be a `lifecam-topic-write-email` function/binary/script with a kafka
  back-end.
* Collectors are collecting from one or more topics that they're streaming
  from, and publishing to other topics.
* Collectors remember where they're up to on their sources and stream from
  a last known date, using `lifecap topic messages topic -f ...`

### ❓ Why?

At the highest level, the data is streamed to ML algorithms that extract real
context and summarize your life. It can be pushed into RAG databases and so on,
giving agents enough context to actually work on behalf of the user.

### 💀 This seems excessive

Yes, yes it does. But it'll grant superpowers. By summarizing at the minute,
hour, day, month and year levels, and combining multiple summary sources we
have a tree of the user's life activity that can actually be queried
efficiently.

## 💩 Ethical considerations

Any data collection project of this magnitude must balance user needs against
clear and present dangers associated with holding and processing such higly
sensitive personal data.

After careful review of the licensing landscape, it was decided that current
popular software licenses do not meet reasonable inclusivity or diversity
requirements, and are lacking in appropriate and understandable restrictions
both technically and legally, and represent a systemic bias in technology
that discriminates against the most vulnerable and marginalized groups.

For this reason, we have adopted a custom license with robust and appropriate
terms that MUST be accepted before using this software. Please see the license
section for these terms in full. We hope you find the length, depth, and girth
of this choice to your tastes.

## ⚖️ License

WTFPL with one additional clause:

1. DON'T BLAME ME

Do whatever the fuck you want to, as long as you don't blame me.

## 🔗 Links

* [🏠 home](https://bitplane.net/dev/sh/lifecap)
* [🐱 github](https://github.com/bitplane/lifecap)

