## profiling
{
  #USE_ZPROF=1
  #SHOW_PROF_TIME=1

  if [[ ! -z "$USE_ZPROF" ]]; then
    zmodload zsh/zprof
  fi

  if [[ ! -z "$SHOW_PROF_TIME" ]]; then
    zmodload zsh/datetime
    function get_time_ms() {
      strftime '%s%.'
    }
    function show_time() {
      local start=$1
      local end=$2
      echo $((end - start))
    }
    start_time=$(get_time_ms)
  fi
}

## functions
function hub-pr-checkout() {
  local prs=$(gh pr list 2>/dev/null)
  if [ -z "$prs" ]; then
    echo "pr not found." 1>&2
    return
  fi
  local number=$(echo "$prs" | fzf --exit-0 +m --query "$LBUFFER" | sed 's/^[^0-9]*\([0-9]*\).*$/\1/1')
  if [ -z "$number" ]; then
    return
  fi
  gh pr checkout "$number"
}

function zinit-installed() {
  local cmd="$1"
  which "$cmd" | grep "$ZPFX" >/dev/null
}

## zinit
{
  [[ -f ~/.local/share/zinit/zinit.git/zinit.zsh ]] && source ~/.local/share/zinit/zinit.git/zinit.zsh
  autoload -Uz _zinit
  (( ${+_comps} )) && _comps[zinit]=_zinit

  zinit light-mode for \
    zdharma-continuum/zinit-annex-bin-gem-node
}

## plugin
{
  ## prezto
  zinit is-snippet for \
    PZTM::environment \
    PZTM::helper \
    PZTM::spectrum \
    PZTM::directory \
    PZTM::history \
    PZTM::terminal \
    atload="zstyle ':prezto:module:editor' key-bindings emacs" \
      PZTM::editor
  zinit wait="0a" lucid is-snippet for \
    PZTM::utility \
    PZTM::completion

  ## prompt
  if (( $+commands[starship] )); then
    zinit light-mode for \
      id-as="starship" \
      atclone="starship init zsh > zhook.zsh" \
      atpull="%atclone" \
      src="zhook.zsh" nocompile="!" \
      zdharma-continuum/null
  else
    zinit light-mode for \
      pick="async.zsh" src="pure.zsh" \
      compile="(pure|async).zsh" \
      sindresorhus/pure
  fi

  ## application
  zinit as="command" wait lucid from="gh-r" for \
    sbin="**/bat" @sharkdp/bat \
    sbin="**/fd" @sharkdp/fd \
    sbin="**/ghq" x-motemen/ghq \
    sbin="fzf" junegunn/fzf

  if ! zinit-installed exa && (( $+commands[exa] )); then
    alias ls=exa
  else
    # https://github.com/ogham/exa/issues/414
    zinit as="command" wait lucid from="gh-r" for \
      if='[[ "$(uname -m)" != "aarch64" ]]' \
      id-as="exa" atinit="alias ls=exa" sbin="bin/exa" ogham/exa
  fi

  zinit as="null" lucid from="gh-r" for \
    mv="direnv* -> direnv" sbin="direnv" \
    atclone="./direnv hook zsh > zhook.zsh" \
    atpull="%atclone" \
    src="zhook.zsh" nocompile="!" \
    direnv/direnv

  zinit as="command" wait="0a" lucid from="gh-r" for \
    id-as="gh" sbin="**/gh" \
    atclone="./gh completion -s zsh > _gh" \
    atpull="%atclone" \
    cli/cli

  zinit wait="0a" lucid light-mode for \
    pick="asdf.sh" @asdf-vm/asdf

  zinit as="command" wait lucid light-mode for \
    pick="bin/tfenv" tfutils/tfenv
  
  zinit as="command" wait="0a" lucid light-mode for \
    atclone='PYENV_ROOT="$PWD" ./libexec/pyenv init - > zhook.zsh' \
    atpull="%atclone" atinit='export PYENV_ROOT="$PWD"' \
    pick="bin/pyenv" src="zhook.zsh" nocompile="!" \
    pyenv/pyenv

  export SDKMAN_DIR="$ZPFX/sdkman"
  zinit as="command" wait="0c" lucid light-mode for \
    id-as"sdkman" run-atpull \
    atclone="
      wget 'https://get.sdkman.io/?rcupdate=false' -O scr.sh;
      bash scr.sh" \
    atpull="sdk selfupdate" \
    pick="$SDKMAN_DIR/bin/sdk" \
    src="$SDKMAN_DIR/bin/sdkman-init.sh" \
    zdharma-continuum/null

  export OPAM_INIT="$HOME/.opam/opam-init/init.zsh"
  zinit as="command" wait="0a" lucid light-mode for \
    id-as="opam" if="[[ -f $OPAM_INIT ]]" pick="$OPAM_INIT" \
    zdharma-continuum/null

  ## completion
  # for OMZP
  [[ -d "$ZSH_CACHE_DIR/completions" ]] || mkdir -p "$ZSH_CACHE_DIR/completions"
  zinit add-fpath "$ZSH_CACHE_DIR/completions"

  zinit lucid is-snippet for \
    OMZP::rust

  zinit as="completion" wait="0a" lucid is-snippet for \
    OMZP::docker-compose/_docker-compose \
    OMZP::docker/_docker \
    OMZP::rust/_rustc

  function after_completion_setup() {
    autoload -Uz +X bashcompinit && bashcompinit

    # alias
    compdef g=git

    [[ -f /usr/local/bin/aws_completer ]] && complete -C /usr/local/bin/aws_completer aws
    sources=(
      $SDKMAN_DIR/contrib/completion/bash/sdk
      "$GCLOUD_HOME/completion.zsh.inc"
    )
    for s in $sources; do
      [[ -f "$s" ]] && source "$s"
    done
  }

  zinit wait="0b" lucid light-mode for \
    atload="zicompinit; zicdreplay; after_completion_setup" \
    zsh-users/zsh-syntax-highlighting
}

## config
{
  ### history
  export HISTSIZE=1000000
  export SAVEHIST=1000000
  setopt inc_append_history
  setopt share_history
  setopt hist_ignore_space

  ## alias
  alias nv=nvim
  alias t=tig

  function g() {
    if [[ "$1" = "root" ]]; then
      cd "$(git rev-parse --show-superproject-working-tree --show-toplevel | head -n1)"
    else
      git "$@"
    fi
  }

  ### bindings
  function select-history() {
    BUFFER=$(history -n -r 1 | fzf --no-sort +m --query "$LBUFFER" --prompt="History > ")
    CURSOR=$#BUFFER
  }
  zle -N select-history
  bindkey '^r' select-history

  function select-repo() {
    local selected="$(ghq list -p | fzf)"

    if [ -n "$selected" ]; then
      builtin cd "$selected"
      zle accept-line
    fi

    zle reset-prompt
  }
  zle -N select-repo
  bindkey '^g' select-repo
}

## profiling
{
  if [[ ! -z "$SHOW_PROF_TIME" ]]; then
    end_time=$(get_time_ms)
    show_time $start_time $end_time
  fi

  if [[ ! -z "$USE_ZPROF" ]]; then
    if type zprof >/dev/null 2>&1; then
      zprof | less
    fi
  fi
}
