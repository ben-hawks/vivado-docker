# Installs either all boards, or a specific board as specified in the $SPECIFIC_BOARD shell environment variable (empty string for all boards)
set specific_board $::env(SPECIFIC_BOARD)

xhub::refresh_catalog [xhub::get_xstores xilinx_board_store]

if {$specific_board eq ""} {
    xhub::install [xhub::get_xitems]
} else {
	xhub::install [xhub::get_xitems $specific_board]
}

