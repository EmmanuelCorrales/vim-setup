DOTFILES_HOME=$HOME/.dotfiles
DOTFILES_OLD=$HOME/.dotfiles.old/`date +"%m-%d-%y-%T"`

git clone --bare https://github.com/EmmanuelCorrales/dotfiles.git $DOTFILES_HOME

function dotfiles {
  git --git-dir=$DOTFILES_HOME --work-tree=$HOME $@
}

mkdir -p $DOTFILES_OLD
dotfiles checkout

if [ $? = 0 ]; then
  echo "Checked out dotfiles.";
else
  echo "Backing up pre-existing dot files.";
  dotfiles checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I {} mv $HOME/{} $BACKUP_DIR/{}
fi;

dotfiles checkout
dotfiles config status.showUntrackedFiles no

# Vundle setup
if [ -d ~/.vim ]; then
  echo "Backing up old .vim directory."
  mv ~/.vim $DOTFILES_OLD
fi
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
echo | echo | vim +PluginInstall +qall &>/dev/null