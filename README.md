# dotfiles

## requirements

- rcrc: https://github.com/thoughtbot/rcm
- file for `zinit`
- tree for `zinit ls`

## setup

```bash
$ apt install git neovim zsh rcm file tree
$ git clone https://github.com/watiko/dotfiles.git
$ env RCRC=$HOME/dotfiles/rcrc rcup
$ env NO_EDIT=1 sh -c "$(curl -fsSL https://git.io/zinit-install)"
```
