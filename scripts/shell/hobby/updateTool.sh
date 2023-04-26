# Prior to running this script the following defintion was defined:
# upstream/ - the main repo.
git fetch upstream -q
check=$(git rev-list HEAD..upstream/main) # https://adamj.eu/tech/2020/01/18/a-git-check-for-missing-commits-from-a-remote/
if [[ $check ]];then echo "Updated: Yes"; else echo "Updated: No"; fi
if [[ ($1 || $check) && $(git rev-parse --abbrev-ref HEAD) = "main" ]];then
	git reset --hard upstream/main -q
elif [[ ($1 || $check) && $(git rev-parse --abbrev-ref HEAD) != "main" ]]; then
	git merge upstream/main -q
fi
