die() {
	error=${1:-Undefined Error}
	echo "$0: $LINE $error"
}
die "File not found"
die
