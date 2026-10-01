# shellcheck shell=sh disable=SC3043
# (SC3043: `local` is not POSIX, but bash and zsh, the two shells this file
# is written for, both have it.)
#
# wtx: shell wrapper for wtx.
# A child process cannot change the directory of its parent shell,
# so this function runs wtx and then does the cd itself.
# Load with: eval "$(wtx init zsh)"  (or bash)

wtx() {
	local target rc
	case "${1-}" in
	"")
		command wtx help
		;;
	new)
		target="$(command wtx "$@")"
		rc=$?
		[ "$rc" -eq 0 ] || return "$rc"
		if [ -n "$target" ] && [ -d "$target" ]; then
			cd "$target" || return
		fi
		;;
	cd)
		shift
		target="$(command wtx path "$@")"
		rc=$?
		[ "$rc" -eq 0 ] || return "$rc"
		if [ -n "$target" ] && [ -d "$target" ]; then
			cd "$target" || return
		fi
		;;
	*)
		command wtx "$@"
		;;
	esac
}
