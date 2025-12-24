. "$HOME/.cargo/env"
# only load alias if sail is installed
if [ -f sail ] && [ -f vendor/bin/pint ]; then
  alias sail='bash sail'
  alias pint='./vendor/bin/pint'
else 
fi
