# claude container

Don't let claude run commands on your computer, run claude in a container!

## Overview

The idea here is by running claude code in a container, you get to pick what files claude can see and edit.  
It obviously cannot execute anything it wants on your host computer; it can just run commands inside the container.

## Legal

### Disclaimer

This project is not affiliated with, endorsed by, or sponsored by Anthropic. Claude and Claude Code are trademarks 
and products of Anthropic. This repository provides unofficial containerization scripts for Claude Code and is an 
independent community project.  Official documentation for Claude Code can be found at https://docs.claude.com/en/docs/claude-code

### Requirements

Users must:
- Have a valid Claude Code license/subscription from Anthropic
- Comply with Anthropic's Terms of Service and Acceptable Use Policy
- Obtain Claude Code through official Anthropic channels

### Liability Disclaimer

This project is provided "as-is" without any warranties. Users are responsible for ensuring their use complies with all applicable terms of service and laws.

## Usage

You can expose one directory to claude code using this repo. 

```
./claude.sh <directory_to_expose_to_claude_container>
```

For example, if you want to work on the nginx project, and have the source stored in `~/src/nginx`,
you would run:

```
./claude.sh ~/src/nginx
```

```
ryan@MacBookPro:~/src/claudecode$ ./claude.sh ~/src/nginx
[+] Running 1/1
 ✔ Container claudecode  Started                                                                                                   10.2s
node@f2267f64de35:/src/nginx$
```

Since the directory is shared into the container with read-write permissions, any changes
made by claude inside the container will be saved to your host machine.

## Faster access

A trick for faster invocation is to symlink `claude.sh` into your `~/bin` directory:

```
(mkdir -p ~/bin && cd ~/bin && ln -sf ~/src/claudecontainer/claude.sh .)
```

Make sure `~/bin` is path of your `$PATH`.  If not, add this to your `~/.bash_profile` or `~/.bashrc`:

```
export PATH="~/bin:$PATH"
```

Not you can run `claude.sh` from any directory:

```
claude.sh ~/src/nginx
```

## Where does this repo get claude code from?

The `claude.sh` script will download claude code's Dockerfile from:
https://github.com/anthropics/claude-code/blob/main/.devcontainer/Dockerfile

It also downloads the firewall initialization script that Anthropic has published from:
https://raw.githubusercontent.com/anthropics/claude-code/refs/heads/main/.devcontainer/init-firewall.sh

Both of these files are stored in `./claudecode/`.  Each time `./claude.sh` is run, it will check
to see if those files exist, and if not, will download them from the above URLs.

### Getting latest 

If you want to get the latest `Dockerfile` and `init-firewall.sh`, run:

```
rm ./claudecode/Dockerfile ./claudecode/init-firewall.sh
```

then re-run your `./claude.sh <directory_to_share>` command.

