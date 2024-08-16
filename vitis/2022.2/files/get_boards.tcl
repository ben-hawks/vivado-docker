# Installs either all boards, or a specific board as specified in the $SPECIFIC_BOARD shell environment variable (empty string for all boards)
set specific_board $::env(SPECIFIC_BOARD)

vi

if {$specific_board eq ""} {
    xhub::install [xhub::get_xitems]
} else {
	xhub::install [xhub::get_xitems $specific_board]
}

