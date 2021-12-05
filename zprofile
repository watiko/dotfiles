if [[ "$OSTYPE" == darwin* ]]; then
  export BROWSER='open'
fi

if (( $+commands[nvim] )); then
  export EDITOR='nvim'
  export VISUAL='nvim'
else
  export EDITOR='vim'
  export VISUAL='vim'
fi
export PAGER='less'

if [[ -z "$LANG" ]]; then
  export LANG='en_US.UTF-8'
fi

# Ensure path arrays do not contain duplicates.
typeset -gU cdpath fpath mailpath path

## setup tools
{
  export FLUTTER_HOME="$HOME/soft/flutter"
  export GCLOUD_HOME="$HOME/soft/google-cloud-sdk"

  export PATH="$HOME/bin:$PATH"

  export PATH="$FLUTTER_HOME/bin:$PATH"
  export PATH="$GCLOUD_HOME/bin:$PATH"
  export PATH="$HOME/.gobrew/current/bin:$HOME/.gobrew/bin:$PATH"
  export PATH="$HOME/.deno/bin:$PATH"
  export PATH="$HOME/.poetry/bin:$PATH"
  export PATH="$HOME/.cargo/bin:$PATH"
}
