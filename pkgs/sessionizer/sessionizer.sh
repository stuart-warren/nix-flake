PROJECTS_BASE="${HOME}/src"

function search_database {
    cat <(fd '.git$' "${PROJECTS_BASE}" --prune -u --type d -x echo "{//}") <(echo "${HOME}")
}

function find_projects {
    QUERY=""
    [ $# -gt 0 ] && QUERY="${*}"
    search_database | fzf -1 --query="${QUERY}"
}

function tmux_sessionizer {
    selected=$(find_projects "$@")
    if [[ -z "${selected}" ]]; then
        exit 0
    fi
    selected_name="$(basename "${selected}" | tr . _)"
    if ! tmux has-session -t "${selected_name}" 2>/dev/null; then
        tmux new-session -ds "${selected_name}" -c "${selected}"
    fi
    tmux switch-client -t "${selected_name}"
}

# function zellij_sessionizer {
#     while true; do
#         selected=$(find_projects "$@")
#         if [[ -z "${selected}" ]]; then
#             continue
#         fi
#         selected_name="$(basename "${selected}" | tr . _)"
#         cd "${selected}" || break
#         zellij attach --create "${selected_name}"
#         echo "detach/quit session ${selected_name}"
#     done
# }

[[ -n "$TMUX_PANE" ]] && tmux_sessionizer "$@" && exit 0
# [[ -n "$ZELLIJ_SESSION_NAME" ]] && echo "detach from session first" && exit 1
# [[ -z "$TMUX_PANE" ]] && zellij_sessionizer "$@" && exit 0
