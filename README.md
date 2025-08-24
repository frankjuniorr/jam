Jam 🎸
===========

<p align="left">
  <a href="http://creativecommons.org/licenses/by-nc-sa/4.0/">
    <img src="https://img.shields.io/badge/-CC_BY--SA_4.0-000000.svg?style=for-the-badge&logo=creative-commons&logoColor=white"/>
  </a>
</p>

## Description
**jam** stands for *Just Another Menu*.  
It’s a collection of mini-applications built on top of interactive `fzf` menus.  

Basically, it’s a way to use and navigate through the "aliases" I already had — but now in an interactive, context-based, and TUI-driven way. Most of these mini-apps are just *wrappers*, or abstracted ways of how I personally like to run certain commands in my daily workflow.

 ## Use
Since this repository was originally derived from my "aliases", it’s quite personal in nature. At first it lived inside my Dotfiles repo, but eventually grew large enough to deserve its own place.  

To use it, simply call the main entry script located in the project’s root:  

```bash
./jam.sh
```

This script also accepts a parameter: the .yaml file corresponding to each menu.
For example:

```bash
./jam.sh menus/system/system.yaml
```

This will open the system menu directly — and you can do the same with any other menu.

## Install
Because it’s just Shell Script, there’s no installation required.
However, it does depend on several external tools.

I haven’t built an automated dependency installer yet (since Linux environments can vary a lot), but the code is full of validations: it will only run if all required dependencies are available.

----

  ### License:

<p align="center">
  <a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/">
    <img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png" />
  </a>
</p>
