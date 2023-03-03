RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
LBLUE='\033[1;34m'
NC='\033[0m'

echo -e "\n${LBLUE}[INFO]${NC} STARTING SETUP\n"

echo -e "\n${LBLUE}[INFO]${NC} BUILDING GEM\n"

gem build gofile_ruby.gemspec

echo -e "\n${GREEN}[OK]${NC} BUILD COMPLETE\n"

# Only find first match (gem file with highest version number)
gemfile_dir=$(find . -maxdepth 1 -name "*gofile_ruby-*" | sort -n -r | head -n 1)

if [[ -n $gemfile_dir ]];
then
    echo -e "\n${LBLUE}[INFO]${NC} INSTALLING GEM\n"
    gem install $gemfile_dir
else
    echo -e "\n${RED}[ERROR]${NC} GEMFILE NOT FOUND! PLEASE ENSURE THE GOFILE_RUBY .gem FILE EXISTS IN ROOT DIRECTORY!\n"
fi

echo -e "\n${GREEN}[OK]${NC} SUCCESSFULLY INSTALLED GEM\n"