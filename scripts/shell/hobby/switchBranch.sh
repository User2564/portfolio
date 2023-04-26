# Prior to running this script the following defintions were defined:
# origin/ - the user's repo which was forked from upstream/.
# upstream/ - the main repo.
# git push --set-upstream origin origin/main / git checkout -b main --track origin/main
previousBranch="Not found"
if [[ $(git rev-parse --quiet --abbrev-ref @{-1} 2>/dev/null) && $? -eq 0 ]]; then
	previousBranch=$(git rev-parse --abbrev-ref @{-1})
fi

read -p "Push commits/branch? Y/N: " commit
read -p "Sync Master? Y/N: " sync
read -p "Switch to supplied branch ($1) / previous ($previousBranch)? Y/N: " switch

if [[ $commit == "Y" ]]; then
	git push -q 2>/dev/null || git push -qu origin $(git rev-parse --abbrev-ref HEAD) 1>/dev/null
fi
if [[ $sync == "Y" ]]; then
	git stash save * && git checkout -q main && git reset --hard upstream/main -q && git push -q && git checkout -q @{-1} && git stash pop
fi
if [[ $switch == "Y" ]]; then 
	if [[ -n $1 ]];then git checkout -q $1; else git checkout -q @{-1}; fi
fi 
read -p "Delete previous branch ($(git rev-parse --abbrev-ref @{-1}))? Y/N: " del
if [[ $del == "Y" ]]; then git branch -qD @{-1}; fi
