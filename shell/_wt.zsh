# zsh completion for wtx.
# Load after compinit: eval "$(wtx init zsh)"

_wt() {
	local -a subcmds names
	subcmds=(
		'new:create a worktree'
		'list:list worktrees'
		'cd:change to a worktree'
		'path:print a worktree path'
		'push:push worktree changes'
		'pull:pull worktree changes'
		'rm:remove a worktree'
		'move:move a worktree'
		'init:print shell integration'
		'help:show help'
	)

	if (( CURRENT == 2 )); then
		_describe -t commands 'wtx command' subcmds
		return
	fi

	case "${words[2]}" in
	cd | path | rm | move | mv)
		(( CURRENT == 3 )) || return 0
		names=("${(@f)$(command wtx path --names 2>/dev/null)}")
		names=("${(@)names:#}")
		compadd -a names
		;;
	init)
		(( CURRENT == 3 )) || return 0
		compadd zsh bash
		;;
	new)
		compadd -- -n --dry-run --no-seed --no-install
		;;
	move | mv)
		(( CURRENT > 3 )) && compadd -- -n --dry-run --no-install
		;;
	esac
	return 0
}

if (( $+functions[compdef] )); then
	compdef _wt wtx
fi
